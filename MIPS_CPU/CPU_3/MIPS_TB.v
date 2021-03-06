`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  MIPS_TB.v
 * Project:    Lab_Assignment_6
 * Designer:   Joseph Almeida, Peter Huynh
 * Email:      Josephnalmeida@gmail.com, peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 19, 2018
 *
 * Purpose:   Test fixture that instantiates the control unit,
 *				  instruction unit, integer datapath, and the data memory modules.
 *				  The testbench will implement the set of microoperations specified
 *				  in the lab document as well as reading the MIPS register file
 *				  and display the contents of the memory location starting
 *				  at hex address 0x03F0
 *
 * Notes:
 *
 ****************************************************************************/

module MIPS_TB;
	// Inputs
	reg clk;
	reg reset;

	wire INTR;
	wire INT_ACK;

	wire io_cs;
	wire io_wr;
	wire io_rd;
	wire DM_cs;
	wire DM_rd;
	wire DM_wr;

	wire [31:0] ALU_OUT_wire, DP_OUT_wire, DM_OUT_wire;

	 CPU		 			  CPU   (.sys_clk(clk), 
 										.reset(reset),
										.Din(DM_OUT_wire), 
										.INTR(INTR), 
										.INT_ACK(INT_ACK),
										.Address(ALU_OUT_wire),
										.Dout(DP_OUT_wire),
										.IO_cs(io_cs),
										.IO_rd(io_rd),
										.IO_wr(io_wr),
										.DM_cs(DM_cs),
										.DM_rd(DM_rd),
										.DM_wr(DM_wr));


	 dataMemory         DM    (.clk(clk),
										.dm_cs(DM_cs), 
										.dm_wr(DM_wr),
										.dm_rd(DM_rd),
										.Address({20'b0,ALU_OUT_wire[11:0]}), 
										.D_in(DP_OUT_wire), 
										.D_Out(DM_OUT_wire)); 

	 IO_Memory          IOM   (.clk(clk),
										.io_cs(io_cs), 
										.io_wr(io_wr),
										.io_rd(io_rd),
										.Address({20'b0,ALU_OUT_wire[11:0]}), 
										.D_in(DP_OUT_wire), 
										.D_Out(DM_OUT_wire),
										.INTR(INTR), 
										.INT_ACK(INT_ACK)); 

	// Create 10ns clock period
	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;

		$readmemh("dMem14_Fa18.dat", DM.data_mem);
		$readmemh("iMem14_Fa18_w_isr_commented.dat", CPU.IU.IM.instruction_mem);
		$timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds

		$display(" "); $display(" ");
		$display("****************************************************************");
		$display(" C E C S    4 4 0    M C U   T e s t b e n c h     R e s u l t s");
		$display("****************************************************************");
		$display(" ");

		@(negedge clk)
			reset=1;
		@(negedge clk)
			reset=0;
	end
endmodule
