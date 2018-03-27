/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module HarrisCornersPipelinedTestbench();

`include "../etc/HCTestbenchGen/HarrisCornersTestbenchData.inc.sv"

localparam MAX_ROW_LENGTH = 2048;
localparam INTERNAL_SCORE_BITS = 2 * MATRIX_BITS + 1;
//total delay is 4 rows and 22? clocks
localparam DELAY = 4 * IMAGE_WIDTH + 22;

logic clk, reset, sw_wr_en, hc_wr_en;
logic [LUMA_BITS-1:0] in;
wire [LUMA_BITS-1:0] window [3][3];
logic signed [SCORE_BITS-1:0] score, score_cmp;
int error_count;
logic [INTERNAL_SCORE_BITS-1:0] internal_score;

SlidingWindow #(
	.DATA_BITS(LUMA_BITS),
	.WINDOW_NUM_ROWS(3),
	.WINDOW_NUM_COLS(3),
	.MAX_ROW_LENGTH(MAX_ROW_LENGTH),
	.COORD_BITS(16)
) window_mod (
	.clk(clk),
	.reset(reset),
	.r_row_length(IMAGE_WIDTH),
	.in_valid(sw_wr_en),
	.in_data(in),
	.out_window(window)
);

HarrisCornersPipelined #(
	.LUMA_BITS(LUMA_BITS),
	.MATRIX_BITS(MATRIX_BITS),
	.MAX_ROW_LENGTH(MAX_ROW_LENGTH),
	.COORD_BITS(16)
) test_mod (
	.clk(clk),
	.reset(reset),
	.r_row_length(IMAGE_WIDTH),
	.in_valid(hc_wr_en),
	.in_window(window),
	.out_score(internal_score)
);

int cursor = -2;

initial begin
	$display("Testing HarrisCornersPipelined");
	clk = 0;
	error_count = 0;
end

always begin
	#5;
	clk = 1;
	#5;
	clk = 0;
end

assign reset = cursor == -1;
assign sw_wr_en = cursor >= 0 && cursor < (IMAGE_HEIGHT * IMAGE_WIDTH);
assign hc_wr_en = cursor >= 0 && cursor < (IMAGE_HEIGHT * IMAGE_WIDTH);
assign in = image_data[cursor];

always_comb begin
	if ((cursor >= DELAY) && (cursor < IMAGE_WIDTH * IMAGE_HEIGHT + DELAY)) begin
		score_cmp = comparison_data[cursor - DELAY];
	end else begin
		score_cmp = 'hx;
	end
	
	score = internal_score[INTERNAL_SCORE_BITS-1 -: SCORE_BITS];
end

always @(posedge clk) begin
	automatic logic failure = 0;
	
	cursor++;
	
	failure = (score != score_cmp);
	
	if (failure) begin
		$display("Assertion failure at t=%d", cursor);
		error_count++;
	end
end

endmodule
