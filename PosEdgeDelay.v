module PosEdgeDelay(clk, sigIn, waitCnt, sharedBit, sigOut);
/***
This module looks at a signal and uses a timer to delay rising edges.  Once the timer reaches the given number of clock cycles (specified by an input), an output is forced to a state which inverts one of the input bits, sharedBit.

Ted Golfinopoulos, 11 September 2012
***/

parameter WAIT_CNT_SIZE=11;
//parameter INVERT_FLAG=1'b0; //If high, invert output.

input clk, sigIn;
input [WAIT_CNT_SIZE-1:0] waitCnt;
input sharedBit; //The output bit inverts this input bit.
output sigOut;

reg sigInPosEdge, sigInPosEdgeLast;
reg [WAIT_CNT_SIZE-1:0] posEdgeDelayTimer;
reg sigOutReg;

initial begin
	#0
	sigOutReg=1'b0;
	posEdgeDelayTimer=1'b0;
	sigInPosEdge=1'b0;
	sigInPosEdgeLast=1'b0;
end

//Divide input signal down by 2; divided down signal has constant value between rising edges, and state changes on positive edges.  Sample for state changes in this divided down signal.
always @(posedge sigIn) begin
	sigInPosEdge=~sigInPosEdge; //Changes state on positive edges of sigIn.
end

//Check for state changes in sigInPosEdge, indicating rising edge in input signal.  Wait a specified delay time, and then impose the corresponding rising edge in the output signal.
always @(posedge clk) begin
	if(sigInPosEdgeLast != sigInPosEdge) begin
		posEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		sigInPosEdgeLast = sigInPosEdge; //Update positive edge state register.
		//$display("Divided signal state change, INVERT_FLAG=%b",INVERT_FLAG);
	end

	//Delay timer.
	//If timer has been reset, start counting until wait limit is reached.  Then, stop and update output.
	//Since this is the positive edge timer, the update is to force the output high.
	//After the output is forced high, the timer is incremented once more to unlock output.
	if(posEdgeDelayTimer<waitCnt) begin
		posEdgeDelayTimer=posEdgeDelayTimer+1'b1;
	end else if(posEdgeDelayTimer==waitCnt) begin //Leave timer locked at waitCnt
		posEdgeDelayTimer=posEdgeDelayTimer+1'b1;
		//Force output high, effecting rising edge.  But if INVERT_FLAG is high, force low.
		sigOutReg=~sharedBit;
		$display("time=%d,waitCnt=%d, sigOutReg=%b",$time,waitCnt, sigOutReg);
	end //Otherwise, don't increment timer any longer, and don't force the output state.
end

assign sigOut=sigOutReg; //Tie output to sigOutReg register, which is modified in clk always block.

endmodule

