/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//performs the calculation y=(x-1)*4/5+1, using integer division
//asserting in_valid throws away any results currently being computed
module DimensionCalculator_4_5(clk, in_valid, in_dim, out_valid, out_dim);

parameter COORD_BITS = 16;

input clk;
input in_valid;
input [COORD_BITS-1:0] in_dim;

output out_valid;
output [COORD_BITS-1:0] out_dim;

logic [COORD_BITS+1:0] quotient;
logic [2:0] remainder; //ignored
logic error; //can never occur

assign out_dim = quotient + 1;

SlowDividerUnsigned #(
	.DIVIDEND_BITS(COORD_BITS+2),
	.DIVISOR_BITS(3)
) divider (
	.clk(clk),
	.in_dividend((in_dim-1) << 2),
	.in_divisor(5),
	.in_valid(in_valid),
	.out_quotient(quotient),
	.out_remainder(remainder),
	.out_error(error),
	.out_valid(out_valid)
);

endmodule
