/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module SectorSelTestbench();

localparam NUM_TEST_CASES = 71;
localparam DELAY = 5;
localparam BIT_DEPTH = 20;

typedef struct {
	bit [BIT_DEPTH-1:0] x, y;
	bit [5:0] sector;
	bit is_nan;
} test_cases_t;

localparam test_cases_t TEST_CASES[NUM_TEST_CASES] = '{
	'{0, 0, 6'bxxxxxx, 1'b1},
	'{0, -200, 0, 1'b0},
	'{20, -199, 1, 1'b0},
	'{39, -196, 2, 1'b0},
	'{58, -191, 3, 1'b0},
	'{77, -185, 4, 1'b0},
	'{94, -176, 5, 1'b0},
	'{111, -166, 6, 1'b0},
	'{127, -155, 7, 1'b0},
	'{141, -141, 8, 1'b0},
	'{155, -127, 9, 1'b0},
	'{166, -111, 10, 1'b0},
	'{176, -94, 11, 1'b0},
	'{185, -77, 12, 1'b0},
	'{191, -58, 13, 1'b0},
	'{196, -39, 14, 1'b0},
	'{199, -20, 15, 1'b0},
	'{200, 0, 16, 1'b0},
	'{199, 20, 17, 1'b0},
	'{196, 39, 18, 1'b0},
	'{191, 58, 19, 1'b0},
	'{185, 77, 20, 1'b0},
	'{176, 94, 21, 1'b0},
	'{166, 111, 22, 1'b0},
	'{155, 127, 23, 1'b0},
	'{141, 141, 24, 1'b0},
	'{127, 155, 25, 1'b0},
	'{111, 166, 26, 1'b0},
	'{94, 176, 27, 1'b0},
	'{77, 185, 28, 1'b0},
	'{58, 191, 29, 1'b0},
	'{39, 196, 30, 1'b0},
	'{20, 199, 31, 1'b0},
	'{0, 200, 32, 1'b0},
	'{-20, 199, 33, 1'b0},
	'{-39, 196, 34, 1'b0},
	'{-58, 191, 35, 1'b0},
	'{-77, 185, 36, 1'b0},
	'{-94, 176, 37, 1'b0},
	'{-111, 166, 38, 1'b0},
	'{-127, 155, 39, 1'b0},
	'{-141, 141, 40, 1'b0},
	'{-155, 127, 41, 1'b0},
	'{-166, 111, 42, 1'b0},
	'{-176, 94, 43, 1'b0},
	'{-185, 77, 44, 1'b0},
	'{-191, 58, 45, 1'b0},
	'{-196, 39, 46, 1'b0},
	'{-199, 20, 47, 1'b0},
	'{-200, 0, 48, 1'b0},
	'{-199, -20, 49, 1'b0},
	'{-196, -39, 50, 1'b0},
	'{-191, -58, 51, 1'b0},
	'{-185, -77, 52, 1'b0},
	'{-176, -94, 53, 1'b0},
	'{-166, -111, 54, 1'b0},
	'{-155, -127, 55, 1'b0},
	'{-141, -141, 56, 1'b0},
	'{-127, -155, 57, 1'b0},
	'{-111, -166, 58, 1'b0},
	'{-94, -176, 59, 1'b0},
	'{-77, -185, 60, 1'b0},
	'{-58, -191, 61, 1'b0},
	'{-39, -196, 62, 1'b0},
	'{-20, -199, 63, 1'b0},
	'{-174412, -506516, 61, 1'b0},
	'{3038, 122934, 32, 1'b0},
	'{524287, 524287, 24, 1'b0},
	'{524287, -524287, 8, 1'b0},
	'{-524287, 524287, 40, 1'b0},
	'{-524287, -524287, 56, 1'b0}
};

logic clk;
integer input_cursor, output_cursor;
bit [BIT_DEPTH-1:0] x, y;
wire [5:0] sector;
wire is_nan;

assign output_cursor = input_cursor - DELAY;

SectorSel #(
	.INPUT_BITS(BIT_DEPTH)
) ss_mod (
	.clk(clk),
	.in_valid(1),
	.in_x(x),
	.in_y(y),
	.out_sector(sector),
	.out_nan(is_nan)
);

int num_failures;

initial begin
	$display("Testing SectorSel");
	
	num_failures = 0;
	input_cursor = 0;
end

always begin
	clk = 0; #5;
	clk = 1; #5;
end

always_comb begin
	x = TEST_CASES[input_cursor].x;
	y = TEST_CASES[input_cursor].y;
end

always @(posedge clk) begin
	input_cursor <= input_cursor + 1;
	if (output_cursor >= 0 && output_cursor < NUM_TEST_CASES &&
		(is_nan !== TEST_CASES[output_cursor].is_nan || (!is_nan && sector !== TEST_CASES[output_cursor].sector))) begin
		num_failures++;
		$display("Error at t=%d", output_cursor);
	end
end

endmodule
