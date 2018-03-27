/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module VectorRotateTestbench();

`include "../etc/ORBSamples/orbsamples.sv"
`include "../etc/HCTestbenchGen/VectorRotateTestbenchData.inc.sv"

localparam NUM_TEST_VALUES = NUM_ROTATIONS * WIDTH * HEIGHT;
localparam ROTATE_DELAY = 2;

logic clk;
integer input_head, delayed_head;
logic [5:0] input_angle, delayed_angle;
integer input_i, input_j, delayed_i, delayed_j; //delayed coordinates are input coordinates two clocks delayed
logic signed [4:0] input_x, input_y, delayed_x, delayed_y;
logic signed [5:0] rotated_x, rotated_y; //outputs from module
logic signed [5:0] expected_x, expected_y;
logic signed [8:0] sin, cos;

initial begin
	input_head = 0;
end

always begin
	clk = 0; #5; clk = 1; #5;
end

always_ff @(posedge clk) begin
	input_head <= input_head + 1;
	
	if (delayed_head >= 0 && delayed_head < NUM_TEST_VALUES) begin
		//we're in the test region
		if (rotated_x !== expected_x || rotated_y !== expected_y) begin
			$display("Error at angle=%d, x=%d, y=%d: verilog (%d,%d), rust (%d,%d)", delayed_angle, delayed_x, delayed_y, rotated_x, rotated_y, expected_x, expected_y);
		end
	end
end

assign delayed_head = input_head - ROTATE_DELAY;

assign input_angle = input_head / (HEIGHT * WIDTH);
assign delayed_angle = delayed_head / (HEIGHT * WIDTH);

assign input_j = (input_head - input_angle * (HEIGHT * WIDTH)) / WIDTH;
assign input_i = input_head - input_angle * (HEIGHT * WIDTH) - input_j * WIDTH;
assign delayed_j = (delayed_head - delayed_angle * (HEIGHT * WIDTH)) / WIDTH;
assign delayed_i = delayed_head - delayed_angle * (HEIGHT * WIDTH) - delayed_j * WIDTH;

assign input_x = input_i + X_MIN;
assign input_y = input_j + Y_MIN;
assign delayed_x = delayed_i + X_MIN;
assign delayed_y = delayed_j + Y_MIN;

assign cos = ROTATION_LUT[input_angle][0];
assign sin = ROTATION_LUT[input_angle][1];

assign expected_x = EXPECTED_COORDS[delayed_angle][delayed_j][delayed_i][0];
assign expected_y = EXPECTED_COORDS[delayed_angle][delayed_j][delayed_i][1];

VectorRotate vec_rotate (
	.clk(clk),
	.ix(input_x),
	.iy(input_y),
	.cos(cos),
	.sin(sin),
	.ox(rotated_x),
	.oy(rotated_y)
);

endmodule
