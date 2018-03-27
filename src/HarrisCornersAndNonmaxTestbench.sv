/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module HarrisCornersAndNonmaxTestbench();

`include "../etc/HCTestbenchGen/HarrisCornersTestbenchData.inc.sv"

localparam INTERNAL_SCORE_BITS = 2 * MATRIX_BITS + 1;
//total delay is 5 rows and 24 clocks
localparam DELAY_ROWS = 5;
localparam DELAY_COLS = 25;
localparam DELAY = DELAY_ROWS * IMAGE_WIDTH + DELAY_COLS;

localparam MARGIN = 5; //border inside which corners cannot be detected

logic clk, reset, sw_wr_en, hc_wr_en;
logic [LUMA_BITS-1:0] in;
wire [LUMA_BITS-1:0] window [3][3];
int error_count;
logic out_is_corner, is_local_max, ref_is_corner;
logic in_margin;

integer output_x, output_y;

SlidingWindow #(
	.DATA_BITS(LUMA_BITS),
	.WINDOW_NUM_ROWS(3),
	.WINDOW_NUM_COLS(3),
	.MAX_ROW_LENGTH(2048),
	.COORD_BITS(16)
) window_mod (
	.clk(clk),
	.reset(reset),
	.r_row_length(IMAGE_WIDTH),
	.in_valid(sw_wr_en),
	.in_data(in),
	.out_window(window)
);

HarrisCornersAndNonmax #(
	.LUMA_BITS(LUMA_BITS),
	.MAX_IMAGE_WIDTH(2048),
	.MATRIX_BITS(MATRIX_BITS),
	.NONMAX_SCORE_BITS(SCORE_BITS),
	.THRESHOLD(1000),
	.COORD_BITS(16)
) test_mod (
	.clk(clk),
	.reset(reset),
	.r_width(IMAGE_WIDTH),
	.in_valid(hc_wr_en),
	.in_window(window),
	.out_is_corner(is_local_max)
);

int cursor = -2;

assign out_is_corner = is_local_max && !in_margin;
assign reset = cursor == -1;

initial begin
	$display("Testing HarrisCornersAndNonmax");
	//clk = 1;
	//sw_wr_en = 0;
	//hc_wr_en = 0;
	error_count = 0;
end

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

function integer floor_div;
	input integer dividend;
	input integer divisor;
	
	begin
		if (dividend < 0) begin
			return (dividend - divisor + 1) / divisor;
		end else begin
			return dividend / divisor;
		end
	end
endfunction

always_comb begin
	automatic integer output_cursor = cursor - DELAY;
	output_y = floor_div(output_cursor, IMAGE_WIDTH);
	output_x = output_cursor - IMAGE_WIDTH * output_y;
	
	in_margin = output_x < MARGIN || output_y < MARGIN || output_x >= (IMAGE_WIDTH - MARGIN) || output_y >= (IMAGE_HEIGHT - MARGIN);
	
	if ((cursor >= DELAY) && (cursor < IMAGE_WIDTH * IMAGE_HEIGHT + DELAY)) begin
		ref_is_corner = is_corner[cursor - DELAY];
	end else begin
		ref_is_corner = 'hx;
	end
end

assign in = image_data[cursor];
assign sw_wr_en = cursor >= 0;
assign hc_wr_en = cursor >= 0;

always @(posedge clk) begin
	automatic logic failure = 0;
	
	/*if (sw_wr_en) begin
		in = image_data[cursor++];
	end
	sw_wr_en = 1;
	hc_wr_en = 1;*/
	cursor <= cursor + 1;
	
	failure = (out_is_corner != ref_is_corner);
	
	if (ref_is_corner || out_is_corner) begin
		if (failure) begin
			$display("Assertion failure at (%d,%d)", output_x, output_y);
			error_count++;
		end else begin
			$display("Corner detected at (%d,%d)", output_x, output_y);
		end
	end
end

endmodule
