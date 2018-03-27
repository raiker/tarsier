/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//peek column is WINDOW_SIZE_X columns delayed in_column
module YMoment(clk, in_reset, in_valid, in_column, in_peek_column, out_ymoment, out_valid);

parameter LUMA_BITS;
parameter WINDOW_SIZE_X; //should both be odd
parameter WINDOW_SIZE_Y;

localparam ROW_SUM_BITS = $clog2(WINDOW_SIZE_X) + LUMA_BITS;
localparam HALF_HEIGHT = WINDOW_SIZE_Y / 2;
localparam PRODUCT_BITS = $clog2(WINDOW_SIZE_X * HALF_HEIGHT) + LUMA_BITS + 1;
localparam ADDER_TREE_DELAY = $clog2(WINDOW_SIZE_Y);
localparam ADDER_TREE_OUTPUT_BITS = $clog2(WINDOW_SIZE_Y) + PRODUCT_BITS;
localparam MOMENT_BITS = $clog2(HALF_HEIGHT * (HALF_HEIGHT+1) * WINDOW_SIZE_X / 2) + LUMA_BITS + 1;

localparam ROW_FLUSH_CTR_BITS = $clog2(WINDOW_SIZE_X+1);
localparam VALID_CTR_BITS = $clog2(WINDOW_SIZE_X+ADDER_TREE_DELAY+1);

input clk;
input in_reset;
input in_valid;
input [LUMA_BITS-1:0] in_column [WINDOW_SIZE_Y];
input [LUMA_BITS-1:0] in_peek_column [WINDOW_SIZE_Y];

output signed [MOMENT_BITS-1:0] out_ymoment;
output out_valid;

logic [ROW_SUM_BITS-1:0] row_sums [WINDOW_SIZE_Y];
logic signed [PRODUCT_BITS-1:0] scaled_row_sums_1 [WINDOW_SIZE_Y];
logic signed [PRODUCT_BITS-1:0] scaled_row_sums_2 [WINDOW_SIZE_Y];
logic signed[ADDER_TREE_OUTPUT_BITS-1:0] adder_tree_output;

logic [ROW_FLUSH_CTR_BITS-1:0] row_flush_ctr;
logic [VALID_CTR_BITS-1:0] valid_ctr;

always_ff @(posedge clk) begin
	if (in_reset) begin
		row_flush_ctr <= in_valid ? WINDOW_SIZE_X - 1 : WINDOW_SIZE_X;
		valid_ctr <= in_valid ? WINDOW_SIZE_X + ADDER_TREE_DELAY : WINDOW_SIZE_X + ADDER_TREE_DELAY + 1;
	end else if (in_valid) begin
		if (row_flush_ctr != 0) begin
			row_flush_ctr <= row_flush_ctr - 1;
		end
		if (valid_ctr != 0) begin
			valid_ctr <= valid_ctr - 1;
		end
	end
	
	for (int i = 0; i < WINDOW_SIZE_Y; i++) begin
		if (in_reset) begin
			row_sums[i] <= in_valid ? in_column[i] : 0;
		end else if (in_valid) begin
			if (row_flush_ctr != 0) begin
				//if we're currently refilling after a flush, we don't subtract the peek column
				row_sums[i] <= row_sums[i] + in_column[i];
			end else begin
				row_sums[i] <= row_sums[i] + in_column[i] - in_peek_column[i];
			end
			
			scaled_row_sums_2 <= scaled_row_sums_1;
		end
	end
end

always_comb begin
	for (int i = 0; i < WINDOW_SIZE_Y; i++) begin
		automatic int factor = i - HALF_HEIGHT;
		
		scaled_row_sums_1[i] = $signed({1'b0, row_sums[i]}) * factor;
	end
end

AdderTreePipelined #(
	.DATA_WIDTH(PRODUCT_BITS),
	.LENGTH(WINDOW_SIZE_Y),
	.DELAY_STAGES(ADDER_TREE_DELAY)
) final_sum (
	.clk(clk),
	.reset(in_reset),
	.in_advance(in_valid),
	.in_addends(scaled_row_sums_2),
	.out_sum(adder_tree_output)
);

assign out_ymoment = adder_tree_output[MOMENT_BITS-1:0]; //guaranteed to be sufficient
assign out_valid = valid_ctr == 0;

endmodule
