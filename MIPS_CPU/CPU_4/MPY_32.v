`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  MPY_32.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 6th, 2018 
 *
 * Purpose:	This module takes care of the multiply operation for the ALU. The
 * 			inputs are 32z-bit S and T, and 5 bit FS (function select). The 
 * 			outputs are 32-bit Y_hi and Y_lo which are concatenated together
 * 			for the product, as well as the (N)negative and (Z)zero flags.
 *         
 * Notes: 
 *
****************************************************************************/
module MPY_32(
	input [31:0] S, T,
	input [4:0] FS,
	output reg [31:0] Y_hi, Y_lo,
	output reg N,Z
   );
	
	integer int_s, int_t;
	
	always @ (*) begin
		int_s = S;
		int_t = T;
		
		if (FS == 5'h1E) begin
			{Y_hi,Y_lo} = int_s * int_t; //result
		end
		
		//negative flag
		N = Y_hi[31];
		//Z flag
		if ({Y_hi,Y_lo} == 64'b0)
			Z = 1'b1;
		else
			Z = 1'b0;
	end //end always block
	
endmodule
