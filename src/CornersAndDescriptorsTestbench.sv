/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1 ns / 1 ns
module CornersAndDescriptorsTestbench();

`include "../etc/HCTestbenchGen/HarrisCornersTestbenchData.inc.sv"

localparam COORD_BITS = 10;
localparam PARALLEL_MODULES = 4;
localparam INV_RATE = 1;

logic clk;
int cursor = 0;
int out_cursor = 0;
int error_count = 0;

logic in_valid;
logic [LUMA_BITS-1:0] in_pixel;
logic [COORD_BITS-1:0] in_x, in_y;
logic in_consume, in_frame_type, reset;
logic in_begin_frame_reset;
logic out_modeswitch, out_mode;
logic [255:0] out_descriptor;
logic out_valid;
logic [COORD_BITS-1:0] out_feature_x, out_feature_y;
integer rate_ctr;

BufferedCornersAndDescriptors #(
	.LUMA_BITS(LUMA_BITS),
	.MATRIX_BITS(MATRIX_BITS),
	.MAX_IMAGE_WIDTH(2048),
	.MAX_IMAGE_HEIGHT(2048),
	.COORD_BITS(COORD_BITS),
	.NONMAX_SCORE_BITS(SCORE_BITS),
	.PARALLEL_MODULES(PARALLEL_MODULES), //stall when all processing
	.BUFFERING_STRATEGY(1),
	.THRESHOLD(200)
) test_mod (
	.clk(clk),
	.reset(reset),
	.in_begin_frame_reset(in_begin_frame_reset),
	.out_frame_reset_complete(out_frame_reset_complete),
	.r_width(IMAGE_WIDTH),
	.r_height(IMAGE_HEIGHT),
	.in_valid(in_valid),
	.in_pixel(in_pixel),
	.in_x(in_x),
	.in_y(in_y),
	.in_consume(in_consume),
	.in_mask(0),
	.out_descriptor(out_descriptor),
	.out_valid(out_valid),
	.out_feature_x(out_feature_x),
	.out_feature_y(out_feature_y)
);

assign in_valid = rate_ctr == 0;
assign in_pixel = image_data[cursor];
assign in_x = cursor % IMAGE_WIDTH;
assign in_y = cursor / IMAGE_WIDTH;
assign in_consume = 1'b1;
assign reset = rate_ctr == -3;
assign in_begin_frame_reset = rate_ctr == -2;

initial begin
	$display("Testing CornersAndDescriptors");
	error_count = 0;
	rate_ctr = -4;
end

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

always @(posedge clk) begin
	if (in_valid) begin
		cursor <= cursor + 1;
	end
	
	if (rate_ctr == INV_RATE - 1) begin
		rate_ctr <= 0;
	end else begin
		rate_ctr <= rate_ctr + 1;
	end
	
	if (out_valid/* && !out_modeswitch*/) begin
		while (
			out_feature_y > corner_list[out_cursor].y ||
			out_feature_y === corner_list[out_cursor].y && out_feature_x > corner_list[out_cursor].x
		) begin
			$display("Missed feature at (%d, %d)", corner_list[out_cursor].x, corner_list[out_cursor].y);
			error_count++;
			out_cursor++;
		end
		
		if (
			out_feature_x !== corner_list[out_cursor].x ||
			out_feature_y !== corner_list[out_cursor].y
		) begin
			$display("Unexpected feature at (%d, %d)", out_feature_x, out_feature_y);
			error_count++;
		end else if (
			out_descriptor !== corner_list[out_cursor].descriptor
		) begin
			$display("Error!! at (%d,%d) (%h) *****", out_feature_x, out_feature_y, out_descriptor);
			$display("Expected descriptor  - (%h)", corner_list[out_cursor].descriptor);
			error_count++;
			out_cursor++;
		end else begin
			$display("Correct at (%d,%d) (%h)", out_feature_x, out_feature_y, out_descriptor);
			out_cursor++;
		end
	end
end

endmodule
