/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module ShiftRegister(clk, reset, wr_en, in, out);

parameter DATA_BITS;
parameter LENGTH;

input clk;
input reset;
input wr_en;
input [DATA_BITS-1:0] in;
output [DATA_BITS-1:0] out;

logic [DATA_BITS-1:0] shift_chain [LENGTH];

always_ff @(posedge clk) begin
	if (reset) begin
		for (int i = 0; i < LENGTH - 1; i++) begin
			shift_chain[i] <= '0;
		end

		if (wr_en) begin
			shift_chain[LENGTH-1] <= in;
		end else begin
			shift_chain[LENGTH-1] <= '0;
		end
	end else if (wr_en) begin
		for (int i = 1; i < LENGTH; i++) begin
			shift_chain[i-1] <= shift_chain[i];
		end
		shift_chain[LENGTH-1] <= in;
	end
end

assign out = shift_chain[0];

endmodule
