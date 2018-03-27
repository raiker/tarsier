/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module SlowDividerUnsignedTestbench();

parameter DIVIDEND_BITS = 10;
parameter DIVISOR_BITS = 7;

typedef struct {
	logic [DIVIDEND_BITS-1:0] dividend;
	logic [DIVISOR_BITS-1:0] divisor;
	logic [DIVIDEND_BITS-1:0] quotient;
	logic [DIVISOR_BITS-1:0] remainder;
	logic error;
} testcase_t;

parameter NUM_TEST_CASES = 8;
parameter testcase_t TEST_CASES[NUM_TEST_CASES] = '{
	'{100, 0, 'x, 'x, 1},
	'{0, 0, 'x, 'x, 1},
	'{256, 2, 128, 0, 0},
	'{2, 64, 0, 2, 0},
	'{799, 17, 47, 0, 0},
	'{799, 23, 34, 17, 0},
	'{470, 12, 39, 2, 0},
	'{0, 50, 0, 0, 0}
};

integer read_head;
integer num_errors;
logic clk;
logic q_valid, q_bootstrap;
logic [DIVIDEND_BITS-1:0] dividend;
logic [DIVISOR_BITS-1:0] divisor;
logic [DIVIDEND_BITS-1:0] quotient;
logic [DIVISOR_BITS-1:0] remainder;
logic error, output_valid;

initial begin
	read_head = -1;
	q_bootstrap = 1;
	num_errors = 0;
	clk = 0;
	#5;
end

always begin
	#5 clk = ~clk;
end

assign dividend = TEST_CASES[read_head+1].dividend;
assign divisor = TEST_CASES[read_head+1].divisor;

assign q_valid = output_valid || q_bootstrap;

SlowDividerUnsigned #(
	.DIVIDEND_BITS(DIVIDEND_BITS),
	.DIVISOR_BITS(DIVISOR_BITS)
) divider_mod (
	.clk(clk),
	.in_dividend(dividend),
	.in_divisor(divisor),
	.in_valid(q_valid),
	.out_quotient(quotient),
	.out_remainder(remainder),
	.out_error(error),
	.out_valid(output_valid)
);

always_ff @(posedge clk) begin
	q_bootstrap <= 0;
	if (output_valid && read_head < NUM_TEST_CASES) begin
		if (error != TEST_CASES[read_head].error) begin
			num_errors++;
		end else if (!error && (quotient != TEST_CASES[read_head].quotient || remainder != TEST_CASES[read_head].remainder)) begin
			num_errors++;
		end
	end
	
	if (q_valid) read_head <= read_head + 1;
end

endmodule
