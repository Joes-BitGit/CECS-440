`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  MPY_32.v
 * Project:    CECS 440 Lab 3
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 6th, 2018
 *
 * Purpose:	This module takes care of the multiply operation for the ALU. The
 * 			inputs are 32-bit S and T, and 5 bit FS (function select). The
 * 			outputs are 32-bit Y_hi and Y_lo which are concatenated together
 * 			for the product, as well as the (N)negative and (Z)zero flags.
 *
 * Notes:
 *
****************************************************************************/
module MPY_8(
	input [7:0] S, T,
	input [4:0] FS,
	output reg [7:0] VY_hi, VY_lo
   );

	integer int_s, int_t;

	always @ (*) begin
		int_s = S;
		int_t = T;

		if (FS == 5'h2) begin
			{VY_hi,VY_lo} = int_s * int_t; //result
		end
	end //end always block

endmodule
