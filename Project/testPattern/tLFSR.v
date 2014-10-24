module tLFSR(LEDR, KEY, SW);

output[5:0]LEDR;
input[1:0]KEY;
wire clk;
input[17:0]SW;

assign clk = KEY[0];


wire[2:0]out;
wire enable;
wire reset;
wire[2:0]data;

//assign data = SW[17:15];

assign reset = SW[0];


lfsr inst1(.out(out), .enable(1), .clk(clk), .reset(reset), .data(3'b101), .chooseTwo(SW[17:15]));

assign LEDR[2:0] = out;



endmodule


module lfsr    (
out             ,  // Output of the counter
enable          ,  // Enable  for counter
clk             ,  // clock input
reset           ,   // reset input
data				 ,
chooseTwo
);

//----------Output Ports--------------
output [2:0] out;
//------------Input Ports--------------
input [2:0] data;
input enable, clk, reset;
input[2:0]chooseTwo;
//------------Internal Variables--------
reg [2:0] out;
wire        linear_feedback;

//-------------Code Starts Here-------
//assign linear_feedback = !(out[0] ^ out[2]);
assignLinearFeedback inst2(.linear_feedback(linear_feedback), .chooseTwo(chooseTwo), .out(out));


always @(posedge clk)
if (reset) begin // active high reset
  out <= 3'b0 ;
end else if (enable) begin
  out <= {out[2],out[1],
          out[0], linear_feedback};
end 

endmodule // End Of Module counter



module assignLinearFeedback(linear_feedback, chooseTwo, out);

	output reg linear_feedback;
	input[2:0]chooseTwo;
	input[2:0]out;
	
	always@(*)
	begin
		if(chooseTwo[2] & chooseTwo[0])
			linear_feedback = !(out[2] ^ out[0]);
			
		else if(chooseTwo[1] & chooseTwo[0])
			linear_feedback = !(out[1] ^ out[0]);
			
		else if(chooseTwo[2] & chooseTwo[1])
			linear_feedback = !(out[2] & out[1]);
			
		else
			linear_feedback = !(out[2] ^ out[0]);
			
	end
	
	

endmodule
