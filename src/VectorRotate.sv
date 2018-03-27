/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module VectorRotate(clk, ix, iy, cos, sin, ox, oy);
	`include "Functions.sv"
	input clk;
	input signed [4:0] ix, iy; //s4.0
	input signed [8:0] cos, sin; //s0.8
	output logic signed [5:0] ox, oy; //s4.0
	
	logic signed [13:0] xcos, ycos, xsin, ysin; //s5.8
	
	/*always_comb begin
		qx = ix * cos - iy * sin;
		qy = ix * sin + iy * cos;
		
		ox = roundToEven_s5_8(qx[13:0]);
		oy = roundToEven_s5_8(qy[13:0]);
	end*/
	
	always_ff @(posedge clk) begin
		xcos <= ix * cos;
		ycos <= iy * cos;
		xsin <= ix * sin;
		ysin <= iy * sin;
		
		ox <= roundToEven_s5_8(xcos - ysin);
		oy <= roundToEven_s5_8(xsin + ycos);
	end
endmodule
