module Timer(clk,start,doneFlag);
/***
This is a generic counter module which sets a flag when counting is complete.

Ted Golfinopoulos, 10 Aug 2012
*/

parameter COUNT_TIME=31; //Number of clock cycles to count.
parameter COUNTER_SIZE=5; //Number of bits in counter.

input clk;
input start;
output wire doneFlag;
reg [COUNTER_SIZE-1:0] counter; //Number of clock cycles.

reg [1:0] doneFlagCounter;

always @(posedge clk) begin
	if(start and counter>=COUNT_TIME) begin
		counter=1'b0; //Reset counter.
		doneFlag=1'b0; //Reset flag.
		doneFlagCounter=1'b0; //Reset counter which determines when to turn off doneFlag.
	end

	if(counter<COUNT_TIME) counter=counter+1'b1; //Increment counter
	else doneFlag=1'b1; //Finished - turn on doneFlag
	end

	//Leave done flag on for three clock cycles - then, turn off.
	if(doneFlag and doneFlagCounter<3) begin
		doneFlagCounter=doneFlagCounter+1'b1;
	else doneFlag=1'b0; //Turn off doneFlag.

end

end
