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
//  \   \         Filename: top_usr.v
//  /   /         Date Last Modified:
// /___/   /\     Date Created: 8/28/06
// \   \  /  \
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   This module interfaces with the user. The user should provide the data 
//   and various commands.
//Reference:
//Revision History:
//   Rev 1.0 - created. adapted V5 from DDR2 SDRAM controller from MIG 1.6
//             from karthip design. richc. 8/28/06
//   Rev 1.1 - integration with KP DDR2 changes. richc. 11/15/06
//*****************************************************************************

`timescale 1ps/1ps


module usr_top #
  (
   parameter integer TCQ            = 100,
   parameter integer BANK_WIDTH     = 2,
   parameter integer CS_BITS        = 0,
   parameter integer COL_WIDTH      = 10,
   parameter integer DQ_PER_DQS     = 8,
   parameter integer DQ_WIDTH       = 64,
   parameter integer DQS_WIDTH      = 2,
   parameter integer ROW_WIDTH      = 13,
   parameter integer READ_DATA_PIPELINE = 0,
   parameter integer ECC_ENABLE     = 0,
   parameter integer APPDATA_WIDTH  = 128,
   parameter integer EN_WIDTH         = 16,
   parameter integer SIM_ONLY         =1
   )  
  (
   input                                     clk0,
   input                                     clk90,
   input                                     rst0,
   input                                     rst90,
   input                                     rst270,
   input [(DQS_WIDTH*DQ_PER_DQS)-1:0]        rd_data_in_rise,
   input [(DQS_WIDTH*DQ_PER_DQS)-1:0]        rd_data_in_fall,
   input [DQS_WIDTH-1:0]                     phy_calib_rden,
   input [DQS_WIDTH-1:0]                     phy_calib_rden_sel,
   input                                     ctrl_rmw_data_sel,
   input                                     ctrl_rmw_disable,
   input                                     rmw_flag_r,
   input                                     rmw_state_flag,
   input                                     rmw_state2_flag,
   input                                     rd_mod_wr,
   input                                     rmw_wr_flag,
   output                                    rmw_wr_data_rdy,
   output [(2*DQS_WIDTH*DQ_PER_DQS)-1:0]     rmw_data_out,
   output [1:0]                              rd_ecc_error,
   output                                    rd_data_valid,
   output [APPDATA_WIDTH-1:0]                rd_data_fifo_out,
   input                                     app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                 app_wdf_data,
   input [EN_WIDTH-1:0]                      app_wdf_mask_data,
   input                                     wdf_rden,
   output [(2*DQS_WIDTH*DQ_PER_DQS)-1:0]     wdf_data,
   output [((2*DQS_WIDTH*DQ_PER_DQS)/8)-1:0] wdf_mask_data
   );

  
  reg 		      rst0_r;
  reg 		      rst90_r;
  reg 		      rst270_r;
  reg 		      wdf_rden_r;
  reg 		      rmw_state_flag270;
  reg 		      rmw_state_flag90;
  reg 		      rmw_state2_flag270;
  reg 		      rmw_state2_flag90;
  reg 		      rmw_disable270_r;
  reg 		      rmw_disable90_r1, rmw_disable90_r2;
  reg 		      rmw_flag270_r;
  reg 		      rmw_flag90_r1;
  reg 		      rmw_flag90_r2;
  reg 		      rmw_flag90_r3;
  reg 		      rmw_flag90_r4;
  reg 		      rmw_flag90_r5;
  wire 	              rmw_rden;
  wire 		      wdf_read_en;
  wire 		      wdf_mask_rden;
  wire [APPDATA_WIDTH/2-1:0] i_rd_data_fifo_out_fall;
  wire [APPDATA_WIDTH/2-1:0] i_rd_data_fifo_out_rise;
  wire [APPDATA_WIDTH-1:0]   i_app_wdf_data;
  wire [APPDATA_WIDTH/8-1:0] i_app_wdf_mask_data; 
  wire [(DQS_WIDTH*DQ_PER_DQS)-1:0] rmw_data_out_rise;
  wire [(DQS_WIDTH*DQ_PER_DQS)-1:0] rmw_data_out_fall;
  wire [63:0] 			    wdf_rmw_rise_data;
  wire [63:0] 			    wdf_rmw_fall_data;
  wire [7:0] 			    wdf_rmw_rise_mask;
  wire [7:0] 			    wdf_rmw_fall_mask;

  //***************************************************************************

  // For DQ_WIDTH < 64, data is on most significant bits
  assign rd_data_fifo_out = {i_rd_data_fifo_out_rise[APPDATA_WIDTH/2-1:APPDATA_WIDTH/2-APPDATA_WIDTH/2], 
                             i_rd_data_fifo_out_fall[APPDATA_WIDTH/2-1:APPDATA_WIDTH/2-APPDATA_WIDTH/2]};


  // For DQ_WIDTH < 64, data is on least significant bits
  assign i_app_wdf_data[APPDATA_WIDTH-1:0] = app_wdf_data;
  assign i_app_wdf_mask_data[(APPDATA_WIDTH/8)-1:0] = app_wdf_mask_data;

  
  assign rmw_data_out     = {rmw_data_out_fall, 
                             rmw_data_out_rise};

  generate
  if (ECC_ENABLE) begin
    always @ (negedge clk90) begin
      if (rst270_r || ~rmw_flag_r)
	rmw_flag270_r <= #TCQ 1'd0;
      else if (rmw_wr_flag)
        rmw_flag270_r <= #TCQ rmw_flag_r;
    end
    always @ (negedge clk90)
      rmw_disable270_r <= #TCQ ctrl_rmw_disable;
   
    always @ (posedge clk90)begin
      rmw_flag90_r1    <= #TCQ rmw_flag270_r;
      rmw_flag90_r2    <= #TCQ rmw_flag90_r1;
      rmw_flag90_r3    <= #TCQ rmw_flag90_r2;
      rmw_flag90_r4    <= #TCQ rmw_flag90_r3;
      rmw_flag90_r5    <= #TCQ rmw_flag90_r4;
      rmw_disable90_r1 <= #TCQ rmw_disable270_r;
      rmw_disable90_r2 <= #TCQ rmw_disable90_r1; 
    end 
    
    assign wdf_read_en   = (~rmw_disable90_r2 && rmw_flag90_r1 && rmw_flag90_r4) ? 1'd0 : rmw_state_flag90 ? rmw_rden : wdf_rden_r;
    assign wdf_mask_rden = ((~rmw_disable90_r2 && rmw_flag90_r1 && rmw_flag90_r4) || rmw_state2_flag90) ? 1'd0 : rmw_state_flag90 ? rmw_rden : wdf_rden_r;
  end else begin
    assign wdf_read_en   = wdf_rden_r;
    assign wdf_mask_rden = 1'd0;
  end
  endgenerate 
 

  always @ (posedge clk0) begin
      rst0_r <= #TCQ rst0;
  end

  always @ (posedge clk90) begin
      rst90_r <= #TCQ rst90;
  end

  always @ (negedge clk90) begin
      rst270_r <= #TCQ rst270;
  end

  always @ (negedge clk90) begin
    rmw_state_flag270  <= #TCQ rmw_state_flag;
    rmw_state2_flag270 <= #TCQ rmw_state2_flag;     
  end

  always @ (posedge clk90) begin
    rmw_state_flag90  <= #TCQ rmw_state_flag270;
    rmw_state2_flag90 <= #TCQ rmw_state2_flag270;
  end
   
  always@(posedge clk90) begin
    wdf_rden_r <= #TCQ wdf_rden;  
   end

  // read FIFOs: provides minimal buffering to handle when data from different
  // DQS groups are synchronized on different clock cycles   
  usr_rd #
    (
     .TCQ            (TCQ),
     .DQ_PER_DQS     (DQ_PER_DQS),
     .DQS_WIDTH      (DQS_WIDTH),
     .APPDATA_WIDTH  (APPDATA_WIDTH),
     .READ_DATA_PIPELINE (READ_DATA_PIPELINE),
     .ECC_ENABLE     (ECC_ENABLE)
     )
    usr_rd
      (
       .clk90            (clk90),
       .clk0             (clk0),
       .rst90            (rst90_r),
       .rst270           (rst270_r),
       .rst0             (rst0_r),
       .rd_data_in_rise  (rd_data_in_rise),
       .rd_data_in_fall  (rd_data_in_fall),
       .phy_calib_rden_sel (phy_calib_rden_sel),
       .ctrl_rden        (phy_calib_rden),
       .ctrl_rmw_data_sel(ctrl_rmw_data_sel),
       .wdf_rden_r       (wdf_rden_r),
       .rd_mod_wr        (rd_mod_wr),
       .rmw_rden         (rmw_rden),
       .rmw_wr_data_rdy  (rmw_wr_data_rdy),
       .rmw_data_out_rise(rmw_data_out_rise),
       .rmw_data_out_fall(rmw_data_out_fall),
       .rd_ecc_error     (rd_ecc_error),
       .rd_data_valid    (rd_data_valid),
       .rd_data_out_rise (i_rd_data_fifo_out_rise),
       .rd_data_out_fall (i_rd_data_fifo_out_fall),
       .wdf_rmw_rise_data (wdf_rmw_rise_data),
       .wdf_rmw_fall_data (wdf_rmw_fall_data),
       .wdf_rmw_rise_mask (wdf_rmw_rise_mask),
       .wdf_rmw_fall_mask (wdf_rmw_fall_mask)
       );


  // Write Data FIFOs
  usr_wr #
    (
     .TCQ            (TCQ),
     .DQ_WIDTH       (DQ_WIDTH),
     .APPDATA_WIDTH  (APPDATA_WIDTH),
     .ECC_ENABLE     (ECC_ENABLE),
     .SIM_ONLY       (SIM_ONLY)
     )
    u_wr_fifos 
      (
       .clk0              (clk0),
       .clk90             (clk90),
       .rst90             (rst90_r),
       .rst270            (rst270_r),
       .app_wdf_wren      (app_wdf_wren),
       .app_wdf_data      (i_app_wdf_data),
       .app_wdf_mask_data (i_app_wdf_mask_data),
       .ctrl_rmw_data_sel (ctrl_rmw_data_sel),
       .wdf_rden          (wdf_read_en),
       .wdf_mask_rden     (wdf_mask_rden),
       .wdf_data          (wdf_data),
       .wdf_mask_data     (wdf_mask_data),
       .wdf_rmw_rise_data (wdf_rmw_rise_data),
       .wdf_rmw_fall_data (wdf_rmw_fall_data),
       .wdf_rmw_rise_mask (wdf_rmw_rise_mask),
       .wdf_rmw_fall_mask (wdf_rmw_fall_mask)
       ); 
     
endmodule
