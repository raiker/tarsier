/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module UnsignedAdderTreePipelined(clk, reset, in_addends, in_advance, out_sum);

parameter DATA_WIDTH;
parameter LENGTH;
parameter DELAY_STAGES = $clog2(LENGTH);

localparam OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH);
localparam LENGTH_A = LENGTH / 2;
localparam LENGTH_B = LENGTH - LENGTH_A;
localparam OUT_WIDTH_A = DATA_WIDTH + $clog2(LENGTH_A);
localparam OUT_WIDTH_B = DATA_WIDTH + $clog2(LENGTH_B);

input clk;
input reset;
input in_advance; //if 0, the registers do not load their values, so the tree does not advance
input [DATA_WIDTH-1:0] in_addends [LENGTH];
output logic [OUT_WIDTH-1:0] out_sum;

generate
	if (LENGTH == 1) begin
		if (DELAY_STAGES > 0) begin
			//single element, but with some delays left
			logic [DATA_WIDTH-1:0] delay_fifo [DELAY_STAGES];
			assign out_sum = delay_fifo[0];
			
			always_ff @(posedge clk) begin
				if (reset) begin
					for (int i = 0; i < DELAY_STAGES - 1; i++) begin
						delay_fifo[i] <= '0;
					end
					delay_fifo[DELAY_STAGES-1] <= in_advance ? in_addends[0] : '0;
				end else if (in_advance) begin
					delay_fifo[DELAY_STAGES-1] <= in_addends[0];
					
					for (int i = 0; i < DELAY_STAGES - 1; i++) begin
						delay_fifo[i] <= delay_fifo[i+1];
					end
				end
			end
		end else begin
			//single element, no delays
			assign out_sum = in_addends[0];
		end
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
		
		if (DELAY_STAGES > 0) begin
			//divide set into two chunks, conquer
			UnsignedAdderTreePipelined #(
				.DATA_WIDTH(DATA_WIDTH),
				.LENGTH(LENGTH_A),
				.DELAY_STAGES(DELAY_STAGES-1)
			) subtree_a (
				.clk(clk),
				.reset(reset),
				.in_advance(in_advance),
				.in_addends(addends_a),
				.out_sum(sum_a)
			);
			
			UnsignedAdderTreePipelined #(
				.DATA_WIDTH(DATA_WIDTH),
				.LENGTH(LENGTH_B),
				.DELAY_STAGES(DELAY_STAGES-1)
			) subtree_b (
				.clk(clk),
				.reset(reset),
				.in_advance(in_advance),
				.in_addends(addends_b),
				.out_sum(sum_b)
			);
			
			always_ff @(posedge clk) begin
				if (DELAY_STAGES == 1) begin
					if (in_advance) begin
						out_sum <= sum_a + sum_b;
					end else if (reset) begin
						out_sum = '0;
					end
				end else begin
					if (reset) begin
						out_sum <= '0;
					end else if (in_advance) begin
						out_sum <= sum_a + sum_b;
					end
				end
			end
		end else begin
			//no delays left
			UnsignedAdderTreePipelined #(
				.DATA_WIDTH(DATA_WIDTH),
				.LENGTH(LENGTH_A),
				.DELAY_STAGES(0)
			) subtree_a (
				.clk(clk),
				.reset(reset),
				.in_advance(in_advance),
				.in_addends(addends_a),
				.out_sum(sum_a)
			);
			
			UnsignedAdderTreePipelined #(
				.DATA_WIDTH(DATA_WIDTH),
				.LENGTH(LENGTH_B),
				.DELAY_STAGES(0)
			) subtree_b (
				.clk(clk),
				.reset(reset),
				.in_advance(in_advance),
				.in_addends(addends_b),
				.out_sum(sum_b)
			);
			
			assign out_sum = sum_a + sum_b;
		end
	end
endgenerate

endmodule
