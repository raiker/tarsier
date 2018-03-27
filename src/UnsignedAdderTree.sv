/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module UnsignedAdderTree(in_addends, out_sum);

parameter DATA_WIDTH = 8;
parameter LENGTH = 42;

localparam OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH);
localparam LENGTH_A = LENGTH / 2;
localparam LENGTH_B = LENGTH - LENGTH_A;
localparam OUT_WIDTH_A = DATA_WIDTH + $clog2(LENGTH_A);
localparam OUT_WIDTH_B = DATA_WIDTH + $clog2(LENGTH_B);

input [DATA_WIDTH-1:0] in_addends [LENGTH];
output [OUT_WIDTH-1:0] out_sum;

generate
	if (LENGTH == 1) begin
		assign out_sum = in_addends[0];
	end else begin
		wire [OUT_WIDTH_A-1:0] sum_a;
		wire [OUT_WIDTH_B-1:0] sum_b;
		
		logic [DATA_WIDTH-1:0] addends_a [LENGTH_A];
		logic [DATA_WIDTH-1:0] addends_b [LENGTH_B];
		
		always_comb begin
			for (int i = 0; i < LENGTH_A; i++) begin
				addends_a[i] = in_addends[i];
			end
			
			for (int i = 0; i < LENGTH_B; i++) begin
				addends_b[i] = in_addends[i + LENGTH_A];
			end
		end
		
		//divide set into two chunks, conquer
		UnsignedAdderTree #(
			.DATA_WIDTH(DATA_WIDTH),
			.LENGTH(LENGTH_A)
		) subtree_a (
			.in_addends(addends_a),
			.out_sum(sum_a)
		);
		
		UnsignedAdderTree #(
			.DATA_WIDTH(DATA_WIDTH),
			.LENGTH(LENGTH_B)
		) subtree_b (
			.in_addends(addends_b),
			.out_sum(sum_b)
		);
		
		assign out_sum = sum_a + sum_b;
	end
endgenerate

endmodule
