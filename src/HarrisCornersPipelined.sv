/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//Calculates the Harris corner score for the centre pixel
//Window is the pixels [1:3][16:18], if [0][0] is the centre
module HarrisCornersPipelined(clk, reset, r_row_length, in_valid, in_window, out_score);

parameter LUMA_BITS;
parameter MATRIX_BITS;
parameter MAX_ROW_LENGTH;
parameter COORD_BITS;

localparam FILTER_SIZE = 7; //size of inner part of window (1px border for Sobel filter)
localparam SHIFT = (FILTER_SIZE - 1) * 2; // Gaussian filter divisor
localparam WEIGHT_BITS = 9; //number of bits in the highest term of the weight matrix

localparam FEED_MATRIX_BITS = MATRIX_BITS;
localparam WEIGHTED_MATRIX_BITS = MATRIX_BITS + WEIGHT_BITS;
localparam COMBINED_MATRIX_BITS = WEIGHTED_MATRIX_BITS + $clog2(FILTER_SIZE*FILTER_SIZE);//MATRIX_BITS + SHIFT;
localparam SHIFTED_MATRIX_BITS = MATRIX_BITS;
localparam DET_BITS = 2 * (SHIFTED_MATRIX_BITS); //Should be enough precision. TEST ME!
localparam TRACE_BITS = SHIFTED_MATRIX_BITS + 1;
localparam SCORE_BITS = DET_BITS + 1;

input clk, reset;
input [COORD_BITS-1:0] r_row_length;
input in_valid;
input [LUMA_BITS-1:0] in_window [3][3];
output logic signed [SCORE_BITS-1:0] out_score;

logic [LUMA_BITS-1:0] window_ff [3][3];
logic signed [FEED_MATRIX_BITS-1:0] feed_matrix[2][2];
logic signed [FEED_MATRIX_BITS-1:0] feed_matrix_ff[2][2];
wire [MATRIX_BITS-1:0] matrices [2][2][FILTER_SIZE][FILTER_SIZE];
logic signed [WEIGHTED_MATRIX_BITS-1:0] weighted_matrices [2][2][FILTER_SIZE*FILTER_SIZE-1:0];
logic signed [WEIGHTED_MATRIX_BITS-1:0] weighted_matrices_ff [2][2][FILTER_SIZE*FILTER_SIZE-1:0];
logic signed [COMBINED_MATRIX_BITS-1:0] combined_matrix[2][2];
logic signed [SHIFTED_MATRIX_BITS-1:0] combined_matrix_ff1[2][2];
logic signed [SHIFTED_MATRIX_BITS-1:0] combined_matrix_ff2[2][2];

logic signed [DET_BITS-1:0] det, det_ff1, det_ff2;
logic signed [TRACE_BITS-1:0] trace, trace_ff1, trace_ff2;
logic signed [SCORE_BITS-1:0] score_temp;

//highest term is 6 bits, sum is 256 (change local parameters if filter changes)
localparam int weights [FILTER_SIZE] = '{
	1,
	6,
	15,
	20,
	15,
	6,
	1
};


HarrisMatrixPipelined #(
	.LUMA_BITS(LUMA_BITS),
	.MATRIX_BITS(MATRIX_BITS)
) hm_mod (
	.clk(clk),
	.advance(in_valid),
	.window(window_ff),
	.matrix(feed_matrix)
);

generate
	genvar i, j;
	for (i = 0; i < 2; i++) begin : rows
		for (j = 0; j < 2; j++) begin : cols
			SlidingWindow #(
				.DATA_BITS(MATRIX_BITS),
				.WINDOW_NUM_ROWS(FILTER_SIZE),
				.WINDOW_NUM_COLS(FILTER_SIZE),
				.MAX_ROW_LENGTH(MAX_ROW_LENGTH),
				.COORD_BITS(COORD_BITS)
			) window_mod (
				.clk(clk),
				.reset(reset),
				.r_row_length(r_row_length),
				.in_valid(in_valid),
				.in_data(feed_matrix_ff[i][j]),
				.out_window(matrices[i][j])
			);
			
			AdderTreePipelined #(
				.DATA_WIDTH(WEIGHTED_MATRIX_BITS),
				.LENGTH(FILTER_SIZE*FILTER_SIZE)
			) filter_sum_mod (
				.clk(clk),
				.reset(1'b0),
				.in_advance(in_valid),
				.in_addends(weighted_matrices_ff[i][j]),
				.out_sum(combined_matrix[i][j])
			);
		end
	end
endgenerate

always_ff @(posedge clk) begin
	if (in_valid) begin
		window_ff <= in_window;
		feed_matrix_ff <= feed_matrix;
		
		weighted_matrices_ff <= weighted_matrices;

		for (int i = 0; i < 2; i++) begin
			for (int j = 0; j < 2; j++) begin
				combined_matrix_ff1[i][j] <= combined_matrix[i][j][SHIFTED_MATRIX_BITS+SHIFT-1:SHIFT];
			end
		end
		
		combined_matrix_ff2 <= combined_matrix_ff1;
		
		det_ff1 <= det;
		trace_ff1 <= trace;
		det_ff2 <= det_ff1;
		trace_ff2 <= trace_ff1;
		//det_ff <= det;
		//trace_ff <= trace;
		//if (!score_temp[31]) begin
		out_score <= score_temp;
		/*end else begin
			score = 0;
		end*/
	end
end

always_comb begin
	for (int i = 0; i < FILTER_SIZE; i++) begin
		for (int j = 0; j < FILTER_SIZE; j++) begin
			for (int qi = 0; qi < 2; qi++) begin
				for (int qj = 0; qj < 2; qj++) begin
					weighted_matrices[qi][qj][i*FILTER_SIZE+j] = $signed(matrices[qi][qj][i][j]) * weights[i] * weights[j]; //maintain as much precision as possible
				end
			end
		end
	end
	
	//det and trace thing here (2 clocks later)
	det = combined_matrix_ff2[0][0] * combined_matrix_ff2[1][1] - combined_matrix_ff2[0][1] * combined_matrix_ff2[1][0];
	trace = combined_matrix_ff2[0][0] + combined_matrix_ff2[1][1];
	
	score_temp = (det_ff2 - ((trace_ff2 * trace_ff2) >> 4));// >>> SHIFT;
end

endmodule
