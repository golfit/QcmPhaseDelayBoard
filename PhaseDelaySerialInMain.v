module PhaseDelaySerialInMain(clk, progIn, sigIn, sigOut);
/***
This module is the master control for a phase delay board.  Its operation is as follows:
1. Read sigIn every clock cycle
	a. create a period counter which counts one period.
2. sigOut is a delayed version of sigIn - state changes are delayed by an amount contained in a register set by parsed input from progIn.  It will not be buferred - merely, state changes are delayed.

progIn is a serial input in this version.

Ted Golfinopoulos, 8 Aug 2012

PIN ASSIGNMENTS
14 Sep 2012

Ok		clk	Location	PIN_H5	Yes		CLOCK	
Ok		progIn[7]	Location	PIN_A7	Yes		2A/PIN_65 - Program number - phase delay is specified here.	
Ok		progIn[6]	Location	PIN_A8	Yes		2C / PIN_64	
Ok		progIn[5]	Location	PIN_A9	Yes		4C / PIN_63	
Ok		progIn[4]	Location	PIN_A12	Yes		7A / PIN_60	
Ok		progIn[3]	Location	PIN_E16	Yes		7C / PIN_51	
Ok		progIn[2]	Location	PIN_F16	Yes		9C / PIN_49	
Ok		progIn[1]	Location	PIN_A13	Yes		11A / PIN_58	
Ok		progIn[0]	Location	PIN_A15	Yes		11C / PIN_57	
Ok		sigIn	Location	PIN_G1	Yes		Input 1 / PIN_79 / Ch 1 + in / Carries input TTL signal to delay.	
Ok		sigOut	Location	PIN_N1	Yes		Output 4 / PIN_9 / Delayed signal.	
Ok		divOut	Location	PIN_K1	Yes		Diagnostic output to test internal divided-down input signal.	
***/

//parameter F_CLK=16000000; //64000000; //Clock frequency in Hz
//parameter NUM_CYCLE_DIV=64; //Divide a phase cycle into this number of divisions - shift output signal by discrete fractional amounts up to this number.  When progNum=NUM_CYCLE_DIV, the output signal is delayed by 360 degrees.
parameter PROG_NUM_SIZE=6; //Number of bits in prog number register.
parameter N_CLK_SIZE=9; //Pick this from ceil(log2(F_CLK/F_SIG_MIN))
parameter WAIT_NUMERATOR_SIZE=PROG_NUM_SIZE+N_CLK_SIZE;

input [PROG_NUM_SIZE-1:0] progIn;
input clk, sigIn;
output wire sigOut;

wire [N_CLK_SIZE-1:0] n_clk;

//progNum is a number from 0 to NUM_CYCLE_DIV-1 specifying the percentage of a phase cycle to delay the output signal from the input signal.
wire [(PROG_NUM_SIZE-1):0] progNum;
reg [(PROG_NUM_SIZE-1):0] progNumLast;

reg [N_CLK_SIZE-1:0] waitCnt; //Wait this number of cycles when delaying state changes in sigOut.

//Calculation for delay time is tau = (phi/(2*pi))*T, where T=period of sigIn, phi=desired phase delay in radians.
//This is tau=progNum*T/(NUM_CYCLE_DIV).
//We will make NUM_CYCLE_DIV be a power of 2; then the division will become approximated by a bit shift equal to log2(NUM_CYCLE_DIV).  An intermediate result, waitNumerator, stores the numerator, and this is then divided via a bit shift.
reg [WAIT_NUMERATOR_SIZE-1:0] waitNumerator; //This is progNum*T, where T is the period in clock cycles, and progNum the fractional phase delay over NUM_CYCLE_DIV

counter c(clk,sigIn,n_clk);
defparam c.N_CLK_SIZE=N_CLK_SIZE;

DecoderSerial dec(clk, progIn, progNum);
defparam dec.PROG_NUM_SIZE=PROG_NUM_SIZE;
//assign progNum=6'b111111;

//Clock the wait time calculation with the signal - this is the fastest rate that
//the period value, n_clk, can change, and progNum should change more slowly.
//It should allow more time for the multiplication calculation to complete.

always @(posedge sigIn) begin
	waitNumerator=progNum*n_clk;
	//For use with edge or cache delay.
	waitCnt=waitNumerator[WAIT_NUMERATOR_SIZE-1:PROG_NUM_SIZE];
end

CacheDelay d(clk, sigIn, waitCnt, sigOut);
defparam d.WAIT_CNT_SIZE=N_CLK_SIZE;
defparam d.CACHE_SIZE=550; //defparam d.CACHE_SIZE=1650;

endmodule

