`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  ALU_32.v
 * Project:    CECS 440 Lab 3
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 6th, 2018
 *
 * Purpose:	This module is the wrapper that connects the 3 separate modules
 *				(MIPS_32, DIV_32, MPY_32) together. The inputs are 32-bit S and
 *				T, and 5-bit input FS (function select). The outputs are 32-bit
 *		  		Y_hi and Y_lo as well as C(carry), V(overflow), N(negative) and
 *				Z(zero) flags. 2 multiplexers are created to select the correct
 *				from the modules, as well as the flags.
 *
 * Notes:
 *
****************************************************************************/
module ALU_32(
	input [31:0] S,T,
	input [4:0] shamt,
	input [4:0] FS,
	output [31:0] Y_hi, Y_lo,
	output C,V,N,Z
    );

	wire Z_mpy, Z_div, Z_mip, Z_shft,
		  N_mpy, N_div, N_mip, N_shft,
		  C_mip, C_shft, V_mip, V_shft;

   wire [31:0] Y_lo_mpy, Y_lo_div, Y_lo_mip, Y_lo_shft,
					Y_hi_mpy, Y_hi_div, Y_hi_mip;

	MIPS_32		MIPS_32		(.S(S),
									 .T(T),
									 .FS(FS),
									 .Y_hi(Y_hi_mip),
									 .Y_lo(Y_lo_mip),
									 .C(C_mip),
									 .V(V_mip),
									 .N(N_mip),
									 .Z(Z_mip));

	DIV_32		DIV_32		(.S(S),
									 .T(T),
									 .FS(FS),
									 .Y_hi(Y_hi_div),
									 .Y_lo(Y_lo_div),
									 .N(N_div),
									 .Z(Z_div));

	MPY_32		MPY_32		(.S(S),
									 .T(T),
									 .FS(FS),
									 .Y_hi(Y_hi_mpy),
									 .Y_lo(Y_lo_mpy),
									 .N(N_mpy),
									 .Z(Z_mpy));

   shift32	 BARREL_SHFT	(.T(T),
									 .shamt(shamt),
									 .stype(FS),
									 .C(C_shft),.V(V_shft),.N(N_shft),.Z(Z_shft),
									 .Y_lo(Y_lo_shft));


   //mux flags			
	assign {C,V,N,Z} = 	(FS == 5'h1E) ? {1'bx, 1'bx,  N_mpy, Z_mpy  }:
								(FS == 5'h1F) ? {1'bx, 1'bx,  N_div, Z_div  }:
								(FS == 5'h0C | FS == 5'h0D | FS == 5'h0E) ? 
													 {C_shft,V_shft,N_shft,Z_shft}:
													 {C_mip, V_mip, N_mip, Z_mip };

	//mux module outputs
	assign {Y_hi,Y_lo} = (FS==5'h1E)   ? {Y_hi_mpy,   Y_lo_mpy }:
								(FS==5'h1F)   ? {Y_hi_div,   Y_lo_div }:
								(FS==5'h0C|FS==5'h0D|FS==5'h0E) 
												  ? {32'b0,      Y_lo_shft}:
													 {Y_hi_mip,   Y_lo_mip };

endmodule
