/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module UnsignedAdderTreePipelinedTestbench();

logic clk;
logic reset;
logic advance;
logic [7:0] inputs [5];
logic [10:0] sum;

integer cursor;

UnsignedAdderTreePipelined #(
	.DATA_WIDTH(8),
	.LENGTH(5)
) test_mod (
	.clk(clk),
	.reset(reset),
	.in_addends(inputs),
	.in_advance(advance),
	.out_sum(sum)
);

initial begin
	clk = 1;
	cursor = -1;
end

always begin
	#5 clk = !clk;
end

always_ff @(posedge clk) begin
	if (cursor == 4 || cursor == 11) begin
		if (sum !== 31) begin
			$display("Summation error");
		end else begin
			$display("Validation success");
		end
	end
	cursor++;
end

assign reset = cursor == 0 || cursor == 7;
assign advance = cursor != 2 && cursor != 7;
assign inputs = (cursor == 0 || cursor == 8) ? '{2, 3, 5, 8, 13} : '{'x, 'x, 'x, 'x, 'x};

endmodule
