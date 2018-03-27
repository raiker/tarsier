/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module XMoment(clk, in_reset, in_valid, in_column, out_xmoment, out_valid);

parameter LUMA_BITS = 8;
parameter WINDOW_SIZE_X = 37; //should both be odd
parameter WINDOW_SIZE_Y = 37;

localparam ADDER_TREE_DELAY = $clog2(WINDOW_SIZE_Y);
localparam COLUMN_SUM_BITS = $clog2(WINDOW_SIZE_Y) + LUMA_BITS;
localparam PATCH_SUM_BITS = $clog2(WINDOW_SIZE_X * WINDOW_SIZE_Y) + LUMA_BITS;
localparam HALF_WIDTH = WINDOW_SIZE_X / 2;
localparam COL_MUL_BITS = $clog2((HALF_WIDTH+1) * WINDOW_SIZE_Y) + LUMA_BITS;
localparam MOMENT_BITS = $clog2(HALF_WIDTH * (HALF_WIDTH+1) * WINDOW_SIZE_Y / 2) + LUMA_BITS + 1;

localparam DATA_DELAY = ADDER_TREE_DELAY + 4;
localparam VALID_DELAY = DATA_DELAY + WINDOW_SIZE_X - 1;

localparam RESET_CTR_BITS = $clog2(WINDOW_SIZE_X+1);
localparam FIFO_VALID_CTR_BITS = $clog2(VALID_DELAY);

input clk;
input in_reset;
input in_valid;
input [LUMA_BITS-1:0] in_column [WINDOW_SIZE_Y];

output signed [MOMENT_BITS-1:0] out_xmoment;
output out_valid;

logic [COLUMN_SUM_BITS-1:0] shiftreg_input;
logic shiftreg_wr_en;
logic [FIFO_VALID_CTR_BITS-1:0] fifo_valid_ctr;

wire [COLUMN_SUM_BITS-1:0] incoming_column_sum_0, outgoing_column_sum_0;

logic signed [PATCH_SUM_BITS-1:0] patch_diff_1;
logic [COL_MUL_BITS-1:0] a_1, b_1;

logic [COL_MUL_BITS:0] ab_2;
logic [PATCH_SUM_BITS-1:0] patch_sum_2;

logic [PATCH_SUM_BITS-1:0] patch_sum_3;

logic signed [MOMENT_BITS-1:0] xmoment_diff_4;

logic signed [MOMENT_BITS-1:0] xmoment_5;

UnsignedAdderTreePipelined #(
	.DATA_WIDTH(LUMA_BITS),
	.LENGTH(WINDOW_SIZE_Y),
	.DELAY_STAGES(ADDER_TREE_DELAY)
) incoming_column_sum_tree (
	.clk(clk),
	.reset(in_reset),
	.in_advance(in_valid),
	.in_addends(in_column),
	.out_sum(incoming_column_sum_0)
);

ShiftRegister #(
	.DATA_BITS(COLUMN_SUM_BITS),
	.LENGTH(WINDOW_SIZE_X)
) column_sum_shiftreg (
	.clk(clk),
	.reset(in_reset),
	.wr_en(shiftreg_wr_en),
	.in(shiftreg_input),
	.out(outgoing_column_sum_0)
);

assign shiftreg_wr_en = in_valid && !in_reset;
assign shiftreg_input = incoming_column_sum_0;
assign out_valid = fifo_valid_ctr == 0;
assign out_xmoment = xmoment_5;

always_ff @(posedge clk) begin
	if (in_reset) begin
		if (in_valid) begin
			fifo_valid_ctr <= VALID_DELAY - 1;
		end else begin
			fifo_valid_ctr <= VALID_DELAY;
		end
		patch_diff_1 <= 0;
		a_1 <= 0;
		b_1 <= 0;
		ab_2 <= 0;
		patch_sum_2 <= 0;
		patch_sum_3 <= 0;
		xmoment_diff_4 <= 0;
		xmoment_5 <= 0;
	end else if (in_valid) begin
		if (fifo_valid_ctr != 0) begin
			fifo_valid_ctr <= fifo_valid_ctr - 1;
		end
		
		a_1 <= incoming_column_sum_0 * (HALF_WIDTH);
		b_1 <= outgoing_column_sum_0 * (HALF_WIDTH + 1);
		patch_diff_1 <= incoming_column_sum_0 - outgoing_column_sum_0;
		
		ab_2 <= a_1 + b_1;
		patch_sum_2 <= patch_sum_2 + patch_diff_1;
		
		patch_sum_3 <= patch_sum_2;
		
		xmoment_diff_4 <= ab_2 - patch_sum_3;
		
		xmoment_5 <= xmoment_5 + xmoment_diff_4;
	end
end

endmodule
