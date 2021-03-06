module LPfilt(rght_in, lft_in, sequencing, rst_n, rght_out, lft_out, clk);

input rst_n, clk, sequencing;
input signed [15:0] rght_in, lft_in;

output signed [15:0]rght_out, lft_out;

reg signed [15:0]dout;
reg signed [31:0]laccum, raccum;
reg[9:0]addr;
reg FF_seq, pos_seq;

//Instantiates the ROM
ROM_LP LP(.dout(dout), .clk(clk), .addr(addr));

//Implements addr
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		addr <= 10'h000;
	else if(sequencing)
	    addr <= addr + 1;
	else
	    addr <= 10'h000;

//Sequencing posedge detect
always @(posedge clk, negedge rst_n)
 if(!rst_n)
  FF_seq <= 1'b0;
 else
  FF_seq <= sequencing;

assign pos_seq = ~FF_seq && sequencing;

//Implements the accum
always_ff @(posedge clk, negedge rst_n)
if(!rst_n) begin
	    raccum <= 32'h00000000;
	    laccum <= 32'h00000000;
end else if(pos_seq) begin
	    raccum <= 32'h00000000;
	    laccum <= 32'h00000000;
	  end else begin
	    raccum <= raccum + (dout * rght_in);
	    laccum <= laccum + (dout * lft_in);
	  end
assign rght_out = (addr == 1021) ? raccum[30:15] : rght_out;
assign lft_out = (addr == 1021) ? laccum[30:15] : lft_out;

endmodule