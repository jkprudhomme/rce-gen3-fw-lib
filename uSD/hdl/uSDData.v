`timescale 1ns / 1ps
`define DEL 500 // standard delay = 500 ps
////////////////////////////////////////////////////////////////////////////////////////////////
// Title                   : uSDData.v
// Project                 : COB DPM      
// ////////////////////////////////////////////////////////////////////////////////////////////
// Create Date             : 7/18/2012	   
// Design Name             :
// Module Name    	   : uSDData
// Project Name            : COB
// Target Devices  	   : 5VFX70T
// Tool versions  	   : 13.4
// Description             : This is the microSD Data line controller. It receives
//                         ; commands from sdEngine and sends results to same.
// Revision: 
// Revision 0.00 - File Created
// Modification History
// 05/18/2012 Created
//////////////////////////////////////////////////////////////////////////////////
module uSDData (
//-------- Inputs
input sdClk,
input sysRst,
input writeCmd,
input readCmd,
input [3:0] sdDataIn,
input [71:0]  writeDataIn, 
input writeFifoAlmostEmpty,
input readFifoAlmostFull,
input sdStatusCmd,
input chipScopeSel,
//-------- Outputs
output reg [3:0] sdDataOut,
output reg sdDataEn,
output [254:0] sdDataDebug,
output reg writeFifoRe,
output reg readFifoWe,
output reg [71:0] readDataOut,
output reg writeDone,
output reg readDone,
output reg [3:0] dataStatus

);
reg [3:0] writeBlockCnt;  // 6 bit counter for block (512 bytes per block / 8 bytes per fifo read)
reg [2:0] writeByteCnt;   // 3 bit counter for bytes  (which byte of 8 is being written)
reg [2:0] writeBitCnt;    // 3 bit counter for bit    (which bit is written on each line)
reg [3:0] writeCrcCnt;    // 4 bit counter for write crc
reg [63:0] writeData0;    // registered write data from FIFO
reg [63:0] writeData1;    // registered write data from FIFO
reg [3:0] readBlockCnt;   // 6 bit counter for block (512 bytes per block / 8 bytes per fifo write)
reg [2:0] readByteCnt;    // 3 bit counter for bytes (which byte of 8 is being read)
reg [2:0] readBitCnt;     // 3 bit counter for bit   (which bit is read on each line)
reg [3:0] readCrcCnt;     // 3 bit counter for read crc
reg [63:0] readData;      // registered read data to FIFO
reg readStartBit;         // read start bit
reg writeStartBit;        // write start bit
wire [15:0] writeCrcValue3;  // write data3 crc value
wire [15:0] writeCrcValue2;  // write data2 crc value
wire [15:0] writeCrcValue1;  // write data1 crc value
wire [15:0] writeCrcValue0;  // write data0 crc value
wire [15:0] readCrcValue3;  // read data3 crc value
wire [15:0] readCrcValue2;  // read data2 crc value
wire [15:0] readCrcValue1;  // read data1 crc value
wire [15:0] readCrcValue0;  // read data0 crc value
reg [15:0] readCrcCheck3;   // read data crc value from card
reg [15:0] readCrcCheck2;
reg [15:0] readCrcCheck1;
reg [15:0] readCrcCheck0;
reg [3:0] writeCrcIn;
reg writeCrcEnable;          // write crc enable
reg readCrcEnable;          // read crc enable
reg writeCrcRst;             // write crc reset
reg readCrcRst;             // read crc reset
reg [4:0] cmdState;
reg [5:0] writeStatus;

