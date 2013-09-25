module PhaseDelayMain(clk, progIn, sigIn, sigOut);
/***
This module is the master control for a phase delay board.  Its operation is as follows:
1. Read sigIn every clock cycle
	a. create a period counter which counts one period.
2. sigOut is a delayed version of sigIn - state changes are delayed by an amount contained in a register set by parsed input from progIn.  It will not be buferred - merely, state changes are delayed.

Ted Golfinopoulos, 8 Aug 2012
***/

parameter F_CLK=10000000; //Clock frequency in Hz
parameter PROG_NUM_SIZE=8; //Number of bits in prog number register.
parameter NUM_CYCLE_DIV_LOG2=7; //This is log2(NUM_CYCLE_DIV).
parameter NUM_CYCLE_DIV=128; //Divide a phase cycle into this number of divisions - shift output signal by discrete fractional amounts up to this number.  When progNum=NUM_CYCLE_DIV, the output signal is delayed by 360 degrees.
parameter N_CLK_SIZE=8;
parameter WAIT_NUMERATOR_SIZE=PROG_NUM_SIZE+N_CLK_SIZE+2;

input clk, progIn, sigIn;
output wire sigOut;

wire [N_CLK_SIZE-1:0] n_clk;

//progNum is a number from 0 to NUM_CYCLE_DIV-1 specifying the percentage of a phase cycle to delay the output signal from the input signal.
wire [(PROG_NUM_SIZE-1):0] progNum;
reg [(PROG_NUM_SIZE-1):0] progNumLast;

reg scaleFac;
reg [(WAIT_NUMERATOR_SIZE-NUM_CYCLE_DIV_LOG2-1):0] waitCnt; //Wait this number of cycles when delaying state changes in sigOut.

//Calculation for delay time is tau = (phi/(2*pi))*T, where T=period of sigIn, phi=desired phase delay in radians.
//This is tau=progNum*T/(NUM_CYCLE_DIV).
//We will make NUM_CYCLE_DIV be a power of 2; then the division will become approximated by a bit shift equal to log2(NUM_CYCLE_DIV).  An intermediate result, waitNumerator, stores the numerator, and this is then divided via a bit shift.
reg [WAIT_NUMERATOR_SIZE-1:0] waitNumerator; //This is progNum*T, where T is the period in clock cycles, and progNum the fractional phase delay over NUM_CYCLE_DIV

reg [2:0] clkDiv; //Clock Divider.

counter_n c(clk,sigIn,n_clk);
defparam c.F_CLK=F_CLK/100; //Clock frequency in hundreds of Hz.
defparam c.M=1; //Number of signal cycles over which to average period.

Decoder dec(clk, progIn, progNum);
defparam dec.NUM_SIZE=PROG_NUM_SIZE;

always @(posedge clk) begin
	clkDiv=clkDiv+1'b1;
end

//Slow down waitNumerator calculation - do every 16 clock cycles.
always @(posedge clkDiv[2]) begin
	waitNumerator=progNum*n_clk;
	//Divide the waitNumerator by NUM_CYCLE_DIV,
	//which is approximately equal to taking the last log2(NUM_CYCLE_DIV)+1 bits.
	waitCnt=waitNumerator[WAIT_NUMERATOR_SIZE:(NUM_CYCLE_DIV_LOG2+1)];
end

Delay d(clk, sigIn, waitCnt, sigOut);
defparam d.WAIT_CNT_SIZE=WAIT_NUMERATOR_SIZE-NUM_CYCLE_DIV_LOG2-1;

endmodule

