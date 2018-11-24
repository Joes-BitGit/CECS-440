`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  InstructionMemory.v
 * Project:    Lab_Assignment_5
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 10, 2018 
 *
 * Purpose: 4K X 8 Data Memory that is byte addressable
 *				in big endinan format.
 *         
 * Notes:
 *
 ****************************************************************************/
module InstructionMemory(
    input clk,
    input [31:0] Address,
    input [31:0] D_in,
    input IM_cs,
    input IM_wr,
    input IM_rd,
    output [31:0] D_out
    );
	
	reg [7:0] instruction_mem [0:4095];
	
	always@(posedge clk)begin
		if (IM_cs && IM_wr) //When cs = 1 and wr = 1
			{instruction_mem[Address],
			 instruction_mem[Address+1],
			 instruction_mem[Address+2],
			 instruction_mem[Address+3]}	
			 <= D_in;
	end
	
	//read memory here assign D_out
	//tri-state outputs w/ Hi-Z
	assign D_out = (IM_cs && IM_rd) ? {instruction_mem[Address+0],
												  instruction_mem[Address+1],
												  instruction_mem[Address+2],
												  instruction_mem[Address+3]}:
					   (IM_cs && !IM_rd)?  32'hz				    : 
												  32'h0;

endmodule
