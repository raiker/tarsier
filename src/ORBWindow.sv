/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module ORBWindow(clk, in_valid, in_col, in_coord1, in_coord2, in_flush, in_mode, out_patch_valid, out_xmoment, out_ymoment, out_pix1, out_pix2);
//A flush cycle takes STORAGE_LENGTH clocks, in which all the internal registers are zeroed out and the module becomes ready to accept input
//While flushing, all input is ignored
//A further STORAGE_LENGTH clocks are required to fill the patch with input. Once filled, out_patch_valid goes high
//Once the patch is valid, the module may be switched into random access mode by resetting in_mode
//In random access mode, the coordinates select the pixel values to be sampled and output
//When random access is finished, setting in_mode switches the module back into write mode
//The module will take a further WINDOW_SIZE_X clocks before it is once again valid

parameter LUMA_BITS = 8;
parameter COORD_BITS = 6;
parameter MOMENT_BITS = 24;

localparam WINDOW_SIZE_X = 37;
localparam WINDOW_SIZE_Y = 37;
localparam HALF_WIDTH = WINDOW_SIZE_X / 2;
localparam HALF_HEIGHT = WINDOW_SIZE_Y / 2;
localparam Y_CENTRE = HALF_HEIGHT;

localparam INPUT_COLUMN_ADDR = 0;
localparam WINDOW_BEGIN_ADDR = -$clog2(WINDOW_SIZE_Y) - 3; //adder tree delay + extra delay from XMoment calculation
localparam WINDOW_CENTRE_ADDR = WINDOW_BEGIN_ADDR - HALF_WIDTH - 1;
localparam WINDOW_END_ADDR = WINDOW_BEGIN_ADDR - WINDOW_SIZE_X;
localparam STORAGE_LENGTH = -WINDOW_END_ADDR;

localparam X_ADDRESS_BITS = $clog2(STORAGE_LENGTH);
localparam Y_ADDRESS_BITS = $clog2(WINDOW_SIZE_Y);
localparam ROW_LENGTH = 2**X_ADDRESS_BITS; //length of row memory
localparam XMOMENT_BITS = $clog2(HALF_WIDTH * (HALF_WIDTH+1) * WINDOW_SIZE_Y / 2) + LUMA_BITS + 1;
localparam YMOMENT_BITS = $clog2(HALF_HEIGHT * (HALF_HEIGHT+1) * WINDOW_SIZE_X / 2) + LUMA_BITS + 1;

localparam READ_VALID_DELAY = ROW_LENGTH - WINDOW_SIZE_X;

input clk;
input in_valid;
input [LUMA_BITS-1:0] in_col [WINDOW_SIZE_Y]; //incoming column of pixels
input signed [COORD_BITS-1:0] in_coord1 [2]; //(x,y) coordinate of sample 1
input signed [COORD_BITS-1:0] in_coord2 [2]; //(x,y) coordinate of sample 2
input in_flush; //1 = begin flush cycle, 0 = nothing
input in_mode; //1 = write (sampling hardware disabled, write 1 column per clock, update moments)
               //0 = read (sampling hardware enabled, column input disabled, moments stable)

output out_patch_valid; //if the patch is valid (at least STORAGE_LENGTH clocks since the last flush/transition to write mode)
output logic [LUMA_BITS-1:0] out_pix1, out_pix2; //pixel values of samples (only valid in read mode)
output logic [MOMENT_BITS-1:0] out_xmoment, out_ymoment; //output moment values (valid when patch is valid)

logic mode;
logic patch_dirty; //1 if we've missed writing a column because we're in read mode
logic [X_ADDRESS_BITS-1:0] fill_counter, next_fill_counter;
logic [X_ADDRESS_BITS:0] mem_valid_counter, next_mem_valid_counter;

logic q_write_col;
logic q_read;
logic q_flush_start;

logic [X_ADDRESS_BITS-1:0] x_addresses [2];
logic [LUMA_BITS-1:0] rowdata_out [WINDOW_SIZE_Y][2];

logic signed [XMOMENT_BITS-1:0] xmoment;
logic signed [YMOMENT_BITS-1:0] ymoment, ymoment_early;
logic xmoment_valid, ymoment_valid, ymoment_valid_early;

logic [X_ADDRESS_BITS-1:0] write_col_addr, x_centre, read_col_addr; //x address of the write column, centre of the patch, and column to be evicted
logic [LUMA_BITS-1:0] write_col [WINDOW_SIZE_Y]; //the column to be written
logic [LUMA_BITS-1:0] read_col [WINDOW_SIZE_Y]; //the column to be evicted
logic [LUMA_BITS-1:0] delayed_col [WINDOW_SIZE_Y]; //the column delayed by the width of the window

logic signed [X_ADDRESS_BITS-1:0] x_coord_1, x_coord_2; //for sign extension
logic signed [Y_ADDRESS_BITS-1:0] y_coord_1, y_coord_2;

logic [LUMA_BITS-1:0] vis_col [WINDOW_SIZE_Y];

