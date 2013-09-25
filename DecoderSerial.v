module DecoderSerial(clk,progIn,progNum);
/***
This module reads in a serial program number, applies a sufficient wait to make sure the input is stable, and then updates the program number.

Ted Golfinopoulos, 10 Sep 2012
***/

parameter PROG_NUM_SIZE=8; //
parameter WAIT_TIME=256; //Number of clock cycles to wait before establishing that progNum is stable.

input [PROG_NUM_SIZE-1:0] progIn;
input clk;

reg [PROG_NUM_SIZE-1:0] progInReg, progNumReg;

reg [14:0] timer;

output [PROG_NUM_SIZE-1:0] progNum;

initial begin
	#0
	progInReg=1'b0;
	progNumReg=1'b0;
	timer=1'b0;
end

//Register progIn, wait for it to be stable for a sufficiently long period, and then update output.
always @(posedge clk) begin
	if( progIn!=progInReg ) begin //Reset timer
		progInReg=progIn; //Update progInReg
		timer=1'b0; //Reset timer that keeps track of how long state has been stable.
	end

	//Increment timer as long 
	if(timer<(WAIT_TIME-1)) begin
		timer=timer+1'b1; //Increment timer
	end else begin
		progNumReg=progInReg; //Otherwise, state has been stable for long enough - update output number.
	end
end

assign progNum=progNumReg; //Tie output to output register.

endmodule

