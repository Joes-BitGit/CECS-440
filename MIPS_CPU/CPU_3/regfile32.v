`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  regfile32.v
 * Project:    Lab_Assignment_2
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 12, 2018 
 *
 * Purpose: 32 Bit Register File is the component that contains the 
 *				user regsiters for a given processor that means it 
 *				conatins our general register and any special registers.
 *         
 * Notes:
 *
 ****************************************************************************/
module regfile32(
    input clk, reset, D_En,
    input [31:0] D,
    input [4:0] D_Addr, S_Addr, T_Addr,
    output wire [31:0] S, T
    );
	 
	reg [31:0] data [31:0];
	integer i;

	always @(posedge clk, posedge reset)
	begin
		if(reset)begin
			// Initialize R0 with zeros
			data[0] <= 32'h0;
		end
		// Synchronous Write with no write to R0
		else if(D_En && D_Addr != 32'h0) data[D_Addr] <= D;
	end
	
	// Asynchronous Read
	assign S = data[S_Addr];
	assign T = data[T_Addr];

endmodule
