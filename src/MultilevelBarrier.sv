/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module MultilevelBarrier(clk, reset, in_wait, out_release);

parameter NUM_LEVELS;
localparam COUNTER_BITS = 4;

input clk;
input reset;
input [NUM_LEVELS-1:0] in_wait;

output logic out_release;

logic [COUNTER_BITS-1:0] counters [NUM_LEVELS];
logic [NUM_LEVELS-1:0] hit_barrier;

always_comb begin
	for (int i = 0; i < NUM_LEVELS; i++) begin
		hit_barrier[i] = counters[i] != 0;
	end
	
	out_release = &hit_barrier;
end

always_ff @(posedge clk) begin
	for (int i = 0; i < NUM_LEVELS; i++) begin
		if (reset) begin
			counters[i] = 0;
		end else begin
			counters[i] = counters[i] + in_wait[i] - out_release;
		end
	end
end

endmodule
