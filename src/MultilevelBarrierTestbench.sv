/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps
module MultilevelBarrierTestbench();

localparam NUM_LEVELS = 5;
localparam NUM_TEST_DATA = 21;

typedef struct {
    logic [NUM_LEVELS-1:0] wait_signals;
    logic reset;
    logic expected_release;
} TestCase;

localparam TestCase TEST_DATA [NUM_TEST_DATA] = '{
    '{5'b00000, 1'b1, 1'bx},
    '{5'b00000, 1'b0, 1'b0},
    '{5'b11111, 1'b0, 1'b0},
    '{5'b00000, 1'b0, 1'b1},
    '{5'b00001, 1'b0, 1'b0},
    '{5'b00010, 1'b0, 1'b0},
    '{5'b00100, 1'b0, 1'b0},
    '{5'b01000, 1'b0, 1'b0},
    '{5'b10000, 1'b0, 1'b0},
    '{5'b00000, 1'b0, 1'b1},
    '{5'b00111, 1'b0, 1'b0},
    '{5'b00000, 1'b1, 1'b0},
    '{5'b00111, 1'b1, 1'b0},
    '{5'b00000, 1'b0, 1'b0},
    '{5'b00001, 1'b0, 1'b0},
    '{5'b11111, 1'b0, 1'b0},
    '{5'b11110, 1'b0, 1'b1},
    '{5'b00000, 1'b0, 1'b1},
    '{5'b00000, 1'b0, 1'b0},
    '{5'b00000, 1'b0, 1'b0},
    '{5'b00000, 1'b0, 1'b0}
};

logic clk;
logic reset;
logic [NUM_LEVELS-1:0] wait_signals;
logic barrier_release;
integer read_head;

MultilevelBarrier #(
    .NUM_LEVELS(NUM_LEVELS)
) barrier (
    .clk(clk),
    .reset(reset),
    .in_wait(wait_signals),
    .out_release(barrier_release)
);

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end

initial read_head = 0;

assign reset = TEST_DATA[read_head].reset;
assign wait_signals = TEST_DATA[read_head].wait_signals;

always @(posedge clk) begin
    if (barrier_release != TEST_DATA[read_head].expected_release) begin
        $display("Error at t = %d", read_head);
    end
    read_head += 1;
end

endmodule