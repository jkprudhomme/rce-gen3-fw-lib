//*****************************************************************************
// DISCLAIMER OF LIABILITY
// 
// This text/file contains proprietary, confidential
// information of Xilinx, Inc., is distributed under license
// from Xilinx, Inc., and may be used, copied and/or
// disclosed only pursuant to the terms of a valid license
// agreement with Xilinx, Inc. Xilinx hereby grants you a 
// license to use this text/file solely for design, simulation, 
// implementation and creation of design files limited 
// to Xilinx devices or technologies. Use with non-Xilinx 
// devices or technologies is expressly prohibited and 
// immediately terminates your license unless covered by
// a separate agreement.
//
// Xilinx is providing this design, code, or information 
// "as-is" solely for use in developing programs and 
// solutions for Xilinx devices, with no obligation on the 
// part of Xilinx to provide support. By providing this design, 
// code, or information as one possible implementation of 
// this feature, application or standard, Xilinx is making no 
// representation that this implementation is free from any 
// claims of infringement. You are responsible for 
// obtaining any rights you may require for your implementation. 
// Xilinx expressly disclaims any warranty whatsoever with 
// respect to the adequacy of the implementation, including 
// but not limited to any warranties or representations that this
// implementation is free from claims of infringement, implied 
// warranties of merchantability or fitness for a particular 
// purpose.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications is
// expressly prohibited.
//
// Any modifications that are made to the Source Code are 
// done at the user’s sole risk and will be unsupported.
//
// Copyright (c) 2006-2007 Xilinx, Inc. All rights reserved.
//
// This copyright and support notice must be retained as part 
// of this text at all times. 
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 1.0
//  \   \         Filename: usr_ip_wr_fifo.v
//  /   /         Date Last Modified:
// /___/   /\     Date Created: 8/28/06
// \   \  /  \
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   This module instantiates the block RAM based FIFO to store the user 
//   interface data into it and read after a specified amount in already 
//   written. The reading starts when the almost full signal is generated 
//   whose offset is programmable.
//Reference:
//Revision History:
//   Rev 1.0 - created. adapted V5 from DDR2 SDRAM controller from MIG 1.6
//             from karthip design. richc. 8/28/06
//   Rev 1.1 - integration with KP DDR2 changes. richc. 11/15/06
//   Rev 1.2 - Registered wdf_rden before being input to RDEN of WDF FIFO. MG 9/10/07
//***********************************************************************************

