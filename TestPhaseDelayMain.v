module TestPhaseDelayMain();
/***
This module tests the main module of the phase delay board.  It provides a test input signal, and programs the module with several different phase delays, then looks at the output to verify functionality.

Ted Golfinopoulos, 12 Aug 2012
***/

parameter F_CLK=20E6;
parameter F_SIG=100E3;
parameter NUM_SIZE=7;
parameter SEQ_SIZE=NUM_SIZE+4;

reg [SEQ_SIZE-1:0] seq1,seq2,seq3,seq4;

reg clk;
reg [10:0] clkDiv;
reg decoderInput;
reg f1;
wire sigOut;

integer i;

PhaseDelayMain myMain(clk, decoderInput, f1, sigOut);

initial begin
	$dumpfile ("TestPhaseDelayMainTestbench.vcd");
	$dumpvars;
end

initial begin
	$display("\tTime\tProgNum\tsigOut");
	$monitor("\t%d\t%b\t%b",$time, f1, sigOut);
end

initial begin
	#0
	clk=1'b1;
	clkDiv=0;
	f1=1'b0;

	seq1=0; //In phase
	seq2=128/4; //90 degrees out of phase
	seq3=128/2; //180 degrees out of phase
	seq4=3*128/4; //270 degrees out of phase
//	seq1=11'b01000000000; //In phase
//	seq2=11'b01001000000; //90 degrees out of phase
//	seq3=11'b01010000000; //180 degrees out of phase
//	seq4=11'b01011000000; //270 degrees out of phase

	$display("First sequence");

	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1024
		decoderInput=seq1[SEQ_SIZE-1-i];

//		$display("%d\t%b",i,decoderInput);
	end

	$display("Second sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq2[SEQ_SIZE-1-i];

//		$display("%d\t%b",i,decoderInput);
	end

	$display("Third sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq3[SEQ_SIZE-1-i];

//		$display("%d\t%b",i,decoderInput);
	end

	$display("Fourth sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq4[SEQ_SIZE-1-i];

//		$display("%d\t%b",i,decoderInput);
	end

	#50 $finish; //Stop simulation.
end

//Synthesize signals at different frequencies
always @(posedge clk) begin
	clkDiv=clkDiv+1;

	//Assume clkFreq=20E6; then 1/200 is 100 kHz
	if(clkDiv%(F_CLK/(2*F_SIG))==0) f1=~f1; //100 kHz, since period of signal is two inversions.
end

//Make clock
always begin
	#1
	clk=~clk; //Invert clock
end
endmodule

