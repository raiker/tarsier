/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//in_is_corner needs to lag the centre pixel (the corner pixel) by 25 columns
module ORBArbitrator(
	clk, in_valid, in_col, in_is_corner, in_reset, in_consume, in_x, in_y, in_mask,
	out_descriptor, out_valid, out_feature_x, out_feature_y, out_request_stall);

parameter LUMA_BITS = 8;
parameter PARALLEL_MODULES = 16;
parameter BITS_PER_CLOCK = 1;
parameter COORD_BITS = 10;
parameter BUFFERING_STRATEGY; //0 = Stall when all modules processing, 1 = Stall when any module processing

localparam WINDOW_SIZE_Y = 37;
localparam DESCRIPTOR_BITS = 256;
localparam OUT_FIFO_ADDRESS_BITS = 3;
localparam DESCRIPTOR_CALCULATION_TIME = 4 + 256 / BITS_PER_CLOCK;

typedef struct {
	logic [DESCRIPTOR_BITS-1:0] descriptor;
	logic [COORD_BITS-1:0] x, y;
} descriptor_t;
typedef logic [$bits(descriptor_t)-1:0] descriptor_bits_t;

input clk;
input in_valid;
input [LUMA_BITS-1:0] in_col [WINDOW_SIZE_Y]; //incoming column of pixels
input in_is_corner;
input in_reset;
input in_consume;
input logic [COORD_BITS-1:0] in_x, in_y;
input logic [31:0] in_mask; //set bit to 1 to disable that module

output logic [DESCRIPTOR_BITS-1:0] out_descriptor;
output logic out_valid;
output logic [COORD_BITS-1:0] out_feature_x, out_feature_y;
output out_request_stall;

logic [PARALLEL_MODULES-1:0] q_go;
logic [PARALLEL_MODULES-1:0] q_valid;
logic [PARALLEL_MODULES-1:0] q_window_ready;
logic [PARALLEL_MODULES-1:0] q_accepting_input;
logic q_mux_input_ready [PARALLEL_MODULES];

descriptor_t mux_input [PARALLEL_MODULES];
descriptor_t fifo_output;
descriptor_bits_t mux_input_bits [PARALLEL_MODULES];
descriptor_bits_t fifo_input_bits, fifo_output_bits;
logic fifo_write;
logic fifo_full;

generate
	genvar i;
	
	for (i = 0; i < PARALLEL_MODULES; i++) begin:orb_modules
		ORB2 #(
			.LUMA_BITS(LUMA_BITS),
			.BITS_PER_CLOCK(BITS_PER_CLOCK),
			.COORD_BITS(COORD_BITS)
		) orb_mod (
			.clk(clk),
			.in_col(in_col),
			.in_valid(in_valid),
			.in_go(q_go[i]),
			.in_reset(in_reset),
			.in_x(in_x),
			.in_y(in_y),
			.out_descriptor(mux_input[i].descriptor),
			.out_valid(q_valid[i]),
			.out_window_ready(q_window_ready[i]),
			.out_accepting_input(q_accepting_input[i]),
			.out_feature_x(mux_input[i].x),
			.out_feature_y(mux_input[i].y)
		);
		
		assign mux_input_bits[i] = descriptor_bits_t'(mux_input[i]);
	end
endgenerate

always_comb begin
	q_go = '0;
	
	if (in_is_corner && in_valid) begin
		for (int i = 0; i < PARALLEL_MODULES; i++) begin
			if (q_window_ready[i]/* && !in_mask[i]*/) begin
				q_go[i] = 1'b1;
				break;
			end
		end
	end
end

always_comb begin
	fifo_input_bits = 'x;
	fifo_write = 1'b0;
	
	for (int i = 0; i < PARALLEL_MODULES; i++) begin
		if (q_valid[i]) begin
			fifo_input_bits = mux_input_bits[i];
			fifo_write = 1'b1;
			break;
		end
	end
end

FIFO #(
	.DATA_BITS($bits(descriptor_t)),
	.ADDRESS_BITS(OUT_FIFO_ADDRESS_BITS)
) orb_fifo (
	.clk(clk),
	.reset(in_reset),
	.in_write(fifo_write),
	.in_data(fifo_input_bits),
	.in_read(in_consume),
	.out_data(fifo_output_bits),
	.out_valid(out_valid),
	.out_full(fifo_full)
);

assign fifo_output = descriptor_t'(fifo_output_bits);

assign out_descriptor = fifo_output.descriptor;
assign out_feature_x = fifo_output.x;
assign out_feature_y = fifo_output.y;
assign out_request_stall = (BUFFERING_STRATEGY == 0) ? !(|q_accepting_input) : !(&q_accepting_input);

endmodule
