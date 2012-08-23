`timescale 1ns / 1ps
`define DEL 500 // standard delay = 500 ps
`define USE_CHIPSCOPE // standard delay = 500 ps
////////////////////////////////////////////////////////////////////////////////////////////////
// Title                   : uSDTop.v
// Project                 : COB DPM      
// ////////////////////////////////////////////////////////////////////////////////////////////
// Create Date             : 5/18/2012	   
// Design Name             :
// Module Name    	   : uSDTop
// Project Name            : COB
// Target Devices  	   : 5VFX70T
// Tool versions  	   : 13.4
// Description             : This is the top level without processor of the micro sd controller
//
// Revision: 
// Revision 0.00 - File Created
// Modification History
// 05/18/2012 Created
//////////////////////////////////////////////////////////////////////////////////
module uSDTop (
//-------- Inputs
input apuClk,
input [71:0] cmdFifoData,
input cmdFifoWrEn,
input resultFifoRdEn,
input [71:0] cmdDataFifoData,
input cmdDataFifoWrEn,
input resultDataFifoRdEn,
input sysClk200,
input sysRstN,
input chipScopeSel,
//-------- Outputs
output [35:0] resultFifoData,
output [71:0] resultDataFifoData,
output sdClk,
output cmdRdyRd,
output cmdRdyWr,
output resultPending,
//-------- IO
inout sdCmd,
inout [3:0] sdData
);

//------- Internal Signals
wire sysClk200Buf;       // single ended system clock 125Mhz to DCM
wire sysClk25;          // single ended system clock 25Mhz
wire sysClk40;          // 40M clock to be divided by 100 for 400khz clk
wire sysClk400k;        // single ended system clock 400Khz
wire clkfx40;           // 40Mhz DCM FX clk divide by 10 to get 400Khz 
wire sdCmdIn;           // sd card command data input
wire sdCmdOut;          // sd card command data output
wire sdCmdEn;           // sd card command data output enable active high invert for tristate pin
wire [3:0] sdDataOut;   // sd card data output
wire sdDataEn;          // sd card data output enable active high
wire [3:0] sdDataIn;    // sd card data input
wire sdClkInt;          // internal sd clk switches between 400khz and 25Mhz
wire sysRst;            // Active high system reset
wire dcmLocked;
wire [255:0] csData;   // chipscope data (trigger)
wire csClock;          // chipscope clock
wire [35:0] csControl;  // chipscope control
wire sdClkSel;          // select between 400khz and 25Mhz sd clock
wire initRst;
wire [96:0] sdEngineDebug;
wire [81:0] sdCmdDebug;
wire [71:0] cmdFifoDataOut;
wire cmdFifoRdEn;
wire cmdFifoEmpty;
wire [35:0] resultFifoDataIn;
wire resultFifoWrEn;
wire resultFifoNotFull;
wire [63:0] readDataOut;
wire writeFifoRe;
wire writeFifoAlmostEmpty;
wire readFifoAlmostFull;
wire [71:0] writeDataIn;
wire readFifoWe;
wire newCmd;
wire [31:0] argumentReg;
wire [15:0] cmdReg;
wire [15:0] statusReg;         
wire [135:0] cmdResponse;
wire initDone;
wire dataReady;
wire [254:0] sdDataDebug;
wire writeCmd;
wire readCmd;
wire writeDone;
wire readDone;
wire cmdRdyRdN;
wire cmdFifoAlmostFull;
wire writeDataFifoAlmostFull;
wire resultFifoEmpty;
wire sdReady;
wire resultFifoFull;
wire sdStatusCmd;
wire [3:0] dataStatus;
wire cmdStatus;
wire r1Cmd;
wire r2Cmd;
wire cmdDone;
wire [135:0] cmdResponseInt;
wire readFifoEmpty;
//chipscope signals
// These are for chipScopeSel0&1
// assign csData[183:0] = sdDataDebug[183:0];
// assign csData[184] = sysRstN;
// assign csData[188:185] = sdCmdDebug[3:0]; // [3:0] = cmdState 
// assign csData[196:189] = sdEngineDebug[7:0];
// // assign csData[228:197] = cmdResponse[39:8];
// assign csData[199:197] = {sdEngineDebug[41:40], sdEngineDebug[59]};  //acmd6Done, acmd41Done, acmd42Done
// assign csData[229] = sdStatusCmd;
// assign csData[230] = sdCmdIn;
// assign csData[231] = sdCmdOut;
// assign csData[232] = sdCmdEn;
// assign csData[236:233] = sdDataIn;
// assign csData[240:237] = sdDataOut;
// assign csData[241] = sdDataEn;
// assign csData[242] = chipScopeSel;
// assign csData[248:243] = cmdFifoDataOut[63:58];
// assign csData[252:249] = sdCmdDebug[11:8]; // rxCrcCheck[6:4], cmdStatus
// assign csData[253] = sdCmdDebug[30];
// assign csData[254] = cmdFifoEmpty;
// assign csData[255] = sdClkInt;

// These are for apu
//assign csData[63:0] = cmdFifoData[63:0];
//assign csData[127:64] = cmdFifoDataOut[63:0];
assign csData[127:0] = cmdResponseInt[127:0];
assign csData[128] = cmdFifoEmpty;
assign csData[129] = cmdFifoWrEn;
assign csData[130] = cmdFifoRdEn;
assign csData[131] = resultFifoRdEn;
assign csData[132] = resultFifoEmpty;
assign csData[133] = resultFifoWrEn;
assign csData[165:134] = resultFifoDataIn[31:0];
assign csData[197:166] = resultFifoData[31:0];
assign csData[205:198] = sdEngineDebug[7:0];
assign csData[209:206] = sdDataIn;
assign csData[213:210] = sdDataOut;
assign csData[214] = sdDataEn;
assign csData[215] = sdCmdIn;
assign csData[216] = sdCmdOut;
assign csData[217] = sdCmdEn;
assign csData[218] = initDone;
assign csData[219] = sysRst;
assign csData[220] = sdEngineDebug[60];  // sdInitComplete
assign csData[226:221] = cmdFifoDataOut[63:58];
assign csData[227] = r1Cmd;
assign csData[228] = r2Cmd;
assign csData[229] = cmdDone;
assign csData[234:230] = sdDataDebug[132:128];
assign csData[235] = readFifoWe;
assign csData[236] = resultDataFifoRdEn;
assign csData[237] = readFifoEmpty;
assign csData[238] = dataReady;
assign csData[247:239] = sdEngineDebug[69:61];
assign csData[255] = sdClkInt;

// active high internal reset
assign #`DEL sysRst = ~sysRstN & ~dcmLocked;



