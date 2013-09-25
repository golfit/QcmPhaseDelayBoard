module CacheDelay(clk, sigIn, waitCnt, sigOut);
/***
This delay works by caching a large number of signal inputs on clock (pos) edges, and selecting where in the time series to output based on the requested delay.  The last element in the cache is popped, and the first (zeroth) element pushed, on every clock cycle.

Ted Golfinopoulos, 19 Sep 2012
***/

parameter WAIT_CNT_SIZE=12; //Cache must have same number of bits as maximum number in wait counter.
parameter CACHE_SIZE=2048;

//Make a huge cache.
reg [CACHE_SIZE-1:0] cache;
input [WAIT_CNT_SIZE-1:0] waitCnt;

input clk;
input sigIn;

output sigOut;

reg sigOutReg;

initial begin
	#0
	cache=1'b0; //Reset cache.
end

always @(posedge clk) begin
	cache={cache[CACHE_SIZE-2:0],sigIn}; //Pop out oldest data point, and push newest data point.
end

assign sigOut=cache[waitCnt]; //Look up Index, waitCnt, in cache.

endmodule

//module CacheDelay(clk, sigIn, waitCnt, sigOut, diagOut);

//output diagOut;

//Try a shift operation
//cache=(cache<<1)+sigIn;

//assign diagOut=cache[3]; //Diagnostic out