`timescale 1ns/1ps

module usr_wr_fifo #
   (parameter integer ECC_ENABLE    = 1,
    parameter integer SIM_ONLY      = 1
   )
  (
   input          clk0,
   input          clk90,
   input          rst90,
   input          app_wdf_wren,
   input [63:0]   app_wdf_data,
   input [7:0]    app_wdf_mask_data,
   input          wdf_rden,
   output [63:0]  wdf_data,
   output [7:0]   wdf_data_parity,
   output [7:0]   wdf_mask_data
   );

  wire [63:0]     i_wdf_data_in;
  wire [7:0]      i_wdf_mask_data_in;
  wire [7:0]      wdf_parity_out;
  wire            i_wdf_wren;

   
   

  //***************************************************************************
  
  assign i_wdf_wren = app_wdf_wren;
  assign i_wdf_data_in = app_wdf_data;
  assign i_wdf_mask_data_in = app_wdf_mask_data;

  assign wdf_data_parity = (ECC_ENABLE)? wdf_parity_out : 8'd0;
 
// Change to reverse bit order connecting to FIFO
  wire [0:63] tmp_data_in, tmp_data_out, tmp_data_in_ecc, tmp_data_out_ecc;
  wire [0:7]  tmp_mask_in, tmp_mask_out, tmp_parity_out_ecc;

 
  
  genvar data_i; 
  genvar mask_i;
  genvar ecc_d;
  genvar ecc_p;
  generate 
    if(ECC_ENABLE) begin    // ECC code

    for (ecc_d = 0; ecc_d < 64; ecc_d = ecc_d+1) begin : ecc_data_block
      assign tmp_data_in_ecc[ecc_d] = i_wdf_data_in[ecc_d];
      assign wdf_data[ecc_d] = tmp_data_out_ecc[ecc_d];
    end
    for (ecc_p = 0; ecc_p < 8; ecc_p = ecc_p+1) begin : ecc_parity_block
      assign wdf_parity_out[ecc_p] = tmp_parity_out_ecc[ecc_p];
    end

        FIFO36_72  #
          (
           .ALMOST_EMPTY_OFFSET     (9'h007),
           .ALMOST_FULL_OFFSET      (9'h00F),
           .DO_REG                  (1),          // extra CC output delay
           .EN_ECC_WRITE            ("TRUE"),
           .EN_ECC_READ             ("TRUE"),
           .EN_SYN                  ("FALSE"),
           .FIRST_WORD_FALL_THROUGH ("TRUE")
           )
          u_wdf
            (
             .ALMOSTEMPTY (),
             .ALMOSTFULL  (),
             .DBITERR     (),
             .DO          (tmp_data_out_ecc),
             .DOP         (tmp_parity_out_ecc),
             .ECCPARITY   (),
             .EMPTY       (),
             .FULL        (),
             .RDCOUNT     (),
             .RDERR       (),
             .SBITERR     (),
             .WRCOUNT     (),
             .WRERR       (),
             .DI          (tmp_data_in_ecc),
             .DIP         (),
             .RDCLK       (clk90),
             .RDEN        (wdf_rden),
             .RST         (rst90),
             .WRCLK       (clk0),
             .WREN        (i_wdf_wren)
             );
             
    end else begin // if (ECC_ENABLE)
    
    for (data_i = 0; data_i < 64; data_i = data_i+1) begin : data_block
    assign tmp_data_in[data_i] = i_wdf_data_in[data_i];
    assign wdf_data[data_i] = tmp_data_out[data_i];
    end
    for (mask_i = 0; mask_i < 8; mask_i = mask_i+1) begin : mask_block
      assign tmp_mask_in[mask_i] = i_wdf_mask_data_in[mask_i];
      assign wdf_mask_data[mask_i] = tmp_mask_out[mask_i];
    end

  
  FIFO36_72  #
    (
     .ALMOST_EMPTY_OFFSET     (9'h007),
     .ALMOST_FULL_OFFSET      (9'h00F),
     .DO_REG                  (1),          // extra CC output delay
     //.EN_ECC_WRITE            ("FALSE"),
     //.EN_ECC_READ             ("FALSE"),
     //.EN_SYN                  ("FALSE"),
     //.FIRST_WORD_FALL_THROUGH ("TRUE")
     //.EN_ECC_WRITE            (0),
     //.EN_ECC_READ             (0),
     //.EN_SYN                  (0),
     //.FIRST_WORD_FALL_THROUGH (1)
     .EN_ECC_WRITE            (1'b0),
     .EN_ECC_READ             (1'b0),
     .EN_SYN                  (1'b0),
     .FIRST_WORD_FALL_THROUGH (1'b1)
     )
    u_wdf
      (
       .ALMOSTEMPTY (),
       .ALMOSTFULL  (),
       .DBITERR     (),
       .DO          (tmp_data_out),
       .DOP         (tmp_mask_out),
       .ECCPARITY   (),
       .EMPTY       (),
       .FULL        (),
       .RDCOUNT     (),
       .RDERR       (),
       .SBITERR     (),
       .WRCOUNT     (),
       .WRERR       (),
       .DI          (tmp_data_in),
       .DIP         (tmp_mask_in),
       .RDCLK       (clk90),
       .RDEN        (wdf_rden),
       .RST         (rst90),
       .WRCLK       (clk0),
       .WREN        (i_wdf_wren)
       );
             
    end
endgenerate

  
endmodule