// instantiate pads
// sd data pads


IOBUF IOBUF_sdDat3 (
   .O(sdDataIn[3]),
   .IO(sdData[3]),
   .I(sdDataOut[3]),
   .T(~sdDataEn)
);


IOBUF IOBUF_sdDat2 (
   .O(sdDataIn[2]),
   .IO(sdData[2]),
   .I(sdDataOut[2]),
   .T(~sdDataEn)
);

IOBUF IOBUF_sdDat1 (
   .O(sdDataIn[1]),
   .IO(sdData[1]),
   .I(sdDataOut[1]),
   .T(~sdDataEn)
);

IOBUF IOBUF_sdDat0 (
   .O(sdDataIn[0]),
   .IO(sdData[0]),
   .I(sdDataOut[0]),
   .T(~sdDataEn)
);
// sd cmd pad
IOBUF IOBUF_sdCmd (
   .O(sdCmdIn),
   .IO(sdCmd),
   .I(sdCmdOut),
   .T(~sdCmdEn)
);

// sd clk pad
// figure out if need to change clock freq to fpp(25Mhz) from fop(400khz)
// if so put mux here and figure out
OBUF OBUF_sdClk (
   .O(sdClk),
   .I(sdClkInt)
);

// IBUFGDS IBUFGDS_sysClk (
//    .O(sysClk200In),
//    .I(sysClkP),
//    .IB(sysClkN)
// );

// Generate 25Mhz and 40Mhz clocks



sysDCM sdDCM_1(
   .CLKIN_IN(sysClk200),
   .RST_IN(sysRst),
   .CLKDV_OUT(sdClkInt),
   .CLK0_OUT(sysClk200Buf),
   .LOCKED_OUT(dcmLocked)
);


// Divide 40Mhz clock to 400khz

// clk_div_100 sdFPPClk_1(
//    .clkIn   (sysClk40),
//    .rst    (~dcmLocked),
//    .clkOut (sysClk400k)
// );

// sdClk Mux between 400k and 25Mhz
// BUFGMUX_CTRL sdClkMux_1 (
//    .O  (sdClkInt),
//    .I0 (sysClk400k),
//    .I1 (sysClk25),
//    .S  (sdClkSel)
// );

uSDCmd uSDCmd_1(
    .sdClk(sdClkInt), 
    .sysRst(initRst), 
    .sdCmdIn(sdCmdIn),
    .argumentReg(argumentReg),
    .cmdReg(cmdReg),
    .newCmd(newCmd),
    .sdCmdOut(sdCmdOut),
    .sdCmdEn(sdCmdEn),
    .cmdResponse(cmdResponse),
    .statusReg(statusReg),
    .sdClkSel(sdClkSel),
    .sdCmdDebug(sdCmdDebug),
    .initDone(initDone),
    .dataReady(dataReady),
    .cmdStatus(cmdStatus),
    .chipScopeSel(chipScopeSel)
 );


