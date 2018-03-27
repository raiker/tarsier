/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module CornersAndDescriptors(clk, reset, in_begin_frame_reset, out_frame_reset_complete, r_width, r_height, r_threshold,
	in_valid, in_pixel, in_x, in_y, in_consume, in_mask,
	out_corner_count_increment, out_frame_end, out_request_stall, out_descriptor, out_valid, out_feature_x, out_feature_y);

parameter LUMA_BITS;
parameter MAX_IMAGE_WIDTH;
parameter MAX_IMAGE_HEIGHT;
parameter COORD_BITS;
parameter MATRIX_BITS;
parameter NONMAX_SCORE_BITS;
parameter PARALLEL_MODULES;
parameter BUFFERING_STRATEGY; //0 = Stall when all modules processing, 1 = Stall when any module processing

localparam BITS_PER_CLOCK = 1;
localparam DESCRIPTOR_BITS = 256;
//localparam MATRIX_BITS = 12;
localparam HARRIS_SCORE_BITS = 2 * MATRIX_BITS + 1;
//localparam NONMAX_SCORE_BITS = HARRIS_SCORE_BITS;

//Begin hackiness
//All the below describes coordinates in a virtual space
//(0,0) is the centre pixel, which is the pixel for which cornerness is tested
//The delays are constructed such that the corner score is ready at the same time as that coordinate is centred in the ORB window

localparam CORNERS_DELAY_COLS = 23; //x-coordinate of centre of harris matrix window
localparam CORNERS_DELAY_ROWS = 4; //-ve of y-coordinate of centre of harris matrix window
localparam ORB_DELAY_COLS = 27; //x-coordinate of column input to orb window

//set these parameters so that all the pixels required by above are included in the window
localparam WINDOW_WIDTH = 6;
localparam WINDOW_HEIGHT = 37;
localparam WINDOW_OFFSET_X = 22; //address of the leftmost column of pixels
localparam WINDOW_OFFSET_Y = -18; //topmost row of pixels

//coordinates of incoming pixel
//The input pixel goes straight into the sliding window, and so this virtual coordinate is dependent on the size and position of the window
localparam INPUT_OFFSET_X = WINDOW_OFFSET_X + WINDOW_WIDTH - 1;
localparam INPUT_OFFSET_Y = WINDOW_OFFSET_Y + WINDOW_HEIGHT - 1;

localparam CORNER_X_RESET_VAL = -INPUT_OFFSET_X - 1;
localparam CORNER_Y_RESET_VAL = -INPUT_OFFSET_Y;

localparam X_MARGIN = 18;
localparam Y_MARGIN = 18;

input clk, reset;
input in_valid;
input in_begin_frame_reset;
input [COORD_BITS-1:0] r_width, r_height;
input signed [15:0] r_threshold;
input [LUMA_BITS-1:0] in_pixel;
input [COORD_BITS-1:0] in_x, in_y;
input in_consume; //1 to remove an item from the underlying FIFO
input logic [31:0] in_mask;

output out_frame_reset_complete;
output out_corner_count_increment;
output out_frame_end;
output [DESCRIPTOR_BITS-1:0] out_descriptor;
output out_valid;
output [COORD_BITS-1:0] out_feature_x, out_feature_y;
output out_request_stall;

logic [COORD_BITS-1:0] image_width, image_height;

logic pixel_window_input_valid;
logic [LUMA_BITS-1:0] pixel_window_input_pixel;
logic [LUMA_BITS-1:0] pixel_window [WINDOW_HEIGHT][WINDOW_WIDTH];

logic corners_input_valid_0;
logic [LUMA_BITS-1:0] corners_input_window [3][3];
logic corners_is_local_max_1;
//logic reset_1, reset_2;

logic q_flushing;
logic orb_is_corner_1, orb_is_corner_2;
logic orb_input_valid_1, orb_input_valid_2;
logic [LUMA_BITS-1:0] orb_pixel_column_1 [WINDOW_HEIGHT];
logic [LUMA_BITS-1:0] orb_pixel_column_2 [WINDOW_HEIGHT];
logic signed [COORD_BITS:0] orb_in_corner_x_1, orb_in_corner_y_1, orb_in_corner_x_2, orb_in_corner_y_2;
logic orb_not_in_margin_1;
logic orb_in_consume;
logic [COORD_BITS-1:0] orb_out_corner_x, orb_out_corner_y;
logic orb_out_valid;
logic [DESCRIPTOR_BITS-1:0] orb_out_descriptor;
logic orb_out_request_stall;

assign pixel_window_input_valid = (in_valid || (q_flushing && !orb_out_request_stall)) && !reset; //this is the pipeline advance signal
assign pixel_window_input_pixel = q_flushing ? 8'hdd : in_pixel; //magic value
assign corners_input_valid_0 = pixel_window_input_valid;

always_comb begin
	automatic integer i, j;
	for (j = 0; j < 3; j++) begin
		for (i = 0; i < 3; i++) begin
			corners_input_window[j][i] = pixel_window[CORNERS_DELAY_ROWS - WINDOW_OFFSET_Y - 1 + j][CORNERS_DELAY_COLS - WINDOW_OFFSET_X - 1 + i];
		end
	end
end

assign orb_is_corner_1 = corners_is_local_max_1 && orb_not_in_margin_1;

