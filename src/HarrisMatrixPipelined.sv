/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//NB: Coordinates are x+ to the right, y+ downwards
module HarrisMatrixPipelined(clk, advance, window, matrix);

parameter LUMA_BITS = 8;
parameter MATRIX_BITS = 12;

input clk;
input advance;
input [LUMA_BITS-1:0] window [3][3];
output logic signed [MATRIX_BITS-1:0] matrix [2][2]; //s+11

logic signed[LUMA_BITS+2:0] I_x, I_y; //s+10
logic signed[LUMA_BITS+2:0] I_x_ff, I_y_ff; //s+10
logic signed[(2*LUMA_BITS)+4:0] temp_mat [3]; //s+20

logic signed[LUMA_BITS+2:0] dxa, dxb, dxc, dya, dyb, dyc;
logic signed[LUMA_BITS+2:0] dxa_ff, dxb_ff, dxc_ff, dya_ff, dyb_ff, dyc_ff;

always_comb begin
	dxa = window[0][2] - window[0][0];
	dxb = (window[1][2]<<1) - (window[1][0]<<1);
	dxc = window[2][2] - window[2][0];
	
	dya = window[2][0] - window[0][0];
	dyb = (window[2][1]<<1) - (window[0][1]<<1);
	dyc = window[2][2] - window[0][2];
	//I_x = window[0][2] - window[0][0] + window[1][2]<<1 - window[1][0]<<1 + window[2][2] - window[2][0];
	//I_y = window[2][0] - window[0][0] + window[2][1]<<1 - window[0][1]<<1 + window[2][2] - window[0][2];
	
	I_x = dxa_ff + dxb_ff + dxc_ff;
	I_y = dya_ff + dyb_ff + dyc_ff;
	
	//intermediate variable sized to hold the whole result
	temp_mat[0] = I_x_ff * I_x_ff;
	temp_mat[1] = I_x_ff * I_y_ff;
	temp_mat[2] = I_y_ff * I_y_ff;
	
	//grab the top MATRIX_BITS
	matrix[0][0] = temp_mat[0][(2*LUMA_BITS)+4-:MATRIX_BITS];
	matrix[0][1] = temp_mat[1][(2*LUMA_BITS)+4-:MATRIX_BITS];
	matrix[1][0] = temp_mat[1][(2*LUMA_BITS)+4-:MATRIX_BITS];
	matrix[1][1] = temp_mat[2][(2*LUMA_BITS)+4-:MATRIX_BITS];
end

always_ff @(posedge clk) begin
	if (advance) begin
		I_x_ff <= I_x;
		I_y_ff <= I_y;
		
		dxa_ff <= dxa;
		dxb_ff <= dxb;
		dxc_ff <= dxc;
		
		dya_ff <= dya;
		dyb_ff <= dyb;
		dyc_ff <= dyc;
	end
end

endmodule
