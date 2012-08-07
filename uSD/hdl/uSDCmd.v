`timescale 1ns / 1ps
`define DEL 500 // standard delay = 500 ps
////////////////////////////////////////////////////////////////////////////////////////////////
// Title                   : uSDCmd.v
// Project                 : COB DPM      
// ////////////////////////////////////////////////////////////////////////////////////////////
// Create Date             : 5/18/2012	   
// Design Name             :
// Module Name    	   : uSDCmd
// Project Name            : COB
// Target Devices  	   : 5VFX70T
// Tool versions  	   : 13.4
// Description             : This is the microSD command line controller. It receives
//                         ; commands from sdEngine and sends results to same.
// Revision: 
// Revision 0.00 - File Created
// Modification History
// 05/18/2012 Created
//////////////////////////////////////////////////////////////////////////////////
module uSDCmd (
//-------- Inputs
input sdClk,
input sysRst,
input sdCmdIn,
input [31:0] argumentReg,
input [15:0] cmdReg,
input newCmd,
input chipScopeSel,
//-------- Outputs
output reg sdCmdOut,
output reg sdCmdEn,
output reg [135:0] cmdResponse,
output reg [15:0] statusReg,
output sdClkSel,
output [81:0] sdCmdDebug,
output reg initDone,
output reg dataReady,
output [6:0] rxCrcValue,
output reg cmdStatus
);


reg [7:0] rxCnt;     // 8 bit receive counter
reg [7:0] rxCntDly;  // delayed receive counter for crc check
reg [5:0] txCnt;      // 6 bit transmit counter
reg [6:0] initCount;  // 7 bit init count
reg [3:0] cmdState;   // state machine state
reg startBit;         // receive start bit
wire [47:0] cmdOut;
wire crcIn;
wire [6:0] txCrcValue;
reg txCrcEnable;
wire rxCrcEnableExt;
reg rxCrcEnableInt;
wire rxCrcEnable;
wire [7:0] recSize;
reg txCrcRst;
reg rxCrcRst;
reg [6:0] rxCrcCheck;
// state machine states
parameter RESET   = 4'h0;  // INIT from sdEngine
parameter INIT    = 4'h1;  // 74 clock delay
parameter IDLE    = 4'h2;  // No commands
parameter WAIT    = 4'h3;  // wait state for CRC
parameter SEND    = 4'h4;  // Transmit command
parameter RCV     = 4'h5;  // Receive command
parameter CRC_CHK = 4'h6;   // Check Rec CRC


