module Filter(clk, sigIn, sigOut);
/***
A low-pass filter, requiring an input signal to be stable for a certain number of clock cycles before allowing output to change.  The input size and wait time are set by parameters.

Ted Golfinopoulos, 19 Sep 2012
***/


parameter MIN_TIME=1000; //Minimum number of clock cycles input must be stable for allowing a change.
parameter SIZE=10; //Number of bits of input.

reg [SIZE-1:0] sigInLast, sigOutReg;
reg [10:0] waitCnt;

input clk;
input [SIZE-1:0] sigIn;
output [SIZE-1:0] sigOut;

always @(posedge clk) begin
	if(sigInLast!=sigIn) begin
		sigInLast=sigIn;
		waitCnt=1'b0; //Reset counter
	end else if(waitCnt<MIN_TIME) begin
		waitCnt=waitCnt+1'b1;
	end else if(waitCnt>=MIN_TIME) begin
		sigOutReg=sigInLast;
	end
end

assign sigOut=sigOutReg;

endmodule
