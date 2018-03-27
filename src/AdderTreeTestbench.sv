/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module AdderTreeTestbench();

localparam DATA_WIDTH = 5;
localparam LENGTH = 9;
localparam OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH);

wire signed [OUT_WIDTH-1:0] sum;

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

AdderTree #(
	.DATA_WIDTH(DATA_WIDTH),
	.LENGTH(LENGTH)
) tree_mod (
	.in_addends(input_data),
	.out_sum(sum)
);

initial begin
	$display("Testing AdderTree");
	
	#10
	if (sum != 5) begin
		$display("Validation failure");
	end else begin
		$display("Validation success");
	end
end

endmodule
