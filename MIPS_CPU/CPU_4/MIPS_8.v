`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  MIPS_8.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Peter Huynh, Joseph Almeida
 * Email:      peterhuynh75@gmail.com
 *					josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  November 24th, 2018
 *
 * Purpose:    This module contains the majority of the VALU operations
 *             excluding multiply and divide, as well as some of the data
 *             manipulation operations such as VSPLAT.
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
