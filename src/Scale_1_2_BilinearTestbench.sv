/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module Scale_1_2_BilinearTestbench();

localparam LUMA_BITS = 8;
localparam IMAGE_WIDTH = 8;
localparam IMAGE_HEIGHT = 4;
localparam OUT_IMAGE_WIDTH = 4;
localparam OUT_IMAGE_HEIGHT = 2;

logic [LUMA_BITS-1:0] image_data[IMAGE_HEIGHT][IMAGE_WIDTH] = '{
	'{8'h00, 8'h3f, 8'hff, 8'hff, 8'h20, 8'h98, 8'h70, 8'h48},
	'{8'h00, 8'h3f, 8'hff, 8'hff, 8'h98, 8'h5c, 8'h70, 8'h84},
	'{8'h00, 8'h1f, 8'h7f, 8'h7f, 8'h70, 8'h70, 8'h70, 8'h70},
	'{8'h00, 8'h00, 8'h00, 8'h00, 8'h48, 8'h84, 8'h70, 8'h5c}
};

logic [LUMA_BITS-1:0] out_image_data[OUT_IMAGE_HEIGHT][OUT_IMAGE_WIDTH] = '{
	'{8'h1f, 8'hff, 8'h6b, 8'h6b},
	'{8'h07, 8'h3f, 8'h6b, 8'h6b}
};

logic clk, reset;
integer in_x, in_y, out_x, out_y;
logic [LUMA_BITS-1:0] in_pixel, out_pixel;
logic in_valid, out_valid;
logic is_error;

Scale_1_2_Bilinear #(
	.LUMA_BITS(LUMA_BITS),
	.MAX_INPUT_WIDTH(16),
	.MAX_INPUT_HEIGHT(16),
	.COORD_BITS(16)
) scaler_module (
	.clk(clk),
	.reset(reset),
	.r_width(IMAGE_WIDTH),
	.in_pixel(in_pixel),
	.in_valid(in_valid),
	.in_x(in_x),
	.in_y(in_y),
	.out_pixel(out_pixel),
	.out_valid(out_valid),
	.out_x(out_x),
	.out_y(out_y)
);
	
initial begin
	in_x = -2;
	in_y = 0;
	clk = 0;
end

always begin
	#5 clk = ~clk;
end

always @(posedge clk) begin
	if (in_x < IMAGE_WIDTH + 5) begin
		in_x <= in_x + 1;
	end else begin
		in_x <= 0;
		in_y <= in_y + 1;
	end
end

always_ff @(negedge clk) begin	
	if (is_error) begin
		$display("Error at (%0d,%0d)", out_x, out_y);
	end
end

always_comb begin
	reset = in_x == -1 && in_y == 0;
	in_pixel = image_data[in_y][in_x];
	in_valid = (in_x >= 0) && (in_x < IMAGE_WIDTH) && (in_y >= 0) && (in_y < IMAGE_HEIGHT);
	
	is_error = out_valid && (out_pixel !== out_image_data[out_y][out_x]);
end

endmodule
