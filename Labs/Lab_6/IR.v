`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  IR.v
 * Project:    Lab_Assignment_5
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 10, 2018
 *
 * Purpose:		The instruction register holds the data from the instruction
 *					memory that is stepped through by the PC in order to give
 *					to the datapath to be exceuted
 *
 * Notes:
 *
 ****************************************************************************/
module IR(
	 input clk,
    input reset,
    input [31:0] IR_in,
    input IR_ld,
    output reg [31:0] IR_out
    );

	always@(posedge clk, posedge reset)
	begin
		if (reset) IR_out <= 0;
		else if (IR_ld) IR_out <= IR_in;
	end

endmodule