assign sdClkSel = 1'b1;
assign rxCrcEnableExt = cmdReg[3];
assign rxCrcEnable = rxCrcEnableExt & rxCrcEnableInt;
assign cmdOut = {1'b0, 1'b1, cmdReg[13:8], argumentReg, txCrcValue, 1'b1};
//              47     46    45:40         39:8         7:1         0
assign recSize = (cmdReg[1:0] == 2'b0) ? 0 : (cmdReg[1:0] == 2'b01) ? 135 : 47;
assign sdCmdDebug[3:0] = cmdState;    // [15:8]
assign sdCmdDebug[10:4] = rxCrcCheck;
assign sdCmdDebug[11] = cmdStatus;
assign sdCmdDebug[12] = rxCrcEnable;
assign sdCmdDebug[13] = rxCrcEnableInt;
assign sdCmdDebug[14] = rxCrcEnableExt;
assign sdCmdDebug[22:15] = rxCnt;
assign sdCmdDebug[29:23] = rxCrcValue;


// init counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
       initCount <= 0;
   end
   else begin
      if (initCount == 127) begin
         initCount <= initCount;
      end
      else begin
         initCount <= initCount + 1;
      end
   end
end

// crc reset
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      txCrcRst <= 1'b1;
      rxCrcRst <= 1'b1;
   end
   else begin
      case (cmdState)
      INIT: begin
         txCrcRst <= 1'b1;
         rxCrcRst <= 1'b1;
      end
      IDLE: begin
         txCrcRst <= 1'b1;
         rxCrcRst <= 1'b1;
      end
      WAIT: begin
         txCrcRst <= 1'b0;
         rxCrcRst <= 1'b1;
      end
      SEND: begin
         txCrcRst <= 1'b0;
         rxCrcRst <= 1'b1;
      end
      RCV: begin
         txCrcRst <= 1'b1;
         rxCrcRst <= 1'b0;
      end
      CRC_CHK: begin
         txCrcRst <= 1'b1;
         rxCrcRst <= 1'b0;
      end
      endcase // case (cmdState)
   end
end

// Bit couters

always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      rxCnt <= 47;
      rxCntDly <= 47;
      txCnt <= 47;
   end
   else begin
      if (cmdState == IDLE) begin
         txCnt <= 47;
      end         
      else if (cmdState == SEND) begin
         if (txCnt <= 0) begin
            txCnt <= txCnt;
         end
         else begin
            txCnt <= txCnt - 1;
         end
         rxCnt <= recSize;
         rxCntDly <= recSize;
      end
      else if (cmdState == RCV) begin
         txCnt <= 47;
         if (~sdCmdIn) begin
            rxCnt <= rxCnt -1;
            rxCntDly <= rxCnt;
	 end
         else if (startBit) begin
            if (rxCnt == 0) begin
               rxCnt <= rxCnt;
               rxCntDly <= rxCntDly;
            end
            else begin
               rxCnt <= rxCnt -1;
               rxCntDly <= rxCnt;
            end
	 end
      end
      else begin
         txCnt <= txCnt;
         rxCnt <= rxCnt;
         rxCntDly <= rxCntDly;
      end
   end
end
      
// start bit detector
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      startBit <= 1'b0;
   end
   else begin
   case (cmdState)
   RESET : begin
      startBit <= 1'b0;
   end
   INIT: begin
      startBit <= 1'b0;
   end
   IDLE : begin
      startBit <= 1'b0;
   end
   SEND: begin
      startBit <= 1'b0;
   end
   WAIT : begin
      startBit <= 1'b0;
   end
   RCV: begin
      if (~sdCmdIn) begin
         startBit <= 1'b1;
      end
      else begin
         startBit <= startBit;
      end
   end
   CRC_CHK : begin
      startBit <= startBit;
   end
   endcase // case (cmdState)
   end
end

always @ (posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      cmdState <= RESET;
   end
   else begin
      case(cmdState) // synthesis parallel_case full_case
      RESET: begin
         cmdState <= INIT;
      end
      INIT: begin
         if (initCount == 7'b1111111) begin
            cmdState <= IDLE;
         end
         else begin
            cmdState <= INIT;
         end
      end
      IDLE: begin
         if (newCmd) begin
	    cmdState <= WAIT;
         end
	 else begin
	    cmdState <= IDLE;
	 end
      end
      WAIT: begin
         cmdState <= SEND;
      end
      SEND: begin
         if (txCnt == 0) begin
            if (recSize == 0) begin
               cmdState <= IDLE;
            end
            else begin
               cmdState <= RCV;
            end
         end
         else begin
            cmdState <= SEND;
         end
      end
      RCV: begin
         if (rxCnt == 0) begin
            cmdState <= CRC_CHK;
         end
	 else begin
	    cmdState <= RCV;
         end
      end
      CRC_CHK: begin
         cmdState <= IDLE;
      end
      endcase // case (cmdState)
   end
end

// state outputs
always @(posedge sdClk) begin
  case(cmdState) // synthesis parallel_case full_case
  RESET: begin
     sdCmdOut <= 1'b1;
     sdCmdEn <= 1'b1;
     txCrcEnable <= 1'b0;
     initDone <= 1'b0;
     dataReady <= 1'b0;
     rxCrcEnableInt <= 1'b0;
  end
  INIT: begin
     sdCmdOut <= 1'b1;
     sdCmdEn <= 1'b1;
     txCrcEnable <= 1'b0;
     initDone <= 1'b0;
     dataReady <= 1'b0;
     rxCrcEnableInt <= 1'b0;
  end
  IDLE: begin
     sdCmdOut <= 1'b1;
     sdCmdEn <= 1'b1;
     txCrcEnable <= 1'b0;
     initDone <= 1'b1;
     dataReady <= 1'b0;
     rxCrcEnableInt <= 1'b0;
  end
  WAIT: begin
     sdCmdOut <= 1'b1;
     sdCmdEn <= 1'b1;
     txCrcEnable <= 1'b1;
     initDone <= 1'b1;
     dataReady <= 1'b0;
     rxCrcEnableInt <= 1'b0;
  end
  SEND: begin
     sdCmdEn <= 1'b1;
     sdCmdOut <= cmdOut[txCnt];
     rxCrcEnableInt <= 1'b0;
     txCrcEnable <= 1'b1;
     initDone <= 1'b1;
     dataReady <= 1'b0;
     if (txCnt <= 8) begin
        txCrcEnable <= 1'b0;
     end
     else begin
        txCrcEnable <= 1'b1;
     end
  end
  RCV: begin
     txCrcEnable <= 1'b0;
     sdCmdEn <= 1'b0;
     initDone <= 1'b1;
     cmdResponse[rxCnt] <= sdCmdIn;
     if (rxCnt == 0) begin
        dataReady <= 1'b1;
     end
     else begin
        dataReady <= 1'b0;
     end
     if (rxCnt <= 8) begin
        rxCrcEnableInt <= 1'b0;
     end
     else  begin
        rxCrcEnableInt <= 1'b1;
     end
  end
  CRC_CHK: begin
     txCrcEnable <= 1'b0;
     sdCmdEn <= 1'b0;
     initDone <= 1'b1;
     dataReady <= 1'b1;
  end
  endcase
end

wire rxCrcIn;
assign rxCrcIn  = (rxCnt == recSize) ? 1'b0 : (rxCnt > 6) ? sdCmdIn : 1'b0;

sd_crc_7 sd_crc_7_tx(
   .BITVAL(cmdOut[txCnt]),
   .Enable(txCrcEnable),
   .CLK(sdClk),
   .RST(txCrcRst),
   .CRC(txCrcValue)
);

sd_crc_7 sd_crc_7_rx(
   .BITVAL(rxCrcIn),
   .Enable(rxCrcEnable),
   .CLK(sdClk),
   .RST(rxCrcRst),
   .CRC(rxCrcValue)
);

// capture incomming crc
always @(posedge sdClk) begin
   if (rxCnt < 7) begin
      rxCrcCheck[rxCnt] <= sdCmdIn;
   end
end

// check incomming crc
always @(posedge sdClk) begin
   if (cmdState == CRC_CHK) begin
      if (rxCrcCheck == rxCrcValue) begin
         cmdStatus <= 1'b0;
      end
      else begin
         cmdStatus <= 1'b1;
      end
   end
end


endmodule






   

