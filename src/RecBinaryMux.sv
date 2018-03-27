/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module RecBinaryMux(clk, reset, in_data, in_valid, in_ready, out_data, out_valid, out_ready);

parameter DATA_WIDTH;
parameter LENGTH;

localparam LENGTH_A = LENGTH / 2;
localparam LENGTH_B = LENGTH - LENGTH_A;

input clk;
input reset;
input [DATA_WIDTH-1:0] in_data [LENGTH];
input in_valid [LENGTH];
output logic in_ready [LENGTH];
output logic [DATA_WIDTH-1:0] out_data;
output logic out_valid;
input out_ready;

generate
	if (LENGTH == 1) begin
		//single element
		assign out_data = in_data[0];
		assign out_valid = in_valid[0];
		assign in_ready[0] = out_ready;
	end else begin
		wire accept_input;
		
		wire [DATA_WIDTH-1:0] data_a, data_b;
		wire valid_a, valid_b;
		wire ready_a, ready_b;
		
		logic [DATA_WIDTH-1:0] data_in_a [LENGTH_A];
		logic [DATA_WIDTH-1:0] data_in_b [LENGTH_B];
		logic valid_in_a [LENGTH_A];
		logic valid_in_b [LENGTH_B];
		logic ready_in_a [LENGTH_A];
		logic ready_in_b [LENGTH_B];
		
		always_comb begin
			for (int i = 0; i < LENGTH_A; i++) begin
				data_in_a[i] = in_data[i];
				valid_in_a[i] = in_valid[i];
				in_ready[i] = ready_in_a[i];
			end
			
			for (int i = 0; i < LENGTH_B; i++) begin
				data_in_b[i] = in_data[i + LENGTH_A];
				valid_in_b[i] = in_valid[i + LENGTH_A];
				in_ready[i + LENGTH_A] = ready_in_b[i];
			end
		end
		
		//divide set into two chunks, conquer
		RecBinaryMux #(
			.DATA_WIDTH(DATA_WIDTH),
			.LENGTH(LENGTH_A)
		) subtree_a (
			.clk(clk),
			.reset(reset),
			.in_data(data_in_a),
			.in_valid(valid_in_a),
			.in_ready(ready_in_a),
			.out_data(data_a),
			.out_valid(valid_a),
			.out_ready(ready_a)
		);
		
		RecBinaryMux #(
			.DATA_WIDTH(DATA_WIDTH),
			.LENGTH(LENGTH_B)
		) subtree_b (
			.clk(clk),
			.reset(reset),
			.in_data(data_in_b),
			.in_valid(valid_in_b),
			.in_ready(ready_in_b),
			.out_data(data_b),
			.out_valid(valid_b),
			.out_ready(ready_b)
		);
		
		assign accept_input = !out_valid || out_ready;
		assign ready_a = accept_input && valid_a;
		assign ready_b = accept_input && !valid_a && valid_b;
		
		always_ff @(posedge clk) begin
			if (reset) begin
				out_valid <= 1'b0;
				out_data <= 'x;
			end else if (ready_a) begin
				out_valid <= 1'b1;
				out_data <= data_a;
			end else if (ready_b) begin
				out_valid <= 1'b1;
				out_data <= data_b;
			end else if (out_ready) begin
				out_valid <= 1'b0;
				out_data <= 'x;
			end
		end
	end
endgenerate

endmodule
