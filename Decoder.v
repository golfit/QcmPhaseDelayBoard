module Decoder(clk, sig, numOut);
/***
This module decodes an input signal, sig, reading a number, num.  The encoding is as follows: an initial HIGH pulse of length, tau_w clock cycles, appears, followed by an LOW pulse of equal length.  After the LOW pulse, the bits are encoded from most significant bit to least in time bins of length, tau_w, with bins adjacent to one another.  Finally, the input goes LOW. For example, a bit sequence along the lines of

1110001111110001110000000

would give a binary number, 1101.

This module decodes the signal by timing the initial HIGH pulse to determine tau_w, and then averaging a portion of the input sequence in each time bin of the recorded length, tau_w.

Ted Golfinopoulos, 9 Aug 2012
*/

parameter NUM_SIZE=7;
parameter TIMER_SIZE=13; //Number of bits in timer for measuring duration of ON/OFF pulses in clock cycles.  For 10E6 Hz clock and 2E3 Hz maximum input signal, ON/OFF pulses are 1/2E3 Hz = 500 us, so register has to be able to count to at least 10E6/2E3 = 5E3 < 2^13 = 8192.

parameter THRESHOLD_TIME=127; //Number of consecutive clock cycles that the signal must hold its value before the state is accepted as genuine.

input clk, sig;

output wire [NUM_SIZE-1:0] numOut;

reg [NUM_SIZE-1:0] newNum, lastNum;

reg [3:0] numIndex; //Number to indicate where to index into encoded binary number.

reg sigLast; //Bit holding last value of input state.

//Timers and pulse width registers.
reg [TIMER_SIZE-1:0] sigTimer, sequenceTimer, tau_w;

reg [1:0] stageInSequence; //Number representing the stage in searching for and parsing numbers from serial bit sequences - see below.

reg numLock; //When this bit is high, don't allow changes to bits in decoded number.

assign numOut=lastNum; //Assign wire output to lastNum register.

initial begin
	lastNum=1'b0; //Initialize output.
	newNum=1'b0;
	sigTimer=1'b0;
	sequenceTimer=1'b0;
	tau_w=1'b1;
	sigLast=1'b0;
	stageInSequence=1'b0;
	numIndex=1'b0;
	numLock=1'b0;
end

always @(posedge clk) begin
	//STAGES IN SEQUENCE:
	//0 => waiting for a new sequence.
	//1 => timing initial on pulse.
	//2 => waiting for off time that separates initial arm pulse from number pulse.
	//3 => parsing number pulse

	//TIME HOW LONG SIG HAS BEEN IN CURRENT STATE
	if(sig==sigLast) begin
		//Note - this timer will overflow.
		sigTimer=sigTimer+1'b1;
	end else begin
		//$display("State change");
		if(stageInSequence==1'b1) begin
			tau_w=sigTimer; //If we are timing the pulse length, record time.
			stageInSequence=2'b10; //Advance to next stage - wait for off pulse to finish.
			sequenceTimer=1'b0; //Reset sequence timer.
			sigTimer=1'b0; //Reset signal timer.
			//$display("stageInSequence=%b, sig=%b, tau_w=%d",stageInSequence,sig,tau_w);
		end
		sigTimer=1'b0; //Reset signal timer.
		sigLast=sig; //Update register holding last value of sig.
	end

	//Look for arm pulses - if found, time the arm pulse to calibrate the length of pulses in the sequence.
	if(sigLast && sigTimer>THRESHOLD_TIME && stageInSequence==1'b0) begin
		stageInSequence=1'b1; //Time initial on pulse to calibrate tau_w.
		//$display("stageInSequence=%b, sig=%b",stageInSequence,sig);
	end

	//SEQUENCE TIMER
	if(sequenceTimer<tau_w && stageInSequence>2'b01) begin
		sequenceTimer=sequenceTimer+1'b1; //Increment timer
	end else begin //Reset timer and increment index into parsed number.
		if(stageInSequence==2'b10) begin
			//Initial off period between arm pulse and number pulse is complete - advance stage in sequence.
			stageInSequence=2'b11;
			numIndex=1'b0;
			numLock=1'b0; //Turn off lock for changing bit values.
			//$display("stageInSequence=%b, sig=%b",stageInSequence,sig);
		end else if(stageInSequence==2'b11) begin
			numIndex=numIndex+1'b1; //Increment index in parsed number.
			numLock=1'b0; //Turn off lock on bit value for current number in sequence.
		end

		sequenceTimer=1'b0;
		//Reset signal timer - otherwise, can have repeated bits which are immediately
		//accepted as valid because they have been on for over the threshold time.
		if(stageInSequence>2'b01) begin sigTimer=1'b0; end
	end

	//STAGE 3 - PARSE NUMBERS FROM INPUT SEQUENCE.
	if(stageInSequence==2'b11) begin
		if(numIndex>=NUM_SIZE) begin
			lastNum=newNum; //Update stored number.
			stageInSequence=1'b0; //Number has been parsed - sequence is done.
			//$display("stageInSequence=%b, sig=%b",stageInSequence,sig);
		end else if(sigTimer>THRESHOLD_TIME && !numLock) begin
			newNum[NUM_SIZE-1-numIndex]=sigLast; //Update bit in new number.
			numLock=1'b1; //Don't allow any more changes for this bit in the number.
			//$display("Recorded bit, %b, which has held for %d cycles", sigLast,sigTimer);
		end
	end

end

endmodule

