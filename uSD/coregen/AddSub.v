////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: O.87xd
//  \   \         Application: netgen
//  /   /         Filename: AddSub.v
// /___/   /\     Timestamp: Mon Jun 18 15:25:03 2012
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog /afs/slac.stanford.edu/u/re/bklein/projects/microSD/xil_cores/tmp/_cg/AddSub.ngc /afs/slac.stanford.edu/u/re/bklein/projects/microSD/xil_cores/tmp/_cg/AddSub.v 
// Device	: 5vfx70tff1136-2
// Input file	: /afs/slac.stanford.edu/u/re/bklein/projects/microSD/xil_cores/tmp/_cg/AddSub.ngc
// Output file	: /afs/slac.stanford.edu/u/re/bklein/projects/microSD/xil_cores/tmp/_cg/AddSub.v
// # of Modules	: 1
// Design Name	: AddSub
// Xilinx        : /afs/slac.stanford.edu/g/reseng/vol13/xilinx/13.4/ISE_DS/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module AddSub (
  clk, ce, s, a, b
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input ce;
  output [15 : 0] s;
  input [14 : 0] a;
  input [14 : 0] b;
  
  // synthesis translate_off
  
  wire N0;
  wire \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum<14>1_22 ;
  wire [14 : 0] \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple ;
  wire [14 : 0] \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum ;
  wire [16 : 1] \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output ;
  wire [15 : 0] \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple ;
  assign
    s[15] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [16],
    s[14] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [15],
    s[13] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [14],
    s[12] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [13],
    s[11] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [12],
    s[10] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [11],
    s[9] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [10],
    s[8] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [9],
    s[7] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [8],
    s[6] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [7],
    s[5] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [6],
    s[4] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [5],
    s[3] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [4],
    s[2] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [3],
    s[1] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [2],
    s[0] = \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [1];
  GND   XST_GND (
    .G(N0)
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_1  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [0]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [1])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_2  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [1]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [2])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_3  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [2]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [3])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_4  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [3]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [4])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_5  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [4]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [5])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_6  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [5]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [6])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_7  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [6]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [7])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_8  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [7]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [8])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_9  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [8]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [9])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_10  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [9]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [10])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_11  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [10]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [11])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_12  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [11]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [12])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_13  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [12]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [13])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_14  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [13]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [14])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_15  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [14]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [15])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_16  (
    .C(clk),
    .CE(ce),
    .D(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [15]),
    .Q(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output [16])
  );
  XORCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[14].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [13]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum<14>1_22 ),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [14])
  );
  MUXCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[14].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [13]),
    .DI(a[14]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum<14>1_22 ),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [14])
  );
  XORCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[13].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [12]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [13]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [13])
  );
  MUXCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[13].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [12]),
    .DI(a[13]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [13]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [13])
  );
  XORCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[12].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [11]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [12]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [12])
  );
  MUXCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[12].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [11]),
    .DI(a[12]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [12]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [12])
  );
  XORCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[11].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [10]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [11]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [11])
  );
  MUXCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[11].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [10]),
    .DI(a[11]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [11]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [11])
  );
  XORCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[10].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [9]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [10]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [10])
  );
  MUXCY 
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[10].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [9]),
    .DI(a[10]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [10]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [10])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[9].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [8]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [9]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [9])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[9].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [8]),
    .DI(a[9]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [9]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [9])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[8].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [7]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [8]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [8])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[8].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [7]),
    .DI(a[8]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [8]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [8])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[7].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [6]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [7]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [7])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[7].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [6]),
    .DI(a[7]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [7]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [7])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [5]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [6]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [6])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [5]),
    .DI(a[6]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [6]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [6])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [4]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [5]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [5])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [4]),
    .DI(a[5]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [5]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [5])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [3]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [4]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [4])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [3]),
    .DI(a[4]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [4]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [4])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [2]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [3]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [3])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [2]),
    .DI(a[3]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [3]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [3])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [1]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [2]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [2])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [1]),
    .DI(a[2]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [2]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [2])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carryxor  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [1]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [1])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0]),
    .DI(a[1]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [1]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [1])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carryxortop  (
    .CI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [14]),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [14]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [15])
  );
  XORCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.carryxor0  (
    .CI(N0),
    .LI(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [0])
  );
  MUXCY   \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.carrymux0  (
    .CI(N0),
    .DI(a[0]),
    .S(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum<14>1  (
    .I0(b[14]),
    .I1(a[14]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [14])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<13>1  (
    .I0(b[13]),
    .I1(a[13]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [13])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<12>1  (
    .I0(b[12]),
    .I1(a[12]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [12])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<11>1  (
    .I0(b[11]),
    .I1(a[11]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [11])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<10>1  (
    .I0(b[10]),
    .I1(a[10]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [10])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<9>1  (
    .I0(b[9]),
    .I1(a[9]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [9])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<8>1  (
    .I0(b[8]),
    .I1(a[8]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [8])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<7>1  (
    .I0(b[7]),
    .I1(a[7]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [7])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<6>1  (
    .I0(b[6]),
    .I1(a[6]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [6])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<5>1  (
    .I0(b[5]),
    .I1(a[5]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [5])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<4>1  (
    .I0(b[4]),
    .I1(a[4]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [4])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<3>1  (
    .I0(b[3]),
    .I1(a[3]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [3])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<2>1  (
    .I0(b[2]),
    .I1(a[2]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [2])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<1>1  (
    .I0(b[1]),
    .I1(a[1]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [1])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/Mxor_halfsum_Result<0>1  (
    .I0(b[0]),
    .I1(a[0]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum<14>11  (
    .I0(b[14]),
    .I1(a[14]),
    .O(\U0/xst_addsub/i_baseblox.i_baseblox_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum<14>1_22 )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
