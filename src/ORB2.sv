/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//in_go needs to lag the centre pixel (the corner pixel) by 25 columns
module ORB2(clk, in_valid, in_col, in_go, in_reset, in_x, in_y, out_descriptor, out_valid, out_window_ready, out_accepting_input, out_feature_x, out_feature_y);

parameter LUMA_BITS = 8;
parameter BITS_PER_CLOCK = 1;
parameter COORD_BITS = 10;

localparam WINDOW_SIZE_X = 37;
localparam WINDOW_SIZE_Y = 37;
localparam PATCH_COORD_BITS = 6;
localparam MOMENT_BITS = 24;

`include "../etc/ORBSamples/orbsamples.sv"

localparam ANGLE_BITS = $clog2(NUM_ROTATIONS);

localparam SECTOR_SEL_DELAY = 6; //update below
localparam VEC_ROTATE_DELAY = 2;
localparam MEM_ACCESS_LATENCY = 1;
localparam NUM_SAMPLE_CLOCKS = NUM_COMPARISONS / BITS_PER_CLOCK; //256

localparam T_PATCH_INPUT = 0;
localparam T_SAMPLE_SECTOR = T_PATCH_INPUT + SECTOR_SEL_DELAY; //6
localparam T_VEC_ROTATE_INPUT_START = T_SAMPLE_SECTOR + 1; //7
localparam T_VEC_ROTATE_INPUT_END = T_VEC_ROTATE_INPUT_START + NUM_SAMPLE_CLOCKS; //263
localparam T_IMAGE_SAMPLE_START = T_VEC_ROTATE_INPUT_START + VEC_ROTATE_DELAY + MEM_ACCESS_LATENCY; //10
localparam T_IMAGE_SAMPLE_END = T_IMAGE_SAMPLE_START + NUM_SAMPLE_CLOCKS; //266

input clk;
input in_valid;
input [LUMA_BITS-1:0] in_col [WINDOW_SIZE_Y]; //incoming column of pixels
input in_go; //begin calculating descriptor
input in_reset;
input logic [COORD_BITS-1:0] in_x, in_y;

output logic [NUM_COMPARISONS-1:0] out_descriptor;
output logic out_valid;
output logic out_window_ready;
output out_accepting_input;
output logic [COORD_BITS-1:0] out_feature_x, out_feature_y; //image-space

logic [8:0] state;

logic [1:0] simple_state;

logic q_write_column;
logic q_angle_is_nan;
logic q_mode;
logic q_angle_will_be_nan;

logic signed [8:0] cos_angle, sin_angle; //signed 0.7 fixed-point
logic [ANGLE_BITS-1:0] sector, sector_latched;

logic signed [4:0] x1[BITS_PER_CLOCK], y1[BITS_PER_CLOCK], x2[BITS_PER_CLOCK], y2[BITS_PER_CLOCK]; //inputs
logic signed [5:0] rx1[BITS_PER_CLOCK], ry1[BITS_PER_CLOCK], rx2[BITS_PER_CLOCK], ry2[BITS_PER_CLOCK]; //rounded product, coordinates of samples
logic [7:0] sample_bit_index, output_bit_index;
logic [LUMA_BITS-1:0] pix1[BITS_PER_CLOCK], pix2[BITS_PER_CLOCK]; //pixel values of samples
logic [BITS_PER_CLOCK-1:0] comp; //comparison
logic [BITS_PER_CLOCK-1:0] patch_valid;
logic signed [MOMENT_BITS-1:0] xmoment[BITS_PER_CLOCK], ymoment[BITS_PER_CLOCK];

initial state = 0;

generate
	genvar i;
	for (i = 0; i < BITS_PER_CLOCK; i++) begin:windows
		ORBWindow #(
			.LUMA_BITS(LUMA_BITS),
			.COORD_BITS(PATCH_COORD_BITS),
			.MOMENT_BITS(MOMENT_BITS)
		) window (
			.clk(clk),
			.in_valid(in_valid),
			.in_col(in_col),
			.in_coord1('{rx1[i], ry1[i]}),
			.in_coord2('{rx2[i], ry2[i]}),
			.in_flush(in_reset),
			.in_mode(q_mode),
			.out_patch_valid(patch_valid[i]),
			.out_pix1(pix1[i]),
			.out_pix2(pix2[i]),
			.out_xmoment(xmoment[i]),
			.out_ymoment(ymoment[i])
		);
		
		VectorRotate rv1(
			.clk(clk),
			.ix(x1[i]),
			.iy(y1[i]),
			.cos(cos_angle),
			.sin(sin_angle),
			.ox(rx1[i]),
			.oy(ry1[i])
		);
		
		VectorRotate rv2(
			.clk(clk),
			.ix(x2[i]),
			.iy(y2[i]),
			.cos(cos_angle),
			.sin(sin_angle),
			.ox(rx2[i]),
			.oy(ry2[i])
		);
	end
endgenerate

SectorSel #(
	.INPUT_BITS(MOMENT_BITS)
) sectorsel_mod(
	.clk(clk),
	.in_valid(state < T_SAMPLE_SECTOR),
	.in_x(xmoment[0]),
	.in_y(ymoment[0]),
	.out_sector(sector),
	.out_nan(q_angle_is_nan)
);

assign out_window_ready = &patch_valid;
assign out_accepting_input = state == T_PATCH_INPUT;
assign q_write_column = in_valid && state == T_PATCH_INPUT;
assign q_mode = (state == T_PATCH_INPUT) || in_reset;
assign q_angle_will_be_nan = (xmoment[0] == 0) && (ymoment[0] == 0); //saves flushing if the angle will be NaN

assign simple_state = (state == T_PATCH_INPUT) ? (&patch_valid ? 1 : 0) : 2;

always_comb begin
	cos_angle <= ROTATION_LUT[sector_latched][0];
	sin_angle <= ROTATION_LUT[sector_latched][1];
	
	sample_bit_index = (state - T_VEC_ROTATE_INPUT_START) * BITS_PER_CLOCK;
	output_bit_index = (state - T_IMAGE_SAMPLE_START) * BITS_PER_CLOCK;
	
	for (int i = 0; i < BITS_PER_CLOCK; i++) begin
		x1[i] = ORB_SAMPLES[sample_bit_index+i][0][0];
		y1[i] = ORB_SAMPLES[sample_bit_index+i][0][1];
		x2[i] = ORB_SAMPLES[sample_bit_index+i][1][0];
		y2[i] = ORB_SAMPLES[sample_bit_index+i][1][1];
	end
end

always_comb begin
	for (int i = 0; i < BITS_PER_CLOCK; i++) begin
		comp[i] = pix1[i] < pix2[i];
	end
end

always @(posedge clk) begin
	out_valid <= 0;
	if (in_reset) begin
		state <= T_PATCH_INPUT;
	end else begin
		if (state == T_PATCH_INPUT) begin
			if (in_go && out_window_ready && !q_angle_will_be_nan) begin
				out_feature_x <= in_x;
				out_feature_y <= in_y;
				state <= state + 1;
			end
		end else begin
			if (state == T_SAMPLE_SECTOR) begin
				sector_latched <= sector;
				state <= state + 1;
				out_descriptor <= 'x;
			end else if (state >= T_IMAGE_SAMPLE_START && state < T_IMAGE_SAMPLE_END) begin
				/*for (int i = 0; i < BITS_PER_CLOCK; i++) begin
					out_descriptor[output_bit_index+i] = comp[i];
					//if (sector == 6'h38) $display("((%3d,%3d),(%3d,%3d)) - %02x %02x", rx1[i], ry1[i], rx2[i], ry2[i], pix1[i], pix2[i]);
				end*/
				out_descriptor <= {comp, out_descriptor[NUM_COMPARISONS-BITS_PER_CLOCK:1]};
			end
			
			if (state == T_IMAGE_SAMPLE_END - 1) begin
				//this is the last chunk of the descriptor
				out_valid <= 1;
				state <= T_PATCH_INPUT;
			end else begin
				state <= state + 1;
			end
		end
	end
end

endmodule
