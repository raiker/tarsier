/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module YMomentTestbench();

parameter LUMA_BITS = 8;
parameter WINDOW_SIZE_X = 7;
parameter WINDOW_SIZE_Y = 5;
localparam HALF_HEIGHT = WINDOW_SIZE_Y / 2;
localparam MOMENT_BITS = $clog2(HALF_HEIGHT * (HALF_HEIGHT+1) * WINDOW_SIZE_X / 2) + LUMA_BITS + 1;

localparam REF_IMAGE_WIDTH = 26;

localparam logic [LUMA_BITS-1:0] REF_IMAGE [REF_IMAGE_WIDTH * WINDOW_SIZE_Y] = '{
	//                   *****                       *****                       *****
	8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'hff, 8'h08, 8'h01, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h08, 8'h00, 8'h00, 8'h00, 8'h07, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h05, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'h04, 8'h00, 8'h02, 8'h04, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h04, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00 
};

localparam RESULT_DELAY = 14;
localparam logic signed [MOMENT_BITS-1:0] REF_YMOMENTS [17] = '{
	-64,
	-64,
	-60,
	-54,
	-36,
	-32,
	-14,
	2,
	6,
	3,
	-762,
	-1535,
	-2292,
	-3061,
	-3826,
	-4593,
	-5355
};

localparam NUM_INVALID_COLS = 3;
localparam int INVALID_COLS[NUM_INVALID_COLS] = '{3, 7, 11};

logic clk;
logic in_valid;
logic in_reset;
logic [LUMA_BITS-1:0] in_col [WINDOW_SIZE_Y]; //incoming column of pixels
logic [LUMA_BITS-1:0] in_peek_col [WINDOW_SIZE_Y]; //incoming column of pixels
integer num_errors;
integer read_head, peek_head;
logic signed [MOMENT_BITS-1:0] out_ymoment;
logic out_valid;

YMoment #(
	.LUMA_BITS(LUMA_BITS),
	.WINDOW_SIZE_X(WINDOW_SIZE_X),
	.WINDOW_SIZE_Y(WINDOW_SIZE_Y)
) ymoment_mod (
	.clk(clk),
	.in_reset(in_reset),
	.in_valid(in_valid),
	.in_column(in_col),
	.in_peek_column(in_peek_col),
	.out_ymoment(out_ymoment),
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
		in_peek_col[i] = REF_IMAGE[i * REF_IMAGE_WIDTH + peek_head];
	end
	
	in_valid = is_column_valid(read_head);

	in_reset = read_head == 0;//read_head < WINDOW_SIZE_X;
end

always @(posedge clk) begin
	int i;
	
	if (read_head >= 9) begin
		if (out_ymoment != REF_YMOMENTS[read_head - RESULT_DELAY]) begin
			num_errors++;
			$display("Error at t=%d", read_head);
		end
	end
	read_head = read_head + 1;
	
	peek_head = read_head;
	i = WINDOW_SIZE_X;
	
	while (i != 0 && peek_head > -1) begin
		peek_head = peek_head - 1;
		if (is_column_valid(peek_head)) i--;
	end
end

function is_column_valid;
	input integer x;
	bit valid;
	
	begin
		valid = 1;
		
		for (int i = 0; i < NUM_INVALID_COLS; i++) begin
			if (x == INVALID_COLS[i]) valid = 0;
		end
		
		return valid;
	end
endfunction

endmodule
