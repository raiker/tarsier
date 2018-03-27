/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module DimensionCalculator_4_5_Testbench();

logic clk;
logic in_progress;
logic in_valid;
logic out_valid;

logic [15:0] cursor, out;

DimensionCalculator_4_5 #(
	.COORD_BITS(16)
) calc (
	.clk(clk),
	.in_valid(in_valid),
	.in_dim(cursor),
	.out_valid(out_valid),
	.out_dim(out)
);

initial begin
	cursor = 1;
	in_progress = 0;
	clk = 0;
end

always begin
	#5 clk = !clk;
end

assign in_valid = !in_progress;

always @(posedge clk) begin
	if (out_valid && in_progress) begin
		automatic integer comparison_val = (cursor - 1) * 4 / 5 + 1;
		if (out != comparison_val) begin
			$display("Assertion failed for %d", cursor);
		end

		in_progress <= 0;
		cursor++;
	end else if (in_valid) begin
		in_progress <= 1;
	end
end

endmodule