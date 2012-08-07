///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 13.4
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : chipscope_ila.v
// /___/   /\     Timestamp  : Tue Jul 24 17:05:01 PDT 2012
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead



module chipscope_ila(
    CONTROL,
    CLK,
    TRIG0);


inout [35 : 0] CONTROL;
input CLK;
input [255 : 0] TRIG0;

endmodule