always_comb begin
	for (int i = 0; i < 37; i++) begin
		if (in_valid) begin
			vis_col[i] = in_col[i];
		end else begin
			vis_col[i] = 8'hxx;
		end
	end
end

generate
	genvar i;
	
	for (i = 0; i < WINDOW_SIZE_Y; i++) begin : rows
		orb_window_row_ram ram (
			.clock (clk),
			.address_a (x_addresses[0]),
			.address_b (x_addresses[1]),
			.data_a (write_col[i]),
			.data_b (8'hcc),
			.wren_a (q_write_col),
			.wren_b (1'b0),
			.q_a (rowdata_out[i][0]),
			.q_b (rowdata_out[i][1])
		);
		
		ShiftRegister #(
			.DATA_BITS(LUMA_BITS),
			.LENGTH(WINDOW_SIZE_X)
		) column_delay_chain (
			.clk(clk),
			.reset(q_flush_start),
			.wr_en(q_write_col),
			.in(in_col[i]),
			.out(delayed_col[i])
		);
	end
endgenerate

XMoment #(
	.LUMA_BITS(LUMA_BITS),
	.WINDOW_SIZE_X(WINDOW_SIZE_X),
	.WINDOW_SIZE_Y(WINDOW_SIZE_Y)
) xmoment_mod (
	.clk(clk),
	.in_reset(q_flush_start),
	.in_valid(q_write_col),
	.in_column(write_col),
	.out_xmoment(xmoment),
	.out_valid(xmoment_valid)
);

YMoment #(
	.LUMA_BITS(LUMA_BITS),
	.WINDOW_SIZE_X(WINDOW_SIZE_X),
	.WINDOW_SIZE_Y(WINDOW_SIZE_Y)
) ymoment_mod (
	.clk(clk),
	.in_reset(q_flush_start),
	.in_valid(q_write_col),
	.in_column(write_col),
	.in_peek_column(read_col),
	.out_ymoment(ymoment_early),
	.out_valid(ymoment_valid_early)
);

ShiftRegister #(
	.DATA_BITS(YMOMENT_BITS + 1),
	.LENGTH(2)
) ymoment_delay_chain (
	.clk(clk),
	.reset(q_flush_start),
	.wr_en(q_write_col),
	.in({ymoment_early, ymoment_valid_early}),
	.out({ymoment, ymoment_valid})
);

assign out_xmoment = xmoment; //sign extension
assign out_ymoment = ymoment;

initial begin
	write_col_addr = 0;
end

always_comb begin
	x_centre = write_col_addr - INPUT_COLUMN_ADDR + WINDOW_CENTRE_ADDR;
	
	for (int i = 0; i < WINDOW_SIZE_Y; i++) begin
		read_col[i] = delayed_col[i];
	end
	
	write_col = in_col;
	
	x_coord_1 = in_coord1[0];
	x_coord_2 = in_coord2[0];
	
	if (q_read) begin //random access read
		x_addresses[0] = x_coord_1 + x_centre;
		x_addresses[1] = x_coord_2 + x_centre;
		out_pix1 = rowdata_out[y_coord_1 + Y_CENTRE][0];
		out_pix2 = rowdata_out[y_coord_2 + Y_CENTRE][1];
	end else begin
		x_addresses[0] = write_col_addr; //write port
		x_addresses[1] = 0; //read port
		out_pix1 = 'x;
		out_pix2 = 'x;
	end
end

always_comb begin
	if (q_flush_start) begin
		next_fill_counter = q_write_col ? STORAGE_LENGTH - 1 : STORAGE_LENGTH;
		next_mem_valid_counter = q_write_col ? READ_VALID_DELAY - 1 : READ_VALID_DELAY;
	end else begin
		if (q_write_col && fill_counter > 0) begin
			next_fill_counter = fill_counter - 1;
		end else begin
			next_fill_counter = fill_counter;
		end
		
		if (q_write_col && mem_valid_counter > 0) begin
			next_mem_valid_counter = mem_valid_counter - 1;
		end else begin
			next_mem_valid_counter = mem_valid_counter;
		end
	end
end

//sequential logic
always @(posedge clk) begin
	//update fill counter
	fill_counter <= next_fill_counter;
	mem_valid_counter <= next_mem_valid_counter;
	
	if (q_write_col) begin
		//update pointers
		write_col_addr <= write_col_addr + 1; //should wrap
	end
	
	mode <= in_mode;
	
	y_coord_1 = in_coord1[1];
	y_coord_2 = in_coord2[1];

	//the patch becomes dirty if a column is received while we are in read mode
	//we try to avoid this by stalling input
	if (q_read && in_valid) begin
		patch_dirty <= 1;
	end else if (out_patch_valid) begin
		patch_dirty <= 0;
	end
end

assign out_patch_valid = (fill_counter == 0) && xmoment_valid && ymoment_valid && !q_flush_start && !q_read;

assign q_write_col = (in_mode == 1) && in_valid && !in_flush;
assign q_read = (in_mode == 0);

//don't bother flushing unless the patch is actually dirty
assign q_flush_start = in_flush || (in_mode == 1 && mode == 0 && patch_dirty);

endmodule
