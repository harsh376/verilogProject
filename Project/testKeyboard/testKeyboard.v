module testKeyboard(CLOCK_50,KEY,LEDR,LEDG,PS2_CLK,PS2_DAT);


// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
output[7:0]LEDR;
output[3:0]LEDG;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

wire left;
wire right;
wire up;
wire down;

assign LEDR[3] = left;
assign LEDR[2] = right;
assign LEDR[1] = up;
assign LEDR[0] = down;

test inst1(.ps2_key_data(ps2_key_data), .left(left), .right(right), .up(up), .down(down));


	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);




endmodule

module test(ps2_key_data, left, right, up, down);

	input[7:0]ps2_key_data;
	output reg left, right, up, down;


	always@(*)
	begin

	if(ps2_key_data== 8'b01101011)
	begin	
		left=1;
		right=0;
		up=0;
		down=0;
	end
	
		
	else if(ps2_key_data==8'b01110100)
	begin
		right=1;
		left=0;
		up=0;
		down=0;
	end
		
	else if(ps2_key_data==8'b01110101)
	begin	
		up=1;
		left=0;
		right=0;
		down=0;
	end
		
	else if(ps2_key_data==8'b01110010)
	begin
		down=1;
		left=0;
		right=0;
		up=0;
	end
			
	else
	begin
		left=0;
		right=0;
		up=0;
		down=0;
	end

end

endmodule



