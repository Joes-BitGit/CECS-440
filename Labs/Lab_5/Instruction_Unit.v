`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Instruction_Unit.v
 * Project:    Lab_Assignment_5
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 11, 2018 
 *
 * Purpose: Datapath that stitches the register file and ALU together
 *				to allow data to come in from sources such as memory, I/O,
 *				or applicable IR fields
 *         
 * Notes:
 *
 ****************************************************************************/
module Instruction_Unit(
    input clk, reset, PC_ld, PC_inc, IM_cs, IM_wr, IM_rd, IM_ld,
    input  		 [31:0] PC_in,
    output 		 [31:0] SE_16,
    output wire [31:0] PC_out, IR_out
    );
	
	wire [31:0] iData;
	
	PC 						PC(.clk(clk), 
									.reset(reset), 
									.PC_in(PC_in), 
									.PC_ld(PC_ld), 
									.PC_inc(PC_inc), 
									.PC_out(PC_out));
	
	InstructionMemory 	IM(.clk(clk), 
									.Address(PC_out), 
									.D_in(32'h0), 
									.IM_cs(IM_cs), 
									.IM_wr(1'b0), 
									.IM_rd(IM_rd), 
									.D_out(iData));
	
	IR 						IR(.clk(clk), 
									.reset(reset), 
									.IR_in(iData), 
									.IR_ld(IR_ld), 
									.IR_out(IR_out));
	
	assign SE_16 = {{5'd16{IR_out[15]}},IR_out[15:0]};


endmodule
