module TestDelay();
/***
This module tests the Delay module. 

Ted Golfinopoulos, 11 August 2012 
***/

parameter WAIT_CNT_SIZE=11;

reg clk;
reg [10:0] clkDiv;

reg sigIn, f1, f2, f3; //Input signal and three different signal frequencies.

reg [WAIT_CNT_SIZE-1:0] waitCnt; //Number of clock cycles 

wire sigOut;
integer i;
Delay d(clk, sigIn, waitCnt, sigOut);
defparam d.WAIT_CNT_SIZE=WAIT_CNT_SIZE;

initial begin
	$dumpfile ("TestDelayTestbench.vcd");
	$dumpvars;
end

initial begin
	$display("\tTime\tsigIn\tsigOut");
	$monitor("\t%d\t%b\t%b",$time, sigIn,sigOut);
end

initial begin
	#0
	clk=1'b1;
	clkDiv=0;
	f1=1'b0;
	f2=1'b0;
	f3=1'b0;
	waitCnt=8;

	for(i=0; i<1000; i=i+1) begin	
		#1
		sigIn=f3;
	end

	waitCnt=4;

	for(i=0; i<1000; i=i+1) begin	
		#1
		sigIn=f3;
	end

	waitCnt=3;

	for(i=0; i<1000; i=i+1) begin	
		#1
		sigIn=f2;
	end

	#50 $finish; //Stop simulation.
end

//Synthesize signals at different frequencies
always @(posedge clk) begin
	clkDiv=clkDiv+1;

	//Assume clkFreq=1E6; then 1/5 clock frequency = 200 kHz, 1/10=100 kHz, 1/20=50 kHz
	if(clkDiv%8==0) f1=~f1; //250 kHz, since period of signal is two inversions.
	if(clkDiv%16==0) f2=~f2; //125 kHz
	if(clkDiv%32==0) f3=~f3; //62.5 kHz
end

//Make clock
always begin
	#1
	clk=~clk; //Invert clock
end

endmodule

