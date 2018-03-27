/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/1ns

module ScalerRateTestbench();

parameter INPUT_WIDTH = 1226;
parameter INPUT_HEIGHT = 370;

localparam OUTPUT_WIDTH = (INPUT_WIDTH - 1) * 4 / 5 + 1;
localparam OUTPUT_HEIGHT = (INPUT_HEIGHT - 1) * 4 / 5 + 1;

logic clk, reset;
logic in_valid;
logic [7:0] in_pixel;
integer in_x, in_y;
integer predicted_x, predicted_y;
logic out_valid;
logic [7:0] out_pixel;
logic [15:0] out_x, out_y;

initial begin
	in_x = -2;
	in_y = 0;
	predicted_x = 0;
	predicted_y = 0;
end

always begin
	#5;
	clk = 0;
	#5;
	clk = 1;
end

assign reset = in_x == -1 && in_y == 0;

Scale_4_5_Bilinear #(
	.LUMA_BITS(8),
	.MAX_INPUT_WIDTH(2048),
	.MAX_INPUT_HEIGHT(2048),
	.COORD_BITS(16)
) scaler (
	.clk(clk),
	.reset(reset),
	.r_width(INPUT_WIDTH),
	.in_valid(in_valid),
	.in_pixel(in_pixel),
	.in_x(in_x[15:0]),
	.in_y(in_y[15:0]),
	.out_valid(out_valid),
	.out_pixel(out_pixel),
	.out_x(out_x),
	.out_y(out_y)
);

always @(posedge clk) begin
	if (in_x == INPUT_WIDTH - 1) begin
		in_y <= in_y + 1;
		in_x <= 0;
	end else begin
		in_x <= in_x + 1;
	end

	if (out_valid) begin
		if (predicted_x == OUTPUT_WIDTH - 1) begin
			predicted_y <= predicted_y + 1;
			predicted_x <= 0;
		end else begin
			predicted_x <= predicted_x + 1;
		end
	end
end

always @(posedge clk) begin
	if (out_valid) begin
		if (out_x != predicted_x || out_y != predicted_y) begin
			$display("Error at (%d, %d) (%d, %d)", out_x, out_y, predicted_x[15:0], predicted_y[15:0]);
		end
	end
end

assign in_valid = in_x >= 0 && in_x < INPUT_WIDTH && in_y >= 0 && in_y < INPUT_HEIGHT;
assign in_pixel = 8'h00;

endmodule