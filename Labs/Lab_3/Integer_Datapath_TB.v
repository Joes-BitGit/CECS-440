`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Integer_Datapath_TB.v
 * Project:    Lab_Assignment_3
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 25, 2018 
 *
 * Purpose: Test bench to test the functionality of the IDP
 *         
 * Notes:
 *
 ****************************************************************************/

module Integer_Datapath_TB;

	// Inputs
	reg clk;
	reg reset;
	reg D_En;
	reg [4:0] D_Addr;
	reg [4:0] S_Addr;
	reg [4:0] T_Addr;
	reg [31:0] DT;
	reg T_Sel;
	reg [4:0] FS;
	reg HILO_ld;
	reg [31:0] DY;
	reg [31:0] PC_In;
	reg [2:0] Y_Sel;

	// Outputs
	wire N;
	wire Z;
	wire C;
	wire V;
	wire [31:0] D_OUT;
	wire [31:0] ALU_OUT;
	
	integer i;

	// Instantiate the Unit Under Test (UUT)
	Integer_Datapath uut (
		.clk(clk), 
		.reset(reset), 
		.D_En(D_En), 
		.D_Addr(D_Addr), 
		.S_Addr(S_Addr), 
		.T_Addr(T_Addr), 
		.DT(DT), 
		.T_Sel(T_Sel), 
		.FS(FS), 
		.HILO_ld(HILO_ld), 
		.DY(DY), 
		.PC_In(PC_In), 
		.Y_Sel(Y_Sel), 
		.N(N), 
		.Z(Z), 
		.C(C), 
		.V(V), 
		.D_OUT(D_OUT), 
		.ALU_OUT(ALU_OUT)
	);
	
	task Reg_Dump;
		input [31:0] i;
		begin
			$display(" ");
			$display("REG DUMP");
			for (i=0; i<16; i=i+1) begin
				@(negedge clk) begin
					{DT, HILO_ld, DY, PC_In} = {32'b0,1'b0,32'b0,32'b0};
					{D_Addr, T_Addr, D_En, T_Sel} = {4'b0, 4'b0, 1'b0, 1'b0};
					S_Addr = i;
					FS = 0;
					Y_Sel = 2;
					#1 $display("t=%t  ALU_OUT=%h REGISTER=%d",
									 $time, ALU_OUT, S_Addr);
				end
			end
		end
	endtask
	
	// Create 10ns clock period
	always #5 clk = ~clk;
		
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		D_En = 0;
		D_Addr = 0;
		S_Addr = 0;
		T_Addr = 0;
		DT = 0;
		T_Sel = 0;
		FS = 0;
		HILO_ld = 0;
		DY = 0;
		PC_In = 0;
		Y_Sel = 0;

		// Wait 100 ns for global reset to finish
		// #100;
      $readmemh("IntReg_Lab3.dat", uut.RF_32.data);
		$timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds
		
		$display(" "); $display(" ");
		$display("********************************************************************");
		$display(" C E C S    4 4 0    I D P    T e s t b e n c h      R e s u l t s  ");
		$display("********************************************************************");
		$display(" ");
		
		// Add stimulus here
		@(negedge clk)
			reset=1;
		@(negedge clk)
			reset=0;
		
		Reg_Dump(i);

		@(negedge clk)  // TEST #a: r1 = r3 | r4
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En = 1;
			S_Addr = 3;
			T_Addr = 4;
			D_Addr = 1;
			T_Sel = 0;
			FS = 9;			
			Y_Sel = 2;
			
		@(negedge clk)  // TEST #b: r2 = r1 - r14
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'h1;
			T_Addr = 5'hE;
			D_Addr = 5'h2;
			T_Sel  = 1'h0;
			FS     = 5'h3;			
			Y_Sel  = 3'h2;
			
		@(negedge clk)  // TEST #c: r3 = srl(r4)
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'h0;
			T_Addr = 5'h4;
			D_Addr = 5'h3;
			T_Sel  = 1'h0;
			FS     = 5'hD;			
			Y_Sel  = 3'h2;
			
		@(negedge clk)  // TEST #d: r4 = sll(r5)
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'h0;
			T_Addr = 5'h5;
			D_Addr = 5'h4;
			T_Sel  = 1'h0;
			FS     = 5'hC;			
			Y_Sel  = 3'h2;
			
		@(negedge clk)  // TEST #e: {r6, r5} = r15 / r14
			{DT, D_En, DY, PC_In}={32'b0,1'b1,32'b0,32'b0};
			HILO_ld = 1'h1;
			S_Addr  = 5'hF;
			T_Addr  = 5'hE;
			D_Addr  = 5'h6;
			T_Sel   = 1'h0;
			FS      = 5'h1F;			
			Y_Sel   = 3'h0;
			
		@(negedge clk)  // TEST #e: {r6, r5} = r15 / r14
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'hF;
			T_Addr = 5'hE;
			D_Addr = 5'h6;
			T_Sel  = 1'h0;
			FS     = 5'h1F;			
			Y_Sel  = 3'h0;
			
		@(negedge clk)  // TEST #e: {r6, r5} = r15 / r14
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'hF;
			T_Addr = 5'hE;
			D_Addr = 5'h5;
			T_Sel  = 1'h0;
			FS     = 5'h1F;			
			Y_Sel  = 3'h1;
		
		@(negedge clk)  // TEST #f: {r8, r7} = r11 * 0xffff_fffb (DT)
			{DT, D_En, DY, PC_In}={32'b0,1'b1,32'b0,32'b0};
			DT      = 32'hFFFF_FFFB;
			HILO_ld = 1'h1;
			S_Addr  = 5'hB;
			T_Addr  = 5'hE;
			D_Addr  = 5'h8;
			T_Sel   = 1'h1;
			FS      = 5'h1E;			
			Y_Sel   = 3'h0;
			
		@(negedge clk)  // TEST #f: {r8, r7} = r11 * 0xffff_fffb (DT)
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'hB;
			T_Addr = 5'hE;
			D_Addr = 5'h8;
			T_Sel  = 1'h0;
			FS     = 5'h1E;			
			Y_Sel  = 3'h0;
			
		@(negedge clk)  // TEST #f: {r8, r7} = r11 * 0xffff_fffb (DT)
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'hB;
			T_Addr = 5'hE;
			D_Addr = 5'h7;
			T_Sel  = 1'h0;
			FS     = 5'h1E;			
			Y_Sel  = 3'h1;
			
		@(negedge clk)  // TEST #g: r12 = 0xABCD_EF01 (DY)
			{DT, HILO_ld, PC_In}={32'b0,1'b0,32'b0};
			DY     = 32'hABCD_EF01;
			D_En   = 1'h1;
			S_Addr = 5'hF;
			T_Addr = 5'hE;
			D_Addr = 5'hC;
			T_Sel  = 1'h1;
			FS     = 5'h0;			
			Y_Sel  = 3'h3;
			
		@(negedge clk)  // TEST #h: r11 = r0 nor r11
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'h0;
			T_Addr = 5'hB;
			D_Addr = 5'hB;
			T_Sel  = 1'h0;
			FS     = 5'hB;			
			Y_Sel  = 3'h2;
		
		@(negedge clk)  // TEST #i: r10 = r0 - r10
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'h0;
			T_Addr = 5'hA;
			D_Addr = 5'hA;
			T_Sel  = 1'h0;
			FS     = 5'h3;			
			Y_Sel  = 3'h2;
		
		@(negedge clk)  // TEST #j: r9 = r10 + r11
			{DT, HILO_ld, DY, PC_In}={32'b0,1'b0,32'b0,32'b0};
			D_En   = 1'h1;
			S_Addr = 5'hA;
			T_Addr = 5'hB;
			D_Addr = 5'h9;
			T_Sel  = 1'h0;
			FS     = 5'h2;			
			Y_Sel  = 3'h2;
			
		@(negedge clk)  // TEST #k: r13 = 0x100100C0 (PC_in)
			{DT, HILO_ld, DY}={32'b0,1'b0,32'b0};
			PC_In  = 32'h100100C0;
			D_En   = 1'h1;
			S_Addr = 5'h0;
			T_Addr = 5'h0;
			D_Addr = 5'hD;
			T_Sel  = 1'h0;
			FS     = 5'h0;			
			Y_Sel  = 3'h4;
		
		$display(" ");	
		Reg_Dump(i);
	end
      
endmodule

