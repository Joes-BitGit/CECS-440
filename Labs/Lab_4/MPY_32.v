`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  MPY_32.v
 * Project:    Lab_Assignment_1
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 2, 2018 
 *
 * Purpose: The multiplication algorithm yields a 64-bit product. 
 *          
 * Notes: Only uses the negative and zero flag.
 *
 ****************************************************************************/
module MPY_32(
    input [31:0] S_MPY, T_MPY,
    input [4:0] FS_MPY,
    output reg [31:0] MPY_hi, MPY_lo,
    output reg N, Z
    );
	 
	// Variables used to cast 32 bit signed integers
	integer int_S, int_T;
	
	always @(*) begin
		int_S = S_MPY;
		int_T = T_MPY;
		
		if (FS_MPY == 5'h1E) {MPY_hi,MPY_lo} = int_S * int_T;			 //MULT
			
		N = MPY_hi[31];
		Z = ({MPY_lo, MPY_hi} == 64'b0) ? 1'b1 : 1'b0;
	end

endmodule
