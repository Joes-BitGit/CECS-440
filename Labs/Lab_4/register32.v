`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Integer_Datapath.v
 * Project:    Lab_Assignment_4
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 4, 2018 
 *
 * Purpose: Datapath that stitches the register file and ALU together
 *				to allow data to come in from sources such as memory, I/O,
 *				or applicable IR fields
 *         
 * Notes:
 *
 ****************************************************************************/
module register32(
    input clk,
    input reset,
    input [31:0] D,
    output [31:0] Q
    );

	always@(posedge clk, posedge reset) begin
		if (reset) begin
			D <= 0;
		end
		else begin
			Q <= D;
		end
	end


endmodule
