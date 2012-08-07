////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: O.87xd
//  \   \         Application: netgen
//  /   /         Filename: fifo36x1024sdwrite.v
// /___/   /\     Timestamp: Tue Jul 24 13:14:58 2012
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog /afs/slac.stanford.edu/u/re/bklein/projects/microSD/coregen/tmp/_cg/fifo36x1024sdwrite.ngc /afs/slac.stanford.edu/u/re/bklein/projects/microSD/coregen/tmp/_cg/fifo36x1024sdwrite.v 
// Device	: 5vfx70tff1136-2
// Input file	: /afs/slac.stanford.edu/u/re/bklein/projects/microSD/coregen/tmp/_cg/fifo36x1024sdwrite.ngc
// Output file	: /afs/slac.stanford.edu/u/re/bklein/projects/microSD/coregen/tmp/_cg/fifo36x1024sdwrite.v
// # of Modules	: 1
// Design Name	: fifo36x1024sdwrite
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

module fifo36x1024sdwrite (
  rd_en, rst, empty, wr_en, rd_clk, full, prog_empty, wr_clk, prog_full, dout, din
)/* synthesis syn_black_box syn_noprune=1 */;
  input rd_en;
  input rst;
  output empty;
  input wr_en;
  input rd_clk;
  output full;
  output prog_empty;
  input wr_clk;
  output prog_full;
  output [35 : 0] dout;
  input [35 : 0] din;
  
  // synthesis translate_off
  
  wire N0;
  wire N1;
  wire \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/Mshreg_power_on_wr_rst_0_2 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_reg_9 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_reg_15 ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDERR_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRERR_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<12>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<11>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<10>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<9>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<8>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<7>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<6>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<5>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<4>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<12>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<11>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<10>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<9>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<8>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<7>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<6>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<5>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<4>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/Mshreg_power_on_wr_rst_0_Q15_UNCONNECTED ;
  wire [0 : 0] \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/power_on_wr_rst ;
  wire [4 : 0] \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb ;
  wire [4 : 0] \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb ;
  wire [0 : 0] \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/wr_rst_i ;
  GND   XST_GND (
    .G(N0)
  );
  VCC   XST_VCC (
    .P(N1)
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb_4  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_reg_9 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb_3  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [4]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb_2  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb_1  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb_0  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [0])
  );
  FDPE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_reg  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [0]),
    .D(N0),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_reg_15 )
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb_4  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_reg_15 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [4])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb_3  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [4]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [3])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb_2  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [2])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb_1  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [1])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb_0  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_fb [0])
  );
  FDPE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_reg  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_fb [0]),
    .D(N0),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/rd_rst_reg_9 )
  );
  FIFO36_EXP #(
    .ALMOST_FULL_OFFSET ( 13'h0004 ),
    .SIM_MODE ( "SAFE" ),
    .DATA_WIDTH ( 36 ),
    .DO_REG ( 1 ),
    .EN_SYN ( "FALSE" ),
    .FIRST_WORD_FALL_THROUGH ( "FALSE" ),
    .ALMOST_EMPTY_OFFSET ( 13'h0005 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36  (
    .RDEN(rd_en),
    .WREN(wr_en),
    .RST(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/wr_rst_i [0]),
    .RDCLKU(rd_clk),
    .RDCLKL(rd_clk),
    .WRCLKU(wr_clk),
    .WRCLKL(wr_clk),
    .RDRCLKU(rd_clk),
    .RDRCLKL(rd_clk),
    .ALMOSTEMPTY(prog_empty),
    .ALMOSTFULL(prog_full),
    .EMPTY(empty),
    .FULL(full),
    .RDERR(\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDERR_UNCONNECTED ),
    .WRERR(\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRERR_UNCONNECTED ),
    .DI({din[31], din[30], din[29], din[28], din[27], din[26], din[25], din[24], din[23], din[22], din[21], din[20], din[19], din[18], din[17], 
din[16], din[15], din[14], din[13], din[12], din[11], din[10], din[9], din[8], din[7], din[6], din[5], din[4], din[3], din[2], din[1], din[0]}),
    .DIP({din[35], din[34], din[33], din[32]}),
    .DO({dout[31], dout[30], dout[29], dout[28], dout[27], dout[26], dout[25], dout[24], dout[23], dout[22], dout[21], dout[20], dout[19], dout[18], 
dout[17], dout[16], dout[15], dout[14], dout[13], dout[12], dout[11], dout[10], dout[9], dout[8], dout[7], dout[6], dout[5], dout[4], dout[3], dout[2]
, dout[1], dout[0]}),
    .DOP({dout[35], dout[34], dout[33], dout[32]}),
    .RDCOUNT({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<12>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<11>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<10>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<9>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<8>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<7>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<6>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<5>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<4>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<3>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<2>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<1>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_RDCOUNT<0>_UNCONNECTED }),
    .WRCOUNT({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<12>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<11>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<10>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<9>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<8>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<7>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<6>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<5>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<4>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<3>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<2>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<1>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/v5_fifo.fblk/gextw[1].inst_extd/gonep.inst_prim/gfn72.sngfifo36_WRCOUNT<0>_UNCONNECTED })
  );
  LUT2 #(
    .INIT ( 4'hE ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/WR_RST_I<1>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/wr_rst_reg_15 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/power_on_wr_rst [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/wr_rst_i [0])
  );
  SRLC16E #(
    .INIT ( 16'h001F ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/Mshreg_power_on_wr_rst_0  (
    .A0(N0),
    .A1(N0),
    .A2(N1),
    .A3(N0),
    .CE(N1),
    .CLK(wr_clk),
    .D(N0),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/Mshreg_power_on_wr_rst_0_2 ),
    .Q15(\NLW_U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/Mshreg_power_on_wr_rst_0_Q15_UNCONNECTED )
  );
  FDE #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/power_on_wr_rst_0  (
    .C(wr_clk),
    .CE(N1),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/Mshreg_power_on_wr_rst_0_2 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/gbiv5.bi/rstbt/power_on_wr_rst [0])
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
