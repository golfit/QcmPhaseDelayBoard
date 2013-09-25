module TestPhaseDelaySerialInMain();
/***
This module tests the PhaseDelaySerialInMain.v module and the sub-modules for which it has a dependency.  In this setup, a serial number is read on a number of input bits, specifying the phase delay.  The input signal is clocked to yield a frequency measurement, and the number of clock cycles corresponding to the required phase delay calculated.  In parallel, the input signal is delayed by the appropriate number of clock cycles.

Ted Golfinopoulos, 11 September 2012
***/

parameter F_CLK=10E6;
parameter F_SIG=100E3;
parameter NUM_SIZE=7;
parameter N_CLK_SIZE=8; //Number of bits in clock counter registers.  Pick from ceil(log2(F_CLK/F_SIG_MIN)).
parameter SEQ_SIZE=NUM_SIZE+4;
parameter PROG_NUM_MAX=128;
parameter NUM_CLOCKS_PER_TEST=50; //For each test, allow this many clock cycles for the input signal before changing program number.

reg [SEQ_SIZE-1:0] seq1,seq2,seq3,seq4;

reg clk;
reg [10:0] clkDiv;
reg [NUM_SIZE-1:0] progIn;
reg f1;
wire sigOut;

//Diagnostic outputs of phase delay module
/*
wire [N_CLK_SIZE-1:0] waitCnt;
wire [NUM_SIZE-1:0] progNum;
wire [N_CLK_SIZE-1:0] n_clk;
*/
integer i;

PhaseDelaySerialInMain myMain(clk, progIn, f1, sigOut);
//PhaseDelaySerialInMain myMain(clk, progIn, f1, sigOut, waitCnt, n_clk, progNum); //With diagnostic outputs
defparam myMain.F_CLK=F_CLK;
defparam myMain.PROG_NUM_SIZE=NUM_SIZE;
defparam myMain.NUM_CYCLE_DIV=PROG_NUM_MAX; //2^NUM_SIZE.
defparam myMain.N_CLK_SIZE=N_CLK_SIZE;

initial begin
	$dumpfile ("TestPhaseDelayMainTestbench.vcd");
	$dumpvars;
end

initial begin
//	$display("\tTime \t sigIn\t sigOut\t progIn\t progNum\t n_clk\t waitCnt");
//	$monitor("\t%d\t%b\t%d\t%d\t%d\t%d\t%d",$time, f1, sigOut,progIn, progNum, n_clk,waitCnt);
	$display("\tTime \t sigIn\t sigOut");
	$monitor("\t%d\t%b\t%b",$time, f1, sigOut);

end

initial begin
	#0
	clk=1'b1;
	clkDiv=0;
	f1=1'b0;

	seq1=0; //In phase
	seq2=PROG_NUM_MAX/4; //90 degrees out of phase
	seq3=PROG_NUM_MAX/2-1; //180 degrees out of phase
	seq4=3*PROG_NUM_MAX/4; //270 degrees out of phase

	#10
	progIn=seq1;

	#((F_CLK/F_SIG)*NUM_CLOCKS_PER_TEST)
	progIn=seq2;

	#((F_CLK/F_SIG)*NUM_CLOCKS_PER_TEST)
	progIn=seq3;

	#((F_CLK/F_SIG)*NUM_CLOCKS_PER_TEST)
	progIn=seq4;

	#((F_CLK/F_SIG)*NUM_CLOCKS_PER_TEST)
	$finish; //Stop simulation.
	
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

