/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1 ns / 1 ns
module ORB2Testbench();

`include "../etc/ORBTestbenchGen/ORBTestbenchData.inc.sv"

//localparam EXPECTED = 256'b1100111000001101001100010100010000000011000011100011000010100111001011101110000110010100001000000110001100000001011111011111000001000000000101010000111001000000000000010100001010000110011110010000000001111110010110100001010001001111001111010100100110000110;
//localparam EXPECTED = 256'b1000001010011100000110000011110111011011000011010100001111111001001101110001000000001111010011111100010111010001100000101110100100010000001000100000101000000011101111111000100001010101100001011110011100011100100000010000101000101000000110101101100110110000;

localparam DELAY = $clog2(37) + 3;
localparam FACTOR = 2;

logic clk;
logic in_valid, out_valid, in_go, window_ready, reset, accepting_input;
logic [255:0] descriptor;
integer out_feature_x, out_feature_y;
logic [LUMA_BITS-1:0] in_col [37]; //incoming column of pixels

ORB2 #(
	.LUMA_BITS(LUMA_BITS),
	.BITS_PER_CLOCK(1)
) orb_mod (
	.clk(clk),
	.in_col(in_col),
	.in_valid(in_valid),
	.in_go(in_go),
	.in_reset(reset),
	.in_x(0),
	.in_y(0),
	.out_descriptor(descriptor),
	.out_valid(out_valid),
	.out_window_ready(window_ready),
	.out_accepting_input(accepting_input),
	.out_feature_x(out_feature_x),
	.out_feature_y(out_feature_y)
);

logic test_run;
integer read_head, state;

initial begin
	$display("Testing ORB");
	//clk = 1;
	test_run = 0;
	state = -1;
end

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

always_comb begin
	reset = state == -1;
	read_head = state / FACTOR;
	in_valid = read_head >= 0 && read_head < (37 + DELAY) && (state % FACTOR == 0);
	in_go = state == (37 + DELAY) * FACTOR;
	
	for (int i = 0; i < 37; i++) begin
		in_col[i] = image_data[i][read_head];
	end	
end

always @(posedge clk) begin
	if (!test_run && out_valid) begin
		if (descriptor == EXPECTED_DESCRIPTOR) begin
			$display("Test passed");
		end else begin
			$display("Test failed");
		end
		
		$display("%x", descriptor);
		$display("%x", EXPECTED_DESCRIPTOR);
		
		test_run = 1;
	end
	state++;
end

endmodule
