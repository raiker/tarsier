/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1 ns / 1 ns
module ORBWindowTestbench();

parameter LUMA_BITS = 8;
parameter WINDOW_SIZE_X = 7;
parameter WINDOW_SIZE_Y = 5;
parameter COORD_BITS = 3;
parameter MOMENT_BITS = 16;

parameter REF_IMAGE_WIDTH = 22;

parameter logic [LUMA_BITS-1:0] REF_IMAGE [REF_IMAGE_WIDTH * WINDOW_SIZE_Y] = '{
	//                   *****                       *****                       *****
	8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'hff, 8'h08, 8'h01, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h08, 8'h00, 8'h00, 8'h00, 8'h07, 8'h00, 8'h00, 8'h00, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h05, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'h04, 8'h00, 8'h02, 8'h04, 8'h00, 8'h00, 8'h00, 
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h00, 8'h00, 8'hff, 8'h00, 8'h04, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
};

parameter NUM_INVALID_COLS = 3;
parameter int INVALID_COLS[NUM_INVALID_COLS] = '{3, 7, 11};

typedef struct {
	integer x, y;
	logic [LUMA_BITS-1:0] val;
} sample_t;

parameter NUM_SAMPLE_PAIRS = 3;
parameter sample_t SAMPLES[NUM_SAMPLE_PAIRS][2] = '{
	'{'{ 0,  0, 8'h00}, '{ 3, -1, 8'h07}},
	'{'{-2,  2, 8'h04}, '{ 0, -2, 8'h00}},
	'{'{-1, -1, 8'h08}, '{-2,  2, 8'h04}}
};

typedef struct {
	logic signed [MOMENT_BITS-1:0] xmoment, ymoment;
} moment_t;

parameter NUM_TEST_MOMENTS = 49;
parameter moment_t TEST_MOMENTS[NUM_TEST_MOMENTS] = '{
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x}, //10
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{34, -64},
	'{9, -64},
	'{-15, -60},
	'{-33, -54},
	'{-28, -36}, //20
	'{9, -32},
	'{16, -14},
	'{18, 2},
	'{6, 6},
	'{16, 3},
	'{16, 3},
	'{16, 3},
	'{16, 3},
	'{'x, 'x},
	'{'x, 'x}, //30
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x},
	'{'x, 'x}, //40
	'{34, -64},
	'{9, -64},
	'{-15, -60},
	'{-33, -54},
	'{-28, -36},
	'{9, -32},
	'{16, -14},
	'{18, 2}
};

parameter T_LOAD_START = 0;
parameter T_SAMPLE_START = REF_IMAGE_WIDTH;
parameter T_RELOAD_START = T_SAMPLE_START + NUM_INVALID_COLS;

parameter T_LOAD_PATCH_VALID = 16;
parameter T_RELOAD_PATCH_VALID = T_RELOAD_START + T_LOAD_PATCH_VALID;

logic clk;
logic in_valid;
logic [LUMA_BITS-1:0] in_col [WINDOW_SIZE_Y]; //incoming column of pixels
logic signed [COORD_BITS-1:0] in_coord1 [2]; //(x,y) coordinate of sample 1
logic signed [COORD_BITS-1:0] in_coord2 [2]; //(x,y) coordinate of sample 2
logic in_flush; //1 = begin flush cycle, 0 = nothing
logic in_mode; //1 = write (sampling hardware disabled, write 1 column per clock, update moments)
               //0 = read (sampling hardware enabled, column input disabled, moments stable)

logic out_patch_valid; //if the patch is valid (at least WINDOW_SIZE_X clocks since the last flush/transition to write mode)
logic [LUMA_BITS-1:0] out_pix1, out_pix2; //pixel values of samples (only valid in read mode)
logic [MOMENT_BITS-1:0] out_xmoment, out_ymoment; //output moment values (valid when patch is valid)

ORBWindow #(
	.LUMA_BITS(LUMA_BITS),
	.WINDOW_SIZE_X(WINDOW_SIZE_X),
	.WINDOW_SIZE_Y(WINDOW_SIZE_Y),
	.COORD_BITS(3),
	.MOMENT_BITS(MOMENT_BITS)
) orb_window_mod (
	.clk(clk),
	.in_valid(in_valid),
	.in_col(in_col),
	.in_coord1(in_coord1),
	.in_coord2(in_coord2),
	.in_flush(in_flush),
	.in_mode(in_mode),
	.out_patch_valid(out_patch_valid),
	.out_pix1(out_pix1),
	.out_pix2(out_pix2),
	.out_xmoment(out_xmoment),
	.out_ymoment(out_ymoment)
);

integer num_errors;
integer read_head;
integer sample_head;
integer state;
logic is_error;

always_comb begin
	for (int i = 0; i < WINDOW_SIZE_Y; i++) begin
		in_col[i] = REF_IMAGE[i * REF_IMAGE_WIDTH + read_head];
	end
end

initial begin
	$display("Testing ORBWindow");
	num_errors = 0;
	clk = 0;
	state = -1;
	#10;
end

always begin
	clk = 1;
	#5;
	clk = 0;
	#5;
end

always @(posedge clk) begin
	state <= state + 1;
	num_errors += is_error;
	if (is_error) begin
		$display("Error at t=%d", state);
	end
end

always_comb begin
	is_error = 0;
	
	if (state < T_SAMPLE_START) begin
		in_mode = 1;
		read_head = state;
		if ((state >= T_LOAD_PATCH_VALID) != out_patch_valid) is_error = 1;
	end else if (state < T_RELOAD_START) begin
		in_mode = 0;
		read_head = 'x;
	end else begin
		in_mode = 1;
		read_head = state - T_RELOAD_START;
		if (state < T_RELOAD_PATCH_VALID) begin
			if (out_patch_valid != 0) is_error = 1;
		end else begin
			if (out_patch_valid != 1) is_error = 1;
		end
	end
	
	in_valid = 1;
	for (int i = 0; i < NUM_INVALID_COLS; i++) begin
		if (read_head == INVALID_COLS[i]) in_valid = 0;
	end

	in_flush = state == 0;
	
	if (state < NUM_TEST_MOMENTS && out_patch_valid) begin
		if (out_xmoment !== TEST_MOMENTS[state].xmoment) is_error = 1;
		if (out_ymoment !== TEST_MOMENTS[state].ymoment) is_error = 1;
	end
	
	sample_head = state - REF_IMAGE_WIDTH;
	in_coord1 = '{SAMPLES[sample_head][0].x, SAMPLES[sample_head][0].y};
	in_coord2 = '{SAMPLES[sample_head][1].x, SAMPLES[sample_head][1].y};
	
	if (state >= REF_IMAGE_WIDTH && state < REF_IMAGE_WIDTH + NUM_SAMPLE_PAIRS) begin
		if (out_pix1 !== SAMPLES[sample_head][0].val) is_error = 1;
		if (out_pix2 !== SAMPLES[sample_head][1].val) is_error = 1;
	end
end

endmodule
