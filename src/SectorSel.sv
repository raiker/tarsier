/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module SectorSel(clk, in_valid, in_x, in_y, out_sector, out_nan);

localparam ANGLE_BITS = 6; //doesn't work if < 2
parameter INPUT_BITS = 32;

input clk;
input in_valid;
input signed [INPUT_BITS-1:0] in_x, in_y;
output logic [ANGLE_BITS-1:0] out_sector;
output logic out_nan;

localparam NUM_ANGLES = 2**(ANGLE_BITS);
localparam NUM_TAN_VALS = NUM_ANGLES / 4;
localparam PI = 3.1415926535897;
localparam TAN_BITS = 16;
localparam TAN_SHIFT = 11;
localparam TEMP_PRODUCT_BITS = TAN_BITS + INPUT_BITS;
localparam INTERNAL_BITS = TEMP_PRODUCT_BITS - TAN_SHIFT;

//=round(-2048*tan((2n-31)pi/64))
//effectively shifted left by 11 places
localparam bit[TAN_BITS-1:0] tan_v [NUM_TAN_VALS] = '{
	41688,
	13806,
	8176,
	5724,
	4330,
	3417,
	2761,
	2260,
	1856,
	1519,
	1228,
	969,
	733,
	513,
	304,
	101
};

logic nan_1, nan_2, nan_3, nan_4;
logic [1:0] quad_1, quad_2, quad_3, quad_4;
logic signed [INPUT_BITS-1:0] x_1;
logic signed [INPUT_BITS-1:0] y_1, y_2, y_3;
logic signed [INTERNAL_BITS-1:0] yvals_2 [NUM_TAN_VALS];
logic signed [INTERNAL_BITS-1:0] yvals_3 [NUM_TAN_VALS];
logic [NUM_TAN_VALS-1:0] cmp_4;

always_ff @(posedge clk) begin
	if (in_valid) begin
		//pipeline stage 1
		begin
			automatic logic [1:0] quadrant = 0;
			automatic logic signed [INPUT_BITS-1:0] x = in_x;
			automatic logic signed [INPUT_BITS-1:0] y = in_y;
			
			if (x < 0 || (y > 0 && x == 0)) begin	
				x = -x;
				y = -y;
				quadrant = quadrant + 2; //rotate onto right half
			end
			if (y >= 0) begin
				automatic int tx = y;
				automatic int ty = -x;
				x = tx;
				y = ty;
				quadrant = quadrant + 1; //rotate onto upper-right quarter
			end
			
			quad_1 <= quadrant;
			x_1 <= x;
			y_1 <= y;
			nan_1 <= (in_x == 0) && (in_y == 0);
		end
		
		//pipeline stage 2
		begin
			for (int i = 0; i < NUM_TAN_VALS; i++) begin
				automatic logic signed [TEMP_PRODUCT_BITS-1:0] temp = x_1 * tan_v[i];
				yvals_2[i] <= -(temp>>>TAN_SHIFT);
			end
			
			nan_2 <= nan_1;
			quad_2 <= quad_1;
			y_2 <= y_1;
		end

		//pipeline stage 3
		begin
			yvals_3 <= yvals_2;

			nan_3 <= nan_2;
			quad_3 <= quad_2;
			y_3 <= y_2;
		end
		
		//pipeline stage 4
		begin
			for (int i = 0; i < NUM_TAN_VALS; i++) begin
				cmp_4[i] <= (yvals_3[i] <= y_3);
			end
			
			nan_4 <= nan_3;
			quad_4 <= quad_3;
		end
		
		//pipeline stage 5
		begin
			automatic logic [ANGLE_BITS-1:0] fine_angle;
			casex (cmp_4)
				16'bxxxxxxxxxxxxxxx0: fine_angle = 0;
				16'bxxxxxxxxxxxxxx01: fine_angle = 1;
				16'bxxxxxxxxxxxxx01x: fine_angle = 2;
				16'bxxxxxxxxxxxx01xx: fine_angle = 3;
				16'bxxxxxxxxxxx01xxx: fine_angle = 4;
				16'bxxxxxxxxxx01xxxx: fine_angle = 5;
				16'bxxxxxxxxx01xxxxx: fine_angle = 6;
				16'bxxxxxxxx01xxxxxx: fine_angle = 7;
				16'bxxxxxxx01xxxxxxx: fine_angle = 8;
				16'bxxxxxx01xxxxxxxx: fine_angle = 9;
				16'bxxxxx01xxxxxxxxx: fine_angle = 10;
				16'bxxxx01xxxxxxxxxx: fine_angle = 11;
				16'bxxx01xxxxxxxxxxx: fine_angle = 12;
				16'bxx01xxxxxxxxxxxx: fine_angle = 13;
				16'bx01xxxxxxxxxxxxx: fine_angle = 14;
				16'b01xxxxxxxxxxxxxx: fine_angle = 15;
				16'b1xxxxxxxxxxxxxxx: fine_angle = 16;
			endcase
			
			out_nan <= nan_4;
			out_sector <= (quad_4 << 4) + fine_angle;
		end
	end
end

endmodule
