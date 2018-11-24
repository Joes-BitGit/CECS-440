`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Integer_Datapath.v
 * Project:    Lab_Assignment_4
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 2.0
 * Rev. Date:  October 5, 2018 
 *
 * Purpose: Top level module that instantiates the datapath and data memory
 *         
 * Notes:
 *
 ****************************************************************************/
module Datapath_Top(
    input clk, reset, D_En,
    input [4:0] D_Addr, S_Addr, T_Addr,
    input [31:0] DT,
    input T_Sel,
    input [4:0] FS,
    input HILO_ld,
    input [31:0] PC_in,
    input [2:0] Y_Sel,
    input dm_cs, dm_wr, dm_rd,
	 output C, V, N, Z
    );
	 
	 wire [31:0] DM_WIRE, D_wire, ADDRESS;
	 
	//							  clk, reset, D_En, D_Addr, S_Addr, T_Addr,  
	Integer_Datapath IDP  (clk, reset, D_En, D_Addr, S_Addr, T_Addr, 
	 
	// 						  DT, T_Sel, FS, HILO_ld, DY     ,  
								  DT, T_Sel, FS, HILO_ld, DM_WIRE,   
									
	// 						  PC_In, Y_Sel, N, Z, C, V, D_OUT , ALU_OUT	
								  PC_in, Y_Sel, N, Z, C, V, D_wire, ADDRESS);
									
	// 						  clk, Address              , D_in  , 	
	dataMemory       DM   (clk, {20'b0,ADDRESS[11:0]}, D_wire, 
	
	//							  dm_cs, dm_wr, dm_rd, D_Out
								  dm_cs, dm_wr, dm_rd, DM_WIRE);


endmodule
