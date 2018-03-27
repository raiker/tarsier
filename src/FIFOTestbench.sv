/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module FIFOTestbench();

localparam DATA_BITS = 5;
localparam NUM_DATA = 32;

logic clk;
logic [DATA_BITS-1:0] in, out;
logic wr_en, rd_en, valid, full;

FIFO #(
	.DATA_BITS(DATA_BITS),
	.ADDRESS_BITS(4)
) fifomod (
	.clk(clk),
	.reset(1'b0),
	.in_write(wr_en),
	.in_data(in),
	.in_read(rd_en),
	.out_data(out),
	.out_valid(valid),
	.out_full(full)
);

//int cursor = 0;

bit [DATA_BITS-1:0] data [NUM_DATA] = '{
	0,
	3,
	6,
	9,
	12,
	15,
	2,
	5,
	8,
	11,
	14,
	1,
	4,
	7,
	10,
	13,
	0,
	3,
	6,
	9,
	12,
	15,
	2,
	5,
	8,
	11,
	14,
	1,
	4,
	7,
	10,
	13
};

initial begin
	$display("Testing FIFO");
	//wr_en = 0;
	clk = 0;
	
	for (int cursor = 0; cursor < NUM_DATA; cursor++) begin
		in = data[cursor];
		wr_en = 1;
		rd_en = (cursor & 3) == 0;
		#5;
		clk = 1;
		#5;
		clk = 0;		
	end
	wr_en = 0;
	rd_en = 1;
	for (int i = 0; i < 20; i++) begin
		#5;
		clk = 1;
		#5;
		clk = 0;		
	end
end

/*always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

always_ff @(posedge clk) begin
	bit failure = 0;
	
	if (cursor < NUM_DATA) begin
		if (wr_en) begin
			in = data[cursor++];
		end
		wr_en = 1;
	end else begin
		wr_en = 0;
	end
	
	if (failure) begin
		$display("Assertion failure");
	end
end*/

endmodule
