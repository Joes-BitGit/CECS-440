`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 * 
 * File Name:  Integer_Datapath2_TB.v
 * Project:    Lab_Assignment_4
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 5, 2018 
 *
 * Purpose: Test bench that test the functionality of the datapath and 
 *				data memory
 *         
 * Notes:
 *
 ****************************************************************************/

module Integer_Datapath2_TB;

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
	reg [31:0] PC_in;
	reg [2:0] Y_Sel;
	reg dm_cs;
	reg dm_wr;
	reg dm_rd;

	// Outputs
	wire C;
	wire V;
	wire N;
	wire Z;
	
	integer i;
	wire [31:0] DM_WIRE, D_wire, ADDRESS;
	 
	//							  clk, reset, D_En, D_Addr, S_Addr, T_Addr,  
	Integer_Datapath IDP  (.clk(clk), .reset(reset), .D_En(D_En), .D_Addr(D_Addr), .S_Addr(S_Addr), .T_Addr(T_Addr), 
	 
	// 						  DT				 ,T_Sel, FS, HILO_ld, DY     ,  
								  .DT(DT), .T_Sel(T_Sel), .FS(FS), .HILO_ld(HILO_ld), .DY(DM_WIRE),   
									
	// 						  PC_In       , Y_Sel, N, Z, C, V, D_OUT , ALU_OUT	
								  .PC_In(PC_in), .Y_Sel(Y_Sel), .N(N), .Z(Z), .C(C), .V(V), .D_OUT(D_wire), .ALU_OUT(ADDRESS));
									
	// 						  clk, Address,       		   D_in,   dm_cs, dm_wr, dm_rd, D_Out	
	dataMemory       DM   (.clk(clk), .Address({20'b0,ADDRESS[11:0]}), .D_in(D_wire), .dm_cs(dm_cs), .dm_wr(dm_wr), .dm_rd(dm_rd), .D_Out(DM_WIRE));

	
	task Reg_Dump;
		begin
			$display(" ");
			$display("REG DUMP");
			for (i=0; i<16; i=i+1) begin
				@(negedge clk) begin
					{DT   		  , HILO_ld, PC_in       , D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel} = 
					{32'hFFFF_FFFB, 1'b0   , 32'h100100C0, 5'b0  , 5'b0  , i[4:0], 1'b0, 1'b0 , 5'h2, 3'h0 };
					
					{dm_cs, dm_rd, dm_wr} = 3'b000;
					
					#1 $display("t=%t  T_Out=%h REGISTER=%d" ,
					   $time, IDP.T, IDP.T_Addr);
				end
			end //end for loop
		end //end begin
	endtask
	
	
	task Mem_Dump;
		begin
			$display(" ");
			$display("MEM DUMP");
			for (i=32'h0FF8; i<32'h0FFC;i=i+4) begin
				@(negedge clk)
				{DT   		  , HILO_ld, PC_in       , D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel} = 
				{32'hFFFF_FFFB, 1'b0   , 32'h100100C0, 5'b0  , 5'b0  , i[4:0], 1'b0, 1'b0 , 5'h0, 3'h3 };
				
				{dm_cs, dm_rd, dm_wr} = 3'b000;
				
				#1 $display("t=%t DATA_MEM = %h %h %h %h",
					$time, DM.data_mem[i],DM.data_mem[i+1],DM.data_mem[i+2],DM.data_mem[i+3]);
			end
		end
	endtask
				
	
	// Create 10ns clock period
	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		{clk, reset, D_En, D_Addr, S_Addr, T_Addr, DT, T_Sel, FS, HILO_ld, PC_in, Y_Sel, dm_cs, dm_wr, dm_rd} = 0;

      $readmemh("IntReg_Lab4.dat", IDP.RF_32.data);
		$readmemh("dMem_Lab4.dat", DM.data_mem);
		$timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds
		
		$display(" "); $display(" ");
		$display("*********************************************************************");
		$display(" C E C S    4 4 0    I D P 2   T e s t b e n c h      R e s u l t s  ");
		$display("*********************************************************************");
		$display(" ");
		
		// Add stimulus here
		@(negedge clk)
			reset=1;
		@(negedge clk)
			reset=0;
			
		//Displaying the initial contents of the Register File
		Reg_Dump();
		
		// a) R1 <- R3 | R4
		@(negedge clk) //RS <- R3(r3), RT <- R4(r4)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'h0  , 5'd3  , 5'd4  , 1'b0, 1'b0 , 5'd9, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) //ALU_Out <- RS(R3)| RT(R4)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'h0  , 5'd3  , 5'd4  , 1'b0, 1'b0 , 5'd9, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R1 <- ALU_Out(R3 | R4)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'h1  , 5'd3  , 5'd4  , 1'b1, 1'b0 , 5'd9, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
		
		/*****************************************************************************************
		******************************************************************************************/
			
		// b) R2 <- R1 - R14
		@(negedge clk) // RS <- R1(r1), RT <- R14(r14)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'd0  , 5'd1  , 5'd14,  1'b0, 1'b0 , 5'd3, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RS(R1) - RT(R14)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'd0  , 5'd0  , 5'd0,   1'b0, 1'b0 , 5'd3, 3'd2,  32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R2 <- ALU_Out(R1 - R14)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'd2  , 5'd0  , 5'd0,   1'b1, 1'b0 , 5'd3, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
			
		// c) r3 <- shr r4
		@(negedge clk) // RT <- R4(r4)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'd0  , 5'd0  , 5'd4,   1'b0, 1'b0 , 5'hD, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RT(r4) SHL
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0  , 5'd0,   1'b0, 1'b0 , 5'hD, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R3 <- ALU_Out(r4 shl)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd3  , 5'd0  , 5'd0,   1'b1, 1'b0 , 5'hD, 3'd2 , 32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
			
		// d) r4 <- shl r5
		@(negedge clk) // RT <- R4(r4)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } = 
			{1'b0   , 5'd0  , 5'd0  , 5'd5  , 1'b0, 1'b0 , 5'hC, 3'd2,  32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RT(r14) SHL
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0  , 5'd0,   1'b0, 1'b0 , 5'hC, 3'd2,  32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R2 <- ALU_Out(r14 shl)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0   , 5'd4  , 5'd0  , 5'd0,   1'b1, 1'b0 , 5'hC, 3'd2,  32'h100100C0, 32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/

		// e*) {r6,r5} <- r15/r14
		@(negedge clk) // RS <- R15(r15), RT <- R14(r14)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd15 , 5'd14,   1'b0, 1'b0 , 5'h1F, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // HI/LO <- RS(r15) / RT(r14)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b1,    5'd0  , 5'd15 , 5'd14,   1'b0, 1'b0 , 5'h1F, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R6 <- HI(RS/RT[31:16])
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd6  , 5'd0 ,  5'd0,   1'b1, 1'b0 , 5'h1F, 3'd0,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R5 <- LO(RS/RT[15:0])
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd5  , 5'd0 ,  5'd0,   1'b1, 1'b0 , 5'h1F, 3'd1,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
			
		// f*) {r8,r7} <- r11 * 0xFFFF_FFFB
		@(negedge clk) // RS <- R11(r11), RT <- DT(0xFFFF_FFFB)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd11 , 5'd0,   1'b0, 1'b1 , 5'h1E, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // HI/LO <- RS(r11) * DT(0xFFFF_FFFB)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b1,    5'd0  , 5'd11 , 5'd0,   1'b0, 1'b1 , 5'h1E, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R8 <- HI(r11*0xFFFF_FFFB[31:16])
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd8  , 5'd0 ,  5'd0,   1'b1, 1'b0 , 5'h1E, 3'd0,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R7 <- LO(r11*0xFFFF_FFFB[15:0])
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd7  , 5'd0 ,  5'd0,   1'b1, 1'b0 , 5'h1E, 3'd1,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
		
		// g) r12 <- m[r15]
		@(negedge clk) // RS <- R15
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd15 ,  5'd0,   1'b0, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RS(r15) PASS_S
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd15 ,  5'd0,   1'b0, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // MAR <- ALU_Out(r15)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd12  , 5'd0 ,  5'd0,   1'b1, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b101;
			
		@(negedge clk) //R12 <- M[15], read DY (Y_sel = 3'd3)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0 , 5'd0  ,  5'd0,   1'b0, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b101;
			
		@(negedge clk) //R12 <- M[15], read DY (Y_sel = 3'd3)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd12 , 5'd0  ,  5'd0,   1'b1, 1'b0 , 5'h00, 3'd3,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
		
		// h) r11 <- r0 nor r11
		@(negedge clk) // RS <- R0(r0), RT <- R11(r11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0  , 5'd11,  1'b0, 1'b0 , 5'h0B, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <-RS(r0) nor R11(r11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0  , 5'd0,   1'b0, 1'b0 , 5'h0B, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R11 <- ALU_Out(r0 nor r11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd11 , 5'd0  , 5'd0,   1'b1, 1'b0 , 5'h0B, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
		
		// i) r10 <- r0 - r10
		@(negedge clk) // RS <- R0(r0), RT <- R10(r10)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0  , 5'd10,  1'b0, 1'b0 , 5'd3, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RS(R0) - RT(R10)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0  , 5'd0,   1'b0, 1'b0 , 5'd3, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R2 <- ALU_Out(r0 - r10)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd10 , 5'd0 ,  5'd0,   1'b1, 1'b0 , 5'd3, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
		
		// j) r9 <- r10 + r11
		@(negedge clk) // RS <- R10(r10), RT <- R11(R11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd10 , 5'd11,  1'b0, 1'b0 , 5'd2, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RS(R10) + RT(R11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd10 , 5'd11,  1'b0, 1'b0 , 5'd2, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R9 <- ALU_Out(R10 + R11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd9  , 5'd10 , 5'd11,  1'b1, 1'b0 , 5'd2, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/	
		
		// k) r13 <- 0x100100C0 
		@(negedge clk) // RS <- R10(r10), RT <- R11(R11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0 ,  5'd0,   1'b0, 1'b0 , 5'd0, 3'd4,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_Out <- RS(R10) + RT(R11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0 ,  5'd0,   1'b0, 1'b0 , 5'd0, 3'd4,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // R9 <- ALU_Out(R10 + R11)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd13 , 5'd0 , 5'd0,   1'b1, 1'b0 , 5'd0, 3'd4,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		/*****************************************************************************************
		******************************************************************************************/
		
		// I) M[r14] <- R12
		@(negedge clk) //RS <- R14(r14), RT <- R12(r12)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd14 ,  5'd12,   1'b0, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // ALU_OUT<- RS(r14), D_OUT <- R12
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd14 ,  5'd12,   1'b1, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b000;
			
		@(negedge clk) // M[14] <- ALU_OUT(r14)
			{HILO_ld, D_Addr, S_Addr, T_Addr, D_En, T_Sel, FS  , Y_Sel, PC_in       , DT           } =
			{1'b0,    5'd0  , 5'd0 ,  5'd0,   1'b0, 1'b0 , 5'h00, 3'd2,  32'h100100C0 ,32'hFFFF_FFFB};
			
			{dm_cs, dm_wr, dm_rd} = 3'b110;

		//Displaying final contents of the register file and memory		
		Reg_Dump();
		
		Mem_Dump();
		
	end //initial end
      
endmodule
