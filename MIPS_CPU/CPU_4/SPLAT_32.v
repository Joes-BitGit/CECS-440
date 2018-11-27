`timescale 1ns / 1ps
/****************************** C E C S  4 4 0 ******************************
 *
 * File Name:  SPLAT_32.v
 * Project:    CECS 440 Senior Project Design
 * Designer:   Peter Huynh, Joseph Almeida
 * Email:      peterhuynh75@gmail.com, josephnalmeida@gmail.com
 * Rev. No.:   Version 1.0
 * Rev. Date:  November 24th, 2018
 *
 * Purpose:    The SPLAT module purpose is to replicate the elements of a
 *             register and output it evenly.
 *
 * Notes:      Utilizes the replication operator to copy the elements.
 *
****************************************************************************/
module SPLAT_32(
  input [31:0] S,
  input [1:0] SPLAT,
  output reg [31:0] VY_hi, VY_lo
  );

  always @ (*) begin
      case(SPLAT)
        2'h3 : {VY_hi, VY_lo} = {32'b0, {4{S[7:0]}}};
        2'h2 : {VY_hi, VY_lo} = {32'b0, {4{S[15:8]}}};
        2'h1 : {VY_hi, VY_lo} = {32'b0, {4{S[23:16]}}};
        2'h0 : {VY_hi, VY_lo} = {32'b0, {4{S[31:24]}}};
        default : {VY_hi, VY_lo} = 64'h0;
      endcase
  end
endmodule