assign sdDataDebug[63:0]    = chipScopeSel ? readData      : writeData0;
assign sdDataDebug[127:64]  = chipScopeSel ? {44'b0, dataStatus, readCrcCheck3} : writeData1;
assign sdDataDebug[144:128] = {2'b0, writeStatus, writeCrcIn, cmdState};
assign sdDataDebug[147:145] = chipScopeSel ? readByteCnt   : writeByteCnt;
assign sdDataDebug[150:148] = chipScopeSel ? readBitCnt    : writeBitCnt;
assign sdDataDebug[166:151] = chipScopeSel ? readCrcValue3 : writeCrcValue3;
assign sdDataDebug[167]     = chipScopeSel ? readCrcEnable : writeCrcEnable;   
assign sdDataDebug[168]     = chipScopeSel ? readCrcRst    : writeCrcRst;
assign sdDataDebug[169]     = chipScopeSel ? readFifoWe    : writeFifoRe;  
assign sdDataDebug[173:170] = chipScopeSel ? readCrcCnt    : writeCrcCnt;
assign sdDataDebug[174]     = chipScopeSel ? readCmd       : writeCmd;
assign sdDataDebug[180:175] = chipScopeSel ? {1'b0, readStartBit, readBlockCnt}  : {1'b0, writeStartBit, writeBlockCnt};
// state machine states
parameter[4:0]
   RESET       = 5'h00,  //  from sdEngine
   IDLE        = 5'h01,  //  No commands
   WRITE_WAIT  = 5'h02,  // prefetch fifo data
   WRITE_WAIT1 = 5'h03,  // prefetch fifo data
   WRITE_WAIT2 = 5'h04,  // precharge crc
   WRITE_START = 5'h05,  // Write start bit
   WRITE       = 5'h06,  // Write Data
   WRITE_CRC   = 5'h07,  // Write CRC
   WRITE_STOP  = 5'h08,  // Write Stop bit
   WRITE_TURN  = 5'h09,  // delay for status
   WRITE_TURN1 = 5'h0A,  // delay for status2
   WRITE_STAT0 = 5'h0B,  // read status start bit
   WRITE_STAT1 = 5'h0C,  // read first status bit
   WRITE_STAT2 = 5'h0D,  // read second status bit
   WRITE_STAT3 = 5'h0E,  // read third status bit
   WRITE_STAT4 = 5'h0F,  // read fourth status bit
   WRITE_STAT5 = 5'h10,  // read fifth status bit
   BUSY_CHK    = 5'h11,  // Check write complete
   NOT_BUSY    = 5'h12,  // send done bit
   READ_START  = 5'h13,  // Read start bit
   READ        = 5'h14,  // Read Data
   READ_CRC    = 5'h15,  // Read CRC
   CRC_CHK     = 5'h16;  // Check CRC


// write block counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeBlockCnt <= 0;
   end
   else if (cmdState == IDLE)  begin
      writeBlockCnt <= 0;
   end
   else if (writeStartBit) begin
      if (writeByteCnt == 7 & writeBitCnt == 7) begin
         if (writeBlockCnt == 15) begin
	    writeBlockCnt <= writeBlockCnt;
	 end
	 else begin
            writeBlockCnt <= writeBlockCnt + 1;
	 end
      end
      else begin
         writeBlockCnt <= writeBlockCnt;
      end
   end
   else begin
      writeBlockCnt <= writeBlockCnt;
   end
end

// write byte counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeByteCnt <= 0;
   end
   else if (cmdState == IDLE) begin
         writeByteCnt <= 0;
   end
   else if (writeStartBit) begin
      if (writeBitCnt == 7) begin
         if (writeByteCnt == 7 & writeBlockCnt == 15) begin
	    writeByteCnt <= writeByteCnt;
	 end
	 else begin
            writeByteCnt <= writeByteCnt + 1;
	 end
      end
      else begin
         writeByteCnt <= writeByteCnt;
      end
   end
   else begin
      writeByteCnt <= writeByteCnt;
   end
end


// write bit counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeBitCnt <= 0;
   end
   else if (cmdState == IDLE) begin
      writeBitCnt <= 0;
   end
   else if (writeStartBit) begin
      if (writeBlockCnt == 15 & writeByteCnt == 7 & writeBitCnt == 7) begin
         writeBitCnt <= writeBitCnt;
      end
      else begin
         writeBitCnt <= writeBitCnt + 1;
      end
   end
   else begin
      writeBitCnt <= writeBitCnt;
   end
end

// read block counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      readBlockCnt <= 0;
   end
   else if (cmdState == IDLE) begin
      readBlockCnt <= 0;
   end
   else if (readStartBit) begin
      if (readByteCnt == 7 & readBitCnt == 7) begin
         if (readBlockCnt == 15) begin
            readBlockCnt <= readBlockCnt;
	 end
	 else begin
            readBlockCnt <= readBlockCnt + 1;
         end
      end
      else begin
         readBlockCnt <= readBlockCnt;
      end
   end
   else begin
      readBlockCnt <= readBlockCnt;
   end
end

// read byte counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      readByteCnt <= 0;
   end
   else if (cmdState == IDLE) begin
      readByteCnt <= 0;
   end
   else if (readStartBit) begin
      if (readBitCnt == 7) begin
         if (readByteCnt == 7 & readBlockCnt == 15) begin
            readByteCnt <= readByteCnt;
	 end
	 else begin
            readByteCnt <= readByteCnt + 1;
	 end
      end
      else begin
         readByteCnt <= readByteCnt;
      end
   end
   else begin
      readByteCnt <= readByteCnt;
   end
end

// read bit counter
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      readBitCnt <= 0;
   end
   else if (cmdState == IDLE) begin
      readBitCnt <= 0;
   end
   else if (readStartBit) begin
      if (readBlockCnt == 15 & readByteCnt == 7 & readBitCnt == 7) begin
         readBitCnt <= readBitCnt;
      end
      else begin
         readBitCnt <= readBitCnt + 1;
      end
   end
   else begin
      readBitCnt <= readBitCnt;
   end
end


// crc reset
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeCrcRst <= 1'b1;
      readCrcRst <= 1'b1;
   end
   else begin
      case (cmdState)
      RESET: begin
         writeCrcRst <= 1'b1;
         readCrcRst <= 1'b1;
      end
      IDLE: begin
         writeCrcRst <= 1'b1;
         readCrcRst <= 1'b1;
      end
      WRITE_WAIT: begin
         writeCrcRst <= 1'b0;
      end
      READ_START: begin
         readCrcRst <= 1'b0;
      end
      endcase // case (cmdState)
   end
end

// crc counters
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
       writeCrcCnt <= 15;
       readCrcCnt<= 15;
   end
   else begin
      case (cmdState)
      RESET: begin
         writeCrcCnt <= 15;
         readCrcCnt<= 15;
      end
      IDLE: begin
          writeCrcCnt <= 15;
          readCrcCnt<= 15;
      end
      WRITE_CRC: begin
          writeCrcCnt <= writeCrcCnt - 1;
      end
      READ: begin
//         if (readBitCnt == 7 & readByteCnt == 7 & readBlockCnt == 15)
//            readCrcCnt <= readCrcCnt - 1;
//         else
            readCrcCnt <= readCrcCnt;
      end

      READ_CRC: begin
          readCrcCnt<= readCrcCnt - 1;
      end
      endcase // case (cmdState)
   end
end

      
// start bit detector / generator
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeStartBit <= 1'b0;
      readStartBit  <= 1'b0;
   end
   else begin
   case (cmdState)
   RESET : begin
      writeStartBit <= 1'b0;
      readStartBit <= 1'b0;
   end
   IDLE: begin
      writeStartBit <= 1'b0;
      readStartBit <= 1'b0;      
   end
   WRITE_START : begin
      writeStartBit <= 1'b1;
   end
   WRITE_CRC: begin
      writeStartBit <= 1'b0;
   end
   READ_START: begin
      if (~sdDataIn[3] & ~sdDataIn[2] & ~sdDataIn[1] & ~sdDataIn[0]) begin
         readStartBit <= 1'b1;
      end
      else begin
         readStartBit <= 1'b0;
      end
   end
   READ: begin
      writeStartBit <= 1'b0;
      readStartBit <= 1'b1;
   end
   READ_CRC : begin
      writeStartBit <= 1'b0;
      readStartBit <= 1'b0;      
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
      case(cmdState) // synthesis parallel_case
      RESET: begin
         cmdState <= IDLE;
      end
      IDLE: begin
         if (writeCmd) 
	    cmdState <= WRITE_WAIT;
         else if (readCmd) 
	    cmdState <= READ_START;
	 else 
	    cmdState <= IDLE;
      end
      WRITE_WAIT: begin
         cmdState <= WRITE_WAIT1;
      end
      WRITE_WAIT1: begin
         cmdState <= WRITE_WAIT2;
      end
      WRITE_WAIT2: begin
         cmdState <= WRITE_START;
      end
      WRITE_START: begin
         cmdState <= WRITE;
      end
      WRITE: begin
         if (writeBlockCnt == 15 & writeByteCnt == 7 & writeBitCnt == 7)
            cmdState <= WRITE_CRC;
         else 
            cmdState <= WRITE;
      end
      WRITE_CRC: begin
         if (writeCrcCnt == 0) 
            cmdState <= WRITE_STOP;
	 else 
	    cmdState <= WRITE_CRC;
      end
      WRITE_STOP: begin
         cmdState <= WRITE_TURN;
      end
      WRITE_TURN: begin
         cmdState <= WRITE_TURN1;
      end
      WRITE_TURN1: begin
         cmdState <= WRITE_STAT0;
      end
      WRITE_STAT0: begin
         cmdState <= WRITE_STAT1;
      end
      WRITE_STAT1: begin
         cmdState <= WRITE_STAT2;
      end
      WRITE_STAT2: begin
         cmdState <= WRITE_STAT3;
      end
      WRITE_STAT3: begin
         cmdState <= WRITE_STAT4;
      end
      WRITE_STAT4: begin
         cmdState <= WRITE_STAT5;
      end
      WRITE_STAT5: begin
         cmdState <= BUSY_CHK;
      end
      BUSY_CHK: begin
         if (~sdDataIn[0]) 
            cmdState <= BUSY_CHK;
	 else 
	    cmdState <= NOT_BUSY;
      end
      NOT_BUSY: begin
         cmdState <= IDLE;
      end
      READ_START: begin
         if (~sdDataIn) 
            cmdState <= READ;
         else 
            cmdState <= READ_START;
      end
      READ: begin
         if (readBlockCnt == 15 & readByteCnt == 7 & readBitCnt == 7 & ~sdStatusCmd) 
            cmdState <= READ_CRC;
         else if (readBlockCnt == 1 & readByteCnt == 7 & readBitCnt == 7 & sdStatusCmd) 
            cmdState <= READ_CRC;
         else 
            cmdState <= READ;
      end
      READ_CRC: begin
         if (readCrcCnt == 0) 
            cmdState <= CRC_CHK;
         else 
            cmdState <= READ_CRC;
      end
      CRC_CHK: begin
         cmdState <= IDLE;
      end
//      default : DEAD;
      endcase // case (cmdState)
   end
end

// state outputs
always @(posedge sdClk) begin
  case(cmdState) // synthesis parallel_case full_case
     RESET: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     IDLE: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus <= 4'b0;
     end
     WRITE_WAIT: begin
	writeFifoRe <= 1'b1;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_WAIT1: begin
	writeFifoRe <= 1'b1;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b1;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_WAIT2: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b1;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_START: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b1;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE: begin
        if (writeByteCnt == 1 & writeBitCnt == 7) begin
   	   writeFifoRe <= 1'b1;
        end
        else if (writeByteCnt == 3 & writeBitCnt == 7) begin
   	   writeFifoRe <= 1'b1;
        end
        else if (writeByteCnt == 5 & writeBitCnt == 7 & writeBlockCnt < 15) begin
   	   writeFifoRe <= 1'b1;
        end
        else if (writeByteCnt == 7 & writeBitCnt == 7 & writeBlockCnt < 15) begin
   	   writeFifoRe <= 1'b1;
        end
        else begin
           writeFifoRe <= 1'b0;
        end
	readFifoWe  <= 1'b0;
        if (writeByteCnt == 7 & writeBitCnt == 7 & writeBlockCnt == 15) begin
           writeCrcEnable <= 1'b0;
        end
        else begin
           writeCrcEnable <= 1'b1;
        end
        readCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_CRC: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_STOP: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b1;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_TURN: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_TURN: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_TURN1: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     WRITE_STAT0: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus[5] <= sdDataIn[0];
     end
     WRITE_STAT1: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus[4] <= sdDataIn[0];
     end
     WRITE_STAT2: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus[3] <= sdDataIn[0];
     end
     WRITE_STAT3: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus[2] <= sdDataIn[0];
     end
     WRITE_STAT4: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus[1] <= sdDataIn[0];
     end
     WRITE_STAT5: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
        writeStatus[0] <= sdDataIn[0];
     end
      BUSY_CHK: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
      end
      NOT_BUSY: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b1;
        readDone    <= 1'b0;
      end
     READ_START: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        if (~sdDataIn[3] & ~sdDataIn[2] & ~sdDataIn[1] & ~sdDataIn[0]) begin
           readCrcEnable <= 1'b1;
        end
        else begin
           readCrcEnable <= 1'b0;
	end
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     READ: begin
        if (readByteCnt == 1 & readBitCnt == 7) begin
   	   readFifoWe <= 1'b1;
        end
        else if (readByteCnt == 3 & readBitCnt == 7) begin
   	   readFifoWe <= 1'b1;
        end
        else if (readByteCnt == 5 & readBitCnt == 7) begin
   	   readFifoWe <= 1'b1;
        end
        else if (readByteCnt == 7 & readBitCnt == 7) begin
   	   readFifoWe <= 1'b1;
        end
        else begin
           readFifoWe <= 1'b0;
        end
	writeFifoRe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        if (readByteCnt == 7 & readBitCnt == 7 & readBlockCnt == 15 & ~sdStatusCmd) begin
	   readCrcEnable <= 1'b0;
	end
        else if (readByteCnt == 7 & readBitCnt == 7 & readBlockCnt == 1 & sdStatusCmd) begin
	   readCrcEnable <= 1'b0;
	end
	else begin
           readCrcEnable <= 1'b1;
	end
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
     READ_CRC: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b0;
     end
      CRC_CHK: begin
	writeFifoRe <= 1'b0;
	readFifoWe  <= 1'b0;
        writeCrcEnable <= 1'b0;
        readCrcEnable <= 1'b0;
        sdDataEn    <= 1'b0;
        writeDone   <= 1'b0;
        readDone    <= 1'b1;
     end
  endcase
end

// capture write data
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeData0 <= 64'h0;
   end
   else if (cmdState == WRITE_WAIT2) begin
      writeData0 <= writeDataIn[63:0];
   end
   else if (cmdState == WRITE & writeByteCnt == 1) begin
      writeData0[31:0] <= writeData1[31:0];
   end
   else if (cmdState == WRITE & writeByteCnt == 3) begin
      writeData0[63:32] <= writeData1[63:32];
   end
   else if (cmdState == WRITE & writeByteCnt == 5) begin
      writeData0[31:0] <= writeData1[31:0];
   end
   else if (cmdState == WRITE & writeByteCnt == 7) begin
      writeData0[63:32] <= writeData1[63:32];
   end
   else begin
      writeData0 <= writeData0;
   end
end

// capture write data
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      writeData1 <= 64'h0;
   end
   else if (writeFifoRe) begin
      writeData1 <= writeDataIn[63:0];
   end
   else begin
      writeData1 <= writeData1;
   end
end


// output write data
always @(posedge sdClk)
begin
   case (cmdState) // synthesis parallel_case full_case
   RESET: begin
      sdDataOut <= 4'hF;
      writeCrcIn <= 4'h0;
   end
   IDLE: begin
      sdDataOut <= 4'hF;
      writeCrcIn <= 4'h0;
   end
   WRITE_WAIT: begin
      sdDataOut <= 4'hF;
      writeCrcIn <= 4'h0;
   end
   WRITE_WAIT1: begin
      sdDataOut <= 4'hF;
      writeCrcIn <= 4'h0;
   end
   WRITE_WAIT2: begin
      sdDataOut <= 4'hF;
      writeCrcIn <= 4'h0;
   end
   WRITE_START: begin
      sdDataOut <= 4'h0;
      writeCrcIn[3]  <= writeData0[7];
      writeCrcIn[2]  <= writeData0[6];
      writeCrcIn[1]  <= writeData0[5];
      writeCrcIn[0]  <= writeData0[4];
   end
   WRITE_CRC: begin
      sdDataOut[3] <= writeCrcValue3[writeCrcCnt];
      sdDataOut[2] <= writeCrcValue2[writeCrcCnt];
      sdDataOut[1] <= writeCrcValue1[writeCrcCnt];
      sdDataOut[0] <= writeCrcValue0[writeCrcCnt];
      writeCrcIn <= 4'h0;
   end
   WRITE: begin
   case (writeByteCnt)
      0: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[7];
	    sdDataOut[2] <= writeData0[6];
	    sdDataOut[1] <= writeData0[5];
	    sdDataOut[0] <= writeData0[4];
            writeCrcIn[3] <= writeData0[3];
	    writeCrcIn[2] <= writeData0[2];
	    writeCrcIn[1] <= writeData0[1];
	    writeCrcIn[0] <= writeData0[0];
	 end
         1: begin
            sdDataOut[3] <= writeData0[3];
	    sdDataOut[2] <= writeData0[2];
	    sdDataOut[1] <= writeData0[1];
	    sdDataOut[0] <= writeData0[0];
            writeCrcIn[3] <= writeData0[15];
	    writeCrcIn[2] <= writeData0[14];
	    writeCrcIn[1] <= writeData0[13];
	    writeCrcIn[0] <= writeData0[12];
	 end
         2: begin
            sdDataOut[3] <= writeData0[15];
	    sdDataOut[2] <= writeData0[14];
	    sdDataOut[1] <= writeData0[13];
	    sdDataOut[0] <= writeData0[12];
            writeCrcIn[3] <= writeData0[11];
	    writeCrcIn[2] <= writeData0[10];
	    writeCrcIn[1] <= writeData0[9];
	    writeCrcIn[0] <= writeData0[8];
	 end
         3: begin
            sdDataOut[3] <= writeData0[11];
	    sdDataOut[2] <= writeData0[10];
	    sdDataOut[1] <= writeData0[9];
	    sdDataOut[0] <= writeData0[8];
            writeCrcIn[3] <= writeData0[23];
	    writeCrcIn[2] <= writeData0[22];
	    writeCrcIn[1] <= writeData0[21];
	    writeCrcIn[0] <= writeData0[20];
	 end
         4: begin
            sdDataOut[3] <= writeData0[23];
	    sdDataOut[2] <= writeData0[22];
	    sdDataOut[1] <= writeData0[21];
	    sdDataOut[0] <= writeData0[20];
            writeCrcIn[3] <= writeData0[19];
	    writeCrcIn[2] <= writeData0[18];
	    writeCrcIn[1] <= writeData0[17];
	    writeCrcIn[0] <= writeData0[16];
	 end
         5: begin
            sdDataOut[3] <= writeData0[19];
	    sdDataOut[2] <= writeData0[18];
	    sdDataOut[1] <= writeData0[17];
	    sdDataOut[0] <= writeData0[16];
            writeCrcIn[3] <= writeData0[31];
	    writeCrcIn[2] <= writeData0[30];
	    writeCrcIn[1] <= writeData0[29];
	    writeCrcIn[0] <= writeData0[28];
	 end
         6: begin
            sdDataOut[3] <= writeData0[31];
	    sdDataOut[2] <= writeData0[30];
	    sdDataOut[1] <= writeData0[29];
	    sdDataOut[0] <= writeData0[28];
            writeCrcIn[3] <= writeData0[27];
	    writeCrcIn[2] <= writeData0[26];
	    writeCrcIn[1] <= writeData0[25];
	    writeCrcIn[0] <= writeData0[24];
	 end
         7: begin
            sdDataOut[3] <= writeData0[27];
	    sdDataOut[2] <= writeData0[26];
	    sdDataOut[1] <= writeData0[25];
	    sdDataOut[0] <= writeData0[24];
            writeCrcIn[3] <= writeData0[39];
	    writeCrcIn[2] <= writeData0[38];
	    writeCrcIn[1] <= writeData0[37];
	    writeCrcIn[0] <= writeData0[36];
	 end
	 endcase // case (writeBitCnt)
      end
      1: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[39];
	    sdDataOut[2] <= writeData0[38];
	    sdDataOut[1] <= writeData0[37];
	    sdDataOut[0] <= writeData0[36];
            writeCrcIn[3] <= writeData0[35];
	    writeCrcIn[2] <= writeData0[34];
	    writeCrcIn[1] <= writeData0[33];
	    writeCrcIn[0] <= writeData0[32];
	 end
         1: begin
            sdDataOut[3] <= writeData0[35];
	    sdDataOut[2] <= writeData0[34];
	    sdDataOut[1] <= writeData0[33];
	    sdDataOut[0] <= writeData0[32];
            writeCrcIn[3] <= writeData0[47];
	    writeCrcIn[2] <= writeData0[46];
	    writeCrcIn[1] <= writeData0[45];
	    writeCrcIn[0] <= writeData0[44];
	 end
         2: begin
            sdDataOut[3] <= writeData0[47];
	    sdDataOut[2] <= writeData0[46];
	    sdDataOut[1] <= writeData0[45];
	    sdDataOut[0] <= writeData0[44];
            writeCrcIn[3] <= writeData0[43];
	    writeCrcIn[2] <= writeData0[42];
	    writeCrcIn[1] <= writeData0[41];
	    writeCrcIn[0] <= writeData0[40];
	 end
         3: begin
            sdDataOut[3] <= writeData0[43];
	    sdDataOut[2] <= writeData0[42];
	    sdDataOut[1] <= writeData0[41];
	    sdDataOut[0] <= writeData0[40];
            writeCrcIn[3] <= writeData0[55];
	    writeCrcIn[2] <= writeData0[54];
	    writeCrcIn[1] <= writeData0[53];
	    writeCrcIn[0] <= writeData0[52];
	 end
         4: begin
            sdDataOut[3] <= writeData0[55];
	    sdDataOut[2] <= writeData0[54];
	    sdDataOut[1] <= writeData0[53];
	    sdDataOut[0] <= writeData0[52];
            writeCrcIn[3] <= writeData0[51];
	    writeCrcIn[2] <= writeData0[50];
	    writeCrcIn[1] <= writeData0[49];
	    writeCrcIn[0] <= writeData0[48];
	 end
         5: begin
            sdDataOut[3] <= writeData0[51];
	    sdDataOut[2] <= writeData0[50];
	    sdDataOut[1] <= writeData0[49];
	    sdDataOut[0] <= writeData0[48];
            writeCrcIn[3] <= writeData0[63];
	    writeCrcIn[2] <= writeData0[62];
	    writeCrcIn[1] <= writeData0[61];
	    writeCrcIn[0] <= writeData0[60];
	 end
         6: begin
            sdDataOut[3] <= writeData0[63];
	    sdDataOut[2] <= writeData0[62];
	    sdDataOut[1] <= writeData0[61];
	    sdDataOut[0] <= writeData0[60];
            writeCrcIn[3] <= writeData0[59];
	    writeCrcIn[2] <= writeData0[58];
	    writeCrcIn[1] <= writeData0[57];
	    writeCrcIn[0] <= writeData0[56];
	 end
         7: begin
            sdDataOut[3] <= writeData0[59];
	    sdDataOut[2] <= writeData0[58];
	    sdDataOut[1] <= writeData0[57];
	    sdDataOut[0] <= writeData0[56];
            writeCrcIn[3] <= writeData0[7];
	    writeCrcIn[2] <= writeData0[6];
	    writeCrcIn[1] <= writeData0[5];
	    writeCrcIn[0] <= writeData0[4];
	 end
	 endcase // case (writeBitCnt)
      end
      2: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[7];
	    sdDataOut[2] <= writeData0[6];
	    sdDataOut[1] <= writeData0[5];
	    sdDataOut[0] <= writeData0[4];
            writeCrcIn[3] <= writeData0[3];
	    writeCrcIn[2] <= writeData0[2];
	    writeCrcIn[1] <= writeData0[1];
	    writeCrcIn[0] <= writeData0[0];
	 end
         1: begin
            sdDataOut[3] <= writeData0[3];
	    sdDataOut[2] <= writeData0[2];
	    sdDataOut[1] <= writeData0[1];
	    sdDataOut[0] <= writeData0[0];
            writeCrcIn[3] <= writeData0[15];
	    writeCrcIn[2] <= writeData0[14];
	    writeCrcIn[1] <= writeData0[13];
	    writeCrcIn[0] <= writeData0[12];
	 end
         2: begin
            sdDataOut[3] <= writeData0[15];
	    sdDataOut[2] <= writeData0[14];
	    sdDataOut[1] <= writeData0[13];
	    sdDataOut[0] <= writeData0[12];
            writeCrcIn[3] <= writeData0[11];
	    writeCrcIn[2] <= writeData0[10];
	    writeCrcIn[1] <= writeData0[9];
	    writeCrcIn[0] <= writeData0[8];
	 end
         3: begin
            sdDataOut[3] <= writeData0[11];
	    sdDataOut[2] <= writeData0[10];
	    sdDataOut[1] <= writeData0[9];
	    sdDataOut[0] <= writeData0[8];
            writeCrcIn[3] <= writeData0[23];
	    writeCrcIn[2] <= writeData0[22];
	    writeCrcIn[1] <= writeData0[21];
	    writeCrcIn[0] <= writeData0[20];
	 end
         4: begin
            sdDataOut[3] <= writeData0[23];
	    sdDataOut[2] <= writeData0[22];
	    sdDataOut[1] <= writeData0[21];
	    sdDataOut[0] <= writeData0[20];
            writeCrcIn[3] <= writeData0[19];
	    writeCrcIn[2] <= writeData0[18];
	    writeCrcIn[1] <= writeData0[17];
	    writeCrcIn[0] <= writeData0[16];
	 end
         5: begin
            sdDataOut[3] <= writeData0[19];
	    sdDataOut[2] <= writeData0[18];
	    sdDataOut[1] <= writeData0[17];
	    sdDataOut[0] <= writeData0[16];
            writeCrcIn[3] <= writeData0[31];
	    writeCrcIn[2] <= writeData0[30];
	    writeCrcIn[1] <= writeData0[29];
	    writeCrcIn[0] <= writeData0[28];
	 end
         6: begin
            sdDataOut[3] <= writeData0[31];
	    sdDataOut[2] <= writeData0[30];
	    sdDataOut[1] <= writeData0[29];
	    sdDataOut[0] <= writeData0[28];
            writeCrcIn[3] <= writeData0[27];
	    writeCrcIn[2] <= writeData0[26];
	    writeCrcIn[1] <= writeData0[25];
	    writeCrcIn[0] <= writeData0[24];
	 end
         7: begin
            sdDataOut[3] <= writeData0[27];
	    sdDataOut[2] <= writeData0[26];
	    sdDataOut[1] <= writeData0[25];
	    sdDataOut[0] <= writeData0[24];
            writeCrcIn[3] <= writeData0[39];
	    writeCrcIn[2] <= writeData0[38];
	    writeCrcIn[1] <= writeData0[37];
	    writeCrcIn[0] <= writeData0[36];
	 end
	 endcase // case (writeBitCnt)
      end
      3: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[39];
	    sdDataOut[2] <= writeData0[38];
	    sdDataOut[1] <= writeData0[37];
	    sdDataOut[0] <= writeData0[36];
            writeCrcIn[3] <= writeData0[35];
	    writeCrcIn[2] <= writeData0[34];
	    writeCrcIn[1] <= writeData0[33];
	    writeCrcIn[0] <= writeData0[32];
	 end
         1: begin
            sdDataOut[3] <= writeData0[35];
	    sdDataOut[2] <= writeData0[34];
	    sdDataOut[1] <= writeData0[33];
	    sdDataOut[0] <= writeData0[32];
            writeCrcIn[3] <= writeData0[47];
	    writeCrcIn[2] <= writeData0[46];
	    writeCrcIn[1] <= writeData0[45];
	    writeCrcIn[0] <= writeData0[44];
	 end
         2: begin
            sdDataOut[3] <= writeData0[47];
	    sdDataOut[2] <= writeData0[46];
	    sdDataOut[1] <= writeData0[45];
	    sdDataOut[0] <= writeData0[44];
            writeCrcIn[3] <= writeData0[43];
	    writeCrcIn[2] <= writeData0[42];
	    writeCrcIn[1] <= writeData0[41];
	    writeCrcIn[0] <= writeData0[40];
	 end
         3: begin
            sdDataOut[3] <= writeData0[43];
	    sdDataOut[2] <= writeData0[42];
	    sdDataOut[1] <= writeData0[41];
	    sdDataOut[0] <= writeData0[40];
            writeCrcIn[3] <= writeData0[55];
	    writeCrcIn[2] <= writeData0[54];
	    writeCrcIn[1] <= writeData0[53];
	    writeCrcIn[0] <= writeData0[52];
	 end
         4: begin
            sdDataOut[3] <= writeData0[55];
	    sdDataOut[2] <= writeData0[54];
	    sdDataOut[1] <= writeData0[53];
	    sdDataOut[0] <= writeData0[52];
            writeCrcIn[3] <= writeData0[51];
	    writeCrcIn[2] <= writeData0[50];
	    writeCrcIn[1] <= writeData0[49];
	    writeCrcIn[0] <= writeData0[48];
	 end
         5: begin
            sdDataOut[3] <= writeData0[51];
	    sdDataOut[2] <= writeData0[50];
	    sdDataOut[1] <= writeData0[49];
	    sdDataOut[0] <= writeData0[48];
            writeCrcIn[3] <= writeData0[63];
	    writeCrcIn[2] <= writeData0[62];
	    writeCrcIn[1] <= writeData0[61];
	    writeCrcIn[0] <= writeData0[60];
	 end
         6: begin
            sdDataOut[3] <= writeData0[63];
	    sdDataOut[2] <= writeData0[62];
	    sdDataOut[1] <= writeData0[61];
	    sdDataOut[0] <= writeData0[60];
            writeCrcIn[3] <= writeData0[59];
	    writeCrcIn[2] <= writeData0[58];
	    writeCrcIn[1] <= writeData0[57];
	    writeCrcIn[0] <= writeData0[56];
	 end
         7: begin
            sdDataOut[3] <= writeData0[59];
	    sdDataOut[2] <= writeData0[58];
	    sdDataOut[1] <= writeData0[57];
	    sdDataOut[0] <= writeData0[56];
            writeCrcIn[3] <= writeData0[7];
	    writeCrcIn[2] <= writeData0[6];
	    writeCrcIn[1] <= writeData0[5];
	    writeCrcIn[0] <= writeData0[4];
	 end
	 endcase // case (writeBitCnt)
      end
      4: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[7];
	    sdDataOut[2] <= writeData0[6];
	    sdDataOut[1] <= writeData0[5];
	    sdDataOut[0] <= writeData0[4];
            writeCrcIn[3] <= writeData0[3];
	    writeCrcIn[2] <= writeData0[2];
	    writeCrcIn[1] <= writeData0[1];
	    writeCrcIn[0] <= writeData0[0];
	 end
         1: begin
            sdDataOut[3] <= writeData0[3];
	    sdDataOut[2] <= writeData0[2];
	    sdDataOut[1] <= writeData0[1];
	    sdDataOut[0] <= writeData0[0];
            writeCrcIn[3] <= writeData0[15];
	    writeCrcIn[2] <= writeData0[14];
	    writeCrcIn[1] <= writeData0[13];
	    writeCrcIn[0] <= writeData0[12];
	 end
         2: begin
            sdDataOut[3] <= writeData0[15];
	    sdDataOut[2] <= writeData0[14];
	    sdDataOut[1] <= writeData0[13];
	    sdDataOut[0] <= writeData0[12];
            writeCrcIn[3] <= writeData0[11];
	    writeCrcIn[2] <= writeData0[10];
	    writeCrcIn[1] <= writeData0[9];
	    writeCrcIn[0] <= writeData0[8];
	 end
         3: begin
            sdDataOut[3] <= writeData0[11];
	    sdDataOut[2] <= writeData0[10];
	    sdDataOut[1] <= writeData0[9];
	    sdDataOut[0] <= writeData0[8];
            writeCrcIn[3] <= writeData0[23];
	    writeCrcIn[2] <= writeData0[22];
	    writeCrcIn[1] <= writeData0[21];
	    writeCrcIn[0] <= writeData0[20];
	 end
         4: begin
            sdDataOut[3] <= writeData0[23];
	    sdDataOut[2] <= writeData0[22];
	    sdDataOut[1] <= writeData0[21];
	    sdDataOut[0] <= writeData0[20];
            writeCrcIn[3] <= writeData0[19];
	    writeCrcIn[2] <= writeData0[18];
	    writeCrcIn[1] <= writeData0[17];
	    writeCrcIn[0] <= writeData0[16];
	 end
         5: begin
            sdDataOut[3] <= writeData0[19];
	    sdDataOut[2] <= writeData0[18];
	    sdDataOut[1] <= writeData0[17];
	    sdDataOut[0] <= writeData0[16];
            writeCrcIn[3] <= writeData0[31];
	    writeCrcIn[2] <= writeData0[30];
	    writeCrcIn[1] <= writeData0[29];
	    writeCrcIn[0] <= writeData0[28];
	 end
         6: begin
            sdDataOut[3] <= writeData0[31];
	    sdDataOut[2] <= writeData0[30];
	    sdDataOut[1] <= writeData0[29];
	    sdDataOut[0] <= writeData0[28];
            writeCrcIn[3] <= writeData0[27];
	    writeCrcIn[2] <= writeData0[26];
	    writeCrcIn[1] <= writeData0[25];
	    writeCrcIn[0] <= writeData0[24];
	 end
         7: begin
            sdDataOut[3] <= writeData0[27];
	    sdDataOut[2] <= writeData0[26];
	    sdDataOut[1] <= writeData0[25];
	    sdDataOut[0] <= writeData0[24];
            writeCrcIn[3] <= writeData0[39];
	    writeCrcIn[2] <= writeData0[38];
	    writeCrcIn[1] <= writeData0[37];
	    writeCrcIn[0] <= writeData0[36];
	 end
	 endcase // case (writeBitCnt)
      end
      5: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[39];
	    sdDataOut[2] <= writeData0[38];
	    sdDataOut[1] <= writeData0[37];
	    sdDataOut[0] <= writeData0[36];
            writeCrcIn[3] <= writeData0[35];
	    writeCrcIn[2] <= writeData0[34];
	    writeCrcIn[1] <= writeData0[33];
	    writeCrcIn[0] <= writeData0[32];
	 end
         1: begin
            sdDataOut[3] <= writeData0[35];
	    sdDataOut[2] <= writeData0[34];
	    sdDataOut[1] <= writeData0[33];
	    sdDataOut[0] <= writeData0[32];
            writeCrcIn[3] <= writeData0[47];
	    writeCrcIn[2] <= writeData0[46];
	    writeCrcIn[1] <= writeData0[45];
	    writeCrcIn[0] <= writeData0[44];
	 end
         2: begin
            sdDataOut[3] <= writeData0[47];
	    sdDataOut[2] <= writeData0[46];
	    sdDataOut[1] <= writeData0[45];
	    sdDataOut[0] <= writeData0[44];
            writeCrcIn[3] <= writeData0[43];
	    writeCrcIn[2] <= writeData0[42];
	    writeCrcIn[1] <= writeData0[41];
	    writeCrcIn[0] <= writeData0[40];
	 end
         3: begin
            sdDataOut[3] <= writeData0[43];
	    sdDataOut[2] <= writeData0[42];
	    sdDataOut[1] <= writeData0[41];
	    sdDataOut[0] <= writeData0[40];
            writeCrcIn[3] <= writeData0[55];
	    writeCrcIn[2] <= writeData0[54];
	    writeCrcIn[1] <= writeData0[53];
	    writeCrcIn[0] <= writeData0[52];
	 end
         4: begin
            sdDataOut[3] <= writeData0[55];
	    sdDataOut[2] <= writeData0[54];
	    sdDataOut[1] <= writeData0[53];
	    sdDataOut[0] <= writeData0[52];
            writeCrcIn[3] <= writeData0[51];
	    writeCrcIn[2] <= writeData0[50];
	    writeCrcIn[1] <= writeData0[49];
	    writeCrcIn[0] <= writeData0[48];
	 end
         5: begin
            sdDataOut[3] <= writeData0[51];
	    sdDataOut[2] <= writeData0[50];
	    sdDataOut[1] <= writeData0[49];
	    sdDataOut[0] <= writeData0[48];
            writeCrcIn[3] <= writeData0[63];
	    writeCrcIn[2] <= writeData0[62];
	    writeCrcIn[1] <= writeData0[61];
	    writeCrcIn[0] <= writeData0[60];
	 end
         6: begin
            sdDataOut[3] <= writeData0[63];
	    sdDataOut[2] <= writeData0[62];
	    sdDataOut[1] <= writeData0[61];
	    sdDataOut[0] <= writeData0[60];
            writeCrcIn[3] <= writeData0[59];
	    writeCrcIn[2] <= writeData0[58];
	    writeCrcIn[1] <= writeData0[57];
	    writeCrcIn[0] <= writeData0[56];
	 end
         7: begin
            sdDataOut[3] <= writeData0[59];
	    sdDataOut[2] <= writeData0[58];
	    sdDataOut[1] <= writeData0[57];
	    sdDataOut[0] <= writeData0[56];
            writeCrcIn[3] <= writeData0[7];
	    writeCrcIn[2] <= writeData0[6];
	    writeCrcIn[1] <= writeData0[5];
	    writeCrcIn[0] <= writeData0[4];
	 end
	 endcase // case (writeBitCnt)
      end
      6: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[7];
	    sdDataOut[2] <= writeData0[6];
	    sdDataOut[1] <= writeData0[5];
	    sdDataOut[0] <= writeData0[4];
            writeCrcIn[3] <= writeData0[3];
	    writeCrcIn[2] <= writeData0[2];
	    writeCrcIn[1] <= writeData0[1];
	    writeCrcIn[0] <= writeData0[0];
	 end
         1: begin
            sdDataOut[3] <= writeData0[3];
	    sdDataOut[2] <= writeData0[2];
	    sdDataOut[1] <= writeData0[1];
	    sdDataOut[0] <= writeData0[0];
            writeCrcIn[3] <= writeData0[15];
	    writeCrcIn[2] <= writeData0[14];
	    writeCrcIn[1] <= writeData0[13];
	    writeCrcIn[0] <= writeData0[12];
	 end
         2: begin
            sdDataOut[3] <= writeData0[15];
	    sdDataOut[2] <= writeData0[14];
	    sdDataOut[1] <= writeData0[13];
	    sdDataOut[0] <= writeData0[12];
            writeCrcIn[3] <= writeData0[11];
	    writeCrcIn[2] <= writeData0[10];
	    writeCrcIn[1] <= writeData0[9];
	    writeCrcIn[0] <= writeData0[8];
	 end
         3: begin
            sdDataOut[3] <= writeData0[11];
	    sdDataOut[2] <= writeData0[10];
	    sdDataOut[1] <= writeData0[9];
	    sdDataOut[0] <= writeData0[8];
            writeCrcIn[3] <= writeData0[23];
	    writeCrcIn[2] <= writeData0[22];
	    writeCrcIn[1] <= writeData0[21];
	    writeCrcIn[0] <= writeData0[20];
	 end
         4: begin
            sdDataOut[3] <= writeData0[23];
	    sdDataOut[2] <= writeData0[22];
	    sdDataOut[1] <= writeData0[21];
	    sdDataOut[0] <= writeData0[20];
            writeCrcIn[3] <= writeData0[19];
	    writeCrcIn[2] <= writeData0[18];
	    writeCrcIn[1] <= writeData0[17];
	    writeCrcIn[0] <= writeData0[16];
	 end
         5: begin
            sdDataOut[3] <= writeData0[19];
	    sdDataOut[2] <= writeData0[18];
	    sdDataOut[1] <= writeData0[17];
	    sdDataOut[0] <= writeData0[16];
            writeCrcIn[3] <= writeData0[31];
	    writeCrcIn[2] <= writeData0[30];
	    writeCrcIn[1] <= writeData0[29];
	    writeCrcIn[0] <= writeData0[28];
	 end
         6: begin
            sdDataOut[3] <= writeData0[31];
	    sdDataOut[2] <= writeData0[30];
	    sdDataOut[1] <= writeData0[29];
	    sdDataOut[0] <= writeData0[28];
            writeCrcIn[3] <= writeData0[27];
	    writeCrcIn[2] <= writeData0[26];
	    writeCrcIn[1] <= writeData0[25];
	    writeCrcIn[0] <= writeData0[24];
	 end
         7: begin
            sdDataOut[3] <= writeData0[27];
	    sdDataOut[2] <= writeData0[26];
	    sdDataOut[1] <= writeData0[25];
	    sdDataOut[0] <= writeData0[24];
            writeCrcIn[3] <= writeData0[39];
	    writeCrcIn[2] <= writeData0[38];
	    writeCrcIn[1] <= writeData0[37];
	    writeCrcIn[0] <= writeData0[36];
	 end
	 endcase // case (writeBitCnt)
      end
      7: begin
         case(writeBitCnt) 
         0: begin
            sdDataOut[3] <= writeData0[39];
	    sdDataOut[2] <= writeData0[38];
	    sdDataOut[1] <= writeData0[37];
	    sdDataOut[0] <= writeData0[36];
            writeCrcIn[3] <= writeData0[35];
	    writeCrcIn[2] <= writeData0[34];
	    writeCrcIn[1] <= writeData0[33];
	    writeCrcIn[0] <= writeData0[32];
	 end
         1: begin
            sdDataOut[3] <= writeData0[35];
	    sdDataOut[2] <= writeData0[34];
	    sdDataOut[1] <= writeData0[33];
	    sdDataOut[0] <= writeData0[32];
            writeCrcIn[3] <= writeData0[47];
	    writeCrcIn[2] <= writeData0[46];
	    writeCrcIn[1] <= writeData0[45];
	    writeCrcIn[0] <= writeData0[44];
	 end
         2: begin
            sdDataOut[3] <= writeData0[47];
	    sdDataOut[2] <= writeData0[46];
	    sdDataOut[1] <= writeData0[45];
	    sdDataOut[0] <= writeData0[44];
            writeCrcIn[3] <= writeData0[43];
	    writeCrcIn[2] <= writeData0[42];
	    writeCrcIn[1] <= writeData0[41];
	    writeCrcIn[0] <= writeData0[40];
	 end
         3: begin
            sdDataOut[3] <= writeData0[43];
	    sdDataOut[2] <= writeData0[42];
	    sdDataOut[1] <= writeData0[41];
	    sdDataOut[0] <= writeData0[40];
            writeCrcIn[3] <= writeData0[55];
	    writeCrcIn[2] <= writeData0[54];
	    writeCrcIn[1] <= writeData0[53];
	    writeCrcIn[0] <= writeData0[52];
	 end
         4: begin
            sdDataOut[3] <= writeData0[55];
	    sdDataOut[2] <= writeData0[54];
	    sdDataOut[1] <= writeData0[53];
	    sdDataOut[0] <= writeData0[52];
            writeCrcIn[3] <= writeData0[51];
	    writeCrcIn[2] <= writeData0[50];
	    writeCrcIn[1] <= writeData0[49];
	    writeCrcIn[0] <= writeData0[48];
	 end
         5: begin
            sdDataOut[3] <= writeData0[51];
	    sdDataOut[2] <= writeData0[50];
	    sdDataOut[1] <= writeData0[49];
	    sdDataOut[0] <= writeData0[48];
            writeCrcIn[3] <= writeData0[63];
	    writeCrcIn[2] <= writeData0[62];
	    writeCrcIn[1] <= writeData0[61];
	    writeCrcIn[0] <= writeData0[60];
	 end
         6: begin
            sdDataOut[3] <= writeData0[63];
	    sdDataOut[2] <= writeData0[62];
	    sdDataOut[1] <= writeData0[61];
	    sdDataOut[0] <= writeData0[60];
            writeCrcIn[3] <= writeData0[59];
	    writeCrcIn[2] <= writeData0[58];
	    writeCrcIn[1] <= writeData0[57];
	    writeCrcIn[0] <= writeData0[56];
	 end
         7: begin
            sdDataOut[3] <= writeData0[59];
	    sdDataOut[2] <= writeData0[58];
	    sdDataOut[1] <= writeData0[57];
	    sdDataOut[0] <= writeData0[56];
            writeCrcIn[3] <= writeData0[7];
	    writeCrcIn[2] <= writeData0[6];
	    writeCrcIn[1] <= writeData0[5];
	    writeCrcIn[0] <= writeData0[4];
	 end
	 endcase // case (writeBitCnt)
      end
   endcase // case (writeByteCnt)
   end // case: WRITE
   WRITE_STOP: begin
      sdDataOut <= 4'hF;
      writeCrcIn <= 4'h0;
   end   
   endcase // case (cmdState)
end



// output read data
always @(posedge sdClk or posedge sysRst)
begin
   if (sysRst) begin
      readData <= 64'h0;
   end
   else if (cmdState == READ) begin
   case (readByteCnt)
   0: begin
      case(readBitCnt)
      0: begin
         readData[7] <= sdDataIn[3];
         readData[6] <= sdDataIn[2];
         readData[5] <= sdDataIn[1];
         readData[4] <= sdDataIn[0];
      end
      1: begin
         readData[3] <= sdDataIn[3];
         readData[2] <= sdDataIn[2];
         readData[1] <= sdDataIn[1];
         readData[0] <= sdDataIn[0];
      end
      2: begin
         readData[15] <= sdDataIn[3];
         readData[14] <= sdDataIn[2];
         readData[13] <= sdDataIn[1];
         readData[12] <= sdDataIn[0];
      end
      3: begin
         readData[11] <= sdDataIn[3];
         readData[10] <= sdDataIn[2];
         readData[9]  <= sdDataIn[1];
         readData[8]  <= sdDataIn[0];
      end
      4: begin
         readData[23] <= sdDataIn[3];
         readData[22] <= sdDataIn[2];
         readData[21] <= sdDataIn[1];
         readData[20] <= sdDataIn[0];
      end
      5: begin
         readData[19] <= sdDataIn[3];
         readData[18] <= sdDataIn[2];
         readData[17] <= sdDataIn[1];
         readData[16] <= sdDataIn[0];
      end
      6: begin
         readData[31] <= sdDataIn[3];
         readData[30] <= sdDataIn[2];
         readData[29] <= sdDataIn[1];
         readData[28] <= sdDataIn[0];
      end
      7: begin
         readData[27] <= sdDataIn[3];
         readData[26] <= sdDataIn[2];
         readData[25] <= sdDataIn[1];
         readData[24] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   1: begin
      case(readBitCnt)
      0: begin
         readData[39] <= sdDataIn[3];
         readData[38] <= sdDataIn[2];
         readData[37] <= sdDataIn[1];
         readData[36] <= sdDataIn[0];
      end
      1: begin
         readData[35] <= sdDataIn[3];
         readData[34] <= sdDataIn[2];
         readData[33] <= sdDataIn[1];
         readData[32] <= sdDataIn[0];
      end
      2: begin
         readData[47] <= sdDataIn[3];
         readData[46] <= sdDataIn[2];
         readData[45] <= sdDataIn[1];
         readData[44] <= sdDataIn[0];
      end
      3: begin
         readData[43] <= sdDataIn[3];
         readData[42] <= sdDataIn[2];
         readData[41]  <= sdDataIn[1];
         readData[40]  <= sdDataIn[0];
      end
      4: begin
         readData[55] <= sdDataIn[3];
         readData[54] <= sdDataIn[2];
         readData[53] <= sdDataIn[1];
         readData[52] <= sdDataIn[0];
      end
      5: begin
         readData[51] <= sdDataIn[3];
         readData[50] <= sdDataIn[2];
         readData[49] <= sdDataIn[1];
         readData[48] <= sdDataIn[0];
      end
      6: begin
         readData[63] <= sdDataIn[3];
         readData[62] <= sdDataIn[2];
         readData[61] <= sdDataIn[1];
         readData[60] <= sdDataIn[0];
      end
      7: begin
         readData[59] <= sdDataIn[3];
         readData[58] <= sdDataIn[2];
         readData[57] <= sdDataIn[1];
         readData[56] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   2: begin
      case(readBitCnt)
      0: begin
         readData[7] <= sdDataIn[3];
         readData[6] <= sdDataIn[2];
         readData[5] <= sdDataIn[1];
         readData[4] <= sdDataIn[0];
      end
      1: begin
         readData[3] <= sdDataIn[3];
         readData[2] <= sdDataIn[2];
         readData[1] <= sdDataIn[1];
         readData[0] <= sdDataIn[0];
      end
      2: begin
         readData[15] <= sdDataIn[3];
         readData[14] <= sdDataIn[2];
         readData[13] <= sdDataIn[1];
         readData[12] <= sdDataIn[0];
      end
      3: begin
         readData[11] <= sdDataIn[3];
         readData[10] <= sdDataIn[2];
         readData[9]  <= sdDataIn[1];
         readData[8]  <= sdDataIn[0];
      end
      4: begin
         readData[23] <= sdDataIn[3];
         readData[22] <= sdDataIn[2];
         readData[21] <= sdDataIn[1];
         readData[20] <= sdDataIn[0];
      end
      5: begin
         readData[19] <= sdDataIn[3];
         readData[18] <= sdDataIn[2];
         readData[17] <= sdDataIn[1];
         readData[16] <= sdDataIn[0];
      end
      6: begin
         readData[31] <= sdDataIn[3];
         readData[30] <= sdDataIn[2];
         readData[29] <= sdDataIn[1];
         readData[28] <= sdDataIn[0];
      end
      7: begin
         readData[27] <= sdDataIn[3];
         readData[26] <= sdDataIn[2];
         readData[25] <= sdDataIn[1];
         readData[24] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   3: begin
      case(readBitCnt)
      0: begin
         readData[39] <= sdDataIn[3];
         readData[38] <= sdDataIn[2];
         readData[37] <= sdDataIn[1];
         readData[36] <= sdDataIn[0];
      end
      1: begin
         readData[35] <= sdDataIn[3];
         readData[34] <= sdDataIn[2];
         readData[33] <= sdDataIn[1];
         readData[32] <= sdDataIn[0];
      end
      2: begin
         readData[47] <= sdDataIn[3];
         readData[46] <= sdDataIn[2];
         readData[45] <= sdDataIn[1];
         readData[44] <= sdDataIn[0];
      end
      3: begin
         readData[43] <= sdDataIn[3];
         readData[42] <= sdDataIn[2];
         readData[41]  <= sdDataIn[1];
         readData[40]  <= sdDataIn[0];
      end
      4: begin
         readData[55] <= sdDataIn[3];
         readData[54] <= sdDataIn[2];
         readData[53] <= sdDataIn[1];
         readData[52] <= sdDataIn[0];
      end
      5: begin
         readData[51] <= sdDataIn[3];
         readData[50] <= sdDataIn[2];
         readData[49] <= sdDataIn[1];
         readData[48] <= sdDataIn[0];
      end
      6: begin
         readData[63] <= sdDataIn[3];
         readData[62] <= sdDataIn[2];
         readData[61] <= sdDataIn[1];
         readData[60] <= sdDataIn[0];
      end
      7: begin
         readData[59] <= sdDataIn[3];
         readData[58] <= sdDataIn[2];
         readData[57] <= sdDataIn[1];
         readData[56] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   4: begin
      case(readBitCnt)
      0: begin
         readData[7] <= sdDataIn[3];
         readData[6] <= sdDataIn[2];
         readData[5] <= sdDataIn[1];
         readData[4] <= sdDataIn[0];
      end
      1: begin
         readData[3] <= sdDataIn[3];
         readData[2] <= sdDataIn[2];
         readData[1] <= sdDataIn[1];
         readData[0] <= sdDataIn[0];
      end
      2: begin
         readData[15] <= sdDataIn[3];
         readData[14] <= sdDataIn[2];
         readData[13] <= sdDataIn[1];
         readData[12] <= sdDataIn[0];
      end
      3: begin
         readData[11] <= sdDataIn[3];
         readData[10] <= sdDataIn[2];
         readData[9]  <= sdDataIn[1];
         readData[8]  <= sdDataIn[0];
      end
      4: begin
         readData[23] <= sdDataIn[3];
         readData[22] <= sdDataIn[2];
         readData[21] <= sdDataIn[1];
         readData[20] <= sdDataIn[0];
      end
      5: begin
         readData[19] <= sdDataIn[3];
         readData[18] <= sdDataIn[2];
         readData[17] <= sdDataIn[1];
         readData[16] <= sdDataIn[0];
      end
      6: begin
         readData[31] <= sdDataIn[3];
         readData[30] <= sdDataIn[2];
         readData[29] <= sdDataIn[1];
         readData[28] <= sdDataIn[0];
      end
      7: begin
         readData[27] <= sdDataIn[3];
         readData[26] <= sdDataIn[2];
         readData[25] <= sdDataIn[1];
         readData[24] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   5: begin
      case(readBitCnt)
      0: begin
         readData[39] <= sdDataIn[3];
         readData[38] <= sdDataIn[2];
         readData[37] <= sdDataIn[1];
         readData[36] <= sdDataIn[0];
      end
      1: begin
         readData[35] <= sdDataIn[3];
         readData[34] <= sdDataIn[2];
         readData[33] <= sdDataIn[1];
         readData[32] <= sdDataIn[0];
      end
      2: begin
         readData[47] <= sdDataIn[3];
         readData[46] <= sdDataIn[2];
         readData[45] <= sdDataIn[1];
         readData[44] <= sdDataIn[0];
      end
      3: begin
         readData[43] <= sdDataIn[3];
         readData[42] <= sdDataIn[2];
         readData[41]  <= sdDataIn[1];
         readData[40]  <= sdDataIn[0];
      end
      4: begin
         readData[55] <= sdDataIn[3];
         readData[54] <= sdDataIn[2];
         readData[53] <= sdDataIn[1];
         readData[52] <= sdDataIn[0];
      end
      5: begin
         readData[51] <= sdDataIn[3];
         readData[50] <= sdDataIn[2];
         readData[49] <= sdDataIn[1];
         readData[48] <= sdDataIn[0];
      end
      6: begin
         readData[63] <= sdDataIn[3];
         readData[62] <= sdDataIn[2];
         readData[61] <= sdDataIn[1];
         readData[60] <= sdDataIn[0];
      end
      7: begin
         readData[59] <= sdDataIn[3];
         readData[58] <= sdDataIn[2];
         readData[57] <= sdDataIn[1];
         readData[56] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   6: begin
      case(readBitCnt)
      0: begin
         readData[7] <= sdDataIn[3];
         readData[6] <= sdDataIn[2];
         readData[5] <= sdDataIn[1];
         readData[4] <= sdDataIn[0];
      end
      1: begin
         readData[3] <= sdDataIn[3];
         readData[2] <= sdDataIn[2];
         readData[1] <= sdDataIn[1];
         readData[0] <= sdDataIn[0];
      end
      2: begin
         readData[15] <= sdDataIn[3];
         readData[14] <= sdDataIn[2];
         readData[13] <= sdDataIn[1];
         readData[12] <= sdDataIn[0];
      end
      3: begin
         readData[11] <= sdDataIn[3];
         readData[10] <= sdDataIn[2];
         readData[9]  <= sdDataIn[1];
         readData[8]  <= sdDataIn[0];
      end
      4: begin
         readData[23] <= sdDataIn[3];
         readData[22] <= sdDataIn[2];
         readData[21] <= sdDataIn[1];
         readData[20] <= sdDataIn[0];
      end
      5: begin
         readData[19] <= sdDataIn[3];
         readData[18] <= sdDataIn[2];
         readData[17] <= sdDataIn[1];
         readData[16] <= sdDataIn[0];
      end
      6: begin
         readData[31] <= sdDataIn[3];
         readData[30] <= sdDataIn[2];
         readData[29] <= sdDataIn[1];
         readData[28] <= sdDataIn[0];
      end
      7: begin
         readData[27] <= sdDataIn[3];
         readData[26] <= sdDataIn[2];
         readData[25] <= sdDataIn[1];
         readData[24] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   7: begin
      case(readBitCnt)
      0: begin
         readData[39] <= sdDataIn[3];
         readData[38] <= sdDataIn[2];
         readData[37] <= sdDataIn[1];
         readData[36] <= sdDataIn[0];
      end
      1: begin
         readData[35] <= sdDataIn[3];
         readData[34] <= sdDataIn[2];
         readData[33] <= sdDataIn[1];
         readData[32] <= sdDataIn[0];
      end
      2: begin
         readData[47] <= sdDataIn[3];
         readData[46] <= sdDataIn[2];
         readData[45] <= sdDataIn[1];
         readData[44] <= sdDataIn[0];
      end
      3: begin
         readData[43] <= sdDataIn[3];
         readData[42] <= sdDataIn[2];
         readData[41]  <= sdDataIn[1];
         readData[40]  <= sdDataIn[0];
      end
      4: begin
         readData[55] <= sdDataIn[3];
         readData[54] <= sdDataIn[2];
         readData[53] <= sdDataIn[1];
         readData[52] <= sdDataIn[0];
      end
      5: begin
         readData[51] <= sdDataIn[3];
         readData[50] <= sdDataIn[2];
         readData[49] <= sdDataIn[1];
         readData[48] <= sdDataIn[0];
      end
      6: begin
         readData[63] <= sdDataIn[3];
         readData[62] <= sdDataIn[2];
         readData[61] <= sdDataIn[1];
         readData[60] <= sdDataIn[0];
      end
      7: begin
         readData[59] <= sdDataIn[3];
         readData[58] <= sdDataIn[2];
         readData[57] <= sdDataIn[1];
         readData[56] <= sdDataIn[0];
      end
      endcase // case (readBitCnt)
   end
   endcase // case (readByteCnt)
   end // if (cmdState == READ)
end

always @(posedge sdClk)
begin
   if (readByteCnt == 7 & readBitCnt == 7) begin
      readDataOut[63:0] <= readData;
      readDataOut[71:64] <= 8'h0;
   end
end

sd_crc_16 Sd_crc_16_data3_write(
   .BITVAL(writeCrcIn[3]),
   .Enable(writeCrcEnable),
   .CLK(sdClk),
   .RST(writeCrcRst),
   .CRC(writeCrcValue3)
);

sd_crc_16 sd_crc_16_data2_write(
   .BITVAL(writeCrcIn[2]),
   .Enable(writeCrcEnable),
   .CLK(sdClk),
   .RST(writeCrcRst),
   .CRC(writeCrcValue2)
);

sd_crc_16 sd_crc_16_data1_write(
   .BITVAL(writeCrcIn[1]),
   .Enable(writeCrcEnable),
   .CLK(sdClk),
   .RST(writeCrcRst),
   .CRC(writeCrcValue1)
);

sd_crc_16 sd_crc_16_data0_write(
   .BITVAL(writeCrcIn[0]),
   .Enable(writeCrcEnable),
   .CLK(sdClk),
   .RST(writeCrcRst),
   .CRC(writeCrcValue0)
);

sd_crc_16 sd_crc_16_data3_read(
   .BITVAL(sdDataIn[3]),
   .Enable(readCrcEnable),
   .CLK(sdClk),
   .RST(readCrcRst),
   .CRC(readCrcValue3)
);

sd_crc_16 sd_crc_16_data2_read(
   .BITVAL(sdDataIn[2]),
   .Enable(readCrcEnable),
   .CLK(sdClk),
   .RST(readCrcRst),
   .CRC(readCrcValue2)
);
   
sd_crc_16 sd_crc_16_data1_read(
   .BITVAL(sdDataIn[1]),
   .Enable(readCrcEnable),
   .CLK(sdClk),
   .RST(readCrcRst),
   .CRC(readCrcValue1)
);
   
sd_crc_16 sd_crc_16_data0_read(
   .BITVAL(sdDataIn[0]),
   .Enable(readCrcEnable),
   .CLK(sdClk),
   .RST(readCrcRst),
   .CRC(readCrcValue0)
);

// capture read crc value from incomming data
always @(posedge sdClk) begin
   if (~readCrcEnable) begin
      readCrcCheck3[readCrcCnt] <= sdDataIn[3];
      readCrcCheck2[readCrcCnt] <= sdDataIn[2];
      readCrcCheck1[readCrcCnt] <= sdDataIn[1];
      readCrcCheck0[readCrcCnt] <= sdDataIn[0];
   end
end


// check read crc value
always @(posedge sdClk or posedge sysRst) begin
   if (sysRst) begin
      dataStatus <= 4'b0;
   end
   else if (cmdState == CRC_CHK) begin
      if (readCrcCheck3 == readCrcValue3) begin
         dataStatus[3] <= 1'b1;
      end
      else begin
         dataStatus[3] <= 1'b0;
      end
      if (readCrcCheck2 == readCrcValue2) begin
         dataStatus[2] <= 1'b1;
      end
      else begin
         dataStatus[2] <= 1'b0;
      end
      if (readCrcCheck1 == readCrcValue1) begin
         dataStatus[1] <= 1'b1;
      end
      else begin
         dataStatus[1] <= 1'b0;
      end
      if (readCrcCheck0 == readCrcValue0) begin
         dataStatus[0] <= 1'b1;
      end
      else begin
         dataStatus[0] <= 1'b0;
      end
   end
end
      
endmodule






   

