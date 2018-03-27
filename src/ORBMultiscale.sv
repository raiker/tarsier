/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//Instantiates multiple copies of the feature detector/extractor combo,
//one for each scale level in the pyramid
//Input: pixels, one-by-one
//Output: features

module ORBMultiscale(clk, reset, in_begin_frame_reset, out_frame_reset_complete, r_width, r_height, r_threshold,
	in_valid, in_pixel, in_x, in_y, in_output_ready, in_masks,
	out_corner_count_increments, out_frame_end, out_descriptor, out_valid, out_feature_x, out_feature_y, out_level);

parameter LUMA_BITS = 8;
parameter MAX_IMAGE_WIDTH;
parameter MAX_IMAGE_HEIGHT;
parameter COORD_BITS = 10;
parameter SCORE_BITS = 24;
parameter MATRIX_BITS = 16;
parameter FIFO_LEN = 512;

parameter OCTAVES = 2;
parameter LEVELS_PER_OCTAVE = 3; //fixed for a 4/5 scale
//check image width calculation if this is changed
`ifdef QUARTUS
parameter integer PARALLEL_MODULES[OCTAVES * LEVELS_PER_OCTAVE] = '{1, 1, 1, 1, 1, 1};
`else
parameter integer PARALLEL_MODULES[6] = '{4, 2, 1, 1, 1, 1};
//parameter integer PARALLEL_MODULES[2] = '{2, 2};
`endif

localparam DESCRIPTOR_BITS = 256;
localparam LEVEL_BITS = 16;

input clk, in_valid;
input reset;
input in_begin_frame_reset;
input [COORD_BITS-1:0] r_width, r_height;
input signed [15:0] r_threshold;

input [LUMA_BITS-1:0] in_pixel;
input [COORD_BITS-1:0] in_x, in_y;
input in_output_ready;
input [31:0] in_masks [OCTAVES * LEVELS_PER_OCTAVE];

output out_frame_reset_complete;
output out_corner_count_increments [OCTAVES * LEVELS_PER_OCTAVE];
output out_frame_end;
output logic [DESCRIPTOR_BITS-1:0] out_descriptor;
output logic out_valid;
output logic [COORD_BITS-1:0] out_feature_x, out_feature_y;
output logic [LEVEL_BITS-1:0] out_level;

typedef struct {
	logic in_valid;
	logic [LUMA_BITS-1:0] in_pixel;
	logic [COORD_BITS-1:0] in_x, in_y;
} input_parameter_set_t;

typedef struct {
	//logic out_modeswitch, out_mode;
	logic [DESCRIPTOR_BITS-1:0] out_descriptor;
	logic [COORD_BITS-1:0] out_feature_x, out_feature_y;
	logic [LEVEL_BITS-1:0] out_level;
} output_descriptor_t;

typedef struct {
	logic [COORD_BITS-1:0] width, height;
	logic becomes_valid;
} dimensions_t;

typedef logic [$bits(output_descriptor_t)-1:0] output_descriptor_bits_t;

dimensions_t level_dims [OCTAVES*LEVELS_PER_OCTAVE];
input_parameter_set_t scale_inputs [OCTAVES*LEVELS_PER_OCTAVE];
output_descriptor_t descriptor_outputs [OCTAVES*LEVELS_PER_OCTAVE];
output_descriptor_bits_t mux_input_bits [OCTAVES*LEVELS_PER_OCTAVE];
output_descriptor_bits_t mux_output_bits;
output_descriptor_t mux_output;
logic mux_ready [OCTAVES*LEVELS_PER_OCTAVE];
logic mux_input_valid [OCTAVES*LEVELS_PER_OCTAVE];
logic [OCTAVES*LEVELS_PER_OCTAVE-1:0] level_frame_end;
logic [OCTAVES*LEVELS_PER_OCTAVE-1:0] level_frame_reset_complete;

function int scale_dim_4_5;
	input int x;
	scale_dim_4_5 = (x-1)*4/5+1;
endfunction

generate
	genvar i, j;
	for (i = 0; i < OCTAVES; i++) begin:octaves
		for (j = 0; j < LEVELS_PER_OCTAVE; j++) begin:sublevels
			//dimension calculations
			localparam LEVEL_MAX_IMAGE_WIDTH = MAX_IMAGE_WIDTH >> i;
			localparam LEVEL_MAX_IMAGE_HEIGHT = MAX_IMAGE_HEIGHT >> i;

			if (i == 0) begin
				//0th octave
				if (j == 0) begin
					localparam THIS_LEVEL = i * LEVELS_PER_OCTAVE + j;

					//0th level of 0th octave, no scaling
					always_ff @(posedge clk) begin
						if (in_begin_frame_reset) begin
							level_dims[THIS_LEVEL].width = r_width;
							level_dims[THIS_LEVEL].height = r_height;
							level_dims[THIS_LEVEL].becomes_valid = 1;
						end else begin
							level_dims[THIS_LEVEL].becomes_valid = 0;
						end
					end

					//very first level, no scaling
					assign scale_inputs[THIS_LEVEL].in_valid = in_valid;
					assign scale_inputs[THIS_LEVEL].in_pixel = in_pixel;
					assign scale_inputs[THIS_LEVEL].in_x = in_x;
					assign scale_inputs[THIS_LEVEL].in_y = in_y;
				end else begin
					localparam THIS_LEVEL = i * LEVELS_PER_OCTAVE + j;
					localparam SRC_LEVEL = i * LEVELS_PER_OCTAVE + j - 1;

					logic [COORD_BITS-1:0] width, height;
					logic valid_0, valid_1, valid_2;

					DimensionCalculator_4_5 #(
						.COORD_BITS(COORD_BITS)
					) x_dim (
						.clk(clk),
						.in_valid(level_dims[SRC_LEVEL].becomes_valid),
						.in_dim(level_dims[SRC_LEVEL].width),
						.out_valid(valid),
						.out_dim(width)
					);

					DimensionCalculator_4_5 #(
						.COORD_BITS(COORD_BITS)
					) y_dim (
						.clk(clk),
						.in_valid(level_dims[SRC_LEVEL].becomes_valid),
						.in_dim(level_dims[SRC_LEVEL].height),
						.out_valid(valid_0),
						.out_dim(height)
					);

					assign level_dims[THIS_LEVEL].becomes_valid = valid_1 && !valid_2;

					always_ff @(posedge clk) begin
						valid_1 <= valid_0;
						valid_2 <= valid_1;
						if (valid_0) begin
							level_dims[THIS_LEVEL].width = width;
							level_dims[THIS_LEVEL].height = height;
						end
					end

					Scale_4_5_Bilinear #(
						.LUMA_BITS(LUMA_BITS),
						.MAX_INPUT_WIDTH(LEVEL_MAX_IMAGE_WIDTH),
						.MAX_INPUT_HEIGHT(LEVEL_MAX_IMAGE_HEIGHT),
						.COORD_BITS(COORD_BITS)
					) scaler_4_5 (
						.clk(clk),
						.reset(level_dims[SRC_LEVEL].becomes_valid),
						.r_width(level_dims[SRC_LEVEL].width),
						.in_valid(scale_inputs[SRC_LEVEL].in_valid),
						.in_pixel(scale_inputs[SRC_LEVEL].in_pixel),
						.in_x(scale_inputs[SRC_LEVEL].in_x),
						.in_y(scale_inputs[SRC_LEVEL].in_y),
						.out_valid(scale_inputs[THIS_LEVEL].in_valid),
						.out_pixel(scale_inputs[THIS_LEVEL].in_pixel),
						.out_x(scale_inputs[THIS_LEVEL].in_x),
						.out_y(scale_inputs[THIS_LEVEL].in_y)
					);
				end
			end else begin
				//other octaves				
				localparam THIS_LEVEL = i * LEVELS_PER_OCTAVE + j;
				localparam SRC_LEVEL = (i-1) * LEVELS_PER_OCTAVE + j;

				assign level_dims[THIS_LEVEL].width = level_dims[SRC_LEVEL].width >> 1;
				assign level_dims[THIS_LEVEL].height = level_dims[SRC_LEVEL].height >> 1;
				assign level_dims[THIS_LEVEL].becomes_valid = level_dims[SRC_LEVEL].becomes_valid;

				Scale_1_2_Bilinear #(
					.LUMA_BITS(LUMA_BITS),
					.MAX_INPUT_WIDTH(LEVEL_MAX_IMAGE_WIDTH),
					.MAX_INPUT_HEIGHT(LEVEL_MAX_IMAGE_HEIGHT),
					.COORD_BITS(COORD_BITS)
				) scaler_1_2 (
					.clk(clk),
					.reset(level_dims[SRC_LEVEL].becomes_valid),
					.r_width(level_dims[SRC_LEVEL].width),
					.in_valid(scale_inputs[SRC_LEVEL].in_valid),
					.in_pixel(scale_inputs[SRC_LEVEL].in_pixel),
					.in_x(scale_inputs[SRC_LEVEL].in_x),
					.in_y(scale_inputs[SRC_LEVEL].in_y),
					.out_valid(scale_inputs[THIS_LEVEL].in_valid),
					.out_pixel(scale_inputs[THIS_LEVEL].in_pixel),
					.out_x(scale_inputs[THIS_LEVEL].in_x),
					.out_y(scale_inputs[THIS_LEVEL].in_y)
				);
			end
			
			//processing
			localparam level = i * LEVELS_PER_OCTAVE + j;
			logic [COORD_BITS-1:0] module_out_x, module_out_y;
			
			BufferedCornersAndDescriptors #(
				.LUMA_BITS(LUMA_BITS),
				.MATRIX_BITS(MATRIX_BITS),
				.MAX_IMAGE_WIDTH(LEVEL_MAX_IMAGE_WIDTH),
				.MAX_IMAGE_HEIGHT(LEVEL_MAX_IMAGE_HEIGHT),
				.COORD_BITS(COORD_BITS),
				.NONMAX_SCORE_BITS(SCORE_BITS),
				.PARALLEL_MODULES(PARALLEL_MODULES[level]),
				.FIFO_LEN(FIFO_LEN),
				.BUFFERING_STRATEGY(level > 0) //set level 0 to be *stall when ALL modules busy*, and all other levels to be *stall when ANY module busy*
			) corners_mod (
				.clk(clk),
				.reset(reset),
				.in_begin_frame_reset(level_dims[level].becomes_valid),
				.out_frame_reset_complete(level_frame_reset_complete[level]),
				.r_width(level_dims[level].width),
				.r_height(level_dims[level].height),
				.r_threshold(r_threshold),
				.in_valid(scale_inputs[level].in_valid),
				.in_pixel(scale_inputs[level].in_pixel),
				.in_x(scale_inputs[level].in_x),
				.in_y(scale_inputs[level].in_y),
				.in_consume(mux_ready[level]),
				.in_mask(in_masks[level]),
				.out_corner_count_increment(out_corner_count_increments[level]),
				.out_frame_end(level_frame_end[level]),
				.out_descriptor(descriptor_outputs[level].out_descriptor),
				.out_valid(mux_input_valid[level]),
				.out_feature_x(module_out_x),
				.out_feature_y(module_out_y)
			);
			
			assign descriptor_outputs[level].out_level = {12'h000, level};
			
			assign mux_input_bits[level] = output_descriptor_bits_t'(descriptor_outputs[level]);
			
			CoordinateTransformer #(
				.COORD_BITS(COORD_BITS),
				.OCTAVE(i),
				.SUBLEVEL(j)
			) ct_x (
				.in_coord(module_out_x),
				.out_coord(descriptor_outputs[level].out_feature_x)
			);
			
			CoordinateTransformer #(
				.COORD_BITS(COORD_BITS),
				.OCTAVE(i),
				.SUBLEVEL(j)
			) ct_y (
				.in_coord(module_out_y),
				.out_coord(descriptor_outputs[level].out_feature_y)
			);
		end
	end
endgenerate

RecBinaryMux #(
	.DATA_WIDTH($bits(output_descriptor_bits_t)),
	.LENGTH(OCTAVES*LEVELS_PER_OCTAVE)
) pipelined_mux (
	.clk(clk),
	.reset(reset),
	.in_data(mux_input_bits),
	.in_valid(mux_input_valid),
	.in_ready(mux_ready),
	.out_data(mux_output_bits),
	.out_valid(out_valid),
	.out_ready(in_output_ready)
);

MultilevelBarrier #(
	.NUM_LEVELS(OCTAVES*LEVELS_PER_OCTAVE)
) frame_end_barrier (
	.clk(clk),
	.reset(reset),
	.in_wait(level_frame_end),
	.out_release(out_frame_end)
);

MultilevelBarrier #(
	.NUM_LEVELS(OCTAVES*LEVELS_PER_OCTAVE)
) reset_barrier (
	.clk(clk),
	.reset(reset),
	.in_wait(level_frame_reset_complete),
	.out_release(out_frame_reset_complete)
);

assign mux_output = output_descriptor_t'(mux_output_bits);
assign out_descriptor = mux_output.out_descriptor;
assign out_feature_x = mux_output.out_feature_x;
assign out_feature_y = mux_output.out_feature_y;
assign out_level = mux_output.out_level;
	
endmodule
