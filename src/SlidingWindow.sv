/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//Assumes values are fed in row-major order, top to bottom
//coordinates are x+ to the right, y+ downwards
module SlidingWindow(clk, reset, r_row_length, in_valid, in_data, out_window);

parameter DATA_BITS;
parameter WINDOW_NUM_ROWS;
parameter WINDOW_NUM_COLS;
parameter MAX_ROW_LENGTH;
parameter COORD_BITS;

input clk, reset;
input [COORD_BITS-1:0] r_row_length;
input in_valid;
input [DATA_BITS-1:0] in_data;
output logic [DATA_BITS-1:0] out_window [WINDOW_NUM_ROWS][WINDOW_NUM_COLS];

wire [DATA_BITS-1:0] row_taps[WINDOW_NUM_ROWS];

MultitapShiftRegister #(
	.DATA_BITS(DATA_BITS),
	.MAX_TAP_SPACING(MAX_ROW_LENGTH),
	.NUM_TAPS(WINDOW_NUM_ROWS-1),
	.COORD_BITS(COORD_BITS)
) tapped_shift_register (
	.clk(clk),
	.reset(reset),
	.r_tap_spacing(r_row_length),
	.in_valid(in_valid),
	.in_data(in_data),
	.out_data(row_taps[1:WINDOW_NUM_ROWS-1])
);

assign row_taps[0] = in_data;

int i, j;

//hack so that memory has known values
initial begin
	for (i = 0; i < WINDOW_NUM_ROWS; i++) begin
		for (j = 0; j < WINDOW_NUM_COLS; j++) begin
			out_window[i][j] = {(DATA_BITS){1'b1}};
		end
	end
end

always @(posedge clk) begin
	if (in_valid) begin
		//shift the shift registers
		for (i = 0; i < WINDOW_NUM_ROWS; i++) begin
			for (j = 0; j < WINDOW_NUM_COLS - 1; j++) begin
				out_window[i][j] = out_window[i][j+1];
			end
			
			out_window[i][WINDOW_NUM_COLS-1] = row_taps[WINDOW_NUM_ROWS-1-i];
		end
	end
end

endmodule

module SlidingWindowSigned(clk, reset, r_row_length, in_valid, in_data, out_window);

parameter DATA_BITS;
parameter WINDOW_NUM_ROWS;
parameter WINDOW_NUM_COLS;
parameter MAX_ROW_LENGTH;
parameter COORD_BITS;

input clk, reset;
input [COORD_BITS-1:0] r_row_length;
input in_valid;
input signed [DATA_BITS-1:0] in_data;
output logic signed [DATA_BITS-1:0] out_window [WINDOW_NUM_ROWS][WINDOW_NUM_COLS];

wire [DATA_BITS-1:0] row_taps[WINDOW_NUM_ROWS];

MultitapShiftRegister #(
	.DATA_BITS(DATA_BITS),
	.MAX_TAP_SPACING(MAX_ROW_LENGTH),
	.NUM_TAPS(WINDOW_NUM_ROWS-1),
	.COORD_BITS(COORD_BITS)
) tapped_shift_register (
	.clk(clk),
	.reset(reset),
	.r_tap_spacing(r_row_length),
	.in_valid(in_valid),
	.in_data(in_data),
	.out_data(row_taps[1:WINDOW_NUM_ROWS-1])
);

assign row_taps[0] = in_data;

int i, j;

//hack so that memory has known values
initial begin
	for (i = 0; i < WINDOW_NUM_ROWS; i++) begin
		for (j = 0; j < WINDOW_NUM_COLS; j++) begin
			out_window[i][j] = {(DATA_BITS){1'b1}};
		end
	end
end

always @(posedge clk) begin
	if (in_valid) begin
		//shift the shift registers
		for (i = 0; i < WINDOW_NUM_ROWS; i++) begin
			for (j = 0; j < WINDOW_NUM_COLS - 1; j++) begin
				out_window[i][j] = out_window[i][j+1];
			end
			
			out_window[i][WINDOW_NUM_COLS-1] = row_taps[WINDOW_NUM_ROWS-1-i];
		end
	end
end

endmodule
