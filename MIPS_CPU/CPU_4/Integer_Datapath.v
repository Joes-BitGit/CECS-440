`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  Integer_Datapath.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Joseph Almeida
 * Email:      Josephnalmeida@gmail.com
 * Rev. No.:   Version 1.1
 * Rev. Date:  October 16, 2018
 *
 * Purpose: Datapath that stitches the register file and ALU together
 *				to allow data to come in from sources such as memory, I/O,
 *				or applicable IR fields
 *
 * Notes:
 *
 ****************************************************************************/
module Integer_Datapath(
    input clk, reset, D_En, HILO_ld, FLAG_ld, S_Sel, VHILO_ld,
	 input [1:0] D_sel, T_Sel, SPLAT,
	 input [2:0] Y_Sel,
    input [4:0] D_Addr, S_Addr, T_Addr, FS, shamt,
    input [31:0] DY, DT, PC_In,
    input psc, psv, psn, psz,
    output wire N, Z, C, V,
    output [31:0] D_OUT, ALU_OUT,
	 output wire [31:0] RS
    );

	wire  Creg, Vreg, Nreg, Zreg;
	reg  [31:0] HI, LO;
	reg  [31:0] VHI, VLO;
	wire [31:0] T;
	wire [31:0] S;
	wire [31:0] Y_HI, Y_LO;
	wire [31:0] VY_HI, VY_LO, VALU_Out_WIRE;
	wire [31:0] T_OUT, S_OUT;
	wire [31:0] ALU_Out_WIRE, D_in;
	wire [4:0] D_mux;

	assign D_mux = (D_sel == 2'b00) ? (D_Addr) :
						(D_sel == 2'b01) ? (T_Addr) :
						(D_sel == 2'b10) ? (5'd31)  :
												 (5'd29)  ;

	regfile32 RF_32 		(.clk(clk),
								 .reset(reset),
								 .D_En(D_En),
								 .D(ALU_OUT),
								 .D_Addr(D_mux),
								 .S_Addr(S_Addr),
								 .T_Addr(T_Addr),
								 .S(S),
								 .T(T));

	// T-MUX
	assign T_OUT = (T_Sel == 2'b01) ? DT: 
						(T_Sel == 2'b10) ? {28'b0, psc, psv, psn, psz}: 
						(T_Sel == 2'b11) ? PC_In: 
												 T;
   // S-MUX
   assign S_OUT = (S_Sel == 1'b1) ? ALU_Out_WIRE : 
												S;
	// RS Register
	reg32     RS32       (.clk(clk),
								 .reset(reset),
								 .D(S_OUT), 
								 .Q(RS)); 

	// RT Register
	reg32     RT32       (.clk(clk),
								 .reset(reset),
								 .D(T_OUT),
								 .Q(D_OUT));
	// ALU
	ALU_32 	 ALU32 		(.S(RS), 
								 .T(D_OUT),
								 .FS(FS),
								 .Y_hi(Y_HI),
								 .Y_lo(Y_LO),
								 .N(Nreg),
								 .Z(Zreg),
								 .C(Creg),
								 .V(Vreg),
								 .shamt(shamt));

	//8-Bit Vector ALU
   VALU_32 VALU_32 		(.S(RS),
								 .T(D_OUT),
								 .FS(FS),
								 .SPLAT(SPLAT),
								 .VY_hi(VY_HI),
								 .VY_lo(VY_LO));

  assign {C, V, N, Z} = (FLAG_ld) ? DY[3:0] : {Creg, Vreg, Nreg, Zreg};

	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			{HI,LO} <= 64'b0;
      {VHI,VLO} <= 64'b0;
		end
    //regular HILO ld
		else if (HILO_ld == 1'b1)
			{HI,LO} <= {Y_HI, Y_LO};
    //vector HILO ld
    else if (VHILO_ld == 1'b1)
      {VHI,VLO} <= {VY_HI, VY_LO};
	end

	// ALU_OUT Register
	reg32     ALU_OUTREG (.clk(clk), .reset(reset), .D(Y_LO), .Q(ALU_Out_WIRE));
	
	// D_in Register
	reg32     D_in_REG   (.clk(clk), .reset(reset), .D(DY),   .Q(D_in));

   // Vector ALU_OUT Register
	reg32     VALU_OUT   (.clk(clk), .reset(reset), .D(VY_LO),.Q(VALU_Out_WIRE));


	// Y-MUX
	assign ALU_OUT = (Y_Sel == 3'h0)  ? HI   			 :
						  (Y_Sel == 3'h1)  ? LO   			 :
						  (Y_Sel == 3'h2)  ? ALU_Out_WIRE :
						  (Y_Sel == 3'h3)  ? D_in   		 :
						  (Y_Sel == 3'h4)  ? PC_In     	 :
						  (Y_Sel == 3'h5)  ? VHI          :
						  (Y_Sel == 3'h6)  ? VLO          :
												   VALU_Out_WIRE;


endmodule
