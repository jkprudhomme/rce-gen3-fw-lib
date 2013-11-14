-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Package File
-- File          : ArmRceG3Pkg.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Package file for ARM based rce generation 3 processor core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
use work.StdRtlPkg.all;

package ArmRceG3Pkg is

   --------------------------------------------------------
   -- AXI bus, read master signal record
   --------------------------------------------------------

   -- Base Record
   type AxiReadMasterType is record

      -- Read Address channel
      arvalid        : sl;               -- Address valid
      araddr         : slv(31 downto 0); -- Address
      arid           : slv(11 downto 0); -- Channel ID
                                         -- 12 bits for master GP
                                         -- 6  bits for slave GP
                                         -- 3  bits for ACP
                                         -- 6  bits for HP
      arlen          : slv(3  downto 0); -- Transfer count, 0x0=1, 0xF=16
      arsize         : slv(2  downto 0); -- Bytes per transfer, 0x0=1, 0x7=8
      arburst        : slv(1  downto 0); -- Burst Type
                                         -- 0x0 = Fixed address
                                         -- 0x1 = Incrementing address
                                         -- 0x2 = Wrap at cache boundary
      arlock         : slv(1  downto 0); -- Lock control
                                         -- 0x0 = Normal access
                                         -- 0x1 = Exclusive access
                                         -- 0x2 = Locked access
      arprot         : slv(2  downto 0); -- Protection control
                                         -- Bit 0 : 0 = Normal, 1 = Priveleged
                                         -- Bit 1 : 0 = Secure, 1 = Non-secure
                                         -- Bit 2 : 0 = Data access, 1 = Instruction
      arcache        : slv(3  downto 0); -- Cache control
                                         -- Bit 0 : Bufferable
                                         -- Bit 1 : Cachable  
                                         -- Bit 2 : Read allocate enable
                                         -- Bit 3 : Write allocate enable
      arqos          : slv(3  downto 0); -- Xilinx specific, see UG585
      aruser         : slv(4  downto 0); -- ACP only, Xilinx specific, see UG585

      -- Read data channel
      rready         : sl;               -- Master is ready for data

      -- Control 
      rdissuecap1_en : sl;               -- HP only, Xilinx specific, see UG585  

   end record;

   -- Initialization constants
   constant AxiReadMasterInit : AxiReadMasterType := ( 
      arvalid        => '0',
      araddr         => x"00000000",
      arid           => x"000",
      arlen          => "0000",
      arsize         => "000",
      arburst        => "00",
      arlock         => "00",
      arprot         => "000",
      arcache        => "0000",
      arqos          => "0000",
      aruser         => "00000",
      rready         => '0',
      rdissuecap1_en => '0'
   );

   -- Vector
   type AxiReadMasterVector is array (natural range<>) of AxiReadMasterType;


   --------------------------------------------------------
   -- AXI bus, read slave signal record
   --------------------------------------------------------

   -- Base Record
   type AxiReadSlaveType is record

      -- Read Address channel
      arready : sl;               -- Slave is ready for address

      -- Read data channel
      rdata   : slv(63 downto 0); -- Read data from slave
                                  -- 32 bits for GP ports
                                  -- 64 bits for other ports
      rlast   : sl;               -- Read data last strobe
      rvalid  : sl;               -- Read data is valid
      rid     : slv(11 downto 0); -- Read data ID
                                  -- 12 for master GP 
                                  -- 6 for slave GP 
                                  -- 3 for ACP 
                                  -- 6 for HP
      rresp   : slv(1  downto 0); -- Read data result
                                  -- 0x0 = Okay
                                  -- 0x1 = Exclusive access okay
                                  -- 0x2 = Slave indicated error 
                                  -- 0x3 = Decode error

      -- Status
      racount : slv(2  downto 0); -- HP only, Xilinx specific, see UG585
      rcount  : slv(7  downto 0); -- HP only, Xilinx specific, see UG585

   end record;

   -- Initialization constants
   constant AxiReadSlaveInit : AxiReadSlaveType := ( 
      arready => '0',
      rdata   => x"0000000000000000",
      rlast   => '0',
      rvalid  => '0',
      rid     => x"000",
      rresp   => "00",
      racount => "000",
      rcount  => x"00"
   );

   -- Vector
   type AxiReadSlaveVector is array (natural range<>) of AxiReadSlaveType;


   --------------------------------------------------------
   -- AXI bus, write master signal record
   --------------------------------------------------------

   -- Base Record
   type AxiWriteMasterType is record

      -- Write address channel
      awvalid        : sl;               -- Write address is valid
      awaddr         : slv(31 downto 0); -- Write address
      awid           : slv(11 downto 0); -- Channel ID
                                         -- 12 bits for master GP
                                         -- 6  bits for slave GP
                                         -- 3  bits for ACP
                                         -- 6  bits for HP
      awlen          : slv(3  downto 0); -- Transfer count, 0x0=1, 0xF=16
      awsize         : slv(2  downto 0); -- Bytes per transfer, 0x0=1, 0x7=8
      awburst        : slv(1  downto 0); -- Burst Type
                                         -- 0x0 = Fixed address
                                         -- 0x1 = Incrementing address
                                         -- 0x2 = Wrap at cache boundary
      awlock         : slv(1  downto 0); -- Lock control
                                         -- 0x0 = Normal access
                                         -- 0x1 = Exclusive access
                                         -- 0x2 = Locked access
      awprot         : slv(2  downto 0); -- Protection control
                                         -- Bit 0 : 0 = Normal, 1 = Priveleged
                                         -- Bit 1 : 0 = Secure, 1 = Non-secure
                                         -- Bit 2 : 0 = Data access, 1 = Instruction
      awcache        : slv(3  downto 0); -- Cache control
                                         -- Bit 0 : Bufferable
                                         -- Bit 1 : Cachable  
                                         -- Bit 2 : Read allocate enable
                                         -- Bit 3 : Write allocate enable
      awqos          : slv(3  downto 0); -- Xilinx specific, see UG585
      awuser         : slv(4  downto 0); -- ACP only, Xilinx specific, see UG585

      -- Write data channel
      wdata          : slv(63 downto 0); -- Write data
                                         -- 32-bits for master and slave GP
                                         -- 64-bit for others
      wlast          : sl;               -- Write data is last
      wvalid         : sl;               -- Write data is valid
      wstrb          : slv(7  downto 0); -- Write enable strobes, 1 per byte
                                         -- 4-bits for master and slave GP
                                         -- 8-bits for others
      wid            : slv(11 downto 0); -- Channel ID
                                         -- 12 bits for master GP
                                         -- 6  bits for slave GP
                                         -- 3  bits for ACP
                                         -- 6  bits for HP

      -- Write ack channel
      bready         : sl;               -- Write master is ready for status

      -- Control
      wrissuecap1_en : sl;               -- HP only, Xilinx specific, see UG585  

   end record;

   -- Initialization constants
   constant AxiWriteMasterInit : AxiWriteMasterType := ( 
      awvalid        => '0',
      awaddr         => x"00000000",
      awid           => x"000",
      awlen          => "0000",
      awsize         => "000",
      awburst        => "00",
      awlock         => "00",
      awcache        => "0000",
      awprot         => "000",
      awqos          => "0000",
      awuser         => "00000",
      wdata          => x"0000000000000000",
      wlast          => '0',
      wvalid         => '0',
      wid            => x"000",
      wstrb          => "00000000",
      bready         => '0',
      wrissuecap1_en => '0'
   );

   -- Vector
   type AxiWriteMasterVector is array (natural range<>) of AxiWriteMasterType;


   --------------------------------------------------------
   -- AXI bus, write slave signal record
   --------------------------------------------------------

   -- Base Record
   type AxiWriteSlaveType is record

      -- Write address channel
      awready : sl;               -- Write slave is ready for address

      -- Write data channel
      wready  : sl;               -- Write slave is ready for data

      -- Write ack channel
      bresp   : slv(1  downto 0); -- Write acess status
                                  -- 0x0 = Okay
                                  -- 0x1 = Exclusive access okay
                                  -- 0x2 = Slave indicated error 
                                  -- 0x3 = Decode error
      bvalid  : sl;               -- Write status valid
      bid     : slv(11 downto 0); -- Channel ID
                                  -- 12 bits for master GP
                                  -- 6  bits for slave GP
                                  -- 3  bits for ACP
                                  -- 6  bits for HP

      -- Status
      wacount : slv(5  downto 0); -- HP only, Xilinx specific, see UG585
      wcount  : slv(7  downto 0); -- HP only, Xilinx specific, see UG585

   end record;

   -- Initialization constants
   constant AxiWriteSlaveInit : AxiWriteSlaveType := ( 
      awready => '0',
      wready  => '0',
      bresp   => "00",
      bvalid  => '0',
      bid     => x"000",
      wacount => "000000",
      wcount  => x"00"
   );

   -- Vector
   type AxiWriteSlaveVector is array (natural range<>) of AxiWriteSlaveType;

   --------------------------------------------------------
   -- Local Bus Master
   --------------------------------------------------------

   -- Base Record
   type LocalBusMasterType is record
      addr        : slv(31 downto 0); -- read/write address
      readEnable  : sl;               -- Read enable pulse
      writeEnable : sl;               -- Write enable pulse
      writeData   : slv(31 downto 0); -- Write data
   end record;

   -- Initialization constants
   constant LocalBusMasterInit : LocalBusMasterType := ( 
      addr        => x"00000000",
      readEnable  => '0',
      writeEnable => '0',
      writeData   => x"00000000"
   );

   -- Vector
   type LocalBusMasterVector is array (natural range<>) of LocalBusMasterType;

   --------------------------------------------------------
   -- Local Bus Slave
   --------------------------------------------------------

   -- Base Record
   type LocalBusSlaveType is record
      readValid : sl;               -- Read data valid pulse
      readData  : slv(31 downto 0); -- Read data
   end record;

   -- Initialization constants
   constant LocalBusSlaveInit : LocalBusSlaveType := ( 
      readValid => '0',
      readData  => x"00000000"
   );

   -- Vector
   type LocalBusSlaveVector is array (natural range<>) of LocalBusSlaveType;

   --------------------------------------------------------
   -- AXI Write To Controller Record
   --------------------------------------------------------

   -- Base Record
   type AxiWriteToCntrlType is record
      req       : sl;                 -- Write controller request
      address   : slv(31 downto 3);   -- Upper bits of write address
      avalid    : sl;                 -- Write address is valid
      id        : slv(2  downto 0);   -- Write ID
      length    : slv(3  downto 0);   -- Transfer count, 0x0=1, 0xF=16
      data      : slv(63 downto 0);   -- Write data
      dvalid    : sl;                 -- Write data valid
      dstrobe   : slv(7  downto 0);   -- Write enable strobes, 1 per byte
      last      : sl;                 -- Write data is last
   end record;

   -- Initialization constants
   constant AxiWriteToCntrlInit : AxiWriteToCntrlType := ( 
      req       => '0',
      address   => x"0000000" & '0',
      avalid    => '0',
      id        => "000",
      length    => "0000",
      data      => x"0000000000000000",
      dvalid    => '0',
      dstrobe   => x"00",
      last      => '0'
   );

   -- Vector
   type AxiWriteToCntrlVector is array (natural range<>) of AxiWriteToCntrlType;

   --------------------------------------------------------
   -- AXI Write From Controller Record
   --------------------------------------------------------

   -- Base Record
   type AxiWriteFromCntrlType is record
      gnt     : sl;               -- Write controller grant
      afull   : sl;               -- Write controller almost full
      bresp   : slv(1 downto 0);  -- Write response data
                                  -- 0x0 = Okay
                                  -- 0x1 = Exclusive access okay
                                  -- 0x2 = Slave indicated error 
                                  -- 0x3 = Decode error
      bvalid  : sl;               -- Write response valid
   end record;

   -- Initialization constants
   constant AxiWriteFromCntrlInit : AxiWriteFromCntrlType := ( 
      gnt     => '0',
      afull   => '0',
      bresp   => "00",
      bvalid  => '0'
   );

   -- Vector
   type AxiWriteFromCntrlVector is array (natural range<>) of AxiWriteFromCntrlType;

   --------------------------------------------------------
   -- AXI Read To Controller Record
   --------------------------------------------------------

   -- Base Record
   type AxiReadToCntrlType is record
      req       : sl;               -- Read controller request
      address   : slv(31 downto 3); -- Upper bits of read address
      avalid    : sl;               -- Read address is valid
      id        : slv(2  downto 0); -- Read ID
      length    : slv(3  downto 0); -- Transfer count, 0x0=1, 0xF=16
      afull     : sl;               -- Read requester is almost full
   end record;

   -- Initialization constants
   constant AxiReadToCntrlInit : AxiReadToCntrlType := ( 
      req       => '0',
      address   => x"0000000" & '0',
      avalid    => '0',
      id        => "000",
      length    => "0000",
      afull     => '0'
   );

   -- Vector
   type AxiReadToCntrlVector is array (natural range<>) of AxiReadToCntrlType;

   --------------------------------------------------------
   -- AXI Read From Controller Record
   --------------------------------------------------------

   -- Base Record
   type AxiReadFromCntrlType is record
      gnt     : sl;               -- Read controller grant
      afull   : sl;               -- Read controller is almost full
      rdata   : slv(63 downto 0); -- Read data
      rlast   : sl;               -- Read data last
      rvalid  : sl;               -- Read data valid
      rresp   : slv(1  downto 0); -- Read data result
                                  -- 0x0 = Okay
                                  -- 0x1 = Exclusive access okay
                                  -- 0x2 = Slave indicated error 
                                  -- 0x3 = Decode error
   end record;

   -- Initialization constants
   constant AxiReadFromCntrlInit : AxiReadFromCntrlType := ( 
      gnt     => '0',
      afull   => '0',
      rdata   => x"0000000000000000",
      rlast   => '0',
      rvalid  => '0',
      rresp   => "00"
   );

   -- Vector
   type AxiReadFromCntrlVector is array (natural range<>) of AxiReadFromCntrlType;

   --------------------------------------------------------
   -- Inbound Header To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type IbHeaderToFifoType is record
      data  : slv(63 downto 0); -- Header data
      err   : sl;               -- Error, asserted with EOH
      eoh   : sl;               -- End of header
      htype : slv(2 downto 0);  -- Header type field
      mgmt  : sl;               -- Header is management
      valid : sl;               -- Header data valid
   end record;

   -- Initialization constants
   constant IbHeaderToFifoInit : IbHeaderToFifoType := ( 
      data  => x"0000000000000000",
      err   => '0',
      eoh   => '0',
      htype => "000",
      mgmt  => '0',
      valid => '0'
   );

   -- Vector
   type IbHeaderToFifoVector is array (natural range<>) of IbHeaderToFifoType;

   --------------------------------------------------------
   -- Inbound Header From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type IbHeaderFromFifoType is record
      full       : sl; -- Header FIFO is full
      progFull   : sl; -- Header FIFO is half full
      almostFull : sl; -- Header FIFO has one entry left
   end record;

   -- Initialization constants
   constant IbHeaderFromFifoInit : IbHeaderFromFifoType := ( 
      full       => '0',
      progFull   => '0',
      almostFull => '0'
   );

   -- Vector
   type IbHeaderFromFifoVector is array (natural range<>) of IbHeaderFromFifoType;

   --------------------------------------------------------
   -- Outbound Header To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type ObHeaderToFifoType is record
      read  : sl;  -- Read signal to header
   end record;

   -- Initialization constants
   constant ObHeaderToFifoInit : ObHeaderToFifoType := ( 
      read  => '0'
   );

   -- Vector
   type ObHeaderToFifoVector is array (natural range<>) of ObHeaderToFifoType;

   --------------------------------------------------------
   -- Outbound Header From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type ObHeaderFromFifoType is record
      data  : slv(63 downto 0); -- Header data
      eoh   : sl;               -- End of header indication
      htype : slv(2 downto 0);  -- Header type
      mgmt  : sl;               -- Header is managment
      valid : sl;               -- Header data is valid
   end record;

   -- Initialization constants
   constant ObHeaderFromFifoInit : ObHeaderFromFifoType := ( 
      data  => x"0000000000000000",
      eoh   => '0',
      htype => "000",
      mgmt  => '0',
      valid => '0'
   );

   -- Vector
   type ObHeaderFromFifoVector is array (natural range<>) of ObHeaderFromFifoType;

   --------------------------------------------------------
   -- Outbound PPI To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type ObPpiToFifoType is record
      read    : sl;               -- Read from PPI FIFO
      id      : slv(31 downto 0); -- Outbound PPI ID
      version : slv(31 downto 0); -- Outbound PPI Version
      configA : slv(31 downto 0); -- Outbound PPI Config Word A
      configB : slv(31 downto 0); -- Outbound PPI Config Word B
   end record;

   -- Initialization constants
   constant ObPpiToFifoInit : ObPpiToFifoType := ( 
      read    => '0',
      id      => x"00000000",
      version => x"00000000",
      configA => x"00000000",
      configB => x"00000000"
   );

   -- Vector
   type ObPpiToFifoVector is array (natural range<>) of ObPpiToFifoType;

   --------------------------------------------------------
   -- Outbound PPI From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type ObPpiFromFifoType is record
      data   : slv(63 downto 0); -- PPI Data
      size   : slv(2  downto 0); -- Bytes in transfer when EOF, 0x0=1, 0x7=8
      eof    : sl;               -- End of frame indication
      eoh    : sl;               -- End of header
      ftype  : slv(2 downto 0);  -- Frame type
      mgmt   : sl;               -- Frame is management
      valid  : sl;               -- Frame data is valid
      online : sl;               -- PPI online indication
   end record;

   -- Initialization constants
   constant ObPpiFromFifoInit : ObPpiFromFifoType := ( 
      data   => x"0000000000000000",
      size   => "000",
      eof    => '0',
      eoh    => '0',
      ftype  => "000",
      mgmt   => '0',
      valid  => '0',
      online => '0'
   );

   -- Vector
   type ObPpiFromFifoVector is array (natural range<>) of ObPpiFromFifoType;


   --------------------------------------------------------
   -- Inbound PPI To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type IbPpiToFifoType is record
      data    : slv(63 downto 0); -- PPI Data
      size    : slv(2  downto 0); -- Bytes in transfer when EOF, 0x0=1, 0x7=8
      eof     : sl;               -- End of frame indication
      eoh     : sl;               -- End of header
      err     : sl;               -- Frame is in error
      ftype   : slv(2 downto 0);  -- Frame type
      mgmt    : sl;               -- Frame is management
      valid   : sl;               -- Frame data is valid
      id      : slv(31 downto 0); -- Inbound PPI ID
      version : slv(31 downto 0); -- Inbound PPI Version
      configA : slv(31 downto 0); -- Inbound PPI Config Word A
      configB : slv(31 downto 0); -- Inbound PPI Config Word B
   end record;

   -- Initialization constants
   constant IbPpiToFifoInit : IbPpiToFifoType := ( 
      data    => x"0000000000000000",
      size    => "000",
      eof     => '0',
      eoh     => '0',
      err     => '0',
      ftype   => "000",
      mgmt    => '0',
      valid   => '0',
      id      => x"00000000",
      version => x"00000000",
      configA => x"00000000",
      configB => x"00000000"
   );

   -- Vector
   type IbPpiToFifoVector is array (natural range<>) of IbPpiToFifoType;

   --------------------------------------------------------
   -- Inbound PPI From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type IbPpiFromFifoType is record
      pause  : sl;  -- PPI can not accept another frame
      online : sl;  -- PPI online indication
   end record;

   -- Initialization constants
   constant IbPpiFromFifoInit : IbPpiFromFifoType := ( 
      pause  => '0',
      online => '0'
   );

   -- Vector
   type IbPpiFromFifoVector is array (natural range<>) of IbPpiFromFifoType;

   --------------------------------------------------------
   -- Completion To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type CompToFifoType is record
      read : sl;  -- Read from completion FIFO
   end record;

   -- Initialization constants
   constant CompToFifoInit : CompToFifoType := ( 
      read => '0'
   );

   -- Vector
   type CompToFifoVector is array (natural range<>) of CompToFifoType;

   --------------------------------------------------------
   -- Completion From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type CompFromFifoType is record
      id       : slv(31 downto 0); -- Completion ID
      index    : slv(3  downto 0); -- Destination FIFO index
      valid    : sl;               -- Completion is valid
   end record;

   -- Initialization constants
   constant CompFromFifoInit : CompFromFifoType := ( 
      id       => x"00000000",
      index    => "0000",
      valid    => '0'
   );

   -- Vector
   type CompFromFifoVector is array (natural range<>) of CompFromFifoType;


   --------------------------------------------------------
   -- Quad Word To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type QWordToFifoType is record
      data  : slv(63 downto 0);   -- Quad word FIFO data
      valid : sl;                 -- Quad word FIFO valid
   end record;

   -- Initialization constants
   constant QWordToFifoInit : QWordToFifoType := ( 
      data  => x"0000000000000000",
      valid => '0'
   );

   -- Vector
   type QWordToFifoVector is array (natural range<>) of QWordToFifoType;

   --------------------------------------------------------
   -- Quad Word From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type QWordFromFifoType is record
      full       : sl;  -- Quad word FIFO is full
      progFull   : sl;  -- Quad word FIFO is half full
      almostFull : sl;  -- Quad word FIFO has one entry left
   end record;

   -- Initialization constants
   constant QWordFromFifoInit : QWordFromFifoType := ( 
      full       => '0',
      progFull   => '0',
      almostFull => '0'
   );

   -- Vector
   type QWordFromFifoVector is array (natural range<>) of QWordFromFifoType;

   --------------------------------------------------------
   -- Ethernet From ARM
   --------------------------------------------------------

   -- Base Record
   type EthFromArmType is record
      enetGmiiTxEn        : sl;
      enetGmiiTxEr        : sl;
      enetMdioMdc         : sl;
      enetMdioO           : sl;
      enetMdioT           : sl;
      enetPtpDelayReqRx   : sl;
      enetPtpDelayReqTx   : sl;
      enetPtpPDelayReqRx  : sl;
      enetPtpPDelayReqTx  : sl;
      enetPtpPDelayRespRx : sl;
      enetPtpPDelayRespTx : sl;
      enetPtpSyncFrameRx  : sl;
      enetPtpSyncFrameTx  : sl;
      enetSofRx           : sl;
      enetSofTx           : sl;
      enetGmiiTxD         : slv(7 downto 0);  
   end record;

   -- Initialization constants
   constant EthFromArmInit : EthFromArmType := ( 
      enetGmiiTxEn        => '0',
      enetGmiiTxEr        => '0',
      enetMdioMdc         => '0',
      enetMdioO           => '0',
      enetMdioT           => '0',
      enetPtpDelayReqRx   => '0',
      enetPtpDelayReqTx   => '0',
      enetPtpPDelayReqRx  => '0',
      enetPtpPDelayReqTx  => '0',
      enetPtpPDelayRespRx => '0',
      enetPtpPDelayRespTx => '0',
      enetPtpSyncFrameRx  => '0',
      enetPtpSyncFrameTx  => '0',
      enetSofRx           => '0',
      enetSofTx           => '0',
      enetGmiiTxD         => (others=>'0')
   );

   -- Vector
   type EthFromArmVector is array (natural range<>) of EthFromArmType;

   --------------------------------------------------------
   -- Ethernet To ARM
   --------------------------------------------------------

   -- Base Record
   type EthToArmType is record
      enetGmiiCol   : sl;
      enetGmiiCrs   : sl;
      enetGmiiRxClk : sl;
      enetGmiiRxDv  : sl;
      enetGmiiRxEr  : sl;
      enetGmiiTxClk : sl;
      enetMdioI     : sl;
      enetExtInitN  : sl;
      enetGmiiRxd   : slv(7 downto 0);  
   end record;

   -- Initialization constants
   constant EthToArmInit : EthToArmType := ( 
      enetGmiiCol   => '0',
      enetGmiiCrs   => '0',
      enetGmiiRxClk => '0',
      enetGmiiRxDv  => '0',
      enetGmiiRxEr  => '0',
      enetGmiiTxClk => '0',
      enetMdioI     => '0',
      enetExtInitN  => '0',
      enetGmiiRxd   => (others=>'0')
   );

   -- Vector
   type EthToArmVector is array (natural range<>) of EthToArmType;

end ArmRceG3Pkg;

