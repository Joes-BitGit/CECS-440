`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Integer_Datapath.v
 * Project:    Lab_Assignment_3
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 24, 2018 
 *
 * Purpose: Datapath that stitches the register file and ALU together
 *				to allow data to come in from sources such as memory, I/O,
 *				or applicable IR fields
 *         
 * Notes:
 *
 ****************************************************************************/
module Integer_Datapath(
    input clk, reset, D_En,
    input [4:0] D_Addr, S_Addr, T_Addr,
    input [31:0] DT,
    input T_Sel,
    input [4:0] FS,
    input HILO_ld,
    input [31:0] DY, PC_In,
    input [2:0] Y_Sel,
    output N, Z, C, V,
    output [31:0] D_OUT, ALU_OUT
    );
	
	reg [31:0] HI, LO;
	
	wire [31:0] T, S;
	
	wire [31:0] Y_HI, Y_LO;
	
	//    			  clk, reset, D_En, D      , D_Addr, S_Addr, T_Addr, S, T
	regfile32 RF_32 (clk, reset, D_En, ALU_OUT, D_Addr, S_Addr, T_Addr, S, T);
	
	// T-MUX 
	assign D_OUT = (T_Sel == 1'b0) ? T : DT;
	
	//					  S, T    , FS, Y_hi, Y_lo, N, Z, C, V
	ALU_32 	 ALU32 (S, D_OUT, FS, Y_HI, Y_LO, N, Z, C, V);
	
	// HI and LO REGISTERS
	always @ (posedge clk, posedge reset) begin
		if (reset == 1'b1) begin 
			HI <= 0;
			LO <= 0;
		end
		else if (HILO_ld == 1'b1) begin
			HI <= Y_HI;
			LO <= Y_LO;
		end
	end
	
	// Y-MUX
	assign ALU_OUT = (Y_Sel == 3'h0) ? HI   :
						  (Y_Sel == 3'h1) ? LO   :
						  (Y_Sel == 3'h2) ? Y_LO :
						  (Y_Sel == 3'h3) ? DY   :
												  PC_In;
	
	
endmodule
