`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  DIV_32.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 6th, 2018
 *
 * Purpose:	This module takes care of the divide operation for the ALU. The
 * 			inputs are 32-bit S and T, and 5 bit FS (function select). The
 * 			outputs are Y_hi(remainder) and Y_lo (quotient), as well as the
 * 			negative and zero flags.
 *         
 * Notes:
 *
****************************************************************************/
module DIV_32(
	input [31:0] S, T,
	input [4:0] FS,
	output reg [31:0] Y_hi, Y_lo,
	output reg N,Z
   );
	
	integer int_s, int_t;
	
	always @ (*) begin
		int_s = S;
		int_t = T;
		
		if (FS==5'h1F) begin
			Y_lo = int_s / int_t; //quotient
			Y_hi = int_s % int_t; //remainder
		end
		
		//negative flag
		N = Y_lo[31];
		//Z flag
		if (Y_lo == 32'b0)
			Z = 1'b1;
		else
			Z = 1'b0;
			
	end //end always block
endmodule
