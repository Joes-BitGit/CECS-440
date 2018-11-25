`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  MIPS_TB.v
 * Project:    Lab_Assignment_6
 * Designer:   Joseph Almeida, Peter Huynh
 * Email:      Josephnalmeida@gmail.com, peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  November 24, 2018
 *
 * Purpose:   Test fixture that instantiates the CPU, and the data memory 
 *				  modules. The testbench will implement the set of microoperations 
 *				  specified in the ISA document.
 *
 * Notes:
 *
 ****************************************************************************/

module MIPS_TB;
	reg clk;
	reg reset;
	reg INTR;
	wire INT_ACK;
	wire DM_cs;
	wire DM_rd;
	wire DM_wr;

	wire [31:0] ALU_OUT_wire, DP_OUT_wire, DM_OUT_wire ;

	 CPU		 			  CPU   (.sys_clk(clk),
										.reset(reset),
 										.Din(DM_OUT_wire),
 										.INTR(INTR), 		
 										.INT_ACK(INT_ACK),
 										.Address(ALU_OUT_wire),
 										.Dout(DP_OUT_wire),
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

	// Create 10ns clock period
	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		INTR = 0;
//		$readmemh("dMem01_Fa18.dat", DM.data_mem);
//		$readmemh("iMem01_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem02_Fa18.dat", DM.data_mem);
//		$readmemh("iMem02_Fa18_commented.dat", IU.IM.instruction_mem);
// 	$readmemh("dMem03_Fa18.dat", DM.data_mem);
// 	$readmemh("iMem03_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem04_Fa18.dat", DM.data_mem);
//		$readmemh("iMem04_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem05_Fa18.dat", DM.data_mem);
//		$readmemh("iMem05_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem06_Fa18.dat", DM.data_mem);
//		$readmemh("iMem06_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem07_Fa18.dat", DM.data_mem);
//		$readmemh("iMem07_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem08_Fa18.dat", DM.data_mem);
//		$readmemh("iMem08_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem09_Fa18.dat", DM.data_mem);
//		$readmemh("iMem09_Fa18_commented.dat", IU.IM.instruction_mem);
//		$readmemh("dMem10_Fa18.dat", DM.data_mem);
//		$readmemh("iMem10_Fa18_commented.dat", IU.IM.instruction_mem);
// 	$readmemh("dMem11_Fa18.dat", DM.data_mem);
// 	$readmemh("iMem11_Fa18_commented.dat", IU.IM.instruction_mem);
		$readmemh("dMem12_Fa18.dat", DM.data_mem);
		$readmemh("iMem12_Fa18_commented.dat", CPU.IU.IM.instruction_mem);
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

		// #160 INTR = 1'b1;
		// @(posedge INT_ACK)
		// 	INTR = 1'b0;

	end
endmodule
