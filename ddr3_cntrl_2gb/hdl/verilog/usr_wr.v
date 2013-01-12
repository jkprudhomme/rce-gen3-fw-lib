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
//  \   \         Filename: usr_af_wdf.v
//  /   /         Date Last Modified:
// /___/   /\     Date Created: 8/28/06
// \   \  /  \
//  \___\/\___\
//
//Device: Virtex-5
//Purpose:
//   This module instantiates the modules containing internal FIFOs
//Reference:
//Revision History:
//   Rev 1.0 - created. adapted V5 from DDR2 SDRAM controller from MIG 1.6
//             from karthip design. richc. 8/28/06
//   Rev 1.1 - integration with KP DDR2 changes. richc. 11/15/06
//*****************************************************************************

`timescale 1ps/1ps


module usr_wr #
  (
   parameter integer TCQ           = 100,
   parameter integer APPDATA_WIDTH = 128,
   parameter integer DQ_WIDTH      = 64,
   parameter integer ECC_ENABLE    = 1,
   parameter integer SIM_ONLY      = 1
   )
  (
   input                                     clk0,
   input                                     clk90,
   input                                     rst90,
   // Write data FIFO interface
   input                                     app_wdf_wren,
   input [APPDATA_WIDTH-1:0]                 app_wdf_data,
   input [(APPDATA_WIDTH/8)-1:0]             app_wdf_mask_data,
   input                                     ctrl_rmw_data_sel,              
   input                                     wdf_rden,
   input                                     wdf_mask_rden,
   output [(2*DQ_WIDTH)-1:0]                 wdf_data,
   output [((2*DQ_WIDTH)/8)-1:0]             wdf_mask_data,
   output reg [63:0]                         wdf_rmw_rise_data,
   output reg [63:0]                         wdf_rmw_fall_data,
   output reg [7:0]                          wdf_rmw_rise_mask,
   output reg [7:0]                          wdf_rmw_fall_mask 
   );

  // determine number of FIFO72's to use based on data width
  // round up to next integer value when determining WDF_FIFO_NUM
  localparam WDF_FIFO_NUM = (ECC_ENABLE) ? (APPDATA_WIDTH+63)/64 : 
             ((2*DQ_WIDTH)+63)/64;
  // MASK_WIDTH = number of bytes in data bus
  localparam MASK_WIDTH = DQ_WIDTH/8;
  localparam MASK_WIDTH2 = (2*DQ_WIDTH)/8; 


  wire [DQ_WIDTH-1:0]          i_wdf_data_fall_in;
  wire [DQ_WIDTH-1:0]          i_wdf_data_fall_out;
  wire [(64*WDF_FIFO_NUM)-1:0] i_wdf_data_in;
  wire [(64*WDF_FIFO_NUM)-1:0] i_wdf_data_out;
  wire [DQ_WIDTH-1:0]          i_wdf_data_rise_in;
  wire [DQ_WIDTH-1:0]          i_wdf_data_rise_out;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_fall_in;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_fall_out;
  wire [(8*WDF_FIFO_NUM)-1:0]  i_wdf_mask_data_in;
  wire [(8*WDF_FIFO_NUM)-1:0]  i_wdf_mask_data_out;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_rise_in;
  wire [MASK_WIDTH-1:0]        i_wdf_mask_data_rise_out;
  

  // ECC signals 
  wire [(2*DQ_WIDTH)-1:0]      i_wdf_data_out_ecc;
  wire [((2*DQ_WIDTH)/8)-1:0]  i_wdf_mask_data_out_ecc;
  wire [((2*DQ_WIDTH)/8)-1:0]  mask_data_in_ecc;
  reg  [((2*DQ_WIDTH)/8)-1:0]  mask_ecc_in;
  reg  [((2*DQ_WIDTH)/8)-1:0]  mask_ecc_in_90;
  reg                          wdf_wren;
  reg                          wdf_wren_90;
  reg 			       rmw_data_sel_270;
  reg 			       rmw_data_sel_90;
  reg  [3:0]                   wr_addr;
  reg  [3:0]                   rd_addr;
  wire [(8*WDF_FIFO_NUM)-1:0]  wdf_parity_out;
  wire [(8*WDF_FIFO_NUM)-1:0]  wdf_mask_out;
  
  
  //***************************************************************************
  


  genvar wdf_di_i;
  genvar wdf_do_i; 
  genvar mask_i;
  genvar wdf_i;
  genvar loop2;
  generate 
    if(ECC_ENABLE) begin    // ECC code 
    
      assign wdf_data = {i_wdf_data_out_ecc[DQ_WIDTH-1:0], i_wdf_data_out_ecc[(2*DQ_WIDTH)-1:DQ_WIDTH]};
  
      // the byte 9 dm is always held at logic 1 
      assign wdf_mask_data = {i_wdf_mask_data_out_ecc[DQ_WIDTH/8-1:0], i_wdf_mask_data_out_ecc[((2*DQ_WIDTH)/8)-1:DQ_WIDTH/8]};
 
      always @ (posedge clk90)begin
        wdf_rmw_rise_data <= #TCQ i_wdf_data_out_ecc[135:72];
	wdf_rmw_fall_data <= #TCQ i_wdf_data_out_ecc[63:0];
	wdf_rmw_rise_mask <= #TCQ i_wdf_mask_data_out_ecc[16:9];
	wdf_rmw_fall_mask <= #TCQ i_wdf_mask_data_out_ecc[7:0];
      end
     
      
      // write data and mask fifos
      
for (wdf_i = 0; wdf_i < WDF_FIFO_NUM; wdf_i = wdf_i + 1) begin: gen_wdf
      usr_wr_fifo #
        (.ECC_ENABLE(ECC_ENABLE),
         .SIM_ONLY  (SIM_ONLY)
        )
      u_usr_wr_fifo 
        (
         .clk0              (clk0),
         .clk90             (clk90),
         .rst90             (rst90),
         .app_wdf_wren      (app_wdf_wren),
         .app_wdf_data      (app_wdf_data[(64*(wdf_i+1))-1:64*wdf_i]),
         .app_wdf_mask_data (app_wdf_mask_data[(8*(wdf_i+1))-1:8*wdf_i]),
         .wdf_rden          (wdf_rden),
         .wdf_data          (i_wdf_data_out_ecc[((64*(wdf_i+1))+(wdf_i *8))-1:(64*wdf_i)+(wdf_i *8)]),
         .wdf_data_parity   (i_wdf_data_out_ecc[(72*(wdf_i+1))-1:(64*(wdf_i+1))+ (8*wdf_i)]),
         .wdf_mask_data     (wdf_mask_out[(8*(wdf_i+1))-1:8*wdf_i])
         );
    end


   
      // remapping the mask data. The mask data from user i/f does not have
      // the mask for the ECC byte. Assigning 1 to the ECC mask byte 
      // in order to enable it. 
      for (mask_i = 0; mask_i < (DQ_WIDTH)/36; 
           mask_i = mask_i +1) begin: gen_mask
        assign mask_data_in_ecc[((8*(mask_i+1))+ mask_i)-1:((8*mask_i)+mask_i)]
                 = app_wdf_mask_data[(8*(mask_i+1))-1:8*(mask_i)] ;
        assign mask_data_in_ecc[((8*(mask_i+1))+mask_i)] = (|app_wdf_mask_data[(8*(mask_i+1))-1:8*(mask_i)]) ? 1'd1 : 1'd0;
      end

// *************************************************************************************************** //
// LUT RAM FIFO for mask bits
// *************************************************************************************************** //

always @ (negedge clk90)begin
  mask_ecc_in      <= #TCQ mask_data_in_ecc;
  wdf_wren         <= #TCQ app_wdf_wren;
  rmw_data_sel_270 <= #TCQ ctrl_rmw_data_sel;     
end
  
always @ (posedge clk90)begin
  mask_ecc_in_90  <= #TCQ mask_ecc_in;
  wdf_wren_90     <= #TCQ wdf_wren;
  rmw_data_sel_90 <= #TCQ rmw_data_sel_270;
end

  //*************************************************************************** //
  // Write Pointer increment for LUT RAM FIFO
  //*************************************************************************** //

  always @(posedge clk90)
    if (rst90)
      wr_addr <= #TCQ 4'd0;
    else if (wdf_wren_90)
      wr_addr <= #TCQ wr_addr + 1;

  //*************************************************************************** //
  // Read Pointer increment for LUT RAM FIFO
  //*************************************************************************** //

  always @(posedge clk90)
    if (rst90)
      rd_addr <= #TCQ 4'd0;
    else if (wdf_mask_rden)
      rd_addr <= #TCQ rd_addr + 1;
      
usr_ram_d #
    (
     .DATA_WIDTH (MASK_WIDTH2)
     )
    u_usr_ram_mask
    (
     .addra    (wr_addr),
     .addrb    (rd_addr),
     .clka     (clk90),
     .wea      (wdf_wren_90),
     .dinb     (mask_ecc_in_90),
     .douta    (i_wdf_mask_data_out_ecc)
     );


    end else begin 
    
      //***********************************************************************

      // Define intermediate buses:
      assign i_wdf_data_rise_in 
        = app_wdf_data[DQ_WIDTH-1:0];
      assign i_wdf_data_fall_in 
        = app_wdf_data[(2*DQ_WIDTH)-1:DQ_WIDTH];
      assign i_wdf_mask_data_rise_in 
        = app_wdf_mask_data[MASK_WIDTH-1:0];
      assign i_wdf_mask_data_fall_in 
        = app_wdf_mask_data[(2*MASK_WIDTH)-1:MASK_WIDTH];

      //***********************************************************************
      // Write data FIFO Input:
      // Arrange DQ's so that the rise data and fall data are interleaved.
      // the data arrives at the input of the wdf fifo as {fall,rise}.
      // It is remapped as:
      //     {...fall[15:8],rise[15:8],fall[7:0],rise[7:0]}
      // This is done to avoid having separate fifo's for rise and fall data
      // and to keep rise/fall data for the same DQ's on same FIFO
      // Data masks are interleaved in a similar manner
      // NOTE: Initialization data from PHY_INIT module does not need to be
      //  interleaved - it's already in the correct format - and the same
      //  initialization pattern from PHY_INIT is sent to all write FIFOs
      //***********************************************************************


      for (wdf_di_i = 0; wdf_di_i < MASK_WIDTH;  wdf_di_i = wdf_di_i + 1) begin: gen_wdf_data_in
      assign i_wdf_data_in[(16*wdf_di_i)+15:(16*wdf_di_i)]
               = {i_wdf_data_fall_in[(8*wdf_di_i)+7:(8*wdf_di_i)],
                  i_wdf_data_rise_in[(8*wdf_di_i)+7:(8*wdf_di_i)]};
      assign i_wdf_mask_data_in[(2*wdf_di_i)+1:(2*wdf_di_i)]
               = {i_wdf_mask_data_fall_in[wdf_di_i],
                  i_wdf_mask_data_rise_in[wdf_di_i]};
    end
  
      //***********************************************************************
      // Write data FIFO Output:
      // FIFO DQ and mask outputs must be untangled and put in the standard 
      // format of {fall,rise}. Same goes for mask output
      //***********************************************************************


    for (wdf_do_i = 0; wdf_do_i < MASK_WIDTH; 
         wdf_do_i = wdf_do_i + 1) begin: gen_wdf_data_out
      assign i_wdf_data_rise_out[(8*wdf_do_i)+7:(8*wdf_do_i)] 
               = i_wdf_data_out[(16*wdf_do_i)+7:(16*wdf_do_i)];
      assign i_wdf_data_fall_out[(8*wdf_do_i)+7:(8*wdf_do_i)]
               = i_wdf_data_out[(16*wdf_do_i)+15:(16*wdf_do_i)+8];
      assign i_wdf_mask_data_rise_out[wdf_do_i]
               = i_wdf_mask_data_out[2*wdf_do_i];
      assign i_wdf_mask_data_fall_out[wdf_do_i]
               = i_wdf_mask_data_out[(2*wdf_do_i)+1];
    end

  assign wdf_data = {i_wdf_data_rise_out, 
                     i_wdf_data_fall_out};

 

  assign wdf_mask_data = {i_wdf_mask_data_rise_out,
                          i_wdf_mask_data_fall_out};

      //***********************************************************************

for (wdf_i = 0; wdf_i < WDF_FIFO_NUM; wdf_i = wdf_i + 1) begin: gen_wdf
      usr_wr_fifo #
        (.ECC_ENABLE(ECC_ENABLE))
      u_usr_wr_fifo 
        (
         .clk0              (clk0),
         .clk90             (clk90),
         .rst90             (rst90),
         .app_wdf_wren      (app_wdf_wren),
         .app_wdf_data      (i_wdf_data_in[(64*(wdf_i+1))-1:64*wdf_i]),
         .app_wdf_mask_data (i_wdf_mask_data_in[(8*(wdf_i+1))-1:8*wdf_i]),
         .wdf_rden          (wdf_rden),
         .wdf_data          (i_wdf_data_out[(64*(wdf_i+1))-1:64*wdf_i]),
         .wdf_data_parity   (wdf_parity_out[(8*(wdf_i+1))-1:8*wdf_i]),
         .wdf_mask_data     (i_wdf_mask_data_out[(8*(wdf_i+1))-1:8*wdf_i])
         );
    end
      
    end
  endgenerate

  
endmodule
