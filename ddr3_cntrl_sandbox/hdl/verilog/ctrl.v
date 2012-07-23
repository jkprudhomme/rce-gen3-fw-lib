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
//*****************************************************************************
// Copyright (c) 2006 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, Inc.
// All Rights Reserved
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: $Name: i+EDK_HEAD+180229 $
//  \   \         Application: MIG
//  /   /         Filename: u_ctrl_0.v
// /___/   /\     Date Last Modified: $Date: 2010/05/12 17:45:17 $
// \   \  /  \    Date Created: Wed Aug 30 2006
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   This module is the main control logic of the memory interface. All
//   commands are issued from here according to the burst, CAS Latency and the
//   user commands.
//Reference:
//Revision History:
//*****************************************************************************

`timescale 1ps/1ps


module u_ctrl #
  (
   parameter TCQ           = 100,
   parameter BANK_WIDTH    = 3,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter CS_NUM        = 1,
   parameter DQS_BITS      = 2,
   parameter DQ_WIDTH      = 16,
   parameter ROW_WIDTH     = 14,
   parameter ADDITIVE_LAT  = 0,
   parameter BURST_LEN     = 4,
   parameter CAS_LAT       = 5,
   parameter ECC_ENABLE    = 0,
   parameter MIB_CLK_RATIO = 2,
   parameter TREFI_NS      = 7800,
   parameter TRAS          = 40000,
   parameter TRCD          = 15000,
   parameter TRFC          = 105000,
   parameter TRP           = 15000,
   parameter TRTP          = 7500,
   parameter TWR           = 15000,
   parameter TWTR          = 10000,
   parameter CLK_PERIOD    = 3003
   )
  (
   input                   clk,
   input                   rst,
   input                   phy_init_done,
   input                   mi_mcwritedatavalid,
   input                   mi_mc_add_val,
   input [35:0]            mi_mc_add,
   input                   mi_mc_bank_conf,
   input                   mi_mc_row_conf,
   input                   mi_mc_rd,
   input                   rmw_flag,
   input                   rmw_wr_data_rdy,
   input                   wdf_rden,
   output                  rmw_wr_flag,
   output                  rd_mod_wr,
   output reg              rmw_state_flag,
   output reg              rmw_state2_flag,
   output                  mc_mi_addr_rdy_accpt,
   output                  ctrl_ref_flag,
   output                  ctrl_wren,
   output reg              ctrl_rden,
   output reg              ctrl_rmw_data_sel,
   output                  ctrl_rmw_done,
   output                  ctrl_rmw_disable,
   output [ROW_WIDTH-1:0]  ctrl_addr,
   output [BANK_WIDTH-1:0] ctrl_ba,
   output                  ctrl_ras_n,
   output                  ctrl_cas_n,
   output                  ctrl_we_n,
   output [CS_NUM-1:0]     ctrl_cs_n
   );

  // input address split into various ranges
  localparam ADDR_OFFSET         = (DQS_BITS > 3) ? DQS_BITS-1 : DQS_BITS;
//  localparam ADDR_OFFSET         = 0;
  localparam COL_RANGE_START     = ADDR_OFFSET;
  localparam COL_RANGE_END       = (COL_WIDTH + ADDR_OFFSET) -1;   
  localparam ROW_RANGE_START     = COL_RANGE_END + 1;
  localparam ROW_RANGE_END       = ROW_WIDTH + ROW_RANGE_START - 1;
  localparam BANK_RANGE_START    = ROW_RANGE_END + 1;
  localparam BANK_RANGE_END      = BANK_WIDTH + BANK_RANGE_START - 1;
  localparam CS_RANGE_START      = BANK_RANGE_START + BANK_WIDTH;
  localparam CS_RANGE_END        = CS_BITS + CS_RANGE_START - 1;
  // compare address (for determining bank/row hits) split into various ranges
  // (compare address doesn't include column bits)
  localparam CMP_WIDTH            = CS_BITS + BANK_WIDTH + ROW_WIDTH;
  localparam CMP_ROW_RANGE_START  = 0;
  localparam CMP_ROW_RANGE_END    = ROW_WIDTH + CMP_ROW_RANGE_START - 1;
  localparam CMP_BANK_RANGE_START = CMP_ROW_RANGE_END + 1;
  localparam CMP_BANK_RANGE_END   = BANK_WIDTH + CMP_BANK_RANGE_START - 1;
  localparam CMP_CS_RANGE_START   = CMP_BANK_RANGE_END + 1;
  localparam CMP_CS_RANGE_END     = CS_BITS + CMP_CS_RANGE_START - 1;

  localparam BURST_LEN_DIV2      = BURST_LEN / 2;
  localparam OPEN_BANK_NUM       = 4;

  // calculation counters based on clock cycle and memory parameters
  // TRAS: ACTIVE->PRECHARGE interval - 2
  localparam integer TRAS_CYC = (TRAS%CLK_PERIOD) ? (TRAS + CLK_PERIOD)/CLK_PERIOD:(TRAS/CLK_PERIOD);
  // TRCD: ACTIVE->READ/WRITE interval - 3 (for DDR2 factor in ADD_LAT)
  localparam integer TRCD_CK  = (TRCD%CLK_PERIOD) ? ((TRCD + CLK_PERIOD)/CLK_PERIOD):(TRCD/CLK_PERIOD);
  localparam integer TRCD_CYC = (TRCD_CK > ADDITIVE_LAT) ? TRCD_CK - ADDITIVE_LAT : 0;                                
  // TRFC: REFRESH->REFRESH, REFRESH->ACTIVE interval - 2
  localparam integer TRFC_CYC = (TRFC%CLK_PERIOD) ? (TRFC + CLK_PERIOD)/CLK_PERIOD:(TRFC/CLK_PERIOD);
  // TRP: PRECHARGE->COMMAND interval - 2
  // for precharge all add 1 extra clock cycle
  localparam integer TRP_CYC =  (TRP%CLK_PERIOD) ? ((TRP + CLK_PERIOD)/CLK_PERIOD):((TRP/CLK_PERIOD)+ 1);
  // TRTP: READ->PRECHARGE interval - 2 (for DDR2, TRTP = 2 clks)
  localparam integer TRTP_TMP_MIN = (TRTP%CLK_PERIOD) ? (TRTP + CLK_PERIOD)/CLK_PERIOD:(TRTP/CLK_PERIOD);
  localparam integer TRTP_CYC = TRTP_TMP_MIN + ADDITIVE_LAT + BURST_LEN_DIV2 - 2;
  // TWR: WRITE->PRECHARGE interval - 2
  localparam integer WR_LAT = CAS_LAT + ADDITIVE_LAT - 1;
  localparam integer TWR_CK = (TWR%CLK_PERIOD) ? (TWR + CLK_PERIOD)/CLK_PERIOD:(TWR/CLK_PERIOD);
  localparam integer TWR_CYC = TWR_CK + WR_LAT + BURST_LEN_DIV2;
  // TWTR: WRITE->READ interval - 3 (for DDR1, TWTR = 2 clks)
  localparam integer TWTR_TMP_MIN = (TWTR%CLK_PERIOD) ? (TWTR + CLK_PERIOD)/CLK_PERIOD:(TWTR/CLK_PERIOD);
  localparam integer TWTR_CYC = (TWTR_TMP_MIN + (CAS_LAT -1) + BURST_LEN_DIV2 );
  localparam integer TRTW_CYC = BURST_LEN_DIV2 + 3;

  // TRTW: READ->WRITE interval - 3
  //  DDR1: CL + (BL/2) + ECC/REG delays
  //  DDR2: (BL/2) + 2 + ECC/REG delays
  localparam integer CAS_LAT_RD = (CAS_LAT == 25) ? 2 : CAS_LAT;

  // Make sure all values >= 0 (some may be = 0)
  localparam TRAS_COUNT = (TRAS_CYC > 0) ? TRAS_CYC : 0;
  localparam TRCD_COUNT = (TRCD_CYC > 0) ? TRCD_CYC : 0;
  localparam TRFC_COUNT = (TRFC_CYC > 0) ? TRFC_CYC : 0;
  localparam TRP_COUNT  = (TRP_CYC > 0)  ? TRP_CYC : 0;
  localparam TRTP_COUNT = (TRTP_CYC > 0) ? TRTP_CYC : 0;
  localparam TWR_COUNT  = (TWR_CYC > 0)  ? TWR_CYC : 0;
  localparam TWTR_COUNT = (TWTR_CYC > 0) ? TWTR_CYC : 0;
  localparam TRTW_COUNT = (TRTW_CYC > 0) ? TRTW_CYC : 0;

  // Auto refresh interval
  localparam TREFI_COUNT = ((TREFI_NS * 1000)/CLK_PERIOD) - 1;

  // Main memory controller states

  localparam   CTRL_ACTIVE              =     5'h00;
  localparam   CTRL_PRECHARGE           =     5'h01;
  localparam   CTRL_AUTO_REFRESH        =     5'h02;
  localparam   CTRL_BURST_READ          =     5'h03;
  localparam   CTRL_BURST_WRITE         =     5'h04;
  localparam   CTRL_IDLE                =     5'h05;
  localparam   CTRL_PRECHARGE_WAIT      =     5'h06;
  localparam   CTRL_PRECHARGE_WAIT1     =     5'h07;     
  localparam   CTRL_AUTO_REFRESH_WAIT   =     5'h08; 
  localparam   CTRL_ACTIVE_WAIT         =     5'h09; 
  localparam   CTRL_READ_WAIT           =     5'h0A;  
  localparam   CTRL_WRITE_WAIT          =     5'h0B;
  localparam   CTRL_COMMAND_WAIT        =     5'h0C;
  localparam   CTRL_WRITE_BANK_CONF     =     5'h0D;
  localparam   CTRL_READ_BANK_CONF      =     5'h0E;
  
  // Read Modify Write states

  localparam   RMW_IDLE           =     3'h1;
  localparam   RMW_WRITE_WAIT     =     3'h2;
  localparam   RMW_READ           =     3'h3;
  localparam   RMW_READ_WAIT      =     3'h4;
  localparam   RMW_WRITE          =     3'h5;
   

  reg 			                   rst_r;
  reg                                      rst_180r;
  wire [(CS_BITS+BANK_WIDTH)-1:0]          af_addr_bank_cmp;
  reg [30:0]                               af_addr_r;
  reg [30:0]                               af_addr_r1;
  wire [ROW_WIDTH-1:0]                     af_addr_row_cmp;
  reg [2:0]                                auto_cnt_r;
  reg                                      auto_ref_r;  
  reg                                      auto_ref_r1;
  reg                                      auto_ref_r2;
  reg                                      auto_ref_r3;
  reg                                      auto_ref_r4;
  reg                                      auto_ref_r5; 
  reg                                      bank_conf;
  reg                                      bank_conf_r;
  reg [(OPEN_BANK_NUM*CMP_WIDTH)-1:0]      bank_cmp_addr_r
                                           /* synthesis syn_maxfan = 1 */;
  reg                                      bank_hit_any_r;
  reg [OPEN_BANK_NUM-1:0]                  bank_hit_r;
  reg [OPEN_BANK_NUM-1:0]                  bank_valid_r;
  wire                                     conflict_detect;
  reg                                      conflict_detect_r;
  reg 					   change_direction_r;
  reg 					   ctrl_wren_r;
  reg 					   ctrl_wren_r1;
  reg                                      clear_rd_r;
  reg                                      clear_rd_r1;
  reg                                      clear_rd_r2;   
  reg [ROW_WIDTH-1:0]                      ddr_addr_r;
  wire [ROW_WIDTH-1:0]                     ddr_addr_col;
  wire [ROW_WIDTH-1:0]                     ddr_addr_row;
  reg [BANK_WIDTH-1:0]                     ddr_ba_r;
  reg                                      ddr_cas_n_r;
  reg [CS_NUM-1:0]                         ddr_cs_n_r;
  reg                                      ddr_ras_n_r;
  reg                                      ddr_we_n_r;
  reg                                      delay_cmd;
  reg                                      delay_cmd_r;
  reg                                      delay_write;
  reg                                      mc_mi_addr_rdy_accpt_r;
  reg                                      mc_mi_addr_rdy_accpt_r1;
  reg 				           mc_mi_addr_rdy_accpt_r2;
  reg [7:0]                                mc_mi_addr_rdy_accpt_count_r;
  reg 					   wrdata_val_r;
  reg 					   wrdata_val_r1;
  reg 					   wrdata_val_r2;
  reg 					   wrdata_val_r3;
  reg                                      mi_mc_bank_conf_r;
  reg                                      mi_mc_row_conf_r;
  reg 				           mi_mc_conf_r;
  reg 				           mi_mc_conf_r1;
  reg 				           mi_mc_conf_r2;
  reg 				           mi_mc_conf_r3;   
  reg                                      mi_mc_rd_r;
  reg 					   mi_mc_rd_r1;
  reg 					   mi_mc_rd_r2; 
  reg 				           mi_mc_wr_r;
  reg 				           mi_mc_wr_r1;
  reg 				           mi_mc_wr_r2;
  reg [31:0]                               mi_mc_add_r;
  reg 				           mi_mc_add_val_r;
  reg 				           mi_mc_add_val_r1;
  reg 				           mi_mc_add_val_r2;
  reg 				           mi_mc_conflict_r;
  reg                                      mi_mc_bank_conf_c;
  reg                                      mi_mc_row_conf_c;
  reg                                      mi_mc_rd_c;
  reg                                      mi_mc_wr_c;
  reg [35:0]                               mi_mc_add_c;
  reg                                      mi_mc_bank_conf_c_r;
  reg                                      mi_mc_row_conf_c_r;
  reg                                      mi_mc_rd_c_r;
  reg                                      mi_mc_rd_c_r1;
  reg                                      mi_mc_rd_c_r2;
  reg                                      mi_mc_rd_c_r3;
  reg                                      mi_mc_wr_c_r;
  reg                                      mi_mc_wr_c_r1;
  reg 					   mi_mc_wr_c_r2;
  reg 					   mi_mc_wr_c_r3;
  reg 				           mi_mc_wr_rd_c_r;
  reg [35:0]                               mi_mc_add_c_r;
  reg [35:0] 				   mi_mc_add_c_r1;
  reg [35:0] 				   mi_mc_add_c_r2;
  reg [4:0]                                next_state;
  reg                                      no_precharge_r;
  reg                                      no_precharge_wait_r;
  reg                                      phy_init_done_r;
  reg [3:0]                                ras_cnt_r;
  reg 					   ras_ok_r;
  reg [2:0]                                rcd_cnt_r;
  reg 					   rcd_cnt_ok_r;
  reg [2:0]                                rdburst_cnt_r;
  reg 					   rdburst_ok_r;
  wire                                     rd_flag;
  reg                                      rd_flag_r
                                           /* synthesis syn_maxfan = 1 */;
  reg [3:0]                                rd_to_wr_cnt_r;
  reg 					   rd_to_wr_ok_r;
  reg                                      ref_flag_r;
  reg                                      rd_cmd;
  reg                                      rd_cmd_r;
  reg [11:0]                               refi_cnt_r;
  reg [7:0]                                rfc_cnt_r;
  reg 					   rfc_ok_r;
  reg [OPEN_BANK_NUM-1:0]                  row_miss_r;
  reg [2:0]                                rp_cnt_r;
  reg 					   rp_cnt_ok_r;
  reg [4:0]                                rtp_cnt_r;
  reg 					   rtp_ok_r;
  reg [4:0]                                state_r;
  reg [4:0]                                state_r1;
  reg [2:0]                                wrburst_cnt_r;
  reg 					   wrburst_ok_r;
  wire                                     wr_flag;
  reg                                      wr_flag_r
                                           /* synthesis syn_maxfan = 1 */;
  reg [4:0]                                wr_to_rd_cnt_r;
  reg 					   wr_to_rd_ok_r;
  reg [4:0]                                wtp_cnt_r;
  reg 					   wtp_ok_r;
  wire  rd_mod_wr_flag;
  wire  rmw_wr_flag_w;
  wire rmw_disable;
  wire  wdf_rden_out;
  reg   rd_mod_wr_r;
  reg   rd_mod_wr_r1;
  reg   wdf_rden_out_r;
  reg   wdf_rden_r; 
  reg   rmw_done;
  reg   rmw_done_r;
  reg   rmw_done_180r;   
  reg   rmw_wr_flag_r;
  reg   rmw_flag_r;
  reg [2:0]  rmw_state_r;
  reg [2:0]  rmw_next_state;
  reg 	     rmw_disable_r;
  reg 	     rmw_disable_r1;   


  //*****************************************************************

    always @ (posedge clk) begin
      rst_r <= #TCQ rst;
    end
    
    always @ (negedge clk) begin
      rst_180r <= #TCQ rst;
    end
   
  //*****************************************************************
  // register inputs from MIB
  //*****************************************************************

   always @ (posedge clk) begin
     if (rst_r) begin
         mi_mc_add_r       <= #TCQ {32{1'bx}};
         mi_mc_bank_conf_r <= #TCQ 1'bx;
         mi_mc_rd_r        <= #TCQ 1'bx;
         mi_mc_wr_r        <= #TCQ 1'bx;
         mi_mc_row_conf_r  <= #TCQ 1'bx;
     end else begin
	  mi_mc_add_r       <= #TCQ mi_mc_add;
	  mi_mc_rd_r        <= #TCQ mi_mc_rd;
         if (mi_mc_add_val) begin             
            mi_mc_bank_conf_r <= #TCQ mi_mc_bank_conf;
            mi_mc_row_conf_r  <= #TCQ mi_mc_row_conf;      
     end // else: !if(rst)
     end // else: !if(rst)
      
   end // always @ (posedge clk)


 //******************************************************************
  // setting and clearing the commands from MIB
  // commands are set when m_mc_add_val_r signal is
  // asserted and cleared when the read or write is performed. 
  // combinational logic 
  //*****************************************************************
     
    always @* begin
      mi_mc_add_c       = mi_mc_add_c_r;
      mi_mc_bank_conf_c = mi_mc_bank_conf_c_r;
      mi_mc_rd_c        = mi_mc_rd_c_r;
      mi_mc_wr_c        = mi_mc_wr_c_r;
      mi_mc_row_conf_c  = mi_mc_row_conf_c_r; 
      if(mi_mc_add_val_r )
	begin 
         mi_mc_add_c = mi_mc_add_r;
	 mi_mc_bank_conf_c = mi_mc_bank_conf_r;
	 mi_mc_rd_c = mi_mc_rd_r;
         mi_mc_wr_c = ~mi_mc_rd_r;
	 mi_mc_row_conf_c = mi_mc_row_conf_r;    	      
       end else if((state_r == CTRL_BURST_WRITE) || (state_r == CTRL_BURST_READ))begin
	 mi_mc_bank_conf_c = 1'd0;
	 mi_mc_rd_c = 1'd0;
	 mi_mc_wr_c = 1'd0;
	 mi_mc_row_conf_c = 1'd0;	      
       end
   end // always @ *	         

  //*****************************************************************
  // register the combinatioral logic 
  //*****************************************************************

// register inputs from MIB
// register address outputs
   always @ (posedge clk) begin
     if (rst_r) begin
         mi_mc_add_val_r     <= #TCQ 1'd0;
         mi_mc_add_val_r1    <= #TCQ 1'd0;
         mi_mc_add_c_r       <= #TCQ 36'd0;
	 mi_mc_add_c_r1      <= #TCQ 36'd0;
         mi_mc_bank_conf_c_r <= #TCQ 1'd0;
         mi_mc_rd_c_r        <= #TCQ 1'd0;
         mi_mc_wr_c_r        <= #TCQ 1'd0;
         mi_mc_wr_rd_c_r     <= #TCQ 1'd0;
         mi_mc_row_conf_c_r  <= #TCQ 1'd0;
         mi_mc_conflict_r    <= #TCQ 1'd0;
	 wrdata_val_r        <= #TCQ 1'd0;
	 wrdata_val_r1       <= #TCQ 1'd0;
	 wrdata_val_r2       <= #TCQ 1'd0;
	 wrdata_val_r3       <= #TCQ 1'd0;
     end else begin // if (rst)
         mi_mc_add_val_r     <= #TCQ mi_mc_add_val;
         mi_mc_add_val_r1    <= #TCQ mi_mc_add_val_r;
         mi_mc_add_c_r       <= #TCQ mi_mc_add_c;
	 mi_mc_add_c_r1      <= #TCQ mi_mc_add_c_r;
         mi_mc_bank_conf_c_r <= #TCQ mi_mc_bank_conf_c;
         mi_mc_rd_c_r        <= #TCQ mi_mc_rd_c;
         mi_mc_wr_c_r        <= #TCQ mi_mc_wr_c;
         mi_mc_wr_rd_c_r     <= #TCQ mi_mc_rd_c | mi_mc_wr_c;
         mi_mc_row_conf_c_r  <= #TCQ mi_mc_row_conf_c;
         mi_mc_conflict_r    <= #TCQ (mi_mc_bank_conf || mi_mc_row_conf)
                                      && mi_mc_add_val;
	 wrdata_val_r        <= #TCQ mi_mcwritedatavalid;
	 wrdata_val_r1       <= #TCQ wrdata_val_r;
	 wrdata_val_r2       <= #TCQ wrdata_val_r1;
	 wrdata_val_r3       <= #TCQ wrdata_val_r2;

     end // else: !if(rst)
   end // always @ (posedge clk0)



  //***************************************************************************
  // Bank management logic
  // Semi-hardcoded for now for 4 banks
  // will keep multiple banks open if MULTI_BANK_EN is true.
  //***************************************************************************

   assign af_addr_bank_cmp = mi_mc_add_c[CS_RANGE_END:BANK_RANGE_START];
   assign af_addr_row_cmp  = mi_mc_add_c[ROW_RANGE_END:ROW_RANGE_START];

   genvar bank_i;
   generate 
   for (bank_i = 0; bank_i < OPEN_BANK_NUM;
         bank_i = bank_i + 1) begin: gen_bank_hit
      // asserted if bank address match + open bank entry is valid
      always @(posedge clk) begin
        bank_hit_r[bank_i]
          <= #TCQ ((bank_cmp_addr_r[(CMP_WIDTH*(bank_i+1))-1:(CMP_WIDTH*bank_i)+ROW_WIDTH] == af_addr_bank_cmp) && bank_valid_r[bank_i]);
        // asserted if row address match (no check for bank entry valid, rely
        // on this term to be used in conjunction with BANK_HIT[])
        row_miss_r[bank_i]
          <= #TCQ (bank_cmp_addr_r[(CMP_WIDTH*bank_i)+ROW_WIDTH-1:(CMP_WIDTH*bank_i)] != af_addr_row_cmp);
        end
    end // block: gen_bank_hit
   endgenerate
   

   always @(posedge clk) begin
      bank_hit_any_r       <= #TCQ | bank_hit_r;
      no_precharge_wait_r  <= #TCQ bank_valid_r[3] & ~(|bank_hit_r);
      bank_conf_r          <= #TCQ bank_conf;
      conflict_detect_r    <= #TCQ mi_mc_bank_conf_c|| mi_mc_row_conf_c;
    end                        


    always @(*) begin
      // If there's a spare open bank: then don't need to precharge after
      // the current burst, we can keep that row open. Otherwise, if the
      // max # of banks are open, then we do need to precharge at the end
      // of the current burst (since that address gets kicked out of the
      // open bank list), but we don't need to wait at the end of that
      // precharge, because the next activate command will be to a
      // different bank
      no_precharge_r = conflict_detect_r & ~bank_valid_r[3] & ~(|bank_hit_r);
      bank_conf      = conflict_detect_r;
      case ({conflict_detect_r, bank_hit_r})
        // first four cases check cover case when we've already matched
        // banks. Now check to see if row matches as well. If not, then we
        // have a conflict - need to precharge, and kick out the old address.
        // Otherwise, if the row matches, we don't have a conflict, since
        // that bank/row is already open
        5'b10001:
          bank_conf = row_miss_r[0];
        5'b10010:
          bank_conf = row_miss_r[1];
        5'b10100:
          bank_conf = row_miss_r[2];
        5'b11000:
          bank_conf = row_miss_r[3];
      endcase
    end

      // synthesis attribute max_fanout of bank_cmp_addr_r is 1
    always @(posedge clk) begin
      // Clear all bank valid bits during AR (i.e. since all banks get
      // precharged during auto-refresh)
      if (rst_r || (state_r1 == CTRL_AUTO_REFRESH)) begin
        bank_valid_r    <= #TCQ {(OPEN_BANK_NUM-1){1'b0}};
        bank_cmp_addr_r <= #TCQ {(OPEN_BANK_NUM*CMP_WIDTH-1){1'b0}};
      end else begin
        if (state_r == CTRL_ACTIVE) begin
          // 00 is always going to have the latest bank and row.
          bank_cmp_addr_r[CMP_WIDTH-1:0] <= #TCQ mi_mc_add_c_r[CS_RANGE_END:ROW_RANGE_START];
          // This indicates the bank was activated
          bank_valid_r[0] <= #TCQ 1'b1;

          // Check to see where bank hit occurred, and handle new locations
          // of the various banks.

          case({bank_hit_r[2:0]})
                    3'b001:begin      
                       bank_cmp_addr_r[CMP_WIDTH-1:0] <= #TCQ mi_mc_add_c_r[CS_RANGE_END:ROW_RANGE_START];
                       // This indicates the bank was activated
                       bank_valid_r[0] <= #TCQ 1'b1;
                    end                    
                    3'b010: begin //(b0->b1)
                       bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH] <= #TCQ bank_cmp_addr_r[CMP_WIDTH-1:0];
                       bank_valid_r[1] <= #TCQ bank_valid_r[0];
                    end
                    3'b100:begin //(b0->b1, b1->b2)
                       bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH] <= #TCQ bank_cmp_addr_r[CMP_WIDTH-1:0];
                       bank_cmp_addr_r[(3*CMP_WIDTH)-1:2*CMP_WIDTH] <= #TCQ bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH];
                       bank_valid_r[1] <= #TCQ bank_valid_r[0];
                       bank_valid_r[2] <= #TCQ bank_valid_r[1];
                    end
                    default: begin //(b0->b1, b1->b2, b2->b3)
                       bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH] <= #TCQ bank_cmp_addr_r[CMP_WIDTH-1:0];
                       bank_cmp_addr_r[(3*CMP_WIDTH)-1:2*CMP_WIDTH] <= #TCQ bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH];
                       bank_cmp_addr_r[(4*CMP_WIDTH)-1:3*CMP_WIDTH] <= #TCQ bank_cmp_addr_r[(3*CMP_WIDTH)-1:2*CMP_WIDTH];
                       bank_valid_r[1] <= #TCQ bank_valid_r[0];
                       bank_valid_r[2] <= #TCQ bank_valid_r[1];
                       bank_valid_r[3] <= #TCQ bank_valid_r[2];
                    end // case: default
                 endcase
              end // if (state_r1 == CTRL_ACTIVE)
          
            end // else: !if((state_r1 == CTRL_AUTO_REFRESH))
        
         end // always @ (posedge clk)
	   

   
  //***************************************************************************
  // Change of direction detection
  // whener there is a change in direction (read-> write or write-> read)
  // this signal will vbe asserted
  //***************************************************************************
   always @ (posedge clk) begin
     if (rst_r) begin
         change_direction_r <= #TCQ 1'dx;    
     end else begin
   	 change_direction_r <= #TCQ (mi_mc_rd_c && 
                                ((state_r == CTRL_BURST_WRITE) || 
                                  (wr_to_rd_cnt_r >0))) || 
                                (mi_mc_wr_c && 
                                ((state_r == CTRL_BURST_READ)
                                  || (rd_to_wr_cnt_r > 0)));
     end // else: !if(rst)
   end // always @ (posedge clk)


  //***************************************************************************
  // Reg conflits for use in state machine 
  //***************************************************************************  

   always @ (posedge clk) begin
      mi_mc_conf_r  <= #TCQ mi_mc_conflict_r;
      mi_mc_conf_r1 <= #TCQ mi_mc_conf_r;
      mi_mc_conf_r2 <= #TCQ mi_mc_conf_r1 ||  mi_mc_conflict_r;
   end // always @ (posedge clk)


  //***************************************************************************
  // Address ready to accept logic
  // This signal will be asserted when the controller 
  // is ready to accept commands
  //***************************************************************************  
   always @ (posedge clk) begin
      if (rst_r) 
         mc_mi_addr_rdy_accpt_count_r <= #TCQ 8'd15;
      else begin
            if(~phy_init_done_r || auto_ref_r || (state_r == CTRL_PRECHARGE))
   	       mc_mi_addr_rdy_accpt_count_r <= #TCQ 8'd9;
	    else if (state_r1 == CTRL_ACTIVE)
	       mc_mi_addr_rdy_accpt_count_r <= #TCQ rcd_cnt_r+2;
	    else if (state_r == CTRL_AUTO_REFRESH_WAIT)
	       mc_mi_addr_rdy_accpt_count_r <= #TCQ rfc_cnt_r+5;
            else if ((state_r == CTRL_BURST_READ)
                      || (state_r == CTRL_BURST_WRITE))
	       mc_mi_addr_rdy_accpt_count_r <= #TCQ BURST_LEN_DIV2;
	    else if (mc_mi_addr_rdy_accpt_count_r > 8'd0)
	       mc_mi_addr_rdy_accpt_count_r <= #TCQ mc_mi_addr_rdy_accpt_count_r-1;
      end // else: !if(rst)
   end // always @ (posedge clk)


   always @ (posedge clk) begin
 // Added rd_mod_wr to de-assert mc_mi_addr_rdy_accpt_r signal
// during Read Modify Write to prevent MCI from sending additional commands 
      if (rst_r || rmw_flag || rd_mod_wr_r)
           mc_mi_addr_rdy_accpt_r <= #TCQ 1'd0;
      else if((mc_mi_addr_rdy_accpt_count_r <=8'd3) && 
             (~(change_direction_r || bank_conf )))
           mc_mi_addr_rdy_accpt_r <= #TCQ 1'd1;
      else
           mc_mi_addr_rdy_accpt_r <= #TCQ 1'd0;
   end // always @ (posedge clk)


   assign    mc_mi_addr_rdy_accpt = mc_mi_addr_rdy_accpt_r;

   always @ (posedge clk) begin
      if (rst_r)begin
           mc_mi_addr_rdy_accpt_r1 <= #TCQ 1'dx;
         end
      else begin
           mc_mi_addr_rdy_accpt_r1 <= #TCQ mc_mi_addr_rdy_accpt_r;
         end
   end


 
  //***************************************************************************
  // Timing counters
  //***************************************************************************

  //*****************************************************************
  // Write and read enable generation for PHY
  //*****************************************************************

  // write burst count. Counts from (BL/2 to 1).
  // Also logic for controller write enable.
  always @(posedge clk)begin
    if (rst_r) begin
      ctrl_wren_r   <= #TCQ 1'b0;
      wrburst_cnt_r <= #TCQ 3'b000;
    end else if ((state_r == CTRL_BURST_WRITE) || (rmw_state_r == RMW_WRITE)) 
    begin
      ctrl_wren_r   <= #TCQ 1'b1;
      wrburst_cnt_r <= #TCQ BURST_LEN_DIV2;
    end else if (wrburst_cnt_r == 3'd1)
      ctrl_wren_r   <= #TCQ 1'b0;
    else
      wrburst_cnt_r <= #TCQ wrburst_cnt_r - 1;
  end // always @ (posedge clk)

  always @(posedge clk)begin
    if (wrburst_cnt_r <= 3'd3)
      wrburst_ok_r <= #TCQ 1'b1;
    else
      wrburst_ok_r <= #TCQ 1'b0;
  end

  // read burst count. Counts from (BL/2 to 1)
  always @(posedge clk)begin
    if (rst_r) begin
      ctrl_rden     <= #TCQ 1'b0;
      rdburst_cnt_r <= #TCQ 3'b000;
    end else if ((state_r == CTRL_BURST_READ) || (rmw_state_r == RMW_READ)) 
    begin
      ctrl_rden     <= #TCQ 1'b1;
      rdburst_cnt_r <= #TCQ BURST_LEN_DIV2;
    end else if (rdburst_cnt_r == 3'd1)
      ctrl_rden   <= #TCQ 1'b0;
    else if (rdburst_cnt_r == 3'd0)
      rdburst_cnt_r <= #TCQ 3'd0;
    else
      rdburst_cnt_r <= #TCQ rdburst_cnt_r - 1;
  end // always @ (posedge clk)

  always @(posedge clk)begin
    if (rdburst_cnt_r <= 3'd3)
      rdburst_ok_r <= #TCQ 1'b1;
    else
      rdburst_ok_r <= #TCQ 1'b0;
  end

  //*****************************************************************
  // Various delay counters
  //*****************************************************************

  // tRP count - precharge command period
  always @(posedge clk)begin
    if (state_r == CTRL_PRECHARGE)
      rp_cnt_r <= #TCQ TRP_COUNT;
    else if (rp_cnt_r != 3'd0)
      rp_cnt_r <= #TCQ rp_cnt_r - 1;
  end

   always @(posedge clk)begin
    if (state_r == CTRL_PRECHARGE)
      rp_cnt_ok_r <= #TCQ 1'd0;
// changed from 1 to 3 based on MIG2.0 code
    else if (rp_cnt_r <= 3'd3)
      rp_cnt_ok_r <= #TCQ 1'd1;
  end

  // tRFC count - refresh-refresh, refresh-active
  always @(posedge clk)begin
    if (state_r == CTRL_AUTO_REFRESH)
      rfc_cnt_r <= #TCQ TRFC_COUNT;
    else if (rfc_cnt_r != 8'd0)
      rfc_cnt_r <= #TCQ rfc_cnt_r - 1;
  end

    always @(posedge clk)begin
     if (state_r == CTRL_AUTO_REFRESH)
        rfc_ok_r <= #TCQ 1'b0;
// changed from 1 to 3 based on MIG2.0 code
     else if(rfc_cnt_r <= 8'd3) 
        rfc_ok_r <= #TCQ 1'b1;
  end

  // tRCD count - active to read/write
  always @(posedge clk)begin
    if (state_r == CTRL_ACTIVE)
      rcd_cnt_r <= #TCQ TRCD_COUNT;
    else if (rcd_cnt_r != 3'd0)
      rcd_cnt_r <= #TCQ rcd_cnt_r - 1;
  end

   always @(posedge clk)begin
     if (state_r == CTRL_ACTIVE)
        rcd_cnt_ok_r <= #TCQ 1'd0;
// changed from 1 to 3 based on MIG2.0 code
     else if (rcd_cnt_r <= 3'd3) 
        rcd_cnt_ok_r <= #TCQ 1'd1;
  end

  // tRAS count - active to precharge
  always @(posedge clk)begin
    if (rst_r)
      ras_cnt_r <= #TCQ 4'd0;
    else if (state_r == CTRL_ACTIVE)
      ras_cnt_r <= #TCQ TRAS_COUNT;
    else if (ras_cnt_r != 4'd0)
      ras_cnt_r <= #TCQ ras_cnt_r - 1;
  end

  always @(posedge clk)begin
    if (state_r == CTRL_ACTIVE)
      ras_ok_r <= #TCQ 1'b0;
// changed from 1 to 3 based on MIG2.0 code
    else if(ras_cnt_r <= 4'd3) 
      ras_ok_r <= #TCQ 1'b1;
  end  

  // tRTP count - read to precharge
  always @(posedge clk)begin
    if (rst_r)
      rtp_cnt_r <= #TCQ 5'd0;
    else if (state_r == CTRL_BURST_READ)
      rtp_cnt_r <= #TCQ TRTP_COUNT;
    else if (rtp_cnt_r != 5'd0)
      rtp_cnt_r <= #TCQ rtp_cnt_r - 1;
  end

  always @(posedge clk)begin
    if (state_r == CTRL_BURST_READ)
      rtp_ok_r <= #TCQ 1'd0;
// changed from 1 to 3 based on MIG2.0 code
    else if(rtp_cnt_r <= 5'd3)
      rtp_ok_r <= #TCQ 1'd1;
  end

  // wtp count - write to precharge
  always @(posedge clk)begin
    if (rst_r)
      wtp_cnt_r <= #TCQ 5'd0;
    else if (state_r == CTRL_BURST_WRITE)
      wtp_cnt_r <= #TCQ TWR_COUNT;
    else if (wtp_cnt_r != 5'd0)
      wtp_cnt_r <= #TCQ wtp_cnt_r - 1;
  end

  always @(posedge clk)begin
    if (state_r == CTRL_BURST_WRITE)
      wtp_ok_r <= #TCQ 1'd0;
// changed from 1 to 3 based on MIG2.0 code
    else if (wtp_cnt_r <= 5'd3)
      wtp_ok_r <= #TCQ 1'd1;
  end

  // write to read counter
  // write to read includes : write latency + burst time + tWTR
  always @(posedge clk)begin
    if (state_r == CTRL_BURST_WRITE)
//changed from (TWTR_COUNT + BURST_LEN_DIV2 + CAS_LAT); based on MIG controller
      wr_to_rd_cnt_r <= #TCQ TWTR_COUNT; 
    else if (wr_to_rd_cnt_r != 5'd0)
      wr_to_rd_cnt_r <= #TCQ wr_to_rd_cnt_r - 1;
    else
      wr_to_rd_cnt_r <= #TCQ 5'd0;
  end

  always @(posedge clk)begin
    if (state_r == CTRL_BURST_WRITE)
      wr_to_rd_ok_r <= #TCQ 1'd0;
// changed from 1 to 3 based on MIG2.0 code
    else if (wr_to_rd_cnt_r <= 5'd3)
      wr_to_rd_ok_r <= #TCQ 1'd1;
  end
   

  // read to write counter
  always @(posedge clk)begin
    if ((state_r == CTRL_BURST_READ) || (rmw_state_r == RMW_READ))
    // Removed REG_ENABLE parameter and chnaged 2 to 3 based on MIG controller
      rd_to_wr_cnt_r <= #TCQ TRTW_COUNT;
    else if (rd_to_wr_cnt_r != 4'd0)
      rd_to_wr_cnt_r <= #TCQ rd_to_wr_cnt_r - 1;
    else
      rd_to_wr_cnt_r <= #TCQ 4'd0;
  end

  always @(posedge clk)begin
    if ((state_r == CTRL_BURST_READ) || (rmw_state_r == RMW_READ))
      rd_to_wr_ok_r <= #TCQ 1'd0;
// changed from 1 to 3 based on MIG2.0 code
    else if (rd_to_wr_cnt_r <= 4'd3)
      rd_to_wr_ok_r <= #TCQ 1'd1;
  end
   

  // auto refresh interval counter in refresh_clk domain
  always @(posedge clk)
    if (rst_r) begin
      refi_cnt_r <= #TCQ 12'd0;
      ref_flag_r <= #TCQ 1'b0;
// Added rmw_flag assertion condition to issue Auto Refresh command before Read
// Modify Write operation begins. This is done to avoid interrupting Read 
// Modify Write operation with an Auto Refresh.
    end else if ((refi_cnt_r == TREFI_COUNT) 
                  || (rmw_flag  && ~rmw_flag_r && (refi_cnt_r >= TREFI_COUNT - 60))) 
    begin
      refi_cnt_r <= #TCQ 12'd0;
      ref_flag_r <= #TCQ 1'b1;
    end else begin
      refi_cnt_r <= #TCQ refi_cnt_r + 1;
      ref_flag_r <= #TCQ 1'b0;
    end

  assign ctrl_ref_flag = ref_flag_r;

  //refresh flag detect
  //auto_ref high indicates auto_refresh requirement
  //auto_ref is held high until auto refresh command is issued.
  always @(posedge clk)
    if (ref_flag_r && phy_init_done_r)
      auto_ref_r <= #TCQ 1'b1;
    else if ((state_r == CTRL_AUTO_REFRESH)|| rst_r)
      auto_ref_r <= #TCQ 1'b0;

   always @(posedge clk)begin
      if(rst_r) begin
        auto_ref_r1 <= #TCQ 1'd0;
        auto_ref_r2 <= #TCQ 1'd0;
        auto_ref_r3 <= #TCQ 1'd0;
        auto_ref_r4 <= #TCQ 1'd0;  
        auto_ref_r5 <= #TCQ 1'd0;      
      end else if (state_r == CTRL_AUTO_REFRESH)begin
        auto_ref_r1 <= #TCQ 1'd0;
        auto_ref_r2 <= #TCQ 1'd0;
        auto_ref_r3 <= #TCQ 1'd0;
        auto_ref_r4 <= #TCQ 1'd0;  
        auto_ref_r5 <= #TCQ 1'd0;      
     end else begin
        auto_ref_r1 <= #TCQ auto_ref_r;
        auto_ref_r2 <= #TCQ auto_ref_r1;
        auto_ref_r3 <= #TCQ auto_ref_r2;
        auto_ref_r4 <= #TCQ auto_ref_r3;
        auto_ref_r5 <= #TCQ auto_ref_r4;
     end 
   end       

  // keep track of which chip selects got auto-refreshed (avoid auto-refreshing
  // all CS's at once to avoid current spike)
  always @(posedge clk)
    if (rst_r || (state_r == CTRL_PRECHARGE))
      auto_cnt_r <= #TCQ 3'd0;
    else if (state_r == CTRL_AUTO_REFRESH)
      auto_cnt_r <= #TCQ auto_cnt_r + 1;

  // register for timing purposes. Extra delay doesn't really matter
  always @(posedge clk) begin
    phy_init_done_r <= #TCQ phy_init_done;
    rd_cmd_r        <= #TCQ rd_cmd;
    delay_cmd_r     <= #TCQ delay_cmd;
  end
  
  always @ (posedge clk) begin
    if (state_r == CTRL_COMMAND_WAIT)
      delay_write <= #TCQ delay_cmd;
    else
      delay_write <= #TCQ 1'b0;
  end 
   
  always @(posedge clk)
    if (rst_r) begin
      state_r  <= #TCQ CTRL_IDLE;
      state_r1 <= #TCQ CTRL_IDLE;
    end else begin
      state_r  <= #TCQ next_state;
      state_r1 <= #TCQ state_r;
    end
    
    
  //***************************************************************************
  // Read Modify Write State Machine
  //***************************************************************************

assign ctrl_rmw_done  = rmw_done_180r;

assign rd_mod_wr_flag = rmw_done_r ? 1'b0 : (rmw_flag && (state_r == CTRL_COMMAND_WAIT)) ? 1'b1 : 
                        rd_mod_wr_r;

assign rd_mod_wr = rd_mod_wr_r;
                        

  always @(posedge clk) begin
    if (rst_r) begin
      rd_mod_wr_r  <= #TCQ 1'b0;
      rd_mod_wr_r1 <= #TCQ 1'b0;
      rmw_flag_r   <= #TCQ 1'b0;
      ctrl_rmw_data_sel  <= #TCQ 1'b0;
    end else begin
      rd_mod_wr_r <= #TCQ rd_mod_wr_flag;
      rd_mod_wr_r1 <= #TCQ rd_mod_wr_r;
      rmw_flag_r  <= #TCQ rmw_flag;
      ctrl_rmw_data_sel <= #TCQ rd_mod_wr_r & (rmw_state_r != 3'd1);
    end
  end // always @ (posedge clk)

  always @ (posedge clk) begin
    if (rst_r || (rmw_state_r != 3'd4))
      rmw_state_flag <= #TCQ 1'd0;
    else if (rd_to_wr_ok_r)
      rmw_state_flag <= #TCQ 1'd1;
  end

  always @ (posedge clk) begin
    if (rst_r || (rmw_state_r != 3'd2) || ~rd_mod_wr_r)
      rmw_state2_flag <= #TCQ 1'd0;
    else if (rmw_state_r == 3'd2)
      rmw_state2_flag <= #TCQ 1'd1;
  end
  
  always @(negedge clk) begin
    if (rst_180r)
      rmw_done_180r     <= #TCQ 1'b0;
    else
      rmw_done_180r <= #TCQ rmw_done;
  end
  
  always @(posedge clk) begin
    if (rst_r)
      rmw_state_r    <= #TCQ RMW_IDLE;
    else
      rmw_state_r    <= #TCQ rmw_next_state;
  end

  always @ (posedge clk) begin
    if (rst_r)begin
      rmw_done_r     <= #TCQ 1'b0;
      wdf_rden_out_r <= #TCQ 1'b0;
      wdf_rden_r     <= #TCQ 1'b0;
    end else begin
      rmw_done_r     <= #TCQ rmw_done;
      wdf_rden_out_r <= #TCQ wdf_rden_out;
      wdf_rden_r     <= #TCQ wdf_rden;
    end
  end

  SRLC32E rmw_done_srl
        (
         .Q   (wdf_rden_out),
         .Q31 (),
         .A   (5'b00101),
         .CE  (1'b1),
         .CLK (clk),
         .D   (wdf_rden)
         );
      
  
  always @ (*) begin
    rmw_next_state = rmw_state_r;
    rmw_done       = rmw_done_r;
    
    case (rmw_state_r)
    
      RMW_IDLE: begin
	        rmw_done       = 1'b0;
                if (rd_mod_wr_r1 && ~auto_ref_r && state_r == CTRL_COMMAND_WAIT)
                  rmw_next_state = RMW_READ;
                else
                  rmw_next_state = RMW_IDLE;
                end
      RMW_READ: begin
                rmw_next_state = RMW_READ_WAIT;
	        rmw_done       = 1'b0;
                end
      RMW_READ_WAIT: begin
// issue a write command only after 
//data is ready to be read out of the RMW_DATA_FIFO
	             rmw_done       = 1'b0;
                     if (rdburst_ok_r && rd_to_wr_ok_r && rmw_wr_data_rdy)
                       rmw_next_state = RMW_WRITE;
                     end
      RMW_WRITE: begin
                 rmw_next_state = RMW_WRITE_WAIT;
	         rmw_done       = 1'b0;
                 end
      RMW_WRITE_WAIT: begin
	              if (wdf_rden_out_r)
	                rmw_done = 1'b1;
	              if (state_r == CTRL_WRITE_WAIT)
                        rmw_next_state = RMW_IDLE;
	              else
			rmw_next_state = RMW_WRITE_WAIT;
	              end
	 
    endcase // always @ (*)
  end	  
  

  //***************************************************************************
  // main control state machine
  //***************************************************************************
   
    
  always @(*) begin
    next_state = state_r;
    rd_cmd     = rd_cmd_r;
    delay_cmd  = delay_cmd_r;
   
    case (state_r)

      CTRL_IDLE: begin
        // stay in this state until initializaton/calibration done. Can
        // service auto refresh requests during this time as well 
        if (phy_init_done_r)
          if (auto_ref_r)
            next_state = CTRL_PRECHARGE;
          else if (mi_mc_wr_c_r  || mi_mc_rd_c_r )
            next_state = CTRL_ACTIVE;
      end

      CTRL_PRECHARGE: begin
        if (auto_ref_r)
          next_state = CTRL_PRECHARGE_WAIT1;
        // when precharging an LRU bank, do not have to go to wait state
        // since we can't possibly be activating row in same bank next
        else if (no_precharge_wait_r)
          next_state = CTRL_ACTIVE;
        else
          next_state = CTRL_PRECHARGE_WAIT;
      end

      CTRL_PRECHARGE_WAIT:begin
        if (rp_cnt_ok_r)begin
          if (auto_ref_r5)
            // precharge again to make sure we close all the banks
            next_state = CTRL_PRECHARGE;
          else
            next_state = CTRL_ACTIVE;
	end
      end
      

      CTRL_PRECHARGE_WAIT1:begin
        if (rp_cnt_ok_r)
          next_state = CTRL_AUTO_REFRESH;
      end
      

      CTRL_AUTO_REFRESH:begin
        next_state = CTRL_AUTO_REFRESH_WAIT;
	 end

      CTRL_AUTO_REFRESH_WAIT:begin
        if (rfc_ok_r)
          next_state = CTRL_ACTIVE;
      end
      

      CTRL_ACTIVE:begin
	delay_cmd = mi_mc_wr_c_r;
        next_state = CTRL_ACTIVE_WAIT;
      end
      

      CTRL_ACTIVE_WAIT:begin	
	if((auto_ref_r5) && (ras_ok_r))
	  next_state = CTRL_PRECHARGE;
	// Added rd_mod_wr_r condition in case of Auto Refresh before
	// read modify write operation begins
	// Added rmw_flag condition when write with conflict and RMW
        else if (rcd_cnt_ok_r && (rmw_flag || rd_mod_wr_r 
                 || ((mi_mc_rd_c_r && wr_to_rd_ok_r)
                 || ((MIB_CLK_RATIO > 1 && mc_mi_addr_rdy_accpt_r1)
                 || (MIB_CLK_RATIO < 2 && mc_mi_addr_rdy_accpt_r)))))
          next_state = CTRL_COMMAND_WAIT;
      end
      

      CTRL_COMMAND_WAIT: begin
        if (auto_ref_r5 || bank_conf ) begin
	  if (ras_ok_r && wtp_ok_r && rtp_ok_r)
	    if (auto_ref_r5 || ~no_precharge_r)
              next_state = CTRL_PRECHARGE;
	    else
              next_state = CTRL_ACTIVE;
        end else if (mi_mc_rd_c_r  && ~mi_mc_conflict_r)
          next_state = CTRL_BURST_READ;
        else if (mi_mc_wr_c_r && (wrdata_val_r1 || delay_write))begin
              next_state = CTRL_BURST_WRITE;
	end
	 
      end    

      // beginning of write burst
      CTRL_BURST_WRITE:begin
	 next_state = CTRL_WRITE_WAIT;
	 rd_cmd = 1'd0;
         delay_cmd = 1'd0;
      end
      
                     
      CTRL_WRITE_WAIT: begin
	if (bank_conf || auto_ref_r5  || mi_mc_bank_conf_c || mi_mc_row_conf_c)
          next_state = CTRL_WRITE_BANK_CONF;
        // if current burst is finished, and another non-conflict write is
        // already queued up
        else if (mi_mc_wr_c && (wrburst_cnt_r <= 3'd2))
          next_state = CTRL_BURST_WRITE;
        // otherwise, if current write has completed, wait for wr-rd delay
        else if ((wrburst_ok_r) && (wr_to_rd_ok_r))
          next_state = CTRL_COMMAND_WAIT;
      end

      CTRL_BURST_READ:begin
	 next_state = CTRL_READ_WAIT;
	 rd_cmd = 1'd1;
         delay_cmd = 1'd0;
      end
      


      CTRL_READ_WAIT: begin
        if (bank_conf || auto_ref_r5 || mi_mc_conflict_r)
          next_state = CTRL_READ_BANK_CONF;
        else if (mi_mc_rd_c && (rdburst_cnt_r <= 3'd2))
          next_state = CTRL_BURST_READ;
        else if ((rdburst_ok_r) && (rd_to_wr_ok_r))
          next_state = CTRL_COMMAND_WAIT;
      end

      CTRL_WRITE_BANK_CONF: begin
        if (auto_ref_r5) begin
          if((wtp_ok_r) && (ras_ok_r))
            next_state = CTRL_PRECHARGE;
        end else if (bank_conf || mi_mc_conflict_r) begin
          if (no_precharge_r)
            next_state = CTRL_ACTIVE;
          else if ((wtp_ok_r) && (ras_ok_r))
            next_state = CTRL_PRECHARGE;
        end else if (mi_mc_wr_c  && ~mi_mc_conflict_r && wrdata_val_r1
                     && (wrburst_cnt_r <= 3'd2))
          next_state = CTRL_BURST_WRITE;
        else if (wr_to_rd_ok_r)
          next_state = CTRL_COMMAND_WAIT;
      end

      CTRL_READ_BANK_CONF: begin
        if (auto_ref_r5) begin
          if ((rtp_ok_r) && (ras_ok_r))
            next_state = CTRL_PRECHARGE;
        end else if (bank_conf || mi_mc_conflict_r) begin
          if (no_precharge_r)
             next_state = CTRL_ACTIVE;
          else if ((rtp_ok_r) && (ras_ok_r))
            next_state = CTRL_PRECHARGE;
        end else if (mi_mc_rd_c  && ~mi_mc_conflict_r
                    && (rdburst_cnt_r <= 3'd2))
          next_state = CTRL_BURST_READ;
        else if ((rd_to_wr_ok_r))
          next_state = CTRL_COMMAND_WAIT;
      end

    endcase
  end

  //***************************************************************************
  // control signals to memory
  //***************************************************************************

  always @(posedge clk)
    if ((state_r == CTRL_AUTO_REFRESH) ||
        (state_r == CTRL_ACTIVE) ||
        (state_r == CTRL_PRECHARGE))
      ddr_ras_n_r <= #TCQ 1'b0;
    else
      ddr_ras_n_r <= #TCQ 1'b1;

  always @(posedge clk)
    if ((rmw_state_r == RMW_READ) || (rmw_state_r == RMW_WRITE)
        || (state_r == CTRL_BURST_WRITE)
        || (state_r == CTRL_BURST_READ)
        || (state_r == CTRL_AUTO_REFRESH))
      ddr_cas_n_r <= #TCQ 1'b0;
    else
      ddr_cas_n_r <= #TCQ 1'b1;

  always @(posedge clk)
    if ((rmw_state_r == RMW_WRITE) || (state_r == CTRL_BURST_WRITE)
       || (state_r == CTRL_PRECHARGE))
      ddr_we_n_r <= #TCQ 1'b0;
    else
      ddr_we_n_r <= #TCQ 1'b1;

  // turn off auto-precharge when issuing commands (A10 = 0)
  // mapping the col add for linear addressing.

  generate
    if (COL_WIDTH == ROW_WIDTH-1) begin: gen_ddr_addr_col_0
      assign ddr_addr_col = {mi_mc_add_c_r[COL_RANGE_END:10], 1'b0,
                             mi_mc_add_c_r[9:COL_RANGE_START]};
    end
    else if (COL_WIDTH > 10) begin: gen_ddr_addr_col_1
      assign ddr_addr_col = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}},
                             mi_mc_add_c_r[COL_RANGE_END:10], 1'b0,
                             mi_mc_add_c_r[9:COL_RANGE_START]};
    end else begin: gen_ddr_addr_col_2
      assign ddr_addr_col = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}}, 1'b0,
                             mi_mc_add_c_r[COL_RANGE_END:COL_RANGE_START]};
    end
  endgenerate

  // Assign address during row activate
  assign ddr_addr_row = mi_mc_add_c_r[ROW_RANGE_END:ROW_RANGE_START];

  always @(posedge clk)
    if ((state_r == CTRL_ACTIVE))
      ddr_addr_r <= #TCQ ddr_addr_row;
    else if ((rmw_state_r == RMW_READ) || (rmw_state_r == RMW_WRITE)
              || (state_r == CTRL_BURST_WRITE)
              || (state_r == CTRL_BURST_READ))
      ddr_addr_r <= #TCQ ddr_addr_col;
    else if ((state_r == CTRL_PRECHARGE) && auto_ref_r) begin
      // if we're precharging as a result of AUTO-REFRESH, precharge all banks
      ddr_addr_r <= #TCQ {ROW_WIDTH{1'b0}};
      ddr_addr_r[10] <= #TCQ 1'b1;
    end else if (state_r == CTRL_PRECHARGE)
      // if we're precharging to close a specific bank/row, set A10=0
      ddr_addr_r <= #TCQ {ROW_WIDTH{1'b0}};
    else
      ddr_addr_r <= #TCQ {ROW_WIDTH{1'bx}};

  always @(posedge clk)
    // whenever we're precharging, we're either: (1) precharging all banks (in
    // which case banks bits are don't care, (2) precharging the LRU bank,
    // b/c we've exceeded the limit of # of banks open (need to close the LRU
    // bank to make room for a new one), (3) we haven't exceed the maximum #
    // of banks open, but we trying to open a different row in a bank that's
    // already open
    if ((state_r == CTRL_PRECHARGE) && bank_conf_r &&
        !bank_hit_any_r)
      // When LRU bank needs to be closed
      ddr_ba_r <= #TCQ bank_cmp_addr_r[(3*CMP_WIDTH)+CMP_BANK_RANGE_END:
                                  (3*CMP_WIDTH)+CMP_BANK_RANGE_START];
    else
      // Either precharge due to refresh or bank hit case
      ddr_ba_r <= #TCQ mi_mc_add_c_r[BANK_RANGE_END:BANK_RANGE_START];

  // chip enable generation logic
  generate
    // if only one chip select, always assert it after reset
    if (CS_BITS == 0) begin: gen_ddr_cs_0
      always @(posedge clk)
        if (rst_r)
          ddr_cs_n_r[0] <= #TCQ 1'b1;
        else
          ddr_cs_n_r[0] <= #TCQ 1'b0;
    // otherwise if we have multiple chip selects
    end else begin: gen_ddr_cs_1
      always @(posedge clk)
        if (rst_r)
          ddr_cs_n_r <= #TCQ {CS_NUM{1'b1}};
        else if (state_r == CTRL_AUTO_REFRESH) begin
          // if auto-refreshing, only auto-refresh one CS at any time (avoid
          // beating on the ground plane by refreshing all CS's at same time)
          ddr_cs_n_r <= #TCQ {CS_NUM{1'b1}};
          ddr_cs_n_r[auto_cnt_r] <= #TCQ 1'b0;
        end else if ((state_r == CTRL_PRECHARGE) && bank_conf_r &&
                     !bank_hit_any_r) begin
          // precharging the LRU bank
          ddr_cs_n_r <= #TCQ {CS_NUM{1'b1}};
          ddr_cs_n_r[bank_cmp_addr_r[(3*CMP_WIDTH)+CMP_CS_RANGE_END:
                                 (3*CMP_WIDTH)+CMP_CS_RANGE_START]] <= #TCQ 1'b0;
        end else begin
          // otherwise, check the upper address bits to see which CS to assert
          ddr_cs_n_r <= #TCQ {CS_NUM{1'b1}};
          ddr_cs_n_r[mi_mc_add_c_r[CS_RANGE_END:CS_RANGE_START]] <= #TCQ 1'b0;
        end
    end
  endgenerate

  generate
  if(ECC_ENABLE) begin

    always @ (posedge clk)begin
      if (rst_r || ~rmw_flag)
	rmw_wr_flag_r <= #TCQ 1'd0;
      else if (rmw_wr_flag_w)
        rmw_wr_flag_r <= #TCQ rmw_flag;
    end

    always @ (posedge clk)
      ctrl_wren_r1 <= #TCQ ctrl_wren_r;

    always @ (posedge clk)begin
      if (rst_r)begin
	rmw_disable_r  <= #TCQ 1'b0;
        rmw_disable_r1 <= #TCQ 1'b0;
      end
      else if (BURST_LEN == 4)begin
	rmw_disable_r  <= #TCQ rmw_disable;
	rmw_disable_r1 <= #TCQ rmw_disable_r;
      end
    end
   
    assign ctrl_rmw_disable = rmw_disable_r1;
    assign rmw_disable = (((rmw_flag  && ~rmw_flag_r)&& (wrdata_val_r2 || wrdata_val_r3)) ||
                         ((state_r == CTRL_ACTIVE_WAIT) && ~rmw_flag && delay_cmd_r)) ? 1'b1 :
                         ((state_r == CTRL_WRITE_WAIT) && (next_state != CTRL_BURST_WRITE)
                          && ~mi_mc_add_val_r && ~mi_mc_add_val_r1) ? 1'b0 : 
                          rmw_disable_r;
                         
       
    assign ctrl_cas_n = ((BURST_LEN == 4) && rmw_disable) ? ddr_cas_n_r : ((rmw_flag) && (rmw_wr_flag_w)) ? 1'd1 : ddr_cas_n_r;
    assign ctrl_we_n  = ((BURST_LEN == 4) && rmw_disable) ? ddr_we_n_r :((rmw_flag) && (rmw_wr_flag_w)) ? 1'd1 : ddr_we_n_r;
    assign ctrl_wren  = ((BURST_LEN == 4) && rmw_disable) ? ctrl_wren_r :((rmw_flag) && (rmw_wr_flag_w || rmw_wr_flag_r)) ? 1'd0 : ctrl_wren_r;
    assign rmw_wr_flag_w  = ctrl_wren_r & ~ddr_we_n_r;
    assign rmw_wr_flag  = rmw_wr_flag_w;
  end
  else begin
    assign ctrl_cas_n = ddr_cas_n_r;
    assign ctrl_we_n  = ddr_we_n_r;
    assign rmw_wr_flag  = 1'd0;
    assign ctrl_wren  = ctrl_wren_r;
  end
  endgenerate     
   
  assign ctrl_addr  = ddr_addr_r;
  assign ctrl_ba    = ddr_ba_r;
  assign ctrl_ras_n = ddr_ras_n_r;
  assign ctrl_cs_n  = ddr_cs_n_r;

endmodule

