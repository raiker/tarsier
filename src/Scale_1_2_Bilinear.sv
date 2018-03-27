/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module Scale_1_2_Bilinear(clk, reset, r_width, in_pixel, in_valid, in_x, in_y, out_pixel, out_valid, out_x, out_y);

parameter LUMA_BITS;
parameter MAX_INPUT_WIDTH;
parameter MAX_INPUT_HEIGHT; //not used
parameter COORD_BITS;

localparam MAX_OUTPUT_WIDTH = MAX_INPUT_WIDTH / 2;
localparam MAX_OUTPUT_HEIGHT = MAX_INPUT_HEIGHT / 2;

input clk, reset;
input [COORD_BITS-1:0] r_width;
input [LUMA_BITS-1:0] in_pixel;
input in_valid;
input logic [COORD_BITS-1:0] in_x, in_y;

output [LUMA_BITS-1:0] out_pixel;
output logic out_valid;
output logic [COORD_BITS-1:0] out_x, out_y;

logic [LUMA_BITS-1:0] window [2][2];
logic next_valid;
logic [COORD_BITS-1:0] next_x, next_y;
logic [LUMA_BITS+2-1:0] i_result;

SlidingWindow #(
	.DATA_BITS(LUMA_BITS),
	.WINDOW_NUM_ROWS(2),
	.WINDOW_NUM_COLS(2),
	.MAX_ROW_LENGTH(MAX_INPUT_WIDTH),
	.COORD_BITS(COORD_BITS)
) window_mod (
	.clk(clk),
	.reset(reset),
	.r_row_length(r_width),
	.in_valid(in_valid),
	.in_data(in_pixel),
	.out_window(window)
);

always_ff @(posedge clk) begin
	out_valid <= next_valid;
	out_x <= next_x;
	out_y <= next_y;
end

assign i_result = (window[0][0] + window[0][1]) + (window[1][0] + window[1][1]);
assign out_pixel = i_result >> 2;
assign next_valid = in_valid & in_x[0] & in_y[0]; //both coordinates odd
assign next_x = in_x >> 1;
assign next_y = in_y >> 1;

endmodule
