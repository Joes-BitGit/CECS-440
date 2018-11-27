`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  MPY_8.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Peter Huynh, Joseph Almeida
 * Email:      peterhuynh75@gmail.com
 *					josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  November 24th, 2018
 *
 * Purpose:		This modules takes care of the multiply operation for the
 *					VALU. The outputs are VY_hi and VY_lo concatenated together.
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
