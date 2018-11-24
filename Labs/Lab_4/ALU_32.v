`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  ALU_32.v
 * Project:    Lab_Assignment_1
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 4, 2018 
 *
 * Purpose: Top level module ALU that acts as a wrapper to instantiate 
 *				the MIPS, MULT, and DIV modules and outputs the proper 
 *				proper result and flags depending on the funstion select.
 *         
 * Notes:
 *
 ****************************************************************************/
module ALU_32(
    input [31:0] S, T,
    input wire [4:0] FS,
    output [31:0] Y_hi, Y_lo,
    output N, Z, C, V
    );
	 
	 wire [31:0] yhi_mip, ylo_mip, yhi_mul, ylo_mul, yhi_div, ylo_div;
	 wire mips_N, mip_Z, mip_C, mip_V, mul_N, mul_Z, div_N, div_Z;
	 
	 //				S_MIPS, T_MIPS, FS_MIPS, MIPS_hi, MIPS_lo, 
	 MIPS_32 MI32 (S     , T     , FS     , yhi_mip, ylo_mip, 
	 
	 //				N     , Z    , C    , V
						mips_N, mip_Z, mip_C, mip_V);
	 
	 //				S_MPY, T_MPY, FS_MPY, MPY_hi , MPY_lo , N    , Z
	 MPY_32  MP32 (S    , T    , FS    , yhi_mul, ylo_mul, mul_N, mul_Z);
	 
	 //      		S_DIV, T_DIV, FS_DIV, DIV_lo , DIV_hi , N    , Z
	 DIV_32  DV32 (S    , T    , FS    , yhi_div, ylo_div, div_N, div_Z);
	 
	 assign {Y_hi, Y_lo, N, Z, C, V} = (FS == 5'h1E) ? 				 //MULT
	 
												  {yhi_mul, ylo_mul, 
												  
													mul_N, mul_Z, 1'bx, 1'bx}: 
	 
												  (FS == 5'h1F) ? 				 //DIV
												 
												  {yhi_div, ylo_div, 
												  
												   div_N, div_Z, 1'bx, 1'bx}:
												 
												  {yhi_mip, ylo_mip, 			 //MIPS
												  
													mips_N, mip_Z, mip_C, mip_V};

endmodule
