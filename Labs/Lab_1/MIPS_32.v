`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  MIPS_32.v
 * Project:    Lab_Assignment_1
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  August 30, 2018 
 *
 * Purpose: The MIPS_32 module yields a 32-bit result and the upper 32-bits
 *				are set to 0's, where the operation is chosen through a function
 *				select from the wrapper.
 *         
 * Notes: Uses all flags; Negative, zero, overflow, and carry.
 *
 ****************************************************************************/
module MIPS_32(
    input [31:0] S_MIPS, T_MIPS,
    input [4:0] FS_MIPS,
    output reg [31:0] MIPS_hi, MIPS_lo,
    output reg N, Z, C, V
    );
	
	// Variables used to cast 32 bit signed integers
	integer int_s, int_t;
	
	always @* begin
		int_s = S_MIPS;
		int_t = T_MIPS;
		case(FS_MIPS)
			
			// Arithmetic Operations
			5'b00000:	{C,V,MIPS_lo} = {1'bx, 1'bx, S_MIPS}; 			 //Pass S
			
			5'b00001:	{C,V,MIPS_lo} = {1'bx, 1'bx, T_MIPS}; 			 //Pass T
			
			5'b00010:	begin
							{C,MIPS_lo} = S_MIPS + T_MIPS; 		  			 //ADD
								case({S_MIPS[31], T_MIPS[31], MIPS_lo[31]})
									3'b001: V = 1'b1;
									3'b110: V = 1'b1;
									default: V = 1'b0;
								endcase
							end
							
			5'b00011:	begin
							{C,MIPS_lo} = S_MIPS - T_MIPS; 					 //SUB
								case({S_MIPS[31], T_MIPS[31], MIPS_lo[31]})
									3'b011: V = 1'b1;
									3'b100: V = 1'b1;
									default: V = 1'b0;
								endcase
							end

			5'b00100:	begin
							{C,MIPS_lo} = S_MIPS + T_MIPS; 					 //ADDU
							V = (C == 1'b1) ? 1'b1 : 1'b0;
							end

			5'b00101:	begin
							{C,MIPS_lo} = S_MIPS - T_MIPS; 					 //SUBU
							V = (C == 1'b1) ? 1'b1 : 1'b0;
							end
			
			5'b00110:	{C,V,MIPS_lo} = {1'bx, 1'bx,
												 (int_s < int_t) ? 1 : 0};     //SLT
												 
			5'b00111:	{C,V,MIPS_lo} = {1'bx, 1'bx,
												 (S_MIPS < T_MIPS) ? 1 : 0};   //SLTU	
												 
			// Logic Operations
			5'b01000:	{C,V,MIPS_lo} = {1'bx, 1'bx,
												  S_MIPS & T_MIPS}; 				 //AND 
												  
			5'b01001:	{C,V,MIPS_lo} = {1'bx, 1'bx,
												  S_MIPS | T_MIPS}; 				 //OR 
												  
			5'b01010:	{C,V,MIPS_lo} = {1'bx, 1'bx,
												  S_MIPS ^ T_MIPS}; 				 //XOR 
												  
			5'b01011:	{C,V,MIPS_lo} = {1'bx, 1'bx,
												  ~(S_MIPS | T_MIPS)};         //NOR
												  
			5'b01100:	{C,V,MIPS_lo} = {T_MIPS[31], 1'bx, 
												  T_MIPS << 1}; 					 //SLL
												  
			5'b01101:	{C,V,MIPS_lo} = {T_MIPS[0], 1'bx, 
												  T_MIPS >> 1}; 					 //SRL
												  
			5'b01110:	{C,V,MIPS_lo} = {T_MIPS[0], 1'bx, 
												  int_t >>> 1}; 					 //SRA
			
			// Other Operations									  
			5'b01111:	begin
							{C,MIPS_lo} = S_MIPS + 1; 							 //INC
							V = ({S_MIPS[31],MIPS_lo[31]} == 2'b01) ? 1'b1 : 1'b0;
							end
		
			5'b10000:	begin
							{C,MIPS_lo} = S_MIPS - 1; 							 //DEC
							V = ({S_MIPS[31],MIPS_lo[31]} == 2'b10) ? 1'b1 : 1'b0;
							end
		
			5'b10001:	begin
							{C,MIPS_lo} = S_MIPS + 4; 							 //INC4
							V = ({S_MIPS[31],MIPS_lo[31]} == 2'b01) ? 1'b1 : 1'b0;
							end
		
			5'b10010:	begin
							{C,MIPS_lo} = S_MIPS - 4; 							 //DEC4
							V = ({S_MIPS[31],MIPS_lo[31]} == 2'b10) ? 1'b1 : 1'b0;
							end
							
			5'b10011:	{C,V,MIPS_lo} = {1'bx, 1'bx, 32'h0}; 			 //ZEROS
			
			5'b10100:	{C,V,MIPS_lo} = {1'bx, 1'bx, 32'hFFFFFFFF}; 	 //ONES
			
			5'b10101:	{C,V,MIPS_lo} = {1'bx, 1'bx, 32'h3FC}; 		 //SP_INIT
			
			5'b10110:	{C,V,MIPS_lo} = {1'bx, 1'bx, 						 //ANDI
												  S_MIPS & {16'h0, T_MIPS[15:0]}}; 		 
												  
			5'b10111:	{C,V,MIPS_lo} = {1'bx, 1'bx, 						 //ORI
												  S_MIPS | {16'h0, T_MIPS[15:0]}}; 		 
												  
			5'b11000:	{C,V,MIPS_lo} = {1'bx, 1'bx, 
												 {T_MIPS[15:0], 16'h0}}; 		 //LUI
												 
			5'b11001:	{C,V,MIPS_lo} = {1'bx, 1'bx, 						 //XORI
												  S_MIPS ^ {16'h0, T_MIPS[15:0]}}; 		 
												  
			default :	{C,V,MIPS_lo} = {1'b0, 1'bx, S_MIPS};	  		 //Default
																						 //case
		endcase
		
		//handle last two status flags
		// Negative sign on the MSB of result
		N = MIPS_lo[31];
		// Zero Flag
		Z = (MIPS_lo == 32'b0) ? 1'b1 : 1'b0;
		MIPS_hi = 32'b0;
		
	end // end always	

endmodule
