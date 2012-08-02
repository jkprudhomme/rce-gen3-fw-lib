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
//  \   \         Filename: usr_ram_d.v
//  /   /         Date Last Modified:
// /___/   /\     Date Created: 8/30/06
// \   \  /  \
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   Contains the distributed RAM which stores IOB output data that is read 
//   from the memory.
//Reference:
//Revision History:
//   Rev 1.0 - created. adapted V5 from DDR2 SDRAM controller from MIG 1.6
//             from karthip design. richc. 8/28/06
//*****************************************************************************

`timescale 1ns/1ps

module usr_ram_d #
  (
   parameter integer DATA_WIDTH = 8
   )
  (
   input [3:0]                addra,
   input [3:0]                addrb,
   input                      clka,
   input                      wea,
   input [DATA_WIDTH-1:0]     dinb,
   output [DATA_WIDTH-1:0]    douta
   );


  genvar ram16_i;
  generate
    for (ram16_i = 0; ram16_i < DATA_WIDTH; 
         ram16_i = ram16_i + 1) begin: gen_ram16
      RAM16X1D u_ram16x1d
        (
         .D        (dinb[ram16_i]),
         .WE       (wea),
         .WCLK     (clka),
         .A0       (addra[0]),
         .A1       (addra[1]),
         .A2       (addra[2]),
         .A3       (addra[3]),
         .DPRA0    (addrb[0]),
         .DPRA1    (addrb[1]),
         .DPRA2    (addrb[2]),
         .DPRA3    (addrb[3]),
         .SPO      (),
         .DPO      (douta[ram16_i]));
    end
  endgenerate

endmodule
