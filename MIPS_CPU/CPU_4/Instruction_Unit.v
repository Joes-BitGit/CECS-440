`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  Instruction_Unit.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.1
 * Rev. Date:  October 16, 2018
 *
 * Purpose:    This is the module that contains the instantiation of the program
 *             counter, instruction memory and and instruction register module.
 *             The PC and IR are 32-bit registers that interface with the
 *             Instruction Memory module.
 *
 * Notes:
 *
 ****************************************************************************/
module Instruction_Unit(
    input clk, reset, PC_ld, PC_inc, IM_cs, IM_wr, IM_rd, IR_ld,
	 input 		 [1:0]  PC_sel,
    input  		 [31:0] PC_in,
	 input		 [31:0] PC_jr,
    output 		 [31:0] SE_16,
    output wire [31:0] PC_out, IR_out
    );

	wire [31:0] iData;
	reg [31:0] PC_mux;
	
	// PC Mux
	always@(*)
	begin
		if      (PC_sel == 2'b00)	PC_mux = (PC_out + {SE_16[29:0], 2'b0});
		else if (PC_sel == 2'b01)  PC_mux = {PC_out[31:28], IR_out[25:0], 2'b0};
		else if (PC_sel == 2'b10)	PC_mux = (PC_in);
		else if (PC_sel == 2'b11)  PC_mux = (PC_jr);
	end

	PC 						PC(.clk(clk),
									.reset(reset),
									.PC_in(PC_mux),
									.PC_ld(PC_ld),
									.PC_inc(PC_inc),
									.PC_out(PC_out));

	InstructionMemory 	IM(.clk(clk),
									.Address({20'b0,PC_out[11:0]}),
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
