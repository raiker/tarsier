/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module RoundToEvenTestbench();

`include "Functions.sv"

localparam NUM_TEST_CASES = 30;

typedef struct {
	logic [13:0] input_s5_8;
	logic [5:0] output_s5;
} test_cases_t;

localparam test_cases_t TEST_CASES[NUM_TEST_CASES] = '{
	'{14'b000000_00000000, 6'b000000}, //0.0
	'{14'b000000_01000000, 6'b000000}, //0.25
	'{14'b000000_10000000, 6'b000000}, //0.5
	'{14'b000000_11000000, 6'b000001}, //0.75
	'{14'b000001_00000000, 6'b000001}, //1.0
	'{14'b000001_01000000, 6'b000001}, //1.25
	'{14'b000001_10000000, 6'b000010}, //1.5
	'{14'b000001_11000000, 6'b000010}, //1.75
	'{14'b111110_00000000, 6'b111110}, //-2.0
	'{14'b111110_01000000, 6'b111110}, //-1.75
	'{14'b111110_10000000, 6'b111110}, //-1.5
	'{14'b111110_11000000, 6'b111111}, //-1.25
	'{14'b111111_00000000, 6'b111111}, //-1.0
	'{14'b111111_01000000, 6'b111111}, //-0.75
	'{14'b111111_10000000, 6'b000000}, //-0.5
	'{14'b111111_11000000, 6'b000000}, //-0.25
	
	
	'{14'b000011_00000000, 6'b000011}, //3.0
	'{14'b111101_00000000, 6'b111101}, //-3.0
	'{14'b000000_00000000, 6'b000000}, //0.0
	'{14'b000011_01000000, 6'b000011}, //3.25
	'{14'b111100_11000000, 6'b111101}, //-3.25
	'{14'b000010_11000000, 6'b000011}, //2.75
	'{14'b111101_01000000, 6'b111101}, //-2.75
	'{14'b000001_10000000, 6'b000010}, //1.5
	'{14'b111110_10000000, 6'b111110}, //-1.5
	'{14'b000010_10000000, 6'b000010}, //2.5
	'{14'b111101_10000000, 6'b111110}, //-2.5
	'{14'b000000_10000000, 6'b000000}, //0.5
	'{14'b111111_10000000, 6'b000000}, //-0.5
	'{14'b011111_11111111, 6'b100000}  //15.99609375 (result undefined, this is just what the function returns)
};

logic [13:0] input_s5_8;
logic [5:0] output_s5;
logic [5:0] expected_s5;

int num_failures;

initial begin
	$display("Testing RoundToEven_5_8");
	
	num_failures = 0;
	
	for (int i = 0; i < NUM_TEST_CASES; i++) begin
		input_s5_8 = TEST_CASES[i].input_s5_8;
		output_s5 = roundToEven_s5_8(input_s5_8);
		expected_s5 = TEST_CASES[i].output_s5;
		if (output_s5 != expected_s5) begin
			num_failures++;
		end
		#5;
	end
	
	if (num_failures == 0) begin
		$display("All tests passed");
	end else begin
		$display("%d failures", num_failures);
	end
end

endmodule
