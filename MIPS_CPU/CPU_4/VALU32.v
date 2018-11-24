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
module VALU_32(
	input [31:0] S,T,
	input [4:0] FS,
	input [1:0] SPLAT,
	output wire [31:0] VY_hi, VY_lo
    );

		wire [31:0] VY_hi_mip,  VY_lo_mip;
		wire [31:0] VY_hi_mpy,  VY_lo_mpy;
		wire [31:0] VY_hi_div,  VY_lo_div;
		wire [31:0] VY_hi_splt, VY_lo_splt;

	MIPS_8		MIPS_8_1		(.S(S[7:0]),
											   .T(T[7:0]),
											   .FS(FS),
											   .VY_hi(VY_hi_mip[7:0]),
											   .VY_lo(VY_lo_mip[7:0]));

	MIPS_8		MIPS_8_2		(.S(S[15:8]),
												 .T(T[15:8]),
												 .FS(FS),
												 .VY_hi(VY_hi_mip[15:8]),
												 .VY_lo(VY_lo_mip[15:8]));

  MIPS_8		MIPS_8_3		(.S(S[23:16]),
												 .T(T[23:16]),
												 .FS(FS),
												 .VY_hi(VY_hi_mip[23:16]),
												 .VY_lo(VY_lo_mip[23:16]));

	MIPS_8		MIPS_8_4		(.S(S[31:24]),
												  .T(T[31:24]),
												  .FS(FS),
												  .VY_hi(VY_hi_mip[31:24]),
												  .VY_lo(VY_lo_mip[31:24]));

	//MULTIPLY ALU

	MPY_8		MPY_8_1		(.S(S[7:0]),
											   .T(T[7:0]),
											   .FS(FS),
											   .VY_hi(VY_hi_mpy[7:0]),
											   .VY_lo(VY_lo_mpy[7:0]));

	MPY_8		MPY_8_2		(.S(S[15:8]),
												 .T(T[15:8]),
												 .FS(FS),
												 .VY_hi(VY_hi_mpy[15:8]),
												 .VY_lo(VY_lo_mpy[15:8]));

  MPY_8		MPY_8_3		(.S(S[23:16]),
												 .T(T[23:16]),
												 .FS(FS),
												 .VY_hi(VY_hi_mpy[23:16]),
												 .VY_lo(VY_lo_mpy[23:16]));

	MPY_8		MPY_8_4		(.S(S[31:24]),
												  .T(T[31:24]),
												  .FS(FS),
												  .VY_hi(VY_hi_mpy[31:24]),
												  .VY_lo(VY_lo_mpy[31:24]));


  //DIVIDE ALU
	DIV_8		DIV_8_1		  (.S(S[7:0]),
											.T(T[7:0]),
											.FS(FS),
											.VY_hi(VY_hi_div[7:0]),
											.VY_lo(VY_lo_div[7:0]));

	DIV_8   DIV_8_2    (.S(S[15:8]),
											.T(T[15:8]),
											.FS(FS),
											.VY_hi(VY_hi_div[15:8]),
											.VY_lo(VY_lo_div[15:8]));

	DIV_8   DIV_8_3    (.S(S[23:16]),
											.T(T[23:16]),
											.FS(FS),
											.VY_hi(VY_hi_div[23:16]),
											.VY_lo(VY_lo_div[23:16]));

	DIV_8   DIV_8_4    (.S(S[31:24]),
											.T(T[31:24]),
											.FS(FS),
											.VY_hi(VY_hi_div[31:24]),
											.VY_lo(VY_lo_div[31:24]));

	SPLAT_32   SPLAT_1    (.S(S),
											.SPLAT(SPLAT), //index to splat
											.VY_hi(VY_hi_splt),
											.VY_lo(VY_lo_splt));

	//mux module outputs
	assign {VY_hi,VY_lo} = (FS==5'h02)  ? {VY_hi_mpy[31:24], VY_lo_mpy[31:24], VY_hi_mpy[23:16], VY_lo_mpy[23:16], //vector multiply
																				 VY_hi_mpy[15:8],  VY_lo_mpy[15:8],  VY_hi_mpy[7:0],   VY_lo_mpy[7:0]}:
											   (FS==5'h03)  ? {VY_hi_div,   VY_lo_div }: //vector divide
												 (FS==5'h06)  ? {32'b0,VY_hi_mpy[23:16], VY_lo_mpy[23:16], VY_hi_mpy[7:0], VY_lo_mpy[7:0]}: //mule
												 (FS==5'h07)  ? {32'b0,VY_hi_mpy[31:24], VY_lo_mpy[31:24], VY_hi_mpy[15:8], VY_lo_mpy[15:8]}: //mulo
												 (FS==5'h0C)  ? {32'b0, S[15:8],  T[15:8],  S[7:0],   T[7:0]}: //vector merge low
												 (FS==5'h0D)  ? {32'b0, S[31:24], T[31:24], S[23:16], T[23:16]}: //vector merge high
												 (FS==5'h0E)  ? {VY_hi_splt, VY_lo_splt}:
																				{VY_hi_mip,  VY_lo_mip };

endmodule
