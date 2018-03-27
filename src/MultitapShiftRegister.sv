/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//Implements evenly-spaced taps in a RAM shift register
//Higher indices represent older data
module MultitapShiftRegister(clk, reset, r_tap_spacing, in_valid, in_data, out_data);

//public parameters
parameter DATA_BITS;
parameter MAX_TAP_SPACING;
parameter NUM_TAPS;
parameter COORD_BITS;

//private parameters
localparam ADDR_BITS = $clog2(MAX_TAP_SPACING);
localparam MEM_WIDTH = DATA_BITS * NUM_TAPS;

input clk, reset;
input [COORD_BITS-1:0] r_tap_spacing;
input in_valid;
input [DATA_BITS-1:0] in_data;
output logic [DATA_BITS-1:0] out_data [NUM_TAPS];

logic [MEM_WIDTH-1:0] mem_in;
logic [MEM_WIDTH-1:0] mem_out;
logic [ADDR_BITS-1:0] address;
logic [ADDR_BITS-1:0] tap_spacing;

generate
	if (NUM_TAPS > 1) begin
		assign mem_in = {mem_out[0 +: DATA_BITS*(NUM_TAPS-1)], in_data};
	end else begin
		assign mem_in = in_data;
	end
endgenerate

always_comb begin
	int i;

	for (i = 0; i < NUM_TAPS; i++) begin
		out_data[i] = mem_out[DATA_BITS*i +: DATA_BITS];
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		tap_spacing = r_tap_spacing;
		address = 0;
	end else if (in_valid) begin
		address = address + 1;
		if (address >= tap_spacing) address = 0;
	end
end

RAMBlock #(
	.DATA_WIDTH(MEM_WIDTH),
	.ADDR_BITS(ADDR_BITS)
) memory_block(
	.clk(clk),
	.in_we(in_valid),
	.out_read_data(mem_out),
	.in_read_addr(address),
	.in_write_data(mem_in),
	.in_write_addr(address)
);


endmodule
