module EdgeDelay(clk, sigIn, waitCnt, sigOut, diagOut);
//module EdgeDelay(clk, sigIn, waitCnt, sigOut);
/***
This module looks at a signal and uses a timer to delay edges.  Once the timer reaches the given number of clock cycles (specified by an input), an output is forced high.

Ted Golfinopoulos, 12 September 2012
***/

parameter WAIT_CNT_SIZE=11;
parameter INVERT_FLAG=1'b0; //If high, invert output.
parameter MIN_WAIT=3'b10; //Minimum number of clock cycles that a state change must hold in order to count as valid.

input clk, sigIn;
input [WAIT_CNT_SIZE-1:0] waitCnt;
output sigOut;
//output divOut;
output diagOut; //Diagnostic output

reg [WAIT_CNT_SIZE-1:0] posEdgeDelayTimer;
reg [WAIT_CNT_SIZE-1:0] negEdgeDelayTimer;

reg sigOutReg;
reg sigLast;
reg sigReg;

reg resetFlag; //Changes state every time positive edge counter is reset.

initial begin
	#0
	sigOutReg=1'b0;
	posEdgeDelayTimer=1'b0;
	negEdgeDelayTimer=1'b0;
	sigLast=1'b0;
end

reg posEdgeReg, posEdgeRegLast, negEdgeReg, negEdgeRegLast;

always @(posedge sigIn) begin
	posEdgeReg=~posEdgeReg;
end

always @(negedge sigIn) begin
	negEdgeReg=~negEdgeReg;
end

//Check for state changes in sigInPosEdge, indicating rising edge in input signal.  Wait a specified delay time, and then impose the corresponding rising edge in the output signal.
always @(posedge clk) begin
	sigReg=sigIn;
	
	if(posEdgeRegLast!=posEdgeReg && posEdgeDelayTimer>MIN_WAIT) begin
		posEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		posEdgeRegLast=posEdgeReg;
	end else	if(negEdgeRegLast!=negEdgeReg && negEdgeDelayTimer>MIN_WAIT) begin
		negEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		negEdgeRegLast=negEdgeReg;
		resetFlag=~resetFlag;
	end
	
	/* ** POSITIVE EDGE DELAY ** */
	/*
	if(sigLast>sigReg) begin //Rising edge
		posEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		sigLast=sigReg; //Update signal register.
	end else if(sigLast<sigReg) begin //Falling edge // ** NEGATIVE EDGE DELAY ** //
		negEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		sigLast=sigReg; //Update signal register.
		resetFlag=~resetFlag;
	end
	*/
	
	//Delay timer.
	//If timer has been reset, start counting until wait limit is reached.  Then, stop and update output.
	//Since this is the positive edge timer, the update is to force the output high.
	//After the output is forced high, the timer is incremented once more to unlock output.
	if(posEdgeDelayTimer<waitCnt) begin
		posEdgeDelayTimer=posEdgeDelayTimer+1'b1;
	end else if(posEdgeDelayTimer==waitCnt) begin //Leave timer locked at waitCnt
		posEdgeDelayTimer=posEdgeDelayTimer+1'b1;
		sigOutReg=1'b1; //Set output high, effectively delaying rising edge.
	end //Otherwise, don't increment timer any longer, and don't force the output state.
	else

	//Delay timer.
	//If timer has been reset, start counting until wait limit is reached.  Then, stop and update output.
	//Since this is the positive edge timer, the update is to force the output high.
	//After the output is forced high, the timer is incremented once more to unlock output.
	if(negEdgeDelayTimer<waitCnt) begin
		negEdgeDelayTimer=negEdgeDelayTimer+1'b1;
	end else if(negEdgeDelayTimer==waitCnt) begin //Leave timer locked at waitCnt
		negEdgeDelayTimer=negEdgeDelayTimer+1'b1;
		sigOutReg=1'b0; //Set output low, effectively delaying falling edge.
	end //Otherwise, don't increment timer any longer, and don't force the output state.
end

assign sigOut=sigOutReg; //Tie output to sigOutReg register, which is modified in clk always block.
//assign divOut=sigLast; //Diagnostic output.

assign diagOut=negEdgeReg;

endmodule

//Triggering off of signal edges might be problematic.  Try using state changes.
/*
always @(posedge sigIn) begin
	sigInPosEdge=~sigInPosEdge; //Changes state on positive edges of sigIn.
end

always @(negedge sigIn) begin
	sigInNegEdge=~sigInNegEdge; //Changes state on negative edges of sigIn.
end
*/


/*
reg sigInPosEdge, sigInPosEdgeLast;
reg sigInNegEdge, sigInNegEdgeLast;

initial begin
	#0
	sigOutReg=1'b0;
	posEdgeDelayTimer=1'b0;
	negEdgeDelayTimer=1'b0;

	sigInPosEdge=1'b0;
	sigInNegEdge=1'b0;

	sigInPosEdgeLast=1'b0;
	sigInNegEdgeLast=1'b0;
end


always @(posedge clk) begin
	if(sigIn>sigLast) begin //Rising Edge.
		sigLast=sigIn;
		sigInPosEdge=~sigInPosEdge;
	end else if(sigIn<sigLast) begin //Falling edge
		sigLast=sigIn;
		sigInNegEdge=~sigInNegEdge;
	end
end

//Check for state changes in sigInPosEdge, indicating rising edge in input signal.  Wait a specified delay time, and then impose the corresponding rising edge in the output signal.
always @(posedge clk) begin
	// ** POSITIVE EDGE DELAY ** //
	if(sigInPosEdgeLast != sigInPosEdge) begin
		posEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		sigInPosEdgeLast = sigInPosEdge; //Update positive edge state register.
	end

	//Delay timer.
	//If timer has been reset, start counting until wait limit is reached.  Then, stop and update output.
	//Since this is the positive edge timer, the update is to force the output high.
	//After the output is forced high, the timer is incremented once more to unlock output.
	if(posEdgeDelayTimer<waitCnt) begin
		posEdgeDelayTimer=posEdgeDelayTimer+1'b1;
	end else if(posEdgeDelayTimer==waitCnt) begin //Leave timer locked at waitCnt
		posEdgeDelayTimer=posEdgeDelayTimer+1'b1;
		sigOutReg=1'b1; //Set output high, effectively delaying rising edge.
	end //Otherwise, don't increment timer any longer, and don't force the output state.

	// ** NEGATIVE EDGE DELAY ** //
	if(sigInNegEdgeLast != sigInNegEdge) begin
		negEdgeDelayTimer=1'b0; //Reset positive edge delay timer.
		sigInNegEdgeLast = sigInNegEdge; //Update positive edge state register.
	end

	//Delay timer.
	//If timer has been reset, start counting until wait limit is reached.  Then, stop and update output.
	//Since this is the positive edge timer, the update is to force the output high.
	//After the output is forced high, the timer is incremented once more to unlock output.
	if(negEdgeDelayTimer<waitCnt) begin
		negEdgeDelayTimer=negEdgeDelayTimer+1'b1;
	end else if(negEdgeDelayTimer==waitCnt) begin //Leave timer locked at waitCnt
		negEdgeDelayTimer=negEdgeDelayTimer+1'b1;
		sigOutReg=1'b0; //Set output low, effectively delaying falling edge.
	end //Otherwise, don't increment timer any longer, and don't force the output state.
end
*/