uSDData uSDData_1(
   .sdClk(sdClkInt),
   .sysRst(sysRst),
   .writeCmd(writeCmd),
   .readCmd(readCmd),
   .sdDataIn(sdDataIn),
   .writeDataIn(writeDataIn),
//   .writeFifoAlmostEmpty(writeFifoAlmostEmpty),
   .writeFifoAlmostEmpty(1'b0),
   .readFifoAlmostFull(readFifoAlmostFull),
   .sdDataOut(sdDataOut),
   .sdDataEn(sdDataEn),
   .sdDataDebug(sdDataDebug),
   .writeFifoRe(writeFifoRe),
   .readFifoWe(readFifoWe),
   .readDataOut(readDataOut),
   .writeDone(writeDone),
   .sdStatusCmd(sdStatusCmd),
   .readDone(readDone),
   .dataStatus(dataStatus),
   .chipScopeSel(chipScopeSel),
   .r1Cmd(r1Cmd),
   .r2Cmd(r2Cmd),
   .cmdDone(cmdDone),
   .cmdResponseInt(cmdResponseInt)
);

sdEngine sdEngine_1 (
   .sdClkIn(sdClkInt),
   .sysRstN(sysRstN),
   .initRst(initRst),
   .sdReady(sdReady),
   .cmdFifoDataOut(cmdFifoDataOut),
   .cmdFifoRdEn(cmdFifoRdEn),
   .cmdFifoEmpty(cmdFifoEmpty),
   .resultFifoDataIn(resultFifoDataIn), 
   .resultFifoWrEn(resultFifoWrEn), 
   .resultFifoFull(resultFifoFull),
   .newCmd(newCmd), 
   .argumentReg(argumentReg), 
   .cmdReg(cmdReg), 
   .statusReg(statusReg),
   .initDone(initDone),
   .dataReady(dataReady),
   .cmdResponse(cmdResponse),
   .writeCmd(writeCmd),
   .readCmd(readCmd),
   .writeDone(writeDone),
   .readDone(readDone),
//   .writeFifoAlmostEmpty(writeFifoAlmostEmpty),
   .writeFifoAlmostEmpty(1'b0),
   .readFifoAlmostFull(readFifoAlmostFull),
   .sdStatusCmd(sdStatusCmd),
   .chipScopeSel(chipScopeSel),
   .sdEngineDebug(sdEngineDebug),
   .r1Cmd(r1Cmd),
   .r2Cmd(r2Cmd),
   .cmdDone(cmdDone),
   .cmdResponseInt(cmdResponseInt)
);

// invert full flag per Mike's diagram
assign cmdRdyRd = ~cmdRdyRdN;
assign cmdRdyWr = cmdFifoAlmostFull & writeDataFifoAlmostFull;

// command fifo written by APU read by sdEngine

fifo72x512apuwrite cmdFifo(
   .rd_en(cmdFifoRdEn),
   .rst(sysRst),
   .empty(cmdFifoEmpty),
   .wr_en(cmdFifoWrEn),
   .rd_clk(sdClkInt),
   .full(cmdRdyRdN),
   .prog_empty(),
   .wr_clk(apuClk),
   .prog_full(cmdFifoAlmostFull),
   .dout(cmdFifoDataOut),
   .din(cmdFifoData)
);

// invert empty flag
assign resultPending = ~resultFifoEmpty;
fifo36x1024sdwrite resultFifo(
   .rd_en(resultFifoRdEn),
   .rst(sysRst),
   .empty(resultFifoEmpty),
   .wr_en(resultFifoWrEn),
   .rd_clk(apuClk),
   .full(resultFifoFull),
   .prog_empty(),
   .wr_clk(sdClkInt),
   .prog_full(),
   .dout(resultFifoData),
   .din(resultFifoDataIn)
);

fifo72x512apuwrite writeDataFifo(
   .rd_en(writeFifoRe),
   .rst(sysRst),
   .empty(),
   .wr_en(cmdDataFifoWrEn),
   .rd_clk(sdClkInt),
   .full(),
   .prog_empty(writeFifoAlmostEmpty),
   .wr_clk(apuClk),
   .prog_full(writeDataFifoAlmostFull),
   .dout(writeDataIn),
   .din(cmdDataFifoData)
);


fifo72x512sdwrite readDataFifo(
   .rd_en(resultDataFifoRdEn),
   .rst(sysRst),
   .empty(readFifoEmpty),
   .wr_en(readFifoWe),
   .rd_clk(apuClk),
   .full(),
   .prog_empty(),
   .wr_clk(sdClkInt),
   .prog_full(readFifoAlmostFull),
   .dout(resultDataFifoData),
   .din(readDataOut)
);


// chipscope
`ifdef USE_CHIPSCOPE

chipscope_icon icon0 (
   .CONTROL0(csControl)
);

chipscope_ila ila0 (
   .CONTROL(csControl),
// .CLK(sysClk200Buf),
   .CLK(apuClk),
   .TRIG0(csData)
);

`endif


endmodule