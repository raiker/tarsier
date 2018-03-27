/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//Generic synchronous 1-read/1-write RAM block
module RAMBlock(clk, in_we, out_read_data, in_read_addr, in_write_data, in_write_addr);

parameter DATA_WIDTH = 16;
parameter ADDR_BITS = 8;

input clk;
input in_we;
output [DATA_WIDTH-1:0] out_read_data;
input [ADDR_BITS-1:0] in_read_addr;
input [DATA_WIDTH-1:0] in_write_data;
input [ADDR_BITS-1:0] in_write_addr;

logic [DATA_WIDTH-1:0] memory [2**ADDR_BITS];

//hack so that memory has known values
initial begin
	for (int i = 0; i < 2**ADDR_BITS; i++) begin
		memory[i] = {(DATA_WIDTH/2){2'b01}};
	end
end

assign out_read_data = memory[in_read_addr];

always @(posedge clk) begin
	if (in_we) begin
		memory[in_write_addr] <= in_write_data;
	end
end

endmodule
