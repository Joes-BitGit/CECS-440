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
	reg INTR;

	wire INT_ACK;
	wire N;
	wire Z;
	wire C;
	wire V;
	wire [4:0] FS;
	wire PC_ld;
	wire PC_inc;
	wire IM_cs;
	wire IM_wr;
	wire IM_rd;
	wire IR_ld;
	wire D_En;
	wire T_sel;
	wire HILO_ld;
	wire DM_cs;
	wire DM_rd;
	wire DM_wr;
	wire [2:0] Y_sel;
	wire [1:0] PC_sel;
	wire [1:0] D_sel; //this is new too

	wire [31:0] ALU_OUT_wire, SE_16_wire, PC_out_wire, IR_out_wire, DP_OUT_wire,
               DM_OUT_wire, SREG_JR_WIRE;

	MCU					  MCU		(.sys_clk(clk),
										 .reset(reset),
										 .INTR(INTR), 
										 .C(C), .V(V), .Z(Z), .N(N),
										 .FS(FS),
										 .IR(IR_out_wire),
										 .INT_ACK(INT_ACK),
										 .PC_sel(PC_sel),
										 .PC_ld(PC_ld),
										 .PC_inc(PC_inc),
										 .IM_cs(IM_cs),
										 .IM_wr(IM_wr),
                               .IM_rd(IM_rd),
                               .IR_ld(IR_ld),
										 .D_En(D_En),
										 .D_sel(D_sel),
										 .T_sel(T_sel),
										 .HILO_ld(HILO_ld),
										 .DM_cs(DM_cs),
										 .DM_rd(DM_rd),
										 .DM_wr(DM_wr),
										 .Y_sel(Y_sel));


	Instruction_Unit    IU     (.clk(clk),
                               .reset(reset),
                               .PC_ld(PC_ld),
                               .PC_inc(PC_inc),
                               .IM_cs(IM_cs),
                               .IM_wr(IM_wr),
										 .PC_jr(SREG_JR_WIRE),
                               .IM_rd(IM_rd),
                               .IR_ld(IR_ld),
										 .PC_sel(PC_sel),
                               .PC_in(ALU_OUT_wire),
                               .SE_16(SE_16_wire),
                               .PC_out(PC_out_wire),
                               .IR_out(IR_out_wire));

    Integer_Datapath    IDP   (.clk(clk),
										 .reset(reset),
										 .D_En(D_En),
                               .T_Sel(T_sel),
										 .HILO_ld(HILO_ld),
										 .D_sel(D_sel),
                               .Y_Sel(Y_sel),
										 .RS(SREG_JR_WIRE),
                               .D_Addr(IR_out_wire[15:11]),
                               .S_Addr(IR_out_wire[25:21]),
                               .T_Addr(IR_out_wire[20:16]),
                               .FS(FS),
                               .DY(DM_OUT_wire),
										 .DT(SE_16_wire),
                               .PC_In(PC_out_wire),
                               .N(N), .Z(Z), .C(C), .V(V),
                               .D_OUT(DP_OUT_wire),
                               .ALU_OUT(ALU_OUT_wire));

    dataMemory          DM     (.clk(clk),
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

		$readmemh("dMem_Lab6.dat", DM.data_mem);
		$readmemh("iMem_Lab6_with_isr_commented.dat", IU.IM.instruction_mem);
		$timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds

		$display(" "); $display(" ");
		$display("*********************************************************************");
		$display(" C E C S    4 4 0    M C U   T e s t b e n c h      R e s u l t s  	 ");
		$display("*********************************************************************");
		$display(" ");

		@(negedge clk)
			reset=1;
		@(negedge clk)
			reset=0;

		#160 INTR = 1'b1;
		@(posedge INT_ACK)
			INTR = 1'b0;

	end
endmodule
