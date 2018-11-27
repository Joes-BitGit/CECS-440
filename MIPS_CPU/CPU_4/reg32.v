`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  reg32.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 4, 2018 
 *
 * Purpose: General purpose 32-bit register
 *         
 * Notes:
 *
 ****************************************************************************/
module reg32(
    input clk,
    input reset,
    input [31:0] D,
    output reg [31:0] Q
    );

	always@(posedge clk, posedge reset) begin
		if (reset) Q <= 0;
		else Q <= D;
	end

endmodule
