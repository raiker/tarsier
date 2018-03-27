/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module CoordinateTransformerTestbench();

localparam OCTAVES = 4;
localparam LEVELS_PER_OCTAVE = 3;

localparam COORD_BITS = 16;
localparam [COORD_BITS-1:0] in_vals [11] = '{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 25};

integer cursor;
logic clk;
logic [COORD_BITS-1:0] out_vals [OCTAVES * LEVELS_PER_OCTAVE];

initial cursor = -1;

always begin
	clk = 1'b1;
	#5;
	clk = 1'b0;
	#5;
end

generate
	genvar i, j;
	for (i = 0; i < OCTAVES; i++) begin:octaves
		for (j = 0; j < LEVELS_PER_OCTAVE; j++) begin:sublevels
			localparam level = i * LEVELS_PER_OCTAVE + j;
			
			CoordinateTransformer #(
				.COORD_BITS(COORD_BITS),
				.OCTAVE(i),
				.SUBLEVEL(j)
			) ct (
				.in_coord(in_vals[cursor]),
				.out_coord(out_vals[level])
			);
		end
	end
endgenerate

always @(posedge clk) begin
	cursor++;
end

endmodule
