/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module BufferedCornersAndDescriptors(clk, reset, in_begin_frame_reset, out_frame_reset_complete, r_width, r_height, r_threshold,
	in_valid, in_pixel, in_x, in_y, in_consume, in_mask,
	out_corner_count_increment, out_frame_end, out_descriptor, out_valid, out_feature_x, out_feature_y);

parameter LUMA_BITS;
parameter MAX_IMAGE_WIDTH;
parameter MAX_IMAGE_HEIGHT;
parameter COORD_BITS;
parameter MATRIX_BITS;
parameter NONMAX_SCORE_BITS;
parameter PARALLEL_MODULES;
parameter BUFFERING_STRATEGY; //0 = Stall when all modules processing, 1 = Stall when any module processing
parameter FIFO_LEN = 2048; //pixels

localparam DESCRIPTOR_BITS = 256;

typedef struct {
	logic [LUMA_BITS-1:0] pixel;
	logic [COORD_BITS-1:0] x, y;
} buffer_entry_t;

typedef logic [$bits(buffer_entry_t)-1:0] buffer_entry_bits_t;

input clk, reset;
input in_valid;
input in_begin_frame_reset;
input [COORD_BITS-1:0] r_width, r_height;
input signed [15:0] r_threshold;
input [LUMA_BITS-1:0] in_pixel;
input [COORD_BITS-1:0] in_x, in_y;
input in_consume; //1 to remove an item from the underlying FIFO
input logic [31:0] in_mask;

output out_frame_reset_complete;
output out_corner_count_increment;
output out_frame_end;
output [DESCRIPTOR_BITS-1:0] out_descriptor;
output out_valid;
output [COORD_BITS-1:0] out_feature_x, out_feature_y;

logic buffer_input_valid;
logic buffer_consume;
logic buffer_full;
logic buffer_output_valid;
//logic [LUMA_BITS-1:0] buffer_input_pixel;
//logic [LUMA_BITS-1:0] buffer_output_pixel;
buffer_entry_t buffer_input, buffer_output;

logic cd_input_valid;
logic [LUMA_BITS-1:0] cd_input_pixel;
logic [COORD_BITS-1:0] cd_in_x, cd_in_y;
logic cd_consume;
logic cd_reset;
logic cd_request_stall;
logic [DESCRIPTOR_BITS-1:0] cd_out_descriptor;
logic cd_output_valid;
logic [COORD_BITS-1:0] cd_feature_x, cd_feature_y;

assign buffer_input_valid = in_valid;
//cd_request_stall can be used to pause the buffer, unless the buffer is full
assign buffer_consume = (buffer_input_valid && buffer_full) || (!cd_request_stall && buffer_output_valid);
assign buffer_input = '{in_pixel, in_x, in_y};

assign cd_input_valid = buffer_consume;
assign cd_input_pixel = buffer_output.pixel;
assign cd_in_x = buffer_output.x;
assign cd_in_y = buffer_output.y;
assign cd_consume = in_consume;
assign cd_reset = reset;

assign out_descriptor = cd_out_descriptor;
assign out_valid = cd_output_valid;
assign out_feature_x = cd_feature_x;
assign out_feature_y = cd_feature_y;

buffer_entry_bits_t buffer_output_bits;
assign buffer_output = buffer_entry_t'(buffer_output_bits);

FIFO #(
	.DATA_BITS($bits(buffer_entry_t)),
	.ADDRESS_BITS($clog2(FIFO_LEN))
) input_fifo (
	.clk(clk),
	.reset(reset),
	.in_write(buffer_input_valid),
	.in_data(buffer_entry_bits_t'(buffer_input)),
	.in_read(buffer_consume),
	.out_data(buffer_output_bits),
	.out_valid(buffer_output_valid),
	.out_full(buffer_full)
);

CornersAndDescriptors #(
	.LUMA_BITS(LUMA_BITS),
	.MAX_IMAGE_WIDTH(MAX_IMAGE_WIDTH),
	.MAX_IMAGE_HEIGHT(MAX_IMAGE_HEIGHT),
	.COORD_BITS(COORD_BITS),
	.MATRIX_BITS(MATRIX_BITS),
	.NONMAX_SCORE_BITS(NONMAX_SCORE_BITS),
	.PARALLEL_MODULES(PARALLEL_MODULES),
	.BUFFERING_STRATEGY(BUFFERING_STRATEGY)
) cd_mod (
	.clk(clk),
	.reset(cd_reset),
	.in_begin_frame_reset(in_begin_frame_reset),
	.out_frame_reset_complete(out_frame_reset_complete),
	.r_width(r_width),
	.r_height(r_height),
	.r_threshold(r_threshold),
	.in_valid(cd_input_valid),
	.in_pixel(cd_input_pixel),
	.in_x(cd_in_x),
	.in_y(cd_in_y),
	.in_consume(cd_consume),
	.in_mask(in_mask),
	.out_corner_count_increment(out_corner_count_increment),
	.out_frame_end(out_frame_end),
	.out_descriptor(cd_out_descriptor),
	.out_valid(cd_output_valid),
	.out_feature_x(cd_feature_x),
	.out_feature_y(cd_feature_y),
	.out_request_stall(cd_request_stall)
);

endmodule