//module PhaseDelaySerialInMain(clk, progIn, sigIn, sigOut,diagOut);
//module PhaseDelaySerialInMain(clk, progIn, sigIn, sigOut, waitCntOut, n_clkOut, progNumOut);

//DIAGNOSTIC OUTPUTS
/*
output wire [N_CLK_SIZE-1:0] waitCntOut;
output wire [N_CLK_SIZE-1:0]  n_clkOut;
output wire [(PROG_NUM_SIZE-1):0] progNumOut;
assign waitCntOut=waitCnt;
assign n_clkOut=n_clk;
assign progNumOut=progNum;
*/

/*
counter_n c(clk,sigIn,n_clk);
defparam c.F_CLK=F_CLK/100; //Clock frequency in hundreds of Hz.
defparam c.M=1; //Number of signal cycles over which to average period.
defparam c.CLK_COUNTER_SIZE=N_CLK_SIZE;
*/

//Filter f(clk, waitNumerator[WAIT_NUMERATOR_SIZE-1:PROG_NUM_SIZE], waitCnt);
//defparam f.SIZE=N_CLK_SIZE;
//defparam f.MIN_TIME=600; //Minimum number of clock cycles that wait time must be constant before allowing change in the actual waitCnt value.

/*
LPM_MULT m(.result(waitNumerator),.dataa(progNum),.datab(n_clk) ,.clock(sigIn)); //Define multiplication module 
defparam m.MAXIMIZE_SPEED=10; //Increase speed priority in implementation.
defparam m.LPM_WIDTHA=PROG_NUM_SIZE;
defparam m.LPM_WIDTHB=N_CLK_SIZE;
defparam m.LPM_PIPELINE=1;
*/

/*
always @(posedge clk) begin
	waitNumerator=progNum*n_clk;
	//$display("progNum=%b, n_clk=%b", progNum, n_clk);
	//Divide the waitNumerator by NUM_CYCLE_DIV,
	//which is approximately equal to taking the last log2(NUM_CYCLE_DIV)+1 bits.

	//For use with edge delay.
	//waitCnt=waitNumerator[WAIT_NUMERATOR_SIZE-1:PROG_NUM_SIZE];
	
	// ********TEST******* //
	//waitCnt=5'b1000;
	
	//If most significant bit of waitNumerator is high, then delay time is longer than half a period.
	//In this case, invert input signal to delay timer, and delay by tau_delay-(tau_period/2).
	//Otherwise, don't invert input signal, and delay by full tau_delay.

	//If waitCnt>=n_clk/2
//
	invertFlag=(waitNumerator[WAIT_NUMERATOR_SIZE-1:(PROG_NUM_SIZE)]>=n_clk[N_CLK_SIZE-1:1]);
	if(invertFlag) begin	
		//Delay is longer than half a period
		//n_clk[N_CLK_SIZE-1:1]=tau_period / 2
		waitCnt=waitNumerator[WAIT_NUMERATOR_SIZE-1:(PROG_NUM_SIZE)] - n_clk[N_CLK_SIZE-1:1];
	end else begin
		waitCnt=waitNumerator[WAIT_NUMERATOR_SIZE-1:(PROG_NUM_SIZE)];
	end
//
//	waitCnt=waitNumerator[WAIT_NUMERATOR_SIZE-1:(PROG_NUM_SIZE)] - waitNumerator[PROG_NUM_SIZE+PROG_NUM_SIZE-1]*n_clk[N_CLK_SIZE-1:1];

	//$display("sigIn=%b, sigInEffective=%b, waitCnt=%d, waitCntMSB=%b, waitNumeratorMSB=%b", sigIn, (waitNumerator[WAIT_NUMERATOR_SIZE-1])+sigIn, waitCnt, waitCnt[N_CLK_SIZE-1], waitNumerator[WAIT_NUMERATOR_SIZE-1]);
	//$display("sigIn=%b, sigInEffective=%b, waitCnt=%d, waitCntLast=%b, waitNumeratorLast=%b, waitCnt=%b, waitNumerator=%b", sigIn, invertFlag+sigIn, waitCnt, waitCnt[PROG_NUM_SIZE-1], (waitNumerator[WAIT_NUMERATOR_SIZE-1]), waitCnt, waitNumerator);
end
*/

//Invert sigIn if required to delay for longer than half the signal period.
//Delay d(clk, invertFlag+sigIn, waitCnt[N_CLK_SIZE-1-1:0], sigOut);
//defparam d.WAIT_CNT_SIZE=N_CLK_SIZE-1; 

//EdgeDelay d(clk, sigIn, waitCnt, sigOut,diagOut);
//EdgeDelay d(clk, sigIn, waitCnt, sigOut);
//CacheDelay d(clk, sigIn, waitCnt, sigOut, diagOut);
