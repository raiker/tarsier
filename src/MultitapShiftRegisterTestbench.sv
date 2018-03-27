/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps
module MultitapShiftRegisterTestbench();

logic clk, reset;
logic [15:0] width;
logic in_valid;
logic [7:0] in;
logic [7:0] out [3];

MultitapShiftRegister #(
	.DATA_BITS(8),
	.MAX_TAP_SPACING(16),
	.NUM_TAPS(3),
	.COORD_BITS(8)
) mtsr (
	.clk(clk),
	.reset(reset),
	.r_tap_spacing(width),
	.in_valid(in_valid),
	.in_data(in),
	.out_data(out)
);

int cursor;
int num_errors;

initial begin
	$display("Testing MultitapShiftRegister");
	cursor = -2;
	num_errors = 0;
	clk = 0;
end

always begin
	#5;
	clk = 1;
	#5;
	clk = 0;
end

assign in = cursor[7:0];
assign in_valid = cursor >= 0;

always_comb begin
	width = 'x;
	reset = 0;

	if (cursor == -1) begin
		width = 6;
		reset = 1;
	end else if (cursor == 29) begin
		width = 15;
		reset = 1;
	end
end

always @(posedge clk) begin
	if (cursor >= 6) begin
		if (out[0] !== (cursor - 6)) begin
			num_errors++;
		end
	end
	
	if (cursor >= 12) begin
		if (out[1] !== (cursor - 12)) begin
			num_errors++;
		end
	end
	
	if (cursor >= 18) begin
		if (out[2] !== (cursor - 18)) begin
			num_errors++;
		end
	end
	
	if (cursor == 20) begin
		$display("Num errors: %d", num_errors);
	end
	
	cursor++;
end
endmodule
