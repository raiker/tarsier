/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module SlidingWindowTestbench();

localparam LUMA_BITS = 8;
localparam WINDOW_WIDTH = 2;
localparam WINDOW_HEIGHT = 2;
localparam IMAGE_WIDTH = 12;

logic clk, wr_en;
logic [LUMA_BITS-1:0] in;
logic [LUMA_BITS-1:0] window [WINDOW_HEIGHT][WINDOW_WIDTH];

SlidingWindow #(
	.DATA_BITS(LUMA_BITS),
	.WINDOW_NUM_ROWS(WINDOW_HEIGHT),
	.WINDOW_NUM_COLS(WINDOW_WIDTH),
	.MAX_ROW_LENGTH(16),
	.COORD_BITS(4)
) window_mod (
	.clk(clk),
	.reset(reset),
	.r_row_length(IMAGE_WIDTH),
	.in_valid(wr_en),
	.in_data(in),
	.out_window(window)
);

int cursor = -2;

assign reset = cursor == -1;
assign wr_en = cursor >= 0 && cursor < 144;

initial begin
	$display("Testing SlidingWindow2");
	clk = 0;
end

always begin
	#5;
	clk = 1;
	#5;
	clk = 0;
end

bit [7:0] image_data[12*12] = '{
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'haa, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'h55, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
8'hff, 8'hff, 8'hff, 8'hff, 8'haa, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
8'hff, 8'hff, 8'hff, 8'hff, 8'h55, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
8'hff, 8'hff, 8'hff, 8'haa, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
8'hff, 8'hff, 8'hff, 8'h55, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
};

bit [LUMA_BITS-1:0] comparison [WINDOW_HEIGHT][WINDOW_WIDTH] = '{'{8'hff, 8'h55}, '{8'haa, 8'h00}};

logic comparison_match;

always_comb begin
	in = image_data[cursor];
	
	comparison_match = 1;
	
	for (int i = 0; i < WINDOW_HEIGHT; i++) begin
		for (int j = 0; j < WINDOW_WIDTH; j++) begin
			if (window[i][j] != comparison[i][j]) begin
				comparison_match = 0;
			end
		end
	end
end

always_ff @(posedge clk) begin
	cursor <= cursor + 1;
	
	if (cursor == 102) begin
		if (comparison_match) begin
			$display("Assertion passed");
		end else begin
			$display("Assertion failure");
		end
	end
end

endmodule
