`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  ALU_32.v
 * Project:    CECS 440 Lab 3
 * Designer:   Peter Huynh
 * Email:      peterhuynh75@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  September 6th, 2018
 *
 * Purpose:
 *
 * Notes:
 *
****************************************************************************/
module MIPS_8(
  input [7:0] S, T,
  input [4:0] FS,
  output reg [7:0] VY_hi, VY_lo
  );

  parameter ADD     = 5'h0,
				    SUB     = 5'h1,
            AND     = 5'h8,
            OR      = 5'h9,
            XOR     = 5'hA,
            CMPEQ   = 5'hB,
            PASS_S  = 5'h10;

  always @ (*) begin
      VY_hi = 8'h0;
      case(FS)
        PASS_S : VY_lo = S;
        ADD    : VY_lo = S + T;
		    SUB    : VY_lo = S - T;
        AND    : VY_lo = S & T;
        OR     : VY_lo = S | T;
        XOR    : VY_lo = S ^ T;
        CMPEQ  : VY_lo = (S == T) ? 8'hFF : 8'h0;
        default : VY_lo = 8'hF0;
      endcase
  end
endmodule
