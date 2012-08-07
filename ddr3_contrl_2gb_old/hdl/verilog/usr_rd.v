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
//  \   \         Filename: usr_rd.v
//  /   /         Date Last Modified:
// /___/   /\     Date Created: 8/29/06
// \   \  /  \
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   The delay between the read data with respect to the command issued is 
//   calculted in terms of no. of clocks. This data is then stored into the 
//   FIFOs and then read back and given as the ouput for comparison.
//Reference:
//Revision History:
//Assigned fifo_rden_r2 instead of fifo_rden_r3 to rd_data_valid
// due to change to synch FIFO. MG - 9/10/07
//*****************************************************************************

`timescale 1ps/1ps


module usr_rd #
  (
   parameter integer TCQ            = 100,
   parameter integer DQ_PER_DQS     = 8,
   parameter integer DQS_WIDTH      = 2,
   parameter integer READ_DATA_PIPELINE = 1,
   parameter integer APPDATA_WIDTH  = 128,
   parameter integer ECC_ENABLE     = 0
   )   
  (
   input                               clk90,
   input                               clk0,
   input                               rst90,
   input                               rst270,
   input                               rst0,
   input [(DQS_WIDTH*DQ_PER_DQS)-1:0]  rd_data_in_rise,
   input [(DQS_WIDTH*DQ_PER_DQS)-1:0]  rd_data_in_fall,
   input [DQS_WIDTH-1:0]               ctrl_rden,
   input [DQS_WIDTH-1:0]               phy_calib_rden_sel,
   input                               ctrl_rmw_data_sel,
   input                               wdf_rden_r,
   input [63:0]                        wdf_rmw_rise_data,
   input [63:0]                        wdf_rmw_fall_data,
   input [7:0]                         wdf_rmw_rise_mask,
   input [7:0]                         wdf_rmw_fall_mask,
   input                               rd_mod_wr,
   output                              rmw_rden,
   output [(DQS_WIDTH*DQ_PER_DQS)-1:0] rmw_data_out_rise,
   output [(DQS_WIDTH*DQ_PER_DQS)-1:0] rmw_data_out_fall,
   output  [1:0]                       rd_ecc_error,
   //output reg [1:0]                    rd_ecc_error,
   output                              rmw_wr_data_rdy,
   output                              rd_data_valid,
   output [(APPDATA_WIDTH/2)-1:0]      rd_data_out_rise,
   output [(APPDATA_WIDTH/2)-1:0]      rd_data_out_fall
   );
  
  // determine number of FIFO72's to use based on data width
  localparam RDF_FIFO_NUM = ((128/2)+63)/64; //APPDATA_WIDTH
  
  reg                  fifo_rden_r0;
  reg                  fifo_rden_r1;
  reg                  fifo_rden_r2;
  reg                  fifo_rden_r3;
  reg                  fifo_rden_r4;
  reg                  fifo_rden_r5;
  
  reg                  rmw_rden_r0;
  reg                  rmw_rden_r1;
  reg                  rmw_rden_r2;
  reg                  rmw_rden_r3;
  reg                  rmw_rden_r4;
  reg                  rmw_rden_r5;
  
  reg [DQS_WIDTH-1:0]  rden_sel_r;
  wire [DQS_WIDTH-1:0] rden_sel_mux;
  reg 		       rden_skew_r;
  reg [DQS_WIDTH-1:0]  ctrl_rden_r;
  reg [(DQS_WIDTH*DQ_PER_DQS)-1:0] rd_data_in_rise_r;
  reg [(DQS_WIDTH*DQ_PER_DQS)-1:0] rd_data_in_fall_r;
  wire 			   rden;
  wire [(DQS_WIDTH*DQ_PER_DQS)-1:0] rise_data;
  wire [(DQS_WIDTH*DQ_PER_DQS)-1:0] fall_data;
  wire [((RDF_FIFO_NUM -1) *2)+1:0] db_ecc_error;
  wire [((RDF_FIFO_NUM -1) *2)+1:0] sb_ecc_error;
  wire [0:63] 			    rmw_rise_data_in;
  wire [0:63] 			    rmw_fall_data_in;
  
 
  wire  data_valid;
  wire  data_valid_r1; 
  //***************************************************************************

  always @(posedge clk0) begin
     rden_sel_r        <= #TCQ phy_calib_rden_sel;
     rden_skew_r       <= #TCQ |phy_calib_rden_sel;
     ctrl_rden_r       <= #TCQ ctrl_rden;
     rd_data_in_rise_r <= #TCQ rd_data_in_rise;
     rd_data_in_fall_r <= #TCQ rd_data_in_fall;
  end


  // generate readenable
  // use only read enable 0. 
   assign rden = (rden_sel_r[0])?ctrl_rden[0]:ctrl_rden_r[0];
   
  // Instantiate primitive to allow this flop to be attached to multicycle
  // path constraint in UCF.
  genvar rd_i;
  generate 
    for (rd_i = 0; rd_i < DQS_WIDTH; rd_i = rd_i+1) begin: gen_rden_sel_mux
      FD u_ff_rden_sel_mux
        (
         .Q (rden_sel_mux[rd_i]),
         .C (clk0),
         .D (phy_calib_rden_sel[rd_i])
         ) /* synthesis syn_preserve=1 */;
    end
  endgenerate

// assign data based on the skew 

  genvar data_i;
  generate
    for(data_i = 0; data_i < DQS_WIDTH; data_i = data_i+1) begin: gen_data
       assign rise_data[(data_i*8)+7:(data_i*8)] = (rden_sel_mux[data_i])?rd_data_in_rise[(data_i*8)+7:(data_i*8)]
                                                     :rd_data_in_rise_r[(data_i*8)+7:(data_i*8)];
       assign fall_data[(data_i*8)+7:(data_i*8)] = (rden_sel_mux[data_i])?rd_data_in_fall[(data_i*8)+7:(data_i*8)]
                                                     :rd_data_in_fall_r[(data_i*8)+7:(data_i*8)];
end
endgenerate
		       


  // delay read valid to take into account maximum delay difference between
  // the read enable coming from the different DQS groups
  always @(posedge clk0) begin
    if (rst0) begin
      fifo_rden_r0 <= #TCQ 1'b0;
      fifo_rden_r1 <= #TCQ 1'b0;
      fifo_rden_r2 <= #TCQ 1'b0;
      fifo_rden_r3 <= #TCQ 1'b0;
      fifo_rden_r4 <= #TCQ 1'b0;
      fifo_rden_r5 <= #TCQ 1'b0;
    end else begin
      fifo_rden_r0 <= #TCQ rden;
      fifo_rden_r1 <= #TCQ fifo_rden_r0;
      fifo_rden_r2 <= #TCQ fifo_rden_r1;
      fifo_rden_r3 <= #TCQ fifo_rden_r2;
      fifo_rden_r4 <= #TCQ fifo_rden_r3;
      fifo_rden_r5 <= #TCQ fifo_rden_r4;
    end
  end // always @ (posedge clk)

  
  // Change to reverse bit order connecting to FIFO
  wire [0:(DQS_WIDTH*DQ_PER_DQS)-1]      tmp_rise_in, tmp_fall_in;
  wire [63:0]                            rmw_rise_data_out, rmw_fall_data_out;
  wire [7:0]                             rmw_rise_ecc_out, rmw_fall_ecc_out;
  wire [0:63]                            tmp_rmw_rise_data_out, tmp_rmw_fall_data_out;
  wire [0:7]                             tmp_rmw_rise_ecc_out, tmp_rmw_fall_ecc_out, tmp_wdf_rmw_rise_mask, tmp_wdf_rmw_fall_mask;
  wire                                   rmw_wren;
  wire [0:(APPDATA_WIDTH/2)-1]           tmp_rise_out, tmp_fall_out;
  wire [0:63] 				 tmp_rmw_rise_in, tmp_rmw_fall_in, tmp_wdf_rmw_rise_data, tmp_wdf_rmw_fall_data;
  reg  [0:63] 				 tmp_rmw_rise_in_r, tmp_rmw_fall_in_r, tmp_rmw_rise_in_r1, tmp_rmw_fall_in_r1, tmp_rmw_rise_in_r2, tmp_rmw_fall_in_r2;
  reg                                    ecc_inject_rise_err, ecc_inject_fall_err, ecc_inject_rise_err_270, ecc_inject_rise_err_90, ecc_inject_fall_err_270, ecc_inject_fall_err_90;
  wire [0:63]  bram_rise_in;
  wire [0:63]  bram_rise_out;
  wire [0:63]  bram_fall_in;
  wire [0:63]  bram_fall_out;

  
  
  generate
    genvar                               loop1;
    for (loop1 = 0; loop1 < (APPDATA_WIDTH/2); loop1 = loop1+1) begin : dataout_block
      assign rd_data_out_rise[loop1] = tmp_rise_out[loop1];
      assign rd_data_out_fall[loop1] = tmp_fall_out[loop1];
    end
  endgenerate

  // Additional pipeline stage for read data
  
  generate
    genvar                               loop2;
    genvar                               loop3;
    if (READ_DATA_PIPELINE == 1) begin : gen_read_data_pipedelay1
      for (loop2 = 0; loop2 < (DQS_WIDTH*DQ_PER_DQS); loop2 = loop2+1) begin : gen_read_data_fd_block
        FD u_ff_rise_in
          (
           .Q (tmp_rise_in[loop2]),
           .C (clk0),
           .D (rise_data[loop2])
           ) /* synthesis syn_preserve=1 */;
        FD u_ff_fall_in
          (
           .Q (tmp_fall_in[loop2]),
           .C (clk0),
           .D (fall_data[loop2])
           ) /* synthesis syn_preserve=1 */;
      end
    end
    else begin : gen_read_data_pipedelay0
      for (loop3 = 0; loop3 < (DQS_WIDTH*DQ_PER_DQS); loop3 = loop3+1) begin : gen_read_data_assign_block
        assign tmp_rise_in[loop3] = rise_data[loop3];
        assign tmp_fall_in[loop3] = fall_data[loop3];
      end
    end
  endgenerate
       
  // END Rick - SEG


  genvar rdf_i;
  genvar app_loop;
  genvar rmw_loop1;
  genvar rmw_loop2;
  genvar loop;
  genvar loop_ecc; 
  generate
  if(ECC_ENABLE) begin    // ECC code
  
  wire [0:(APPDATA_WIDTH/2)-1]    tmp_rise_fifo_out, tmp_fall_fifo_out;
  reg ctrl_rmw_data_sel_r;
  
  // read data is delayed by an additional cycle for each of:
  // ECC_ENABLE and READ_DATA_PIPELINE
  assign rd_data_valid = data_valid_r1 && (~ctrl_rmw_data_sel_r);
  assign data_valid = (READ_DATA_PIPELINE == 1) ? fifo_rden_r3 : fifo_rden_r2;
  assign data_valid_r1 = (READ_DATA_PIPELINE == 1) ? fifo_rden_r4 : fifo_rden_r3;

// Non registered version

    assign rd_ecc_error[0] = (READ_DATA_PIPELINE == 1) ? (|db_ecc_error) & fifo_rden_r4 : (|db_ecc_error) & fifo_rden_r3;
    assign rd_ecc_error[1] = (READ_DATA_PIPELINE == 1) ? (|sb_ecc_error) & fifo_rden_r3 : (|sb_ecc_error) & fifo_rden_r2;

// registered version
  always@(posedge clk0) begin
    ctrl_rmw_data_sel_r <= #TCQ ctrl_rmw_data_sel;
  end

  
  // Generate a signal to indicate that the rmw_data_fifo is ready for reading.
  // This signal is input to the ctrl.v module to indicate that
  // the rmw_write command can be issued.
  assign rmw_wr_data_rdy   = rmw_rden_r5;
  assign rmw_data_out_rise = {rmw_rise_ecc_out, rmw_rise_data_out};
  assign rmw_data_out_fall = {rmw_fall_ecc_out, rmw_fall_data_out};
  assign rmw_wren          = rmw_rden_r3;
  assign rmw_rden          = rmw_rden_r1;


always@(negedge clk90) begin  
    if (rst270)
      rmw_rden_r0 <= #TCQ 1'b0;
    else if (ctrl_rmw_data_sel)
      rmw_rden_r0 <= #TCQ data_valid;
end // always@ (negedge clk90)

always@(posedge clk90) begin  
      rmw_rden_r1 <= #TCQ rmw_rden_r0;
      rmw_rden_r2 <= #TCQ rmw_rden_r1;
      rmw_rden_r3 <= #TCQ rmw_rden_r2;
      rmw_rden_r4 <= #TCQ rmw_rden_r3;
      rmw_rden_r5 <= #TCQ rmw_rden_r4;
  end

  
  for (rdf_i = 0; rdf_i < RDF_FIFO_NUM; rdf_i = rdf_i + 1) begin: gen_rdf
      // rise fifo
      FIFO36_72  # 
      (
       .ALMOST_EMPTY_OFFSET     (9'h007),
       .ALMOST_FULL_OFFSET      (9'h00F),
       .DO_REG                  (1),          // extra CC output delay
       .EN_ECC_WRITE            ("FALSE"),
       .EN_ECC_READ             ("TRUE"),
       .EN_SYN                  ("TRUE"),
       .FIRST_WORD_FALL_THROUGH ("FALSE")
       )
      u_rdf
        (
         .ALMOSTEMPTY (),
         .ALMOSTFULL  (),
         .DBITERR     (db_ecc_error[rdf_i]),
         .DO          (tmp_rise_fifo_out[(64 *rdf_i)+(rdf_i*8):
                                    ((64*(rdf_i+1)) + (rdf_i*8))-1]),
         .DOP         (),
         .ECCPARITY   (),
         .EMPTY       (),
         .FULL        (),
         .RDCOUNT     (),
         .RDERR       (),
         .SBITERR     (sb_ecc_error[rdf_i]),
         .WRCOUNT     (),
         .WRERR       (),
         .DI          (tmp_rise_in[(64 *rdf_i)+(rdf_i*8):
                                   ((64*(rdf_i+1)) + (rdf_i*8))-1]),
         .DIP         (tmp_rise_in[(64*(rdf_i+1))+ (8*rdf_i):
                                   (72*(rdf_i+1))-1]),
         .RDCLK       (clk0),
         .RDEN        (~rst0),
         .RST         (rst0),
         .WRCLK       (clk0),
         .WREN        (~rst0)
         );
      
     // fall_fifo  
      FIFO36_72  #
      (
       .ALMOST_EMPTY_OFFSET     (9'h007),
       .ALMOST_FULL_OFFSET      (9'h00F),
       .DO_REG                  (1),          // extra CC output delay
       .EN_ECC_WRITE            ("FALSE"),
       .EN_ECC_READ             ("TRUE"),
       .EN_SYN                  ("TRUE"),
       .FIRST_WORD_FALL_THROUGH ("FALSE")
       )
      u_rdf1
        (
         .ALMOSTEMPTY (),
         .ALMOSTFULL  (),
         .DBITERR     (db_ecc_error[rdf_i+1]),
         .DO          (tmp_fall_fifo_out[(64 *rdf_i)+(rdf_i*8):
                                    ((64*(rdf_i+1)) + (rdf_i*8))-1]),
         .DOP         (),
         .ECCPARITY   (),
         .EMPTY       (),
         .FULL        (),
         .RDCOUNT     (),
         .RDERR       (),
         .SBITERR     (sb_ecc_error[rdf_i+1]),
         .WRCOUNT     (),
         .WRERR       (),
         .DI          (tmp_fall_in[(64 *rdf_i)+(rdf_i*8):
                                   ((64*(rdf_i+1)) + (rdf_i*8))-1]),
         .DIP         (tmp_fall_in[(64*(rdf_i+1))+ (8*rdf_i):
                                   (72*(rdf_i+1))-1]),
         .RDCLK       (clk0),
         .RDEN        (~rst0),
         .RST         (rst0),
         .WRCLK       (clk0),
         .WREN        (~rst0)
         );
    
      for (app_loop = 0; app_loop < (APPDATA_WIDTH/2); app_loop = app_loop + 1) begin: gen_ff_rd_data
        FD u_ff_rise_out
          (
           .Q(tmp_rise_out[app_loop]),
           .C(clk0),
           .D(tmp_rise_fifo_out[app_loop])
          ) /* synthesis syn_preserve=1 */;
          
        FD u_ff_fall_out
          (
           .Q(tmp_fall_out[app_loop]),
           .C(clk0),
           .D(tmp_fall_fifo_out[app_loop])
          ) /* synthesis syn_preserve=1 */;
      end
          
           
      for (rmw_loop1 = 0; rmw_loop1 < 64; rmw_loop1 = rmw_loop1+1) begin : gen_rd_data_fd_block
        FD u_fd_rise_in
          (
           .Q (tmp_rmw_rise_in[rmw_loop1]),
           .C (clk0),
           .D (tmp_rise_fifo_out[rmw_loop1])
           ) /* synthesis syn_preserve=1 */;
        FD u_fd_fall_in
          (
           .Q (tmp_rmw_fall_in[rmw_loop1]),
           .C (clk0),
           .D (tmp_fall_fifo_out[rmw_loop1])
           ) /* synthesis syn_preserve=1 */;
        assign tmp_wdf_rmw_rise_data[rmw_loop1] = wdf_rmw_rise_data[rmw_loop1];
        assign tmp_wdf_rmw_fall_data[rmw_loop1] = wdf_rmw_fall_data[rmw_loop1];
        assign rmw_rise_data_out[rmw_loop1] = tmp_rmw_rise_data_out[rmw_loop1];
        assign rmw_fall_data_out[rmw_loop1] = tmp_rmw_fall_data_out[rmw_loop1];
      end // block: gen_rd_data_fd_block
      
      for (rmw_loop2 = 0; rmw_loop2 < 8; rmw_loop2 = rmw_loop2+1) begin : gen_rmw_mask
        assign tmp_wdf_rmw_rise_mask[rmw_loop2] = wdf_rmw_rise_mask[rmw_loop2];
        assign tmp_wdf_rmw_fall_mask[rmw_loop2] = wdf_rmw_fall_mask[rmw_loop2];
        assign rmw_rise_ecc_out[rmw_loop2] = ecc_inject_rise_err_90 ? ~tmp_rmw_rise_ecc_out[rmw_loop2] : tmp_rmw_rise_ecc_out[rmw_loop2];
        assign rmw_fall_ecc_out[rmw_loop2] = ecc_inject_fall_err_90 ? ~tmp_rmw_fall_ecc_out[rmw_loop2] : tmp_rmw_fall_ecc_out[rmw_loop2];
      end

     always @ (negedge clk90)begin
       tmp_rmw_rise_in_r       <= #TCQ tmp_rmw_rise_in;
       tmp_rmw_fall_in_r       <= #TCQ tmp_rmw_fall_in;
       ecc_inject_rise_err_270 <= #TCQ ecc_inject_rise_err;
       ecc_inject_fall_err_270 <= #TCQ ecc_inject_fall_err;
     end
     
     always @ (posedge clk90) begin
       tmp_rmw_rise_in_r1     <= #TCQ tmp_rmw_rise_in_r;
       tmp_rmw_fall_in_r1     <= #TCQ tmp_rmw_fall_in_r;
       tmp_rmw_rise_in_r2     <= #TCQ rmw_rise_data_in;
       tmp_rmw_fall_in_r2     <= #TCQ rmw_fall_data_in;
       ecc_inject_rise_err_90 <= #TCQ ecc_inject_rise_err_270;
       ecc_inject_fall_err_90 <= #TCQ ecc_inject_fall_err_270;	 
     end
     
     always @ (posedge clk0) begin
       if (rst0 || ~rd_mod_wr)
         ecc_inject_rise_err <= #TCQ 1'b0;
       else if (rd_mod_wr && data_valid_r1 && db_ecc_error[0])
         ecc_inject_rise_err <= #TCQ 1'b1;
     end
     
     always @ (posedge clk0) begin
       if (rst0 || ~rd_mod_wr)
         ecc_inject_fall_err <= #TCQ 1'b0;
       else if (rd_mod_wr && data_valid_r1 && db_ecc_error[1])
         ecc_inject_fall_err <= #TCQ 1'b1;
     end
	
      assign rmw_rise_data_in[0:7]     = (tmp_wdf_rmw_rise_mask[0]) ? tmp_wdf_rmw_rise_data[0:7] : tmp_rmw_rise_in_r1[0:7];
      assign rmw_rise_data_in[8:15]    = (tmp_wdf_rmw_rise_mask[1]) ? tmp_wdf_rmw_rise_data[8:15] : tmp_rmw_rise_in_r1[8:15];
      assign rmw_rise_data_in[16:23]   = (tmp_wdf_rmw_rise_mask[2]) ? tmp_wdf_rmw_rise_data[16:23] : tmp_rmw_rise_in_r1[16:23];
      assign rmw_rise_data_in[24:31]   = (tmp_wdf_rmw_rise_mask[3]) ? tmp_wdf_rmw_rise_data[24:31] : tmp_rmw_rise_in_r1[24:31];
      assign rmw_rise_data_in[32:39]   = (tmp_wdf_rmw_rise_mask[4]) ? tmp_wdf_rmw_rise_data[32:39] : tmp_rmw_rise_in_r1[32:39];
      assign rmw_rise_data_in[40:47]   = (tmp_wdf_rmw_rise_mask[5]) ? tmp_wdf_rmw_rise_data[40:47] : tmp_rmw_rise_in_r1[40:47];
      assign rmw_rise_data_in[48:55]   = (tmp_wdf_rmw_rise_mask[6]) ? tmp_wdf_rmw_rise_data[48:55] : tmp_rmw_rise_in_r1[48:55];
      assign rmw_rise_data_in[56:63]   = (tmp_wdf_rmw_rise_mask[7]) ? tmp_wdf_rmw_rise_data[56:63] : tmp_rmw_rise_in_r1[56:63];
     
      assign rmw_fall_data_in[0:7]     = (tmp_wdf_rmw_fall_mask[0]) ? tmp_wdf_rmw_fall_data[0:7] : tmp_rmw_fall_in_r1[0:7];
      assign rmw_fall_data_in[8:15]    = (tmp_wdf_rmw_fall_mask[1]) ? tmp_wdf_rmw_fall_data[8:15] : tmp_rmw_fall_in_r1[8:15];
      assign rmw_fall_data_in[16:23]   = (tmp_wdf_rmw_fall_mask[2]) ? tmp_wdf_rmw_fall_data[16:23] : tmp_rmw_fall_in_r1[16:23];
      assign rmw_fall_data_in[24:31]   = (tmp_wdf_rmw_fall_mask[3]) ? tmp_wdf_rmw_fall_data[24:31] : tmp_rmw_fall_in_r1[24:31];
      assign rmw_fall_data_in[32:39]   = (tmp_wdf_rmw_fall_mask[4]) ? tmp_wdf_rmw_fall_data[32:39] : tmp_rmw_fall_in_r1[32:39];
      assign rmw_fall_data_in[40:47]   = (tmp_wdf_rmw_fall_mask[5]) ? tmp_wdf_rmw_fall_data[40:47] : tmp_rmw_fall_in_r1[40:47];
      assign rmw_fall_data_in[48:55]   = (tmp_wdf_rmw_fall_mask[6]) ? tmp_wdf_rmw_fall_data[48:55] : tmp_rmw_fall_in_r1[48:55];
      assign rmw_fall_data_in[56:63]   = (tmp_wdf_rmw_fall_mask[7]) ? tmp_wdf_rmw_fall_data[56:63] : tmp_rmw_fall_in_r1[56:63];

         
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
      u_rmw_data0
        (
         .ALMOSTEMPTY (),
         .ALMOSTFULL  (),
         .DBITERR     (),
         .DO          (tmp_rmw_rise_data_out),
         .DOP         (tmp_rmw_rise_ecc_out),
         .ECCPARITY   (),
         .EMPTY       (),
         .FULL        (),
         .RDCOUNT     (),
         .RDERR       (),
         .SBITERR     (),
         .WRCOUNT     (),
         .WRERR       (),
         .DI          (tmp_rmw_rise_in_r2),
         .DIP         (),
         .RDCLK       (clk90),
         .RDEN        (wdf_rden_r),
         .RST         (rst90),
         .WRCLK       (clk90),
         .WREN        (rmw_wren)
         );
         
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
      u_rmw_data1
        (
         .ALMOSTEMPTY (),
         .ALMOSTFULL  (),
         .DBITERR     (),
         .DO          (tmp_rmw_fall_data_out),
         .DOP         (tmp_rmw_fall_ecc_out),
         .ECCPARITY   (),
         .EMPTY       (),
         .FULL        (),
         .RDCOUNT     (),
         .RDERR       (),
         .SBITERR     (),
         .WRCOUNT     (),
         .WRERR       (),
         .DI          (tmp_rmw_fall_in_r2),
         .DIP         (),
         .RDCLK       (clk90),
         .RDEN        (wdf_rden_r),
         .RST         (rst90),
         .WRCLK       (clk90),
         .WREN        (rmw_wren)
         );
       end //end for loop    
end else begin // if (ECC_ENABLE)

  // read data is delayed by an additional cycle for READ_DATA_PIPELINE
  assign rd_data_valid = data_valid;
  assign data_valid = (READ_DATA_PIPELINE == 1) ? fifo_rden_r2 : fifo_rden_r1;


  assign       bram_rise_in[0:(DQS_WIDTH*DQ_PER_DQS)-1] = tmp_rise_in;

  assign       tmp_rise_out = bram_rise_out[0:(DQS_WIDTH*DQ_PER_DQS)-1];
   
  assign       bram_fall_in[0:(DQS_WIDTH*DQ_PER_DQS)-1] = tmp_fall_in;
  
  assign       tmp_fall_out = bram_fall_out[0:(DQS_WIDTH*DQ_PER_DQS)-1];
    
    for (rdf_i = 0; rdf_i < RDF_FIFO_NUM; rdf_i = rdf_i + 1) begin: gen_rdf

         
      RAMB36
        #(
          .DOA_REG(1),
          .DOB_REG(1),
          .READ_WIDTH_A(36),
          .READ_WIDTH_B(36),
          .WRITE_WIDTH_A(36),
          .WRITE_WIDTH_B(36),
          .WRITE_MODE_A("WRITE_FIRST"),
          .WRITE_MODE_B("WRITE_FIRST")
          )
          u_rdf
            (
             .CLKA(clk0),
             .DIA(bram_rise_in[(64*rdf_i)+32:(64*rdf_i)+63]),
             .ADDRA(16'b0),
             .DIPA(4'b0),
             .ENA(1'b1),
             .WEA(4'b1111),
             .REGCEA(1'b1),
             .SSRA(1'b0),
             .CASCADEINREGA(1'b0),
             .CASCADEINLATA(1'b0),
             .DOA(bram_rise_out[(64*rdf_i)+32:(64*rdf_i)+63]),
             .CLKB(clk0),
             .DIB(bram_rise_in[(64*rdf_i):(64*rdf_i)+31]),
             .ADDRB(~16'b0),
             .DIPB(4'b0),
             .ENB(1'b1),
             .WEB(4'b1111),
             .REGCEB(1'b1),
             .SSRB(1'b0),
             .CASCADEINREGB(1'b0),
             .CASCADEINLATB(1'b0),
             .DOB(bram_rise_out[(64*rdf_i):(64*rdf_i)+31]),
             // unused outputs
             .DOPA(),
             .DOPB(),
             .CASCADEOUTLATA(),
             .CASCADEOUTREGA(),
             .CASCADEOUTLATB(),
             .CASCADEOUTREGB()
             );

      RAMB36
        #(
          .DOA_REG(1),
          .DOB_REG(1),
          .READ_WIDTH_A(36),
          .READ_WIDTH_B(36),
          .WRITE_WIDTH_A(36),
          .WRITE_WIDTH_B(36),
          .WRITE_MODE_A("WRITE_FIRST"),
          .WRITE_MODE_B("WRITE_FIRST")
          )
          u_rdf1
            (
             .CLKA(clk0),
             .DIA(bram_fall_in[(64*rdf_i)+32:(64*rdf_i)+63]),
             .ADDRA(16'b0),
             .DIPA(4'b0),
             .ENA(1'b1),
             .WEA(4'b1111),
             .REGCEA(1'b1),
             .SSRA(1'b0),
             .CASCADEINREGA(1'b0),
             .CASCADEINLATA(1'b0),
             .DOA(bram_fall_out[(64*rdf_i)+32:(64*rdf_i)+63]),
             .CLKB(clk0),
             .DIB(bram_fall_in[(64*rdf_i):(64*rdf_i)+31]),
             .ADDRB(~16'b0),
             .DIPB(4'b0),
             .ENB(1'b1),
             .WEB(4'b1111),
             .REGCEB(1'b1),
             .SSRB(1'b0),
             .CASCADEINREGB(1'b0),
             .CASCADEINLATB(1'b0),
             .DOB(bram_fall_out[(64*rdf_i):(64*rdf_i)+31]),
             // unused outputs
             .DOPA(),
             .DOPB(),
             .CASCADEOUTLATA(),
             .CASCADEOUTREGA(),
             .CASCADEOUTLATB(),
             .CASCADEOUTREGB()   
             );
         
      end
    end
  endgenerate       





endmodule
