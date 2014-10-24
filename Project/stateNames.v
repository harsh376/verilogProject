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
	
	
	wire left;
	wire right;
	wire up;
	wire down;
	wire enable;
	
	assign left = SW[17];
	assign right = SW[16];
	assign up = SW[15];
	assign down = SW[14];
	
	assign enable = left | right | up | down;
	
	
	assign LEDR[14:8]=xC1;
	assign LEDR[7:0]=xC2;
	
	assign LEDG[7:0]=xCursorDraw;
	
	wire clock;
	//assign clock = KEY[0];
	
	wire resetn;
	wire start;
	//wire enable;
	//wire drawn;
	

	reg[2:0]y;
	reg[2:0]Y;
	parameter Resetn=3'b000, Draw=3'b001, Won=3'b010;
	
	
	assign resetn = SW[0];
	assign start =  SW[1];
	
	
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
	
	wire[7:0]xC1;
	wire[6:0]yC1;
//	assign xC1 = xC-1;
//	assign yC1 = yC-1;
	
	
	wire[7:0]xC2;
	wire[6:0]yC2;
//	assign xC2 = xC+5;
//	assign yC2 = yC+5;
	
	
	
	//assign xC = 8'b01000110;
	//assign yC = 7'b0111100;
	wire[7:0]xCursor;
	wire[6:0]yCursor;
	wire[2:0]colorCursor;
	
	
	wire[7:0]xCursorDraw;
	wire[6:0]yCursorDraw;
	
	
	
	//assign LEDG[2:0] = y;
	//assign LEDG[5:3] = Y;
	
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
	assign number[2:0] = SW[7:5];
	//assign number = 3'b101;
	
	wire enCursor;
	wire won;
	
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
		
		Draw:				
							begin
								
								// pattern is plotted
								if(~enCursor)
								begin
									if(xC!=8'b10011110 & yC!=7'b1110110)
									begin
										x_ = xC + x2;
										y_ = yC + y2;
										color_ = colorC;								
									end
								end
								
								else
								begin
																		
									x_ = xCursor;
									y_ = yCursor;
									color_ = colorCursor;
								end
								
					
							end
							
							
		Won:				begin
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
	Draw3by3 inst2(.clk(CLOCK_50), .countX(x2), .countY(y2), .y(y), .drawn(drawn), .ct(ct), .color(colorC), .xC(xC), .yC(yC), .resetn(resetn),
	.enCursor(enCursor), .xCursor(xCursor), .yCursor(yCursor), .colorCursor(colorCursor), .left(left), .right(right), .up(up), .down(down), 
	.won(won), .xC1(xC1), .yC1(yC1), .xC2(xC2), .yC2(yC2), .xCursorDraw(xCursorDraw), .yCursorDraw(yCursorDraw));
	//assignKeys inst3(.ps2_key_data(ps2_key_data), .left(left), .right(right), .up(up), .down(down), .resetn(resetn));
	
	
	
/*///////////////////////////////////

PS2 INSTANTIATION

*////////////////////////////////////
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

