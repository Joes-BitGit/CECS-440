`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  regfile32_TB.v
 * Project:    Lab_Assignment_2
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 12, 2018 
 *
 * Purpose: This test bench is to verify the ability to use our 
				32 x 32-bit Register file, by writing and reading to it.
 *         
 * Notes:
 *
 ****************************************************************************/

module regfile32_TB;

	// Inputs
	reg clk;
	reg reset;
	reg D_En;
	reg [31:0] D;
	reg [4:0] D_Addr;
	reg [4:0] S_Addr;
	reg [4:0] T_Addr;
	
	integer i;

	// Outputs
	wire [31:0] Sdata;
	wire [31:0] Tdata;

	// Instantiate the Unit Under Test (UUT)
	regfile32 uut (
		.clk(clk), 
		.reset(reset), 
		.D_En(D_En), 
		.D(D), 
		.D_Addr(D_Addr), 
		.S_Addr(S_Addr), 
		.T_Addr(T_Addr), 
		.S(Sdata), 
		.T(Tdata)
	);
	
	// Create 10ns clock period
	always
		#5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		D_En = 0;
		D = 0;
		D_Addr = 0;
		S_Addr = 0;
		T_Addr = 0;

		// Wait 100 ns for global reset to finish
		// #100;
      $readmemh("IntReg_Lab2.dat", uut.data);
		$timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds
		
		$display(" "); $display(" ");
		$display("***********************************************************************");
		$display(" C E C S    4 4 0    REG_FILE    T e s t b e n c h      R e s u l t s  ");
		$display("***********************************************************************");
		$display(" ");
		
		// Add stimulus here
		@(negedge clk)
		reset=1;
		@(negedge clk)
		reset=0;
		
		// 1. For-loop for reading intial values
		$display(" ");
		$display("READ INTITAL VALUES");
		for (i=0; i<16; i=i+1) begin
			S_Addr = i;
			T_Addr = i + 16;
			#1 $display("t=%t  S_Addr=%h, S=%h || T_Addr=%h  T=%h",
							 $time, S_Addr,Sdata,T_Addr,Tdata);
		end
				
		// 2. For-loop for writing
		for (i=0; i<32; i=i+1) begin
			@(negedge clk) begin
				D_En = 1;
				D_Addr = i;
				D = ((~i) << 8) + (-65536 * i) + i;
			end
		end
		
		// 3. For-loop for reading after writing
		$display(" ");
		$display("READ UPDATED RESULTS");
		for (i=0; i<16; i=i+1) begin
			S_Addr = i;
			T_Addr = i + 16;
			#1 $display("t=%t  S_Addr=%h, S=%h || T_Addr=%h  T=%h",
							 $time, S_Addr,Sdata,T_Addr,Tdata);
		end
	end
      
endmodule

