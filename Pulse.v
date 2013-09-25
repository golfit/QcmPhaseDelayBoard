module Pulse(clk, start, out);
/***
This module turns on an output flag for a single clock cycle.

Ted Golfinopoulos, 10 Aug 2012.
*/

input start;
output wire out;

always @(posedge clk) begin
	if(start and !out) out=1'b1;
	else if(out) out=1'b0;
	end
end


endmodule

