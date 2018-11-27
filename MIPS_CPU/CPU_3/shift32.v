`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  shift32.v
 * Project:    Senior Project Design
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  November 24, 2018
 *
 * Purpose:	The barrel shifter module allows for an input that will shift
 * 			a 32-bit value of either SLL, SRL or SRA as well as the shift
 * 			amount. The output is the flags that get set depending on the
 *				output of the shifted value as well as the result.
 *
 * Notes: 
 *
****************************************************************************/

module shift32(
  input [31:0] T,
  input [4:0] shamt,
  input [4:0] stype,
  output reg C, V, N, Z,
  output reg [31:0] Y_lo
  );
  
  parameter SLL = 5'h0C, 
			   SRL = 5'h0D, 
			   SRA = 5'h0E;

  always @ (*) begin
    case (stype)
      SRL:
            case (shamt)
              5'd1  : {V,C,Y_lo} = {1'bx,T[0], 1'b0,T[31:1]};
              5'd2  : {V,C,Y_lo} = {1'bx,T[1], 2'b0,T[31:2]};
              5'd3  : {V,C,Y_lo} = {1'bx,T[2], 3'b0,T[31:3]};
              5'd4  : {V,C,Y_lo} = {1'bx,T[3], 4'b0,T[31:4]};
              5'd5  : {V,C,Y_lo} = {1'bx,T[4], 5'b0,T[31:5]};
              5'd6  : {V,C,Y_lo} = {1'bx,T[5], 6'b0,T[31:6]};
              5'd7  : {V,C,Y_lo} = {1'bx,T[6], 7'b0,T[31:7]};
              5'd8  : {V,C,Y_lo} = {1'bx,T[7], 8'b0,T[31:8]};
              5'd9  : {V,C,Y_lo} = {1'bx,T[8], 9'b0,T[31:9]};
              5'd10 : {V,C,Y_lo} = {1'bx,T[9], 10'b0,T[31:10]};
              5'd11 : {V,C,Y_lo} = {1'bx,T[10],11'b0,T[31:11]};
              5'd12 : {V,C,Y_lo} = {1'bx,T[11],12'b0,T[31:12]};
              5'd13 : {V,C,Y_lo} = {1'bx,T[12],13'b0,T[31:13]};
              5'd14 : {V,C,Y_lo} = {1'bx,T[13],14'b0,T[31:14]};
              5'd15 : {V,C,Y_lo} = {1'bx,T[14],15'b0,T[31:15]};
              5'd16 : {V,C,Y_lo} = {1'bx,T[15],16'b0,T[31:16]};
              5'd17 : {V,C,Y_lo} = {1'bx,T[16],17'b0,T[31:17]};
              5'd18 : {V,C,Y_lo} = {1'bx,T[17],18'b0,T[31:18]};
              5'd19 : {V,C,Y_lo} = {1'bx,T[18],19'b0,T[31:19]};
              5'd20 : {V,C,Y_lo} = {1'bx,T[19],20'b0,T[31:20]};
              5'd21 : {V,C,Y_lo} = {1'bx,T[20],21'b0,T[31:21]};
              5'd22 : {V,C,Y_lo} = {1'bx,T[21],22'b0,T[31:22]};
              5'd23 : {V,C,Y_lo} = {1'bx,T[22],23'b0,T[31:23]};
              5'd24 : {V,C,Y_lo} = {1'bx,T[23],24'b0,T[31:24]};
              5'd25 : {V,C,Y_lo} = {1'bx,T[24],25'b0,T[31:25]};
              5'd26 : {V,C,Y_lo} = {1'bx,T[25],26'b0,T[31:26]};
              5'd27 : {V,C,Y_lo} = {1'bx,T[26],27'b0,T[31:27]};
              5'd28 : {V,C,Y_lo} = {1'bx,T[27],28'b0,T[31:28]};
              5'd29 : {V,C,Y_lo} = {1'bx,T[28],29'b0,T[31:29]};
              5'd30 : {V,C,Y_lo} = {1'bx,T[29],30'b0,T[31:30]};
              5'd31 : {V,C,Y_lo} = {1'bx,T[30],31'b0,T[31:31]};
              default : {V,C,Y_lo} = {1'bx,1'bx,T[31:0]};
            endcase

      SRA:
            case (shamt)
              5'd1  : {V,C,Y_lo} = {1'bx,T[0],{1{T[31]}},T[31:1]};
              5'd2  : {V,C,Y_lo} = {1'bx,T[1],{2{T[31]}},T[31:2]};
              5'd3  : {V,C,Y_lo} = {1'bx,T[2],{3{T[31]}},T[31:3]};
              5'd4  : {V,C,Y_lo} = {1'bx,T[3],{4{T[31]}},T[31:4]};
              5'd5  : {V,C,Y_lo} = {1'bx,T[4],{5{T[31]}},T[31:5]};
              5'd6  : {V,C,Y_lo} = {1'bx,T[5],{6{T[31]}},T[31:6]};
              5'd7  : {V,C,Y_lo} = {1'bx,T[6],{7{T[31]}},T[31:7]};
              5'd8  : {V,C,Y_lo} = {1'bx,T[7],{8{T[31]}},T[31:8]};
              5'd9  : {V,C,Y_lo} = {1'bx,T[8],{9{T[31]}},T[31:9]};
              5'd10 : {V,C,Y_lo} = {1'bx,T[9],{10{T[31]}},T[31:10]};
              5'd11 : {V,C,Y_lo} = {1'bx,T[10],{11{T[31]}},T[31:11]};
              5'd12 : {V,C,Y_lo} = {1'bx,T[11],{12{T[31]}},T[31:12]};
              5'd13 : {V,C,Y_lo} = {1'bx,T[12],{13{T[31]}},T[31:13]};
              5'd14 : {V,C,Y_lo} = {1'bx,T[13],{14{T[31]}},T[31:14]};
              5'd15 : {V,C,Y_lo} = {1'bx,T[14],{15{T[31]}},T[31:15]};
              5'd16 : {V,C,Y_lo} = {1'bx,T[15],{16{T[31]}},T[31:16]};
              5'd17 : {V,C,Y_lo} = {1'bx,T[16],{17{T[31]}},T[31:17]};
              5'd18 : {V,C,Y_lo} = {1'bx,T[17],{18{T[31]}},T[31:18]};
              5'd19 : {V,C,Y_lo} = {1'bx,T[18],{19{T[31]}},T[31:19]};
              5'd20 : {V,C,Y_lo} = {1'bx,T[19],{20{T[31]}},T[31:20]};
              5'd21 : {V,C,Y_lo} = {1'bx,T[20],{21{T[31]}},T[31:21]};
              5'd22 : {V,C,Y_lo} = {1'bx,T[21],{22{T[31]}},T[31:22]};
              5'd23 : {V,C,Y_lo} = {1'bx,T[22],{23{T[31]}},T[31:23]};
              5'd24 : {V,C,Y_lo} = {1'bx,T[23],{24{T[31]}},T[31:24]};
              5'd25 : {V,C,Y_lo} = {1'bx,T[24],{25{T[31]}},T[31:25]};
              5'd26 : {V,C,Y_lo} = {1'bx,T[25],{26{T[31]}},T[31:26]};
              5'd27 : {V,C,Y_lo} = {1'bx,T[26],{27{T[31]}},T[31:27]};
              5'd28 : {V,C,Y_lo} = {1'bx,T[27],{28{T[31]}},T[31:28]};
              5'd29 : {V,C,Y_lo} = {1'bx,T[28],{29{T[31]}},T[31:29]};
              5'd30 : {V,C,Y_lo} = {1'bx,T[29],{30{T[31]}},T[31:30]};
              5'd31 : {V,C,Y_lo} = {1'bx,T[30],{31{T[31]}},T[31:31]};
              default : {V,C,Y_lo} = {1'bx,1'bx,T[31:0]};
            endcase

      SLL:
           case(shamt)
            5'd1  : {V,C,Y_lo} = {1'bx,T[31],T[30:0],1'b0};
            5'd2  : {V,C,Y_lo} = {1'bx,T[30],T[29:0],2'b0};
            5'd3  : {V,C,Y_lo} = {1'bx,T[29],T[28:0],3'b0};
            5'd4  : {V,C,Y_lo} = {1'bx,T[28],T[27:0],4'b0};
            5'd5  : {V,C,Y_lo} = {1'bx,T[27],T[26:0],5'b0};
            5'd6  : {V,C,Y_lo} = {1'bx,T[26],T[25:0],6'b0};
            5'd7  : {V,C,Y_lo} = {1'bx,T[25],T[24:0],7'b0};
            5'd8  : {V,C,Y_lo} = {1'bx,T[24],T[23:0],8'b0};
            5'd9  : {V,C,Y_lo} = {1'bx,T[23],T[22:0],9'b0};
            5'd10 : {V,C,Y_lo} = {1'bx,T[22],T[21:0],10'b0};
            5'd11 : {V,C,Y_lo} = {1'bx,T[21],T[20:0],11'b0};
            5'd12 : {V,C,Y_lo} = {1'bx,T[20],T[19:0],12'b0};
            5'd13 : {V,C,Y_lo} = {1'bx,T[19],T[18:0],13'b0};
            5'd14 : {V,C,Y_lo} = {1'bx,T[18],T[17:0],14'b0};
            5'd15 : {V,C,Y_lo} = {1'bx,T[17],T[16:0],15'b0};
            5'd16 : {V,C,Y_lo} = {1'bx,T[16],T[15:0],16'b0};
            5'd17 : {V,C,Y_lo} = {1'bx,T[15],T[14:0],17'b0};
            5'd18 : {V,C,Y_lo} = {1'bx,T[14],T[13:0],18'b0};
            5'd19 : {V,C,Y_lo} = {1'bx,T[13],T[12:0],19'b0};
            5'd20 : {V,C,Y_lo} = {1'bx,T[12],T[11:0],20'b0};
            5'd21 : {V,C,Y_lo} = {1'bx,T[11],T[10:0],21'b0};
            5'd22 : {V,C,Y_lo} = {1'bx,T[10],T[9:0], 22'b0};
            5'd23 : {V,C,Y_lo} = {1'bx,T[9], T[8:0], 23'b0};
            5'd24 : {V,C,Y_lo} = {1'bx,T[8], T[7:0], 24'b0};
            5'd25 : {V,C,Y_lo} = {1'bx,T[7], T[6:0], 25'b0};
            5'd26 : {V,C,Y_lo} = {1'bx,T[6], T[5:0], 26'b0};
            5'd27 : {V,C,Y_lo} = {1'bx,T[5], T[4:0], 27'b0};
            5'd28 : {V,C,Y_lo} = {1'bx,T[4], T[3:0], 28'b0};
            5'd29 : {V,C,Y_lo} = {1'bx,T[3], T[2:0], 29'b0};
            5'd30 : {V,C,Y_lo} = {1'bx,T[2], T[1:0], 30'b0};
            5'd31 : {V,C,Y_lo} = {1'bx,T[1], T[0:0], 31'b0};
            default : {V,C,Y_lo} = {1'bx,1'bx,T};
          endcase // end SLL
        endcase// end shift type

      //negative flag
  		N = Y_lo[31];

      //Z flag
  		if (Y_lo == 32'b0) Z = 1'b1;
  		else Z = 1'b0;

    end // end Combo
endmodule

