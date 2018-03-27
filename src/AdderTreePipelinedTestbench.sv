/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module AdderTreePipelinedTestbench();

localparam DATA_WIDTH = 5;
localparam LENGTH = 9;
localparam OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH);
localparam EXPECTED_DELAY = $clog2(LENGTH);

wire signed [OUT_WIDTH-1:0] sum;
logic signed [DATA_WIDTH-1:0] addends [LENGTH];

logic clk;
integer cursor;

logic signed [DATA_WIDTH-1:0] input_data [LENGTH] = '{
	1,
	-2,
	3,
	-4,
	5,
	-6,
	7,
	-8,
	9
};

AdderTreePipelined #(
	.DATA_WIDTH(DATA_WIDTH),
	.LENGTH(LENGTH)
) tree_mod (
	.clk(clk),
	.reset(1'b0),
	.in_advance(1'b1),
	.in_addends(addends),
	.out_sum(sum)
);

initial begin
	$display("Testing AdderTree");
	cursor = 0;
end

always begin
	clk = 0; #5;
	clk = 1; #5;
end

always_comb begin
	if (cursor == 0) begin
		addends = input_data;
	end else begin
		for (int i = 0; i < LENGTH; i++) begin
			addends[i] = 'x;
		end
	end
end

always @(posedge clk) begin
	cursor <= cursor + 1;
	
	if (cursor == EXPECTED_DELAY) begin
		if (sum != 5) begin
			$display("Validation failure");
		end else begin
			$display("Validation success");
		end
	end
end

endmodule
