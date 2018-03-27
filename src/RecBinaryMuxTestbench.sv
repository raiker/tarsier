/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module RecBinaryMuxTestbench();

localparam LENGTH = 9;

integer cursor;

logic clk;
logic reset;

initial begin
	cursor = -2;
end

assign reset = cursor < 0;

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

always_ff @(posedge clk) begin
	cursor++;
end

logic [31:0] in_data [LENGTH];
logic in_valid [LENGTH];
logic in_ready [LENGTH];

logic [31:0] out_data;
logic out_valid;
logic out_ready;

assign out_ready = 1'b1;

RecBinaryMux #(
	.DATA_WIDTH(32),
	.LENGTH(LENGTH)
) tree (
	.clk(clk),
	.reset(reset),
	.in_data(in_data),
	.in_valid(in_valid),
	.in_ready(in_ready),
	.out_data(out_data),
	.out_valid(out_valid),
	.out_ready(out_ready)
);

generate
	genvar i;
	for (i = 0; i < LENGTH; i++) begin
		logic write;
		logic [31:0] data;
		logic full; //ignored
		
		FIFO #(
			.DATA_BITS(32),
			.ADDRESS_BITS(4)
		) fifo (
			.clk(clk),
			.reset(reset),
			.in_write(write),
			.in_data(data),
			.in_read(in_ready[i]),
			.out_data(in_data[i]),
			.out_valid(in_valid[i]),
			.out_full(full)
		);
		
		assign data = write ? (i + 1) * 32'h11110000 + cursor : 'x;
		assign write = cursor % ((i+1)*3) == 0;
	end
endgenerate

endmodule
