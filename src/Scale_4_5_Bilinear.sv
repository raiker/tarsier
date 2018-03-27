/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module Scale_4_5_Bilinear(clk, reset, r_width, in_pixel, in_valid, in_x, in_y, out_pixel, out_valid, out_x, out_y);

parameter LUMA_BITS;
parameter MAX_INPUT_WIDTH;
parameter MAX_INPUT_HEIGHT; //not used
parameter COORD_BITS;

localparam MAX_OUTPUT_WIDTH = (MAX_INPUT_WIDTH - 1) * 4 / 5 + 1;
localparam MAX_OUTPUT_HEIGHT = (MAX_INPUT_HEIGHT - 1) * 4 / 5 + 1;

localparam logic [2:0] FACTORS [5][2] = '{
	'{0, 4},
	'{0, 0}, //invalid
	'{3, 1},
	'{2, 2},
	'{1, 3}
};

//necesary because verilog defines 0 * 'x == 'x
function logic [LUMA_BITS-1+9:0] clever_mult;
	input logic [8:0] factor;
	input logic [LUMA_BITS-1:0] value;
	
	begin
		if (factor == 0) begin
			return 0;
		end else begin
			return factor * value;
		end
	end
endfunction

input clk, reset;
input [COORD_BITS-1:0] r_width;
input [LUMA_BITS-1:0] in_pixel;
input in_valid;
input logic [COORD_BITS-1:0] in_x, in_y;

output logic [LUMA_BITS-1:0] out_pixel;
output logic out_valid;
output logic [COORD_BITS-1:0] out_x, out_y;

logic output_pixel;

logic [2:0] x_mod_1;
logic [2:0] y_mod_1;
logic [COORD_BITS-1:0] x_1, x_2, x_3;
logic [COORD_BITS-1:0] y_1, y_2, y_3;
logic valid_1, valid_2, valid_3;
logic [LUMA_BITS-1:0] window_1 [2][2];
logic [LUMA_BITS-1:0] window_2 [2][2];
logic [4:0] factors_2 [2][2];
logic [LUMA_BITS+3:0] weighted_window_3 [2][2];

assign output_pixel = (x_mod_1 != 1) && (y_mod_1 != 1);

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
	.out_window(window_1)
);

always @(posedge clk) begin
	if (in_valid) begin
		if (in_x == 0 && in_y == 0) begin
			x_mod_1 <= 0;
			y_mod_1 <= 0;
			x_1 <= 0;
			y_1 <= 0;
		end else if (in_x == 0) begin
			x_mod_1 <= 0;
			y_mod_1 <= (y_mod_1 == 4) ? 0 : y_mod_1 + 1;
			x_1 <= 0;
			y_1 <= y_1 + (y_mod_1 != 0);
		end else begin
			x_mod_1 <= (x_mod_1 == 4) ? 0 : x_mod_1 + 1;
			x_1 <= x_1 + (x_mod_1 != 0);
		end
		
		//window_1 is set through the SlidingWindow module
	end
	
	if (valid_1) begin
		x_2 <= x_1;
		y_2 <= y_1;
		window_2 <= window_1;
		
		for (int j = 0; j < 2; j++) begin
			for (int i = 0; i < 2; i++) begin
				factors_2[j][i] <= FACTORS[y_mod_1][j] * FACTORS[x_mod_1][i];
			end
		end
	end
	
	if (valid_2) begin
		x_3 <= x_2;
		y_3 <= y_2;
		
		for (int j = 0; j < 2; j++) begin
			for (int i = 0; i < 2; i++) begin
				weighted_window_3[j][i] <= window_2[j][i] * factors_2[j][i];
			end
		end
	end
	
	if (valid_3) begin
		out_x <= x_3;
		out_y <= y_3;
		
		out_pixel <= (
				(weighted_window_3[0][0] + weighted_window_3[0][1]) +
				(weighted_window_3[1][0] + weighted_window_3[1][1])
			) >> 4;
	end

	valid_1 <= in_valid;
	valid_2 <= valid_1 && output_pixel;
	valid_3 <= valid_2;
	out_valid <= valid_3;
end

endmodule