module Draw3by3(clk, countX, countY, y, drawn, ct, color, xC, yC, resetn, enCursor, xCursor, yCursor, colorCursor, 
left, right, up, down, won, xC1, yC1, xC2, yC2, xCursorDraw, yCursorDraw);	
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
	output reg enCursor;
	output reg[7:0]xCursor;
	output reg[6:0]yCursor;
	output reg[2:0]colorCursor;
	input left, right, up, down;
	output reg won;
	
	output reg[7:0]xC1;
	output reg[6:0]yC1;
	output reg[7:0]xC2;
	output reg[6:0]yC2;
	
	
	output reg[7:0]xCursorDraw;
	output reg[6:0]yCursorDraw;
	
	reg[7:0]xCursorErase;
	reg[6:0]yCursorErase;
	
	//input[2:0]number;
	
	reg[2:0]number;
	
	
	
	
	reg[25:0]cycle_count;
	reg[25:0]delay;
	reg d;
	reg erased;
	reg[2:0]s;
	reg finished;
	reg colorCount;
	
	reg[2:0]num;
	reg[2:0]numCount;
	
	reg cursorDrawn;
	
	parameter Draw5by5=3'b000, DelayPattern=3'b001, EraseNModifyCoordinates=3'b010, changeNumber=3'b011;
	
	
	always@(posedge clk)
	begin	
	
	xC1<=xC-1;
	yC1<=yC-1;
	xC2<=xC+5;
	yC2<=yC+5;
	
	if(~resetn)
	begin
		xC<=25;
		yC<=25;
		drawn<=0;
		countX<=0;
		countY<=0;
		cycle_count<=0;
		delay<=0;
		d<=0;
		erased<=0;
		s<=0;
		ct<=0;
		finished<=0;
		number<=3'b101;
		colorCount<=0;
		numCount<=3'b000;
		enCursor<=0;
		xCursor<=80;
		yCursor<=60;
		xCursorDraw<=80;		// 80
		yCursorDraw<=60;			// 60
		cursorDrawn<=0;
		won<=0;
		xC1<=xC-1;
		yC1<=yC-1;
		xC2<=xC+5;
		yC2<=yC+5;
	end
	
		
		
		else if(y == 3'b001)
		begin
			
		
			//if(xCursor>xC1 & xCursor<xC2)
				//won<=1;
		
			if(s==Draw5by5 & ~finished)
			begin
				if(~d)
				begin
					
					
					delay<=0;
					erased<=0;
					
					if(colorCount==0)
						color<=3'b100;
						
					else
						color<=3'b001;
						
					if(countX==4)
					begin
						countX<=0;
						
						if(countY==4)
						begin
							
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
							
				
					ct<=ct+1;
					s<=DelayPattern;
					enCursor<=1;
				end
			end
			
			// delay state
			else if(s==DelayPattern)
			begin
						
			
				if(cycle_count==750000)	
				begin	
					
					// draw cursor
					if(~cursorDrawn)
					begin
						
						xCursorErase<=xCursorDraw;
						yCursorErase<=yCursorDraw;
						
						xCursor<=xCursorDraw;
						yCursor<=yCursorDraw;
						colorCursor<=3'b000;
						
						
						
						if(left)
						begin
							if(xCursorDraw!=8'b00000000)
							begin
								xCursorDraw<=xCursorDraw-1;
								cursorDrawn<=1;
							end
						end
						else if(right)
						begin
							if(xCursorDraw!=8'b10011111)
							begin	
								xCursorDraw<=xCursorDraw+1;
								cursorDrawn<=1;
							end
						end
						else if(up)
						begin
							if(yCursorDraw!=7'b0000000)
							begin
								yCursorDraw<=yCursorDraw-1;
								cursorDrawn<=1;
							end
						end
						else if(down)
						begin
							if(yCursorDraw!=7'b1110111)
							begin
								yCursorDraw<=yCursorDraw+1;
								cursorDrawn<=1;
							end
						end
														
					end		// 	if(~cursorDrawn).......ends
					
					// Erase
					else
					begin
						
						xCursor<=xCursorErase;
						yCursor<=yCursorErase;
						colorCursor<=3'b010;
						
						cursorDrawn<=0;					
					
					end
					
					
					cycle_count<=0;							
				end		// if(cycle_count==250000)  .... ends
				
				else
						cycle_count<=cycle_count+1;
				
							
							
				if(delay==50000000)
				begin					
					s<=EraseNModifyCoordinates;
					enCursor<=0;
				end	
					
				else
				begin
					delay<=delay+1;
													
				end		//  else ( delay != 25000000)....ends
				
				
				
				
			end
			
			// Erase and modify coordinates
			else if(s==EraseNModifyCoordinates)
			begin
			
				//if((xCursor>=xC & xCursor<=xC1) & (yCursor>=yC & yCursor<=yC1)	)
					//s<=3'b100;
			
			
				if(~erased)
				begin
					delay<=0;
					d<=0;
					
					color<=3'b010;
					if(countX==4)
					begin
						countX<=0;
						
						if(countY==4)
						begin
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
					num<=number;
					
					// number = 3
					if(number==3'b011 | number==3'b111)
					begin
									
						if(ct==3'b001)
						begin	
							xC<=xC+15;
							yC<=yC+15;
						end
							
						else if(ct==3'b010)
						begin
							xC<=xC+15;
							yC<=yC+15;
						end
							
						else if(ct==3'b011)
						begin	
							xC<=xC-30;
							yC<=yC-30;
							ct<=0;
							finished<=0;
							if(numCount==7)
								numCount<=numCount+2;
							else
								numCount<=numCount+1;
						end
							
					end
					
					// number = 4
					else if(number==3'b100 | number==3'b010)
					begin
									
						if(ct==3'b001)
							xC<=xC+30;
							
						else if(ct==3'b010)
							yC<=yC+30;
							
						else if(ct==3'b011)
							xC<=xC-30;
							
						else if(ct==3'b100)	// pattern for 4 has finished
						begin	
							yC<=yC-30;
							ct<=0;
							finished<=0;
							if(numCount==7)
								numCount<=numCount+2;
							else
								numCount<=numCount+1;
						end
					
					end
					
					// number = 5
					else if(number==3'b101 | number==3'b001)
					begin
						
						if(ct==3'b001)
							xC<=xC+30;
							
						else if(ct==3'b010)
							yC<=yC+30;
							
						else if(ct==3'b011)
							xC<=xC-30;
							
						else if(ct==3'b100)
						begin
							xC<=xC+15;
							yC<=yC-15;
						end
						
							
						else if(ct==3'b101)
						begin	
							xC<=xC-15;
							yC<=yC-15;
							ct<=0;
							finished<=0;
							if(numCount==7)
								numCount<=numCount+2;
							else
								numCount<=numCount+1;
						end
					
					end
					
					// number = 6
					else if(number==3'b110 | number==3'b000)
					begin
									
						if(ct==3'b001)
							yC<=yC+15;
							
						else if(ct==3'b010)
							yC<=yC+15;
							
						else if(ct==3'b011)
							xC<=xC+20;
							
						else if(ct==3'b100)
							yC<=yC-15;
							
						else if(ct==3'b101)
							yC<=yC-15;	
							
						else if(ct==3'b110)
						begin	
							xC<=xC-20;
							ct<=0;
							finished<=0;
							if(numCount==7)
								numCount<=numCount+2;
							else
								numCount<=numCount+1;
						end
					
					end
					
					
	
					//s<=3'b000;
					s<=changeNumber;
				end
				
			end
		
			
			
			
		
			// change number
			else if(s==changeNumber)
			begin
					
				if(ct==0)
				begin			
					
					
					number[2]<=(num[2] ^ num[0]);
					number[1]<=num[2];
					number[0]<=num[1];
					colorCount<=~colorCount;
					
					
					if(numCount==1)
					begin
						xC<=xC+30;
					end
					
					else if(numCount==2)
					begin
						xC<=xC+30;
					end
					
					else if(numCount==3)
					begin
						xC<=xC-60;
						yC<=yC+50;
					end
					
					else if(numCount==4)
					begin
						xC<=xC+30;
					end
					
					else if(numCount==5)
					begin
						xC<=xC+30;
					end
					
					else if(numCount==6)
					begin
						xC<=xC-30;
						yC<=yC-25;					
					end
					
					else if(numCount==7)
					begin
						xC<=25;
						yC<=25;
					end				
					
				end
				
				s<=Draw5by5;	
			end
			

			
		end
		
	
		
	
	end
endmodule



module assignKeys(ps2_key_data, left, right, up, down, resetn);

	input[7:0]ps2_key_data;
	output reg left, right, up, down;
	input resetn;


	always@(*)
	begin

	if(~resetn)
	begin
		left=0;
		right=0;
		up=0;
		down=0;
	end
	
	else if(ps2_key_data== 8'b01101011)
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
