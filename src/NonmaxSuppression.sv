/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

module NonmaxSuppression(window, threshold, out);

parameter DATA_BITS = 16;
parameter WINDOW_WIDTH = 3;
parameter WINDOW_HEIGHT = 3;
localparam WINDOW_CENTRE_X = WINDOW_WIDTH / 2;
localparam WINDOW_CENTRE_Y = WINDOW_HEIGHT / 2;

input signed [DATA_BITS-1:0] window [WINDOW_HEIGHT][WINDOW_WIDTH];
input signed [15:0] threshold;
output logic out;

always_comb begin
	out = 1;
	if (window[WINDOW_CENTRE_X][WINDOW_CENTRE_Y] < threshold) begin
		out = 0;
	end
	
	for (int j = 0; j < WINDOW_HEIGHT; j++) begin
		for (int i = 0; i < WINDOW_WIDTH; i++) begin
			if (i != WINDOW_CENTRE_X || j != WINDOW_CENTRE_Y) begin
				//bias the +x, +y quadrant
				if (i >= WINDOW_CENTRE_X && j >= WINDOW_CENTRE_Y) begin
					if (window[i][j] > window[WINDOW_CENTRE_X][WINDOW_CENTRE_Y]) begin
						out = 0;
					end
				end else if (window[i][j] >= window[WINDOW_CENTRE_X][WINDOW_CENTRE_Y]) begin
					out = 0;
				end
			end
		end
	end
	for (int j = 0; j < WINDOW_HEIGHT; j++) begin
		for (int i = 0; i < WINDOW_WIDTH; i++) begin
			if (window[i][j] === 'hx) begin
				out = 'hx;
			end
		end
	end
end

endmodule
