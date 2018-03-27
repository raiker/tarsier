/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module CoordinateTransformer(in_coord, out_coord);

parameter COORD_BITS = 16;
parameter OCTAVE;
parameter SUBLEVEL;

//Translate a coordinate at a higher level of the pyramid into its base-level coordinate
//Round to nearest
//trust me, this works
localparam MULTIPLIER = 2 ** (OCTAVE + 1) * 5 ** SUBLEVEL;
localparam ADDEND = (2 ** OCTAVE - 1) * 5 ** SUBLEVEL + 4 ** SUBLEVEL; //the second term here does the round-to-nearest
localparam SHIFT = 2 * SUBLEVEL + 1;

input [COORD_BITS-1:0] in_coord;
output [COORD_BITS-1:0] out_coord;

integer int1, int2;

assign int1 = in_coord * (* multstyle = "logic" *) MULTIPLIER + ADDEND;
assign int2 = int1 >> SHIFT;
assign out_coord = int2[COORD_BITS-1:0];

endmodule
