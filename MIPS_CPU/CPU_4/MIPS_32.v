`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  MIPS_32.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 8th, 2018 
 *
 * Purpose:	This module contains the majority of the ALU operations excluding
 * 			multiply and divide. The inputs of this module are the 32-bit
 * 			sources S and T, as well as the carry flags N(negative), Z(zero),
 * 			V(overflow), and C(carry).
 *         
 * Notes: 	ADDU, SUBU and SLTU are unsigned operations, and the rest are
 *		    	signed operations.
 *
****************************************************************************/
module MIPS_32(
	input [31:0] S, T, //inputs
	input [4:0]	 FS, //function select
	
	output reg [31:0] Y_hi, Y_lo,
	output reg N, Z, V, C 
   );
	
	integer int_s, int_t;
	
	parameter 
//				 Arithmetic
				 PASS_S = 5'h00,
				 PASS_T = 5'h01,
				 ADD	  = 5'h02,
				 SUB	  = 5'h03,
				 ADDU	  = 5'h04,
				 SUBU	  = 5'h05,
				 SLT	  = 5'h06,
				 SLTU	  = 5'h07,
//				 Logic
				 AND	  = 5'h08,
				 OR	  = 5'h09,
				 XOR	  = 5'h0A,
				 NOR	  = 5'h0B,
				 SLL	  = 5'h0C,
				 SRL	  = 5'h0D,
				 SRA	  = 5'h0E,
				 ANDI	  = 5'h16,
				 ORI	  = 5'h17,
				 LUI	  = 5'h18,
				 XORI	  = 5'h19,
//				 Other
				 INC    = 5'h0F,
				 DEC	  = 5'h10,
				 INC4   = 5'h11,
				 DEC4   = 5'h12,
				 ZEROS  = 5'h13,
				 ONES   = 5'h14,
				 SP_INIT= 5'h15;
				 
	always @(*) begin
		int_s = S;  
		int_t = T;
		Y_hi  = 32'h0; //set Y_hi to all 0's
		case (FS)
			PASS_S: begin
				{V,C,Y_lo} = {1'bx,1'bx,S};
			end
			PASS_T: begin
				{V,C,Y_lo} = {1'bx,1'bx,T};
			end
			ADD: begin
				{C,Y_lo} = S + T;
				case ({S[31],T[31],Y_lo[31]})
					3'b001: V = 1'b1;
					3'b110: V = 1'b1;
					default: V = 1'b0;
				endcase
			end
			SUB: begin
				{C,Y_lo} = S - T;
				case ({S[31],T[31],Y_lo[31]})
					3'b100: V = 1'b1;
					3'b011: V = 1'b1;
					default: V = 1'b0;
				endcase
			end
			ADDU: begin
				//no casting necessary because adding is the same thing
				{C,Y_lo} = S + T;
				//if you get a carry in unsigned, it's the same as overflow
				if (C == 1'b1)
					V = 1'b1;
				else
					V = 1'b0;
			end
			SUBU: begin
				{C,Y_lo} = S - T;
				//if you get a carry in unsigned, it's the same as overflow
				if (C == 1'b1) 
					V = 1'b1;
				else
					V = 1'b0;
			end
			SLT: begin
				if (int_s < int_t)
					{V,C,Y_lo} = {1'bx,1'bx,32'h1};
				else
					{V,C,Y_lo} = {1'bx,1'bx,32'h0};
			end
			SLTU: begin
				if (S < T)
					{V,Y_lo} = {1'bx,32'h1};
				else
					{V,Y_lo} = {1'bx,32'b0};
			end
			AND:  {V,C,Y_lo} = {1'bx,1'bx,S&T};
			OR:   {V,C,Y_lo} = {1'bx,1'bx,S|T};
			XOR:  {V,C,Y_lo} = {1'bx,1'bx,S^T};
			NOR:  {V,C,Y_lo} = {1'bx,1'bx,~(S|T)};
			SLL:  {V,C,Y_lo} = {1'bx,T[31],T<<1};
			SRL:  {V,C,Y_lo} = {1'bx,T[0],T>>1};
			SRA:  {V,C,Y_lo} = {1'bx,T[0],int_t>>>1};
			ANDI: {V,C,Y_lo} = {1'bx,1'bx,S & {16'h0,T[15:0]}};
			ORI:  {V,C,Y_lo} = {1'bx,1'bx,S|{16'h0,T[15:0]}};
			LUI:  {V,C,Y_lo} = {1'bx,1'bx,{T[15:0],16'h0}};
			XORI: {V,C,Y_lo} = {1'bx,1'bx,S^{16'h0,T[15:0]}};
			INC: begin
				{C,Y_lo} = S + 1;
				//increment overflows when sign changes from 0 to 1 because 
				//of the extra bit reserved for the sign is used for the value
				V = (S[31] ? 1'b0 : (Y_lo[31] ? 1'b1 : 1'b0));
			end
			DEC: begin
				{C,Y_lo} = S - 1;
				//decrement overflows when sign changes from 1 to 0 because 
				//it went from -8 to 7 (1000 -> 0111)
				V = (S[31] ? (Y_lo[31] ? 1'b0 : 1'b1) : 1'b0); 
			end
			INC4: begin
				{C,Y_lo} = S + 4;
				V = (S[31] ? 1'b0 : (Y_lo[31] ? 1'b1 : 1'b0));
			end
			DEC4: begin
				{C,Y_lo} = S - 4;
				V = (S[31] ? (Y_lo[31] ? 1'b0 : 1'b1) : 1'b0);
			end
			ZEROS: begin
				{V,C,Y_lo} = {1'bx,1'bx, 32'h0};
			end
			ONES: begin
				{V,C,Y_lo} = {1'bx,1'bx, 32'hFFFFFFFF};
			end
			SP_INIT: begin
				{V,C,Y_lo} = {1'bx,1'bx, 32'h3FC};
			end
			default: {C,Y_lo,Y_hi} = {1'b0, 32'b0, 32'b0};
		endcase
		
		//negative flag
		N = Y_lo[31];
		//Z flag
		if (Y_lo == 32'b0)
			Z = 1'b1;
		else
			Z = 1'b0;
	end //end always block	
endmodule
