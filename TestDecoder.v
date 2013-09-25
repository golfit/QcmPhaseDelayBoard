module TestDecoder();

/***
This module tests the Decoder module.  It provides several encoded streams and outputs the decoded number.

Ted Golfinopoulos, 11 Aug 2012
***/

parameter NUM_SIZE=7;
parameter SEQ_SIZE=NUM_SIZE+4;

reg [SEQ_SIZE-1:0] seq1,seq2,seq3;

reg decoderInput;

wire [NUM_SIZE-1:0] num;

reg clk;

integer i;

Decoder d(clk,decoderInput,num);

initial begin
	$dumpfile ("TestDecoderTestbench.vcd");
	$dumpvars;
end

initial begin
	$display("\tTime\tNum");
	$monitor("\t%d\t%b",$time, num);
end

initial begin
	#0
	decoderInput=1'b0;
	clk=1'b1; //Initialize clock.

	seq3=11'b01000000000;
	seq2=11'b01011111110;
	seq1=11'b01011011010;
	seq3=11'b01001011010;

	$display("First sequence");

	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1024
		decoderInput=seq1[SEQ_SIZE-1-i];

		$display("%d\t%b",i,decoderInput);
	end

	$display("Second sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq2[SEQ_SIZE-1-i];

		$display("%d\t%b",i,decoderInput);
	end

	$display("Third sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq3[SEQ_SIZE-1-i];

		$display("%d\t%b",i,decoderInput);
	end

	$display("First sequence");

	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1024
		decoderInput=seq1[SEQ_SIZE-1-i];

		$display("%d\t%b",i,decoderInput);
	end

	$display("Second sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq2[SEQ_SIZE-1-i];

		$display("%d\t%b",i,decoderInput);
	end

	$display("Third sequence");
	for(i=0; i<SEQ_SIZE; i=i+1) begin
		#1055
		decoderInput=seq3[SEQ_SIZE-1-i];

		$display("%d\t%b",i,decoderInput);
	end

	#50 $finish; //End simulation
end

//Make clock
always begin
	#1
	clk=~clk; //Invert clock
end

endmodule

