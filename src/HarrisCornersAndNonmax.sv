/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//reports cornerness for corner at (0,0), given a window at (4:6,24:26)
//total delay is 5 rows and 16 clocks
module HarrisCornersAndNonmax(clk, reset, r_width, r_threshold, in_valid, in_window, out_is_corner);

parameter LUMA_BITS;
parameter MAX_IMAGE_WIDTH;
parameter MATRIX_BITS = 12; //works much better than 8
parameter COORD_BITS;
localparam HARRIS_SCORE_BITS = 2 * MATRIX_BITS + 1;
localparam NONMAX_WINDOW_SIZE = 3;

parameter NONMAX_SCORE_BITS = HARRIS_SCORE_BITS;

input clk, reset;
input [COORD_BITS-1:0] r_width;
input signed [15:0] r_threshold;
input in_valid;
input [LUMA_BITS-1:0] in_window [3][3];

output logic out_is_corner;

logic signed [15:0] threshold;
logic signed [HARRIS_SCORE_BITS-1:0] harris_output_score;

logic signed [NONMAX_SCORE_BITS-1:0] nonmax_input_score;
logic signed [NONMAX_SCORE_BITS-1:0] nonmax_window [NONMAX_WINDOW_SIZE][NONMAX_WINDOW_SIZE];
logic nonmax_output_is_local_max;

assign nonmax_input_score = harris_output_score[(HARRIS_SCORE_BITS-1)-:NONMAX_SCORE_BITS];
//assign out_is_corner = nonmax_output_is_local_max && in_valid;

HarrisCornersPipelined #(
	.LUMA_BITS(LUMA_BITS),
	.MATRIX_BITS(MATRIX_BITS),
	.MAX_ROW_LENGTH(MAX_IMAGE_WIDTH),
	.COORD_BITS(COORD_BITS)
) cornersmod (
	.clk(clk),
	.reset(reset),
	.r_row_length(r_width),
	.in_valid(in_valid),
	.in_window(in_window),
	.out_score(harris_output_score)
);

SlidingWindowSigned #(
	.DATA_BITS(NONMAX_SCORE_BITS),
	.WINDOW_NUM_ROWS(NONMAX_WINDOW_SIZE),
	.WINDOW_NUM_COLS(NONMAX_WINDOW_SIZE),
	.MAX_ROW_LENGTH(MAX_IMAGE_WIDTH),
	.COORD_BITS(COORD_BITS)
) nonmaxwindowmod (
	.clk(clk),
	.reset(reset),
	.r_row_length(r_width),
	.in_valid(in_valid),
	.in_data(nonmax_input_score),
	.out_window(nonmax_window)
);

NonmaxSuppression #(
	.DATA_BITS(NONMAX_SCORE_BITS),
	.WINDOW_WIDTH(NONMAX_WINDOW_SIZE),
	.WINDOW_HEIGHT(NONMAX_WINDOW_SIZE)
) nonmaxmod (
	.window(nonmax_window),
	.threshold(threshold),
	.out(nonmax_output_is_local_max)
);

always_ff @(posedge clk) begin
	if (reset) begin
		threshold <= r_threshold;
	end

	if (in_valid) begin
		out_is_corner <= nonmax_output_is_local_max;
	end
end

/*always_ff @(posedge clk) begin
	$display("%d", harris_output_score);
end*/

endmodule
