/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

`timescale 1ns/100ps

module NonmaxSuppressionTestbench();

localparam DATA_WIDTH = 3;
localparam NUM_TEST_CASES = 7;

struct {
	logic signed [DATA_WIDTH-1:0] window [3][3];
	logic is_corner;
} test_cases [NUM_TEST_CASES] = '{
	'{
		'{
			'{0, 0, 0},
			'{0, 0, 0},
			'{0, 0, 0}
		},
		1'b0
	},
	'{
		'{
			'{0, 0, 0},
			'{0, 0, 0},
			'{0, 0, 3'bx}
		},
		1'bx
	},
	'{
		'{
			'{0, 0, 0},
			'{0, 3, 0},
			'{0, 0, 0}
		},
		1'b1
	},
	'{
		'{
			'{3, 0, 0},
			'{0, 3, 0},
			'{0, 0, 0}
		},
		1'b0
	},
	'{
		'{
			'{0, 0, 0},
			'{0, 3, 0},
			'{0, 0, 3}
		},
		1'b1
	},
	'{
		'{
			'{0, 2, 0},
			'{2, 3, 1},
			'{0, 1, 3}
		},
		1'b1
	},
	'{
		'{
			'{-1, -1, -1},
			'{-1, 0, 0},
			'{-1, 0, 0}
		},
		1'b1
	}
};

logic clk;
integer cursor = 0;
integer error_count = 0;
logic is_local_max;
logic is_error;
logic signed [DATA_WIDTH-1:0] input_window [3][3];

assign input_window = test_cases[cursor].window;

NonmaxSuppression #(
	.DATA_BITS(DATA_WIDTH),
	.WINDOW_WIDTH(3),
	.WINDOW_HEIGHT(3),
	.THRESHOLD(0)
) test_mod (
	.window(input_window),
	.out(is_local_max)
);

initial begin
	$display("Testing NonmaxSuppression");
end

always begin
	clk = 0;
	#5;
	clk = 1;
	#5;
end

always_comb begin
	is_error = (is_local_max !== test_cases[cursor].is_corner);
end

always @(posedge clk) begin
	cursor <= cursor + 1;
	
	if (is_error) begin
		error_count <= error_count + 1;
		$display("Error at t=%d", cursor);
	end
end

endmodule
