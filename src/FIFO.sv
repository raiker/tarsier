/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//output always visible, if in_read high on clock edge, read pointer advances
module FIFO(clk, reset, in_write, in_data, in_read, out_data, out_valid, out_full);

//parameter type DATA_TYPE = integer; //not yet supported in quartus
parameter DATA_BITS = 4;
parameter ADDRESS_BITS = 4;

typedef logic [DATA_BITS-1:0] DATA_TYPE;

input clk;
input reset;
input in_write, in_read;
input DATA_TYPE in_data;
output DATA_TYPE out_data;
output out_valid;
output out_full;

logic [ADDRESS_BITS-1:0] write_head, read_head;
logic [ADDRESS_BITS-1:0] usage;
DATA_TYPE ringbuffer [2**ADDRESS_BITS];

initial begin
	write_head = 0;
	read_head = 0;
end

assign out_data = out_valid ? ringbuffer[read_head] : 'x;
assign out_valid = read_head != write_head;
assign out_full = ((write_head + 1) & (2**ADDRESS_BITS - 1)) == read_head;
assign usage = write_head - read_head;

always @(posedge clk) begin
	if (reset) begin
		write_head <= 0;
		read_head <= 0;
	end else begin
		if (in_write) begin
			ringbuffer[write_head] <= in_data;
			write_head <= write_head + 1;
		end
		if (in_read && out_valid) begin
			read_head <= read_head + 1;
		end
		
		if (!in_read && in_write && out_full) begin
			//clear one extra slot
			read_head <= read_head + 1;
		end
	end
end

endmodule
