`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  Integer_Datapath.v
 * Project:    Lab_Assignment_4
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 5, 2018
 *
 * Purpose: 4K X 8 Data Memory that is byte addressable
 *				in big endinan format.
 *
 * Notes:
 *
 ****************************************************************************/
module dataMemory(
    input clk, dm_cs, dm_wr, dm_rd,
    input [31:0] Address, D_in,
	 output [31:0] D_Out
    );

	reg [7:0] data_mem [0:4095];

	always @ (posedge clk) begin
		if (dm_cs && dm_wr) //When cs = 1 and wr = 1
			{data_mem[Address],
			 data_mem[Address+1],
			 data_mem[Address+2],
			 data_mem[Address+3]}
			 <= D_in;
	end //end always

	//read memory here assign D_OUT
	//tri-state outputs w/ Hi-Z
	assign D_Out = (dm_cs && dm_rd) ? {data_mem[Address+0],
												  data_mem[Address+1],
												  data_mem[Address+2],
												  data_mem[Address+3]}:
												  32'hz				    ;



endmodule
