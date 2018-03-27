/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module XMomentTestbench();

parameter LUMA_BITS = 8;
parameter WINDOW_SIZE_X = 7;
parameter WINDOW_SIZE_Y = 5;
localparam HALF_WIDTH = WINDOW_SIZE_X / 2;
localparam MOMENT_BITS = $clog2(HALF_WIDTH * (HALF_WIDTH+1) * WINDOW_SIZE_Y / 2) + LUMA_BITS + 1;

localparam REF_IMAGE_WIDTH = 26;

localparam logic [LUMA_BITS-1:0] REF_IMAGE [REF_IMAGE_WIDTH * WINDOW_SIZE_Y] = '{
	//                   *****                       *****                       *****
	8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'hff, 8'h08, 8'h01, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'hff, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h08, 8'h00, 8'hff, 8'hff, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h07,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h05, 8'h00, 8'hff, 8'hff, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'h04, 8'hff, 8'hff, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h02, 8'h04,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h04, 8'h00, 8'h00, 8'hff, 8'hff, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
};

localparam RESULT_DELAY = 12;
localparam logic signed [MOMENT_BITS-1:0] REF_XMOMENTS [18] = '{
	//3,
	//8,
	14,
	23,
	30,
	34,
	34,
	9,
	-15,
	-33,
	-28,
	9,
	16,
	3843,
	6375,
	7629,
	3783,
	-47,
	-3837,
	-7650
};

localparam NUM_INVALID_COLS = 3;
localparam int INVALID_COLS[NUM_INVALID_COLS] = '{3, 7, 11};

logic clk;
logic in_valid;
logic in_reset;
logic [LUMA_BITS-1:0] in_col [WINDOW_SIZE_Y]; //incoming column of pixels
integer num_errors;
integer read_head;
logic signed [MOMENT_BITS-1:0] out_xmoment;
logic out_valid;

XMoment #(
	.LUMA_BITS(LUMA_BITS),
	.WINDOW_SIZE_X(WINDOW_SIZE_X),
	.WINDOW_SIZE_Y(WINDOW_SIZE_Y)
) xmoment_mod (
	.clk(clk),
	.in_reset(in_reset),
	.in_valid(in_valid),
	.in_column(in_col),
	.out_xmoment(out_xmoment),
	.out_valid(out_valid)
);

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

initial begin
	read_head = 0;
end

always_comb begin
	for (int i = 0; i < WINDOW_SIZE_Y; i++) begin
		in_col[i] = REF_IMAGE[i * REF_IMAGE_WIDTH + read_head];
	end
	
	in_valid = 1;
	for (int i = 0; i < NUM_INVALID_COLS; i++) begin
		if (read_head == INVALID_COLS[i]) in_valid = 0;
	end
	if (read_head >= REF_IMAGE_WIDTH) in_valid = 0;

	in_reset = read_head == 0;
end

always @(posedge clk) begin
	if (in_valid && out_valid && out_xmoment != REF_XMOMENTS[read_head - RESULT_DELAY]) begin
		num_errors++;
		$display("Error at t=%d", read_head);
	end
	read_head <= read_head + 1;
end

endmodule
