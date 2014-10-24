module testPattern
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
	parameter Resetn=3'b000, Draw=3'b001;
	
	
	assign resetn = SW[0];
	assign start =  SW[1];
	//assign enable = ps2_key_pressed ;
	wire left = SW[17];
	wire right = SW[16];
	wire up = SW[15];
	wire down = SW[14];
	assign enable = left | right | up | down;
	
	// Resetn
	wire[7:0]x1;
	wire[6:0]y1;
	wire[2:0]color1;
	
	wire[7:0]x2;
	wire[6:0]y2;
	wire[2:0]color2;
	
	wire[7:0]xC;
	wire[6:0]yC;
	wire[2:0]colorC;
	//assign xC = 8'b01000110;
	//assign yC = 7'b0111100;
	
	
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
	
	wire[2:0]number;
	assign number = 3'b100;
	
	wire[2:0]ct;
	
	always@(*)
	begin
		case(y)
		
		
		// reset should make the values of x2,y2 to (0,0) if you want
		Resetn:		  	begin
								x_ = x1;
								y_ = y1;
								color_ = 3'b010;
								if(start)Y=Draw;
								else Y=Resetn;
							end
		
		Draw:				begin
								if(xC!=8'b10011110 & yC!=7'b1110110)
								begin
									x_ = xC + x2;
									y_ = yC + y2;
									color_ = colorC;								
								end
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
	Draw3by3 inst2(.clk(CLOCK_50), .countX(x2), .countY(y2), .y(y), .drawn(drawn), .ct(ct), .color(colorC), .xC(xC), .yC(yC), .resetn(resetn));
	//change inst3(.clk(CLOCK_50), .y(y), .xC(xC), .yC(yC), .drawn(drawn), .ct(ct));
	
	
	
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

module Draw3by3(clk, countX, countY, y, drawn, ct, color, xC, yC, resetn);	
	input clk;
	output reg [2:0]countX;	
	output reg [2:0]countY;
	input[2:0]y;
	output reg drawn;
	output reg[2:0]ct;
	output reg[2:0]color;
	output reg[7:0]xC;
	output reg[6:0]yC;
	input resetn;
	
	
	reg[25:0]cycle_count;
	reg[25:0]delay;
	reg d;
	reg erased;
	
	
	always@(posedge clk)
	begin	
	
	if(~resetn)
	begin
		xC<=0;
		yC<=0;
		drawn<=0;
		countX<=0;
		countY<=0;
		cycle_count<=0;
		delay<=0;
		d<=0;
		erased<=0;
		
		
		
	end
	
	else if(cycle_count==1000000)
	begin
	
		if(y == 3'b001)
		begin
		
			if(~drawn)
			begin
				if(~d)
				begin
					delay<=0;
					erased<=0;
					color<=3'b100;
					if(countX==2)
					begin
						countX<=0;
						
						if(countY==2)
						begin
							ct<=ct+1;
							countY <= 0;
							
							//drawn<=1;
							d<=1;
									
						end
						else
							countY<=countY+1;	
					end
					else
						countX<=countX+1;
				end
				else
				begin
				// insert time delay
					drawn<=1;
				end
				
					
			end
			
			else
			begin
				if(~erased)
				begin
					delay<=0;
					d<=0;
					
					color<=3'b010;
					if(countX==2)
					begin
						countX<=0;
						
						if(countY==2)
						begin
							ct<=ct+1;
							countY <= 0;
							//drawn<=0;
							erased<=1;
							//xC<=xC+10;		
						end
						else
						begin
							countY<=countY+1;	
						end
					end
					else
						countX<=countX+1;
				end
				
				else
				begin
					xC<=xC+10;
					drawn<=0;
				end
				
			end
		
		end
		
		cycle_count<=0;
		
	end
	
	else
		cycle_count<=cycle_count+1;
	
	
	end
endmodule

/*
module change(clk, y, xC, yC, drawn, ct);

	input clk;
	input[2:0]y;
	output reg[7:0]xC;
	output reg[6:0]yC;
	output reg drawn;
	input[2:0]ct;
	
	
	always@(posedge clk)
	begin
		if(y == 3'b010)
		begin
			drawn<=0;
			if(ct==3'b001)
				xC<=xC+5;
			
			else if(ct==3'b010)
				yC<=yC+5;
				
			else if(ct==3'b011)
				xC<=xC-5;
						
		end
	end
	

endmodule
*/