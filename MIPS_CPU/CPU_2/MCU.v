`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  MCU.v
 * Project:    Lab_Assignment_6
 * Designer:   Joseph Almeida, Peter Huynh, R. W. Allison
 * Email:      josephnalmeida@gmail.com, peterhuynh75@gmail.com,
 * 				rob.allison@csulb.edu
 * Rev. No.:   Version 1.0
 * Rev. Date:  October 22, 2018
 *
 * Purpose:    A state machine implementing the MIPS Control Unit (MCU)
 *					for the major cycles of fetch, execture and some MIPS
 *					instruction from memoru, inclding checking for interrupts.
 *
 * Notes:
 *
 ****************************************************************************/
module MCU(
    input sys_clk,
    input reset,
    input INTR,
    input C,
    input N,
    input Z,
    input V,
    input [31:0] IR,
	 output reg [4:0] FS,
    output reg INT_ACK,
	 output reg [1:0] PC_sel,
    output reg PC_ld,
    output reg PC_inc,
    output reg IM_cs,
    output reg IM_wr,
    output reg IM_rd,
    output reg IR_ld,
    output reg D_En,
    output reg [1:0] D_sel,
    output reg T_sel,
    output reg HILO_ld,
    output reg DM_cs,
    output reg DM_rd,
    output reg DM_wr,
    output reg [2:0] Y_sel,
    output reg io_cs,
    output reg io_rd,
    output reg io_wr
    );

	 integer i;
    reg psi, psc, psv, psn, psz; // present state flag registers
	 reg nsi, nsc, nsv, nsn, nsz; //next state flag registers

	//**************************
	// internal data structures
	//**************************

	task Reg_Dump;
		begin
			$display("REG DUMP");
			for (i=0; i<16; i=i+1) begin
				@(negedge sys_clk) begin
				//Deassert everything and dump MIPS register
				 {PC_sel,PC_ld,PC_inc,IR_ld} 		  	= 5'b00_0_0_0;
				 {IM_cs,IM_rd,IM_wr} 			  		= 3'b0_0_0;
				 {D_En,D_sel,T_sel,HILO_ld,Y_sel} 	= 8'b0_00_0_0_000;
				 FS 											= 5'h0;
				 INT_ACK 									= 1'b0;
				 {DM_cs,DM_rd,DM_wr} 					= 3'b0_0_0;
				 {io_cs,io_rd,io_wr}               	= 3'b0_0_0;
				 #1 $display("t=%t  Contents=%h $r=%d || Contents=%h $r=%d" ,
					 $time, MIPS_TB.CPU.IDP.RF_32.data[i], i[4:0],
							  MIPS_TB.CPU.IDP.RF_32.data[i+16],
							  (i[4:0]+ 5'd16));
				end
			end //end for loop
		end //end begin
	endtask

	task DUMP_PC_and_IR;
		begin
			$display("PC and IR DUMP");
				@(negedge sys_clk) begin
				//Deassert everything and dump MIPS register
				 {PC_sel,PC_ld,PC_inc,IR_ld} 			= 5'b00_0_0_0;
				 {IM_cs,IM_rd,IM_wr} 					= 3'b0_0_0;
				 {D_En,D_sel,T_sel,HILO_ld,Y_sel} 	= 8'b0_00_0_0_000;
				 FS 											= 5'h0;
				 INT_ACK 									= 1'b0;
				 {DM_cs,DM_rd,DM_wr} 					= 3'b0_0_0;
				 {io_cs,io_rd,io_wr}               	= 3'b0_0_0;
				 #1 $display("t=%t  PC=%h || IR=%h" ,
					 $time, MIPS_TB.CPU.IU.PC.PC_out, MIPS_TB.CPU.IU.IR.IR_out);
				end
		end //end begin
	endtask

	// state assignments
	parameter
		RESET     = 00, FETCH     = 01, DECODE  = 02,
		ADD       = 10, ADDU      = 11, AND     = 12, OR     = 13, NOR      = 14,
		JR	 		 = 15, XOR       = 16, SLTU    = 17, DIV    = 18, SUB      = 19,
		ORI       = 20, LUI    	  = 21, LW      = 22, SW     = 23, ADDI     = 24,
		SRL    	 = 25, SRA       = 26, SLL     = 27, SLT    = 28, XORI     = 29,
		WB_alu  	 = 30, WB_imm 	  = 31, WB_Din  = 32, WB_hi  = 33, WB_lo    = 34,
		WB_mem    = 35, LW_MA     = 36, WB_LW   = 37, JAL    = 38, SLTIU    = 39,
		BEQ       = 40, BEQ2	  	  = 41, BNE   	 = 42, BNE2   = 43, JUMP     = 44,
		SLTI   	 = 45, MFLO      = 46, MFHI    = 47, MULT   = 48, ANDI     = 49,
		BLEZ      = 50, BLEZ2     = 51, BGTZ    = 52, BGTZ2  = 53, SETIE    = 54,
		OUTPUT 	 = 55, OUTPUT_MA = 56, INPUT   = 57,
		INPUT_MA  = 58, WB_INPUT  = 59,
		INTER_1   = 501,INTER_2   = 502,INTER_3 = 503,
		BREAK     = 510,
		ILLEGAL_OP= 511;
	// state register (up to 512 states)
	reg	[8:0] state;

	//FLAG REGISTERS
	always @(posedge sys_clk, posedge reset) begin
		if (reset)
			{psi, psc, psv, psn, psz} = 5'b0;
		else
			{psi, psc, psv, psn, psz} = {nsi,nsc,nsv,nsn,nsz};
	end

	/************************************************
	 *	440 MIPS CONTROL UNIT (Finite State Machine) *
	 ************************************************/
	always @(posedge sys_clk, posedge reset)
		if (reset)
		begin
			//*** control word assignments for the reset condtion ***
			{PC_sel,PC_ld,PC_inc,IR_ld} 							= 5'b00_0_0_0;
			{IM_cs,IM_rd,IM_wr} 										= 3'b0_0_0;
			{D_En,D_sel,T_sel,HILO_ld,Y_sel} 					= 8'b0_00_0_0_000;
			FS 															= 5'h15;
			INT_ACK 														= 1'b0;
			{DM_cs,DM_rd,DM_wr} 										= 3'b0_0_0;
			{io_cs,io_rd,io_wr}               					= 3'b0_0_0;
         #1 {nsi,nsc,nsv,nsn,nsz}								= 5'b0;
			state = RESET;
		end
		else
			case (state)
				FETCH:
				@(negedge sys_clk)
				if (psi == 1'b1 & INT_ACK == 0 & INTR == 1)
				begin	// *** new interrupt pending; prepare for ISR ***
					// control word assignments for "deasserting" everything
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}				   = {psi, psc, psv, psn, psz};
					state = INTER_1;
				end
				else
				begin // *** no new interrupt pending; fetch an instruction
				if (psi == 1'b0 | INTR == 0 | (INT_ACK == 1 & INTR == 0))
					// control word assignments for IR <- iM[PC]; PC <- PC+4
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_1_1;
					{IM_cs,IM_rd,IM_wr} 							= 3'b1_1_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 1'b0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, 4'b0};
					state = DECODE;
				end
         /*
         **********************************************************************
         */
				RESET:
				begin
					@(negedge sys_clk)
						// control word assignments for $sp <- ALU_out(32'h3FC)
						{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
						{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
						{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_11_0_0_010;
						FS 												= 5'h0;
						INT_ACK 											= 1'b0;
						{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
						{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
						#1 {nsi,nsc,nsv,nsn,nsz}					= 5'b0;
						state = FETCH;
				end
        /*
        ************************************************************************
        */
				DECODE:
				begin
				@(negedge sys_clk)
				if(IR[31:26] == 6'h0)
				begin // it is an R_type format
						// control word assignments: RS <- $rs, RT <- $rt (default)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					case(IR[5:0])
						6'h0D  : state = BREAK;
						6'h20  : state = ADD;
						6'h22  : state = SUB;
						6'h08  : state = JR;
						6'h02  : state = SRL;
						6'h03  : state = SRA;
						6'h00  : state = SLL;
						6'h2A  : state = SLT;
						6'h10  : state = MFHI;
						6'h12  : state = MFLO;
						6'h18  : state = MULT;
						6'h1A  : state = DIV;
						6'h24  : state = AND;
						6'h25  : state = OR;
						6'h26  : state = XOR;
						6'h27  : state = NOR;
						6'h2B  : state = SLTU;
						6'h1F  : state = SETIE;
						default: state = ILLEGAL_OP;
					endcase
				end // end of if for R-type format
				else
				begin	// it is an I-type or J-type format
					// control word assignments: RS <- $rs, RT <- DT(se_16)
					//checks if IR is a BEQ or BNE so instead of loading RT with imm16
					if (IR[31:26] == 6'h04 || IR[31:26] == 6'h05 ||
						 IR[31:26] == 6'h06 || IR[31:26] == 6'h07) begin
						{PC_sel,PC_ld,PC_inc,IR_ld} 			= 5'b00_0_0_0;
						{IM_cs,IM_rd,IM_wr} 						= 3'b0_0_0;
						{D_En,D_sel,T_sel,HILO_ld,Y_sel} 	= 8'b0_00_0_0_000;
						FS 											= 5'h0;
						INT_ACK 										= 0;
						{DM_cs,DM_rd,DM_wr} 						= 3'b0_0_0;
						{io_cs,io_rd,io_wr}               	= 3'b0_0_0;
						#1 {nsi,nsc,nsv,nsn,nsz}				= {psi, psc, psv, psn, psz};
					end
					else begin
						{PC_sel,PC_ld,PC_inc,IR_ld} 			= 5'b00_0_0_0;
						{IM_cs,IM_rd,IM_wr} 						= 3'b0_0_0;
						{D_En,D_sel,T_sel,HILO_ld,Y_sel} 	= 8'b0_00_1_0_000;
						FS 											= 5'h0;
						INT_ACK 										= 0;
						{DM_cs,DM_rd,DM_wr} 						= 3'b0_0_0;
						{io_cs,io_rd,io_wr}               	= 3'b0_0_0;
						#1 {nsi,nsc,nsv,nsn,nsz}				= {psi, psc, psv, psn, psz};
					end
					case(IR[31:26])
						6'h0D  : state = ORI;
						6'h08  : state = ADDI;
						6'h0C  : state = ANDI;
						6'h0F  : state = LUI;
						6'h0E  : state = XORI;
						6'h0B  : state = SLTIU;
						6'h2B  : state = SW;
						6'h04  : state = BEQ;
						6'h05  : state = BNE;
						6'h02  : state = JUMP;
						6'h0A  : state = SLTI;
						6'h23  : state = LW;
						6'h03  : state = JAL;
						6'h06  : state = BLEZ;
						6'h07  : state = BGTZ;
						6'h1D  : state = OUTPUT;
						6'h1C  : state = INPUT;
						default: state = ILLEGAL_OP;
					endcase
					end // end of else for I/J -type formats
				end// end of DECODE
        /*
        ************************************************************************
        */
				ADD:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) + RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h2;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, C, V, N, Z};
					state = WB_alu;
				end

				ADDI:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) + RT(se16)
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h2;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi,  C, V, N, Z};
					state = WB_imm;
				end

			   SUB:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) - RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h3;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, C, V, N, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */
				MFHI:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- HI
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				MFLO:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- LO
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_00_0_0_001;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
			   MULT:
				begin
					@(negedge sys_clk)
					// control word assignments: {HI,LO} <- RS($rs) * RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_1_000;
					FS 												= 5'h1E;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
			   DIV:
				begin
					@(negedge sys_clk)
					// control word assignments: {HI,LO} <- {RS($rs) % RT($rt), 
					//													  RS($rs) / RT($rt)}
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_1_000;
					FS 												= 5'h1F;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = FETCH;
				end
        /*
        ************************************************************************
        */

				ORI:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) | {RT[15:0]}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h17;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = WB_imm;
				end
        /*
        ************************************************************************
        */

				XOR:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) ^ RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0A;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */
				XORI:
				begin
					@(negedge sys_clk)
          //control word assignment: ALU_out <- RS($rs) ^ S.E(imm16)
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h19;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = WB_imm;
				end
        /*
        ************************************************************************
        */
				AND:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) & RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h08;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */
				ANDI:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) & S.E.(imm16)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h16;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = WB_imm;
				end

        /*
        ************************************************************************
        */

				OR:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) | RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h09;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */

				NOR:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- ~(RS($rs) | RT($rt))
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0B;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */
				BEQ:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) - RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h3; //SUB
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, Z};
					state = BEQ2;
				end

				BEQ2:
				begin
					@(negedge sys_clk)
					if(psz == 1'b1) begin
					// control word assignments: PC <- PC + {se_16[29:0], 2'b0}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_1_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h3;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					end
					else begin // PC <- PC
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 													= 5'h0;
					INT_ACK 												= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					end
				state = FETCH;
				end
		  /*
        ************************************************************************
        */
				BNE:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) - RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h3; //SUB
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, Z};
					state = BNE2;
				end

				BNE2:
				begin
					@(negedge sys_clk)
					if(psz == 1'b0) begin
					// control word assignments: PC <- PC + {se_16[29:0], 2'b0}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_1_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h3;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					end
					else begin // PC <- PC
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					end
				state = FETCH;
				end
			 /*
          ************************************************************************
          */
  				BLEZ:
  				begin
  					@(negedge sys_clk)
  					// control word assignments: ALU_out <- RS($rs) - RT($rt)
  					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
  					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
  					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
  					FS 												= 5'h3; //SUB
  					INT_ACK 											= 0;
  					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
  					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
  					state = BLEZ2;
  				end

  				BLEZ2:
  				begin
  					@(negedge sys_clk)
            // if s <= 0, branch
  					if(psz == 1'b1 || psn == 1'b1) begin
					// control word assignments: PC <- PC + {se_16[29:0], 2'b0}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_1_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
  					end
  					else begin // PC <- PC
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
  					end
  				state = FETCH;
  				end
        /*
        ************************************************************************
        */
			   BGTZ:
			   begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) - RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h3; //SUB
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, N, Z};
					state = BGTZ2;
				end

			   BGTZ2:
			   begin
					@(negedge sys_clk)
				   // if s >= 0, branch
					if(psz == 1'b1 || psn == 1'b0) begin
					// control word assignments: PC <- PC + {se_16[29:0], 2'b0}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_1_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					 end
					 else begin // PC <- PC
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					 end
				  state = FETCH;
			  end
      /*
      ************************************************************************
      */
				JR:
				begin
					@(negedge sys_clk)
					// control word assignments: PC <- RS($rs)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b11_1_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				LUI:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- {RT[15:0], 16'h0}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h18;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = WB_imm;
				end
        /*
        ************************************************************************
        */
				SW:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) + RT(SE_16), RT <- $rt
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h02;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = WB_mem;
				end
        /*
        ************************************************************************
        */
				OUTPUT:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) + RT(SE_16), RT <- $rt
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h02;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = OUTPUT_MA;
				end
        /*
        ************************************************************************
        */
				OUTPUT_MA:
				begin
					@(negedge sys_clk)
					// control word assignments: IOM <- ALU_out,IOM <- RT
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_010;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b1_0_1;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
		  /*
        ************************************************************************
        */
				INPUT:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) + RT(SE_16), RT <- $rt
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h02;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr} 							= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}				   = {psi, psc, psv, psn, psz};
					state = INPUT_MA;
				end
		  /*
        ************************************************************************
        */
				INPUT_MA:
				begin
					@(negedge sys_clk)
					// control word assignments: Din <- IOM[ALU_out]
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_010;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr} 							= 3'b1_1_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = WB_INPUT;
				end

		  /*
        ************************************************************************
        */
				WB_INPUT:
				begin
					@(negedge sys_clk)
					// control word assignments: RT($rt) <- Din
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_01_0_0_011;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				LW:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs)+RT(SE_16),RT <- $rt
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h02;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = LW_MA;
				end
        /*
        ************************************************************************
        */
				LW_MA:
				begin
					@(negedge sys_clk)
					// control word assignments: Din <- DM[ALU_out]
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_010;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b1_1_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = WB_LW;
				end

        /*
        ************************************************************************
        */
				SLL:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) << 1					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0C;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, C, psv, N, Z};
					state = WB_alu;
				end
		    /*
        ************************************************************************
        */
				SRL:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) >> 1
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0D;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, C, psv, N, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */
				SRA:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- RS($rs) >>> 1
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0E;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, C, psv, N, Z};
					state = WB_alu;
				end

        /*
        ************************************************************************
        */
				SLT:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- if (RS < RT) 1 else 0
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h06;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, Z};
					state = WB_alu;
				end

        /*
        ************************************************************************
        */
				SLTI:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- if (RS < RT(se16))) 1 else 0
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h06;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, Z};
					state = WB_imm;
				end

        /*
        ************************************************************************
        */
				SLTU:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- if (RS < RT)) 1 else 0
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h07;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, Z};
					state = WB_alu;
				end
        /*
        ************************************************************************
        */
				SLTIU:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- if (RS < RT(se16))) 1 else 0
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h07;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, Z};
					state = WB_imm;
				end
        /*
        ************************************************************************
        */
				SETIE:
				begin
					@(negedge sys_clk)
					//main job is to set interrupt bit
					{PC_sel,PC_ld,PC_inc,IR_ld}			 	= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {1'b1, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				JUMP:
				begin
					@(negedge sys_clk)
					// control word assignments: PC <- {PC[31:28], IR[25:0], 2'b0}
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b01_1_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end

        /*
        ************************************************************************
        */
				JAL:
				begin
					@(negedge sys_clk)
					// control word assignments: PC <- {PC[31:28], IR[25:0], 2'b0}
					//                           R31<- PC
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b01_1_0_0;
					{IM_cs,IM_rd,IM_wr}						 	= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_10_0_0_100;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end

				WB_alu:
				begin
					@(negedge sys_clk)
					// control word assignments: R[rd] <- ALU_out
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_00_0_0_010;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				WB_imm:
				begin
					@(negedge sys_clk)
					// control word assignments: R[rt] <- ALU_out
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_01_0_0_010;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				WB_mem:
				begin
					@(negedge sys_clk)
					// control word assignments: M[ ALU_out($rs + SE_16)] <- RT($rt)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_010;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b1_0_1;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				WB_LW:
				begin
					@(negedge sys_clk)
					// control word assignments: RT <- Din
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_01_0_0_011;
					FS 												= 5'h00;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
        /*
        ************************************************************************
        */
				BREAK:
				begin
				@(negedge sys_clk)
				$display("BREAK INSTRUCTION FETCHED %t", $time);
				// control word assignments for "deasserting" everything
				{PC_sel,PC_ld,PC_inc,IR_ld} 					= 5'b00_0_0_0;
				{IM_cs,IM_rd,IM_wr} 								= 3'b0_0_0;
				{D_En,D_sel,T_sel,HILO_ld,Y_sel} 			= 8'b0_00_0_0_000;
				FS 													= 5'h0;
				INT_ACK 												= 0;
				{DM_cs,DM_rd,DM_wr} 								= 3'b0_0_0;
				{io_cs,io_rd,io_wr}               			= 3'b0_0_0;
				#1 {nsi,nsc,nsv,nsn,nsz}						= {psi, psc, psv, psn, psz};
				$display(" R E G I S T E R ' S  A F T E R  B R E A K ");
				$display(" ");
				Reg_Dump; // task to output MIPS Register file
				$display(" ");

				$display (" M E M O R Y  D U M P ");
				for (i=12'h0C0; i<12'h100; i=i+4) begin
				@(negedge sys_clk)
				#1 $display("time=%t M[%h] = %h %h %h %h",
					$time, i, MIPS_TB.DM.data_mem[i],  MIPS_TB.DM.data_mem[i+1],
								 MIPS_TB.DM.data_mem[i+2],MIPS_TB.DM.data_mem[i+3]);
				end
				$display ("time=%t M[3f0] = %h %h %h %h",$time,
							 MIPS_TB.DM.data_mem[12'h3F0],
							 MIPS_TB.DM.data_mem[12'h3F1],
							 MIPS_TB.DM.data_mem[12'h3F2],
							 MIPS_TB.DM.data_mem[12'h3F3]);
							 
				$display (" ");
				$display (" O U T P U T  O F  I/O  M E M O R Y");
				for (i=12'h0C0; i<12'h100; i=i+4) begin
				@(negedge sys_clk)
				#1 $display("time=%t M[%h] = %h %h %h %h",
					$time, i, MIPS_TB.IOM.io_mem[i],	 MIPS_TB.IOM.io_mem[i+1],
								 MIPS_TB.IOM.io_mem[i+2],MIPS_TB.IOM.io_mem[i+3]);
				end
				$finish;
				end
        /*
        ************************************************************************
        */
				ILLEGAL_OP:
				begin
					$display("ILLEGAL OPCODE FETCHED %t", $time);
					@(negedge sys_clk)
					// control word assignments for "deasserting" everything
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_000;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					DUMP_PC_and_IR;
					Reg_Dump;
					$finish;
				end
        /*
        ************************************************************************
        */
				INTER_1:
				begin
					@(negedge sys_clk)
					// control word assignments: ALU_out <- 0x3FC, R[$ra] <- PC
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b1_10_0_0_100;
					FS 												= 5'h15;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = INTER_2;
				end
        /*
        ************************************************************************
        */
				INTER_2:
				begin
					// Read address of ISR into D_in;
					// control word assignments: D_in <- dM[ALU_out(0x3FC)]
					@(negedge sys_clk)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b00_0_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_010;
					FS 												= 5'h0;
					INT_ACK 											= 0;
					{DM_cs,DM_rd,DM_wr} 							= 3'b1_1_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = INTER_3;
				end
        /*
        ************************************************************************
        */
				INTER_3:
				begin
					// Reload PC with addres of ISR; ask the INTR; goto FETCH
					// control word assignments: PC <- D_in(dM[0x3FC]), INT_ACK <- 1
					@(negedge sys_clk)
					{PC_sel,PC_ld,PC_inc,IR_ld} 				= 5'b10_1_0_0;
					{IM_cs,IM_rd,IM_wr} 							= 3'b0_0_0;
					{D_En,D_sel,T_sel,HILO_ld,Y_sel} 		= 8'b0_00_0_0_011;
					FS 												= 5'h00;
					INT_ACK 											= 1;
					{DM_cs,DM_rd,DM_wr} 							= 3'b0_0_0;
					{io_cs,io_rd,io_wr}               		= 3'b0_0_0;
					#1 {nsi,nsc,nsv,nsn,nsz}					= {psi, psc, psv, psn, psz};
					state = FETCH;
				end
		endcase // end of FSM logic
endmodule
