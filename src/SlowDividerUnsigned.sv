/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module SlowDividerUnsigned(clk, in_dividend, in_divisor, in_valid, out_quotient, out_remainder, out_error, out_valid);

parameter DIVIDEND_BITS = 5;
parameter DIVISOR_BITS = 4;
localparam QUOTIENT_BITS = DIVIDEND_BITS;
localparam REMAINDER_BITS = DIVISOR_BITS;
localparam INTERMEDIATE_BITS = DIVIDEND_BITS + DIVISOR_BITS - 1;
localparam COUNTER_BITS = $clog2(QUOTIENT_BITS);

input clk;
input [DIVIDEND_BITS-1:0] in_dividend;
input [DIVISOR_BITS-1:0] in_divisor;
input in_valid;

output logic [QUOTIENT_BITS-1:0] out_quotient;
output logic [REMAINDER_BITS-1:0] out_remainder;
output logic out_error;
output logic out_valid;

logic [COUNTER_BITS-1:0] counter;
logic [INTERMEDIATE_BITS-1:0] current_remainder;
logic [INTERMEDIATE_BITS-1:0] current_subtrahend;

assign out_remainder = current_remainder[REMAINDER_BITS-1:0];

always_ff @(posedge clk) begin
	if (in_valid) begin
		if (in_divisor == 0) begin
			//divide-by-zero
			out_valid <= 1'b1;
			out_error <= 1'b1;
		end else begin
			current_remainder <= {{(DIVISOR_BITS-1){1'b0}}, in_dividend};
			current_subtrahend <= {in_divisor, {(DIVIDEND_BITS-1){1'b0}}};
			out_quotient <= 0;
			
			counter <= QUOTIENT_BITS;
			out_valid <= 1'b0;
			out_error <= 1'b0;
		end
	end else if (counter > 0) begin
		automatic logic write_bit;
		
		if (current_remainder >= current_subtrahend) begin
			write_bit = 1;
			current_remainder <= current_remainder - current_subtrahend;
		end else begin
			write_bit = 0;
		end
		
		current_subtrahend <= current_subtrahend >> 1;
		out_quotient <= (out_quotient << 1) | write_bit;
		
		if (counter == 1) begin
			out_valid <= 1'b1;
		end
		counter <= counter - 1;
	end else begin
		out_valid <= 0;
	end
end

endmodule
