module counter(clk,sigIn,n_clk);
/***
Single-period counter - counts number of clock cycles between signal edges.

Ted Golfinopoulos, 19 Sep 2012
***/

parameter N_CLK_SIZE=8;

input clk, sigIn;
output [N_CLK_SIZE-1:0] n_clk;

reg [N_CLK_SIZE-1:0] n_clk_reg, n_clk_reg_last;
reg clkResetFlag;
reg sigLast;

initial begin
	#0
	sigLast=1'b0;
	n_clk_reg=1'b0;
	n_clk_reg_last=1'b0;
	clkResetFlag=1'b1;
end

always @(posedge clk) begin
	if( sigIn>sigLast ) begin //Rising edge
		//Update n_clk_output
		n_clk_reg_last=n_clk_reg;
		//Reset n_clk counter on next clock edge.
		clkResetFlag=1'b1;
		sigLast=sigIn;
	end else if(sigIn<sigLast) begin //Falling edge
		//Update signal register - get ready for next rising edge.
		sigLast=sigIn;
	end else if(clkResetFlag) begin
		n_clk_reg=1'b1; //Start counting at 1, since it's already been 1 clock cycle since the last rising edge.
		clkResetFlag=1'b0; //Turn off reset flag.
	end else begin
		n_clk_reg=n_clk_reg+1'b1; //Increment counter.
	end
end

assign n_clk=n_clk_reg_last; //Assign period to registered n_clk value.

endmodule

