`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  DIV_32.v
 * Project:    Lab_Assignment_3
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 2, 2018 
 *
 * Purpose: The division algorithm yields a 32-bit(LSB) quotient and a 32-bit
 *				(MSB) remainder. 
 *         
 * Notes: Only uses the negative and zero flag.
 *
 ****************************************************************************/
module DIV_32(
    input [31:0] S_DIV, T_DIV,
    input [4:0] FS_DIV,
    output reg [31:0] DIV_hi, DIV_lo,
    output reg N, Z
    );

	// Variables used to cast 32 bit signed integers
	integer int_S, int_T;
	
	always @ (*) begin
		int_S = S_DIV;
		int_T = T_DIV;
		
		if(FS_DIV == 5'h1F) begin 												 //DIV
			DIV_lo = int_S / int_T;
			DIV_hi = int_S % int_T;
		end

		N = DIV_lo[31];
		Z = (DIV_lo == 32'b0) ? 1'b1 : 1'b0;
	end	
	
endmodule
