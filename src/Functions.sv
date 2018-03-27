/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//returns the ceiling of the logarithm base 2
//undefined for x == 0
function [31:0] log2_ceil;
	input [31:0] x;
	int i;
	
	begin
		if (x == 0) return 0; //bad case
		for (i = 31; i >= 0; i--) begin
			if (x[i]) break;
		end
		//i holds the first set bit
		if (x & ((1 << i) - 1)) begin
			//there are some more bits set
			return i + 1;
		end
		return i;
	end
endfunction

//NB doesn't deal with the pathological case (32'h8000_0000)
function int abs;
	input int x;
	
	begin
		if (x < 0) return -x;
		return x;
	end
endfunction

//round to nearest, ties round to even, for signed 5.8 fixed-point
function bit [5:0] roundToEven_s5_8;
	input bit [13:0] x; //s5.8
	
	begin
		if (!x[8]) begin
			//truncation even
			if (x[7] && |x[6:0]) begin
				//round up to odd
				return {x[13:9], 1'b1};
			end else begin
				//round down to even
				return {x[13:9], 1'b0};
			end
		end else begin
			//truncation odd
			if (x[7]) begin
				//round up to even
				return {x[13:9], 1'b0} + 6'b10;
			end else begin
				//round down to odd
				return {x[13:9], 1'b1};
			end
		end
	end
endfunction

function [7:0] NibbleToUTF8;
	input [3:0] x;
	
	begin
		if (x < 10) begin
			return "0" + x;
		end else begin
			return "W" + x;
		end
	end
endfunction
