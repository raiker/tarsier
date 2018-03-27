/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module ORBMultiscaleTestbench();

`include "../etc/HCTestbenchGen/HarrisCornersTestbenchData.inc.sv"

localparam COORD_BITS = 16;

logic clk;
int cursor = -2;
int out_cursor = 0;
int error_count = 0;

logic in_valid;
logic [LUMA_BITS-1:0] in_pixel;
logic [COORD_BITS-1:0] in_x, in_y;
logic in_consume, in_frame_type, in_reset;
logic out_modeswitch, out_mode;
logic [255:0] out_descriptor;
logic out_valid;
logic [COORD_BITS-1:0] out_feature_x, out_feature_y;
logic [3:0] out_level;
logic begin_frame_reset, end_frame_reset;

ORBMultiscale #(
	.LUMA_BITS(LUMA_BITS),
	.MAX_IMAGE_WIDTH(1024),
	.MAX_IMAGE_HEIGHT(1024),
	.COORD_BITS(COORD_BITS),
	.SCORE_BITS(SCORE_BITS),
	.MATRIX_BITS(MATRIX_BITS),
	.PARALLEL_MODULES('{4, 2, 1, 1, 1, 1}),
	.OCTAVES(2),
	.LEVELS_PER_OCTAVE(3),
	.FIFO_LEN(512),
	.THRESHOLD(200)
) test_mod (
	.clk(clk),
	.reset(in_reset),
	.in_begin_frame_reset(begin_frame_reset),
	.out_frame_reset_complete(end_frame_reset),
	.r_width(IMAGE_WIDTH),
	.r_height(IMAGE_HEIGHT),
	.in_valid(in_valid),
	.in_pixel(in_pixel),
	.in_x(in_x),
	.in_y(in_y),
	.in_masks('{0,0,0,0,0,0}),
	.in_output_ready(1'b1),
	.out_descriptor(out_descriptor),
	.out_valid(out_valid),
	.out_feature_x(out_feature_x),
	.out_feature_y(out_feature_y),
	.out_level(out_level)
);

assign in_valid = cursor >= 0 && cursor < (IMAGE_HEIGHT * IMAGE_WIDTH);
assign in_pixel = image_data[cursor];
assign in_x = cursor % IMAGE_WIDTH;
assign in_y = cursor / IMAGE_WIDTH;
assign in_reset = cursor == -2;
assign begin_frame_reset = cursor == -1;

initial begin
	$display("Testing ORBMultiscale");
	error_count = 0;
end

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

always @(posedge clk) begin
	if (cursor < 0 && (end_frame_reset || in_reset) || cursor >= 0) begin
		cursor <= cursor + 1;
	end
	
	if (out_valid) begin
		$display("Feature at (%d,%d) [%d] - %x", out_feature_x, out_feature_y, out_level, out_descriptor);
		
		/*out_cursor <= out_cursor + 1;
		
		if (
			out_feature_x !== corner_list[out_cursor].x ||
			out_feature_y !== corner_list[out_cursor].y ||
			out_descriptor !== corner_list[out_cursor].descriptor
		) begin
			error_count <= error_count + 1;
			$display("Error at t=%d", cursor);
		end*/
	end
end

endmodule
