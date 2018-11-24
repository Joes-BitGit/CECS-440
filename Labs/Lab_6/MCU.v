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
    output reg [2:0] Y_sel
    );

	 integer i;

	//**************************
	// internal data structures
	//**************************

	task Reg_Dump;
		begin
			$display("REG DUMP");
			for (i=0; i<16; i=i+1) begin
				@(negedge sys_clk) begin
				//Deassert everything and dump MIPS register
				 {PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
				 {IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
				 {D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
				 FS = 5'h0; INT_ACK = 1'b0;
				 {DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
				 #1 $display("t=%t  Contents=%h $r=%h" ,
					 $time, MIPS_TB.IDP.RF_32.data[i], i[4:0]);
				end
			end //end for loop
		end //end begin
	endtask

	task DUMP_PC_and_IR;
		begin
			$display("PC and IR DUMP");
				@(negedge sys_clk) begin
				//Deassert everything and dump MIPS register
				 {PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
				 {IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
				 {D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
				 FS = 5'h0; INT_ACK = 1'b0;
				 {DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
				 #1 $display("t=%t  PC=%h || IR=%h" ,
					 $time, MIPS_TB.IU.PC.PC_out, MIPS_TB.IU.IR.IR_out);
				end
		end //end begin
	endtask

	// state assignments
	parameter
		RESET     = 00,  FETCH   = 01,  DECODE  = 02,
		ADD       = 10,  ADDU    = 11,  AND     = 12,  OR    = 13, NOR   = 14, JR	   = 15,
		ORI       = 20,  LUI     = 21,  LW      = 22,  SW    = 23,
		WB_alu    = 30,  WB_imm  = 31,  WB_Din  = 32,  WB_hi = 33, WB_lo = 34, WB_mem = 35,
		INTER_1   = 501, INTER_2 = 502, INTER_3 = 503,
		BREAK     = 510,
		ILLEGAL_OP= 511;
	// state register (up to 512 states)
	reg	[8:0] state;

	/************************************************
	 *	440 MIPS CONTROL UNIT (Finite State Machine) *
	 ************************************************/
	always @(posedge sys_clk, posedge reset)
		if (reset)
		begin
			//*** control word assignments for the reset condtion ***
			{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
			{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
			{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
			FS = 5'h15; INT_ACK = 1'b0; //set up ALU_out(0x3FC)
			{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
			state = RESET;
		end
		else
			case (state)
				FETCH:
					@(negedge sys_clk)
					if (INT_ACK == 0 & INTR == 1)
					begin	// *** new interrupt pending; prepare for ISR ***
						// control word assignments for "deasserting" everything
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = INTER_1;
					end
					else
					begin // *** no new interrupt pending; fetch an instruction
						if (INTR == 0 | (INT_ACK == 1 & INTR == 0))
							// control word assignments for IR <- iM[PC]; PC <- PC+4
							{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_1_1;
							{IM_cs, IM_rd, IM_wr} = 3'b1_1_0;
							{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
							FS = 5'h0; INT_ACK = 1'b0;
							{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
							state = DECODE;
					end
         /*
         **********************************************************************
         */
				RESET:
				begin
					@(negedge sys_clk)
						// control word assignments for $sp <- ALU_out(32'h3FC)
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_11_0_0_010;
						FS = 5'h0; INT_ACK = 1'b0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h0; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						case(IR[5:0])
							6'h0D  : state = BREAK;
							6'h20  : state = ADD;
							6'h08  : state = JR;
							default: state = ILLEGAL_OP;
						endcase
					end // end of if for R-type format
					else
					begin // it is an I-type or J-type format
							// control word assignments: RS <- $rs, RT <- DT(se_16)
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_000;
						FS = 5'h0; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						case(IR[31:26])
							6'h0D  : state = ORI;
							6'h0F  : state = LUI;
							6'h2B  : state = SW;
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h2; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = WB_alu;
				end
        /*
        ************************************************************************
        */
				ORI:
				begin
					@(negedge sys_clk)
						// control word assignments: ALU_out <- RS($rs) | {16'h0, RT[15:0]}
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h17; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = WB_imm;
				end
        /*
        ************************************************************************
        */
				JR:
				begin
					@(negedge sys_clk)
						// control word assignments: PC <- RS($rs)
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b11_1_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h00; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = FETCH;
				end
        /*
        ************************************************************************
        */
				LUI:
				begin
					@(negedge sys_clk)
						// control word assignments: ALU_out <- {RT[15:0], 16'h0}
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h18; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = WB_imm;
				end
        /*
        ************************************************************************
        */
				SW:
				begin
					@(negedge sys_clk)
						// control word assignments: ALU_out <- RS($rs) + RT(SE_16), RT <- $rt
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h02; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = WB_mem;
				end
        /*
        ************************************************************************
        */
				WB_alu:
				begin
					@(negedge sys_clk)
						// control word assignments: R[rd] <- ALU_out
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_010;
						FS = 5'h0; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = FETCH;
				end
        /*
        ************************************************************************
        */
				WB_imm:
				begin
					@(negedge sys_clk)
						// control word assignments: R[rt] <- ALU_out
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_0_0_010;
						FS = 5'h0; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = FETCH;
				end
        /*
        ************************************************************************
        */
				WB_mem:
				begin
					@(negedge sys_clk)
						// control word assignments: M[ ALU_out($rs + SE_16)] <- RT($rt)
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010;
						FS = 5'h00; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b1_0_1;
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h0; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						$display(" R E G I S T E R ' S  A F T E R  B R E A K ");
						$display(" ");
						Reg_Dump; // task to output MIPS Register file
						$display(" ");
						$display("time=%t M[3F0]=%h", $time, {MIPS_TB.DM.data_mem[12'h3F0],
																		  MIPS_TB.DM.data_mem[12'h3F1],
																		  MIPS_TB.DM.data_mem[12'h3F2],
																		  MIPS_TB.DM.data_mem[12'h3F3]});
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000;
						FS = 5'h0; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b1_10_0_0_100;
						FS = 5'h15; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b00_0_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010;
						FS = 5'h00; INT_ACK = 0;
						{DM_cs, DM_rd, DM_wr} = 3'b1_1_0;
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
						{PC_sel, PC_ld, PC_inc, IR_ld} = 5'b10_1_0_0;
						{IM_cs, IM_rd, IM_wr} = 3'b0_0_0;
						{D_En, D_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_011;
						FS = 5'h00; INT_ACK = 1;
						{DM_cs, DM_rd, DM_wr} = 3'b0_0_0;
						state = FETCH;
				end
		endcase // end of FSM logic
endmodule
