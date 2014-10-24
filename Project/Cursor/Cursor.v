module Cursor
	(
		CLOCK_50,						//	On Board 50 MHz
		LEDR,
		LEDG,
		KEY,							//	Push Button[3:0]
		SW,								//	DPDT Switch[17:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		PS2_CLK,
		PS2_DAT
		
	);
	input			CLOCK_50;				//	50 MHz
	output[17:0]LEDR;
	output[7:0]LEDG;
	input	[3:0]	KEY;					//	Button[3:0]
	input	[17:0]	SW;						//	Switches[17:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]


	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;

	// Internal Wires
	wire		[7:0]	ps2_key_data;
	wire				ps2_key_pressed;

	// Internal Registers
	reg			[7:0]	last_data_received;


	//assign LEDR[7:0] = ps2_key_data;
	
	
	wire clock;
	//assign clock = KEY[0];
	
	wire resetn;
	wire start;
	wire enable;
	wire drawn;
	

	reg[2:0]y;
	reg[2:0]Y;
	parameter Resetn=3'b000, Idle=3'b001, Draw=3'b010, Erase=3'b011;
	
	
	assign resetn = SW[0];
	assign start =  SW[1];
//	assign enable = ps2_key_pressed ;
//	wire left = SW[17];
//	wire right = SW[16];
//	wire up = SW[15];
//	wire down = SW[14];
	assign enable = left | right | up | down;
	wire left;
	wire right;
	wire up;
	wire down;
	
	
	
	// Resetn
	wire[7:0]x1;
	wire[6:0]y1;
	wire[2:0]color1;
	
	wire[7:0]x2;
	wire[6:0]y2;
	wire[2:0]color2;
	
	wire[7:0]x3;
	wire[6:0]y3;
	wire[2:0]color3;

	assign LEDG[2:0] = y;
	assign LEDG[5:3] = Y;
	
	reg[7:0]x_;
	reg[6:0]y_;
	reg[2:0]color_;
	
	wire[7:0]x_VGA;
	wire[6:0]y_VGA;
	wire[2:0]color_VGA;
	
	assign x_VGA = x_;
	assign y_VGA = y_;
	assign color_VGA = color_;
	
	
	always@(*)
	begin
		case(y)
		
		
		// reset should make the values of x2,y2 to (0,0) if you want
		Resetn:		  	begin
								x_ = x1;
								y_ = y1;
								color_ = 3'b010;
								if(start)Y=Idle;
								else Y=Resetn;
							end
		
		Idle:				begin
								if(enable)Y=Draw;
								else Y=Idle;
				
							end
		
		Draw:				begin
								x_ = x2;
								y_ = y2;
								color_ = 3'b100;
								if(drawn)Y=Erase;
								else Y=Draw;								
							end
							
		
		Erase: 			begin
								x_ = x3;
								y_ = y3;
								color_ = 3'b010;
								//Y=Idle;
								Y=Draw;
								
							end
	
			
				
		default: ;
		endcase
	end
	
	
	
	
	
//	reg [25:0]cycle_count;
	
	always@(posedge CLOCK_50)
	begin
		
		if(resetn==0)
		begin	
			y<=Resetn;
			//cycle_count<=0;
		end
			
		else
		begin

				y<=Y;

		end
				
	end
	
	
	Reset inst1(.clk(CLOCK_50), .x1(x1), .y1(y1), .y(y));
	Draw inst2(.clk(CLOCK_50), .y(y), .x2(x2), .y2(y2), .left(left), .right(right), .up(up), .down(down), .drawn(drawn), .x3(x3), .y3(y3));
	assignKeys inst3(.ps2_key_data(ps2_key_data), .left(left), .right(right), .up(up), .down(down));
	
	
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
	
	
	
//////////////////////////////////////////////
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(color_VGA),
			.x(x_VGA),
			.y(y_VGA),
			.plot(1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "";
			
	// Put your code here. Your code should produce signals x,y,color and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.	
endmodule


module assignKeys(ps2_key_data, left, right, up, down);

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



module Reset(clk,x1,y1,y);	
	input clk;
	output reg [7:0]x1;	
	output reg [6:0]y1;
	input[2:0]y;	
	
	wire a=3'b000;
	
	always@(posedge clk)
	if(y==3'b000)
	begin
//		x_init<=8'b01001111;
//		y_init<=8'b0111011;
//		color_init<=3'000;
		if(x1==160)
		begin
			x1<=0;
			
			if(y1==120)
				y1<= 0;
			else
				y1<=y1+1;	
		end
		else
		begin
			x1<=x1+1;
		end
	end
endmodule

module Draw(clk, y, x2, y2, left, right, up, down, drawn, x3, y3);
	
	// slow down the clock so that x2, y2 doesn't get plotted
		input clk;
		input[2:0]y;
		output reg[7:0]x2;
		output reg[6:0]y2;
		input left, right, up, down;
		output reg drawn;
		output reg[7:0]x3;
		output reg[6:0]y3;
		
		reg[25:0]cycle_count;
		
		always@(posedge clk)
		begin
			
			if(cycle_count==250000)
			begin
			
				if(y == 3'b010)
				begin
					x3<=x2;
					y3<=y2;
					if(left)
					begin
						if(x2!=8'b00000000)
						begin
							x2<=x2-1;
							drawn<=1;
						end
					end
					else if(right)
					begin
						if(x2!=8'b10011111)
						begin	
							x2<=x2+1;
							drawn<=1;
						end
					end
					else if(up)
					begin
						if(y2!=7'b0000000)
						begin
							y2<=y2-1;
							drawn<=1;
						end
					end
					else if(down)
					begin
						if(y2!=7'b1110111)
						begin
							y2<=y2+1;
							drawn<=1;
						end
					end
					//drawn<=1;
				end
				
				cycle_count<=0;
			end
			else
				cycle_count<=cycle_count+1;
		end
		
	
endmodule