always_comb begin
	automatic integer i;
	for (i = 0; i < WINDOW_HEIGHT; i++) begin
		orb_pixel_column_1[i] = pixel_window[i][ORB_DELAY_COLS - WINDOW_OFFSET_X];
	end
end

//placeholder for now, delay to enable more complex reset logic
assign out_frame_reset_complete = in_begin_frame_reset;

always_ff @(posedge clk) begin
	if (in_begin_frame_reset) begin
		image_width <= r_width;
		image_height <= r_height;
		orb_in_corner_x_1 <= CORNER_X_RESET_VAL;
		orb_in_corner_y_1 <= CORNER_Y_RESET_VAL;
	end else if (corners_input_valid_0) begin
		if (orb_in_corner_x_1 == image_width - 1) begin
			orb_in_corner_x_1 <= 0;
			orb_in_corner_y_1 <= orb_in_corner_y_1 + 1;
		end else begin
			orb_in_corner_x_1 <= orb_in_corner_x_1 + 1;
		end
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		q_flushing <= 0;
	end else if (in_begin_frame_reset) begin
		q_flushing <= 0;
	end else if (in_valid && (in_x == image_width - 1) && (in_y == image_height - 1)) begin
		q_flushing <= 1;
	end else if (out_frame_end) begin
		q_flushing <= 0;
	end
end

assign out_frame_end = pixel_window_input_valid && orb_input_valid_2 && (orb_in_corner_x_2 == image_width - X_MARGIN - 1) && (orb_in_corner_y_2 == image_height - Y_MARGIN - 1);

assign orb_not_in_margin_1 =
	orb_in_corner_x_1 >= $signed(X_MARGIN) &&
	orb_in_corner_y_1 >= $signed(Y_MARGIN) &&
	orb_in_corner_x_1 < $signed(image_width - X_MARGIN) &&
	orb_in_corner_y_1 < $signed(image_height - Y_MARGIN);

assign orb_in_consume = in_consume;

//outputs
assign out_corner_count_increment = orb_input_valid_2 && orb_is_corner_2 && pixel_window_input_valid;
assign out_descriptor = orb_out_descriptor;
assign out_valid = orb_out_valid;
assign out_feature_x = orb_out_corner_x;
assign out_feature_y = orb_out_corner_y;
assign out_request_stall = orb_out_request_stall;

//pixel window
SlidingWindow #(
	.DATA_BITS(LUMA_BITS),
	.WINDOW_NUM_ROWS(WINDOW_HEIGHT),
	.WINDOW_NUM_COLS(WINDOW_WIDTH),
	.MAX_ROW_LENGTH(MAX_IMAGE_WIDTH),
	.COORD_BITS(COORD_BITS)
) pixel_window_mod (
	.clk(clk),
	.reset(in_begin_frame_reset),
	.r_row_length(r_width),
	.in_valid(pixel_window_input_valid),
	.in_data(pixel_window_input_pixel),
	.out_window(pixel_window)
);

//corner detection
HarrisCornersAndNonmax #(
	.LUMA_BITS(LUMA_BITS),
	.MAX_IMAGE_WIDTH(MAX_IMAGE_WIDTH),
	.MATRIX_BITS(MATRIX_BITS),
	.NONMAX_SCORE_BITS(NONMAX_SCORE_BITS),
	.COORD_BITS(COORD_BITS)
) corner_mod (
	.clk(clk),
	.reset(in_begin_frame_reset),
	.r_width(r_width),
	.r_threshold(r_threshold),
	.in_valid(corners_input_valid_0),
	.in_window(corners_input_window),
	.out_is_corner(corners_is_local_max_1)
);

//buffer the input
always_ff @(posedge clk) begin
	if (reset) begin
		orb_input_valid_1 <= 0;
		orb_input_valid_2 <= 0;
		orb_is_corner_2 <= 0;
		//reset_1 <= reset;
		//reset_2 <= 0;
	end else if (pixel_window_input_valid) begin
		orb_input_valid_1 <= 1;
		orb_input_valid_2 <= orb_input_valid_1;
		orb_pixel_column_2 <= orb_pixel_column_1;
		orb_is_corner_2 <= orb_is_corner_1;
		orb_in_corner_x_2 <= orb_in_corner_x_1;
		orb_in_corner_y_2 <= orb_in_corner_y_1;
		//reset_1 <= reset;
		//reset_2 <= reset_1;
	end
end

//extract ORB descriptors for the corners found
ORBArbitrator #(
	.LUMA_BITS(LUMA_BITS),
	.PARALLEL_MODULES(PARALLEL_MODULES),
	.BITS_PER_CLOCK(BITS_PER_CLOCK),
	.COORD_BITS(COORD_BITS),
	.BUFFERING_STRATEGY(BUFFERING_STRATEGY)
) arbitrator_mod (
	.clk(clk),
	.in_valid(orb_input_valid_2 && pixel_window_input_valid),
	.in_col(orb_pixel_column_2),
	.in_is_corner(orb_is_corner_2),
	.in_reset(reset),
	.in_consume(orb_in_consume),
	.in_x(orb_in_corner_x_2[COORD_BITS-1:0]),
	.in_y(orb_in_corner_y_2[COORD_BITS-1:0]),
	.in_mask(in_mask),
	.out_descriptor(orb_out_descriptor),
	.out_valid(orb_out_valid),
	.out_feature_x(orb_out_corner_x),
	.out_feature_y(orb_out_corner_y),
	.out_request_stall(orb_out_request_stall)
);

endmodule
