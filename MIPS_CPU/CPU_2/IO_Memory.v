`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  IO_Memory.v
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
module IO_Memory(
    input clk, io_cs, io_wr, io_rd, INT_ACK,
    input [31:0] Address, D_in,
    output reg INTR,
	 output [31:0] D_Out
    );

	reg [7:0] io_mem [0:4095];

	always @ (posedge clk) begin
		if (io_cs && io_wr) //When cs = 1 and wr = 1
			{io_mem[Address],
			 io_mem[Address+1],
			 io_mem[Address+2],
			 io_mem[Address+3]}
			 <= D_in;
	end //end always

	//read memory here assign D_OUT
	//tri-state outputs w/ Hi-Z
	assign D_Out = (io_cs && io_rd) ? {io_mem[Address+0],
												  io_mem[Address+1],
												  io_mem[Address+2],
												  io_mem[Address+3]}:
					   /*(io_cs && !io_rd)?*/  32'hz				    ;
												 // D_Out;

  initial begin
    INTR = 1'b0;
    #160 INTR = 1'b1;
    @(posedge INT_ACK)
    	INTR = 1'b0;
  end


endmodule
