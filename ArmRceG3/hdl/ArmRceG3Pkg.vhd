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
   constant AXI_READ_MASTER_INIT_C : AxiReadMasterType := ( 
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

   -- Array
   type AxiReadMasterArray is array (natural range<>) of AxiReadMasterType;


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
   constant AXI_READ_SLAVE_INIT_C : AxiReadSlaveType := ( 
      arready => '0',
      rdata   => x"0000000000000000",
      rlast   => '0',
      rvalid  => '0',
      rid     => x"000",
      rresp   => "00",
      racount => "000",
      rcount  => x"00"
   );

   -- Array
   type AxiReadSlaveArray is array (natural range<>) of AxiReadSlaveType;


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
   constant AXI_WRITE_MASTER_INIT_C : AxiWriteMasterType := ( 
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

   -- Array
   type AxiWriteMasterArray is array (natural range<>) of AxiWriteMasterType;


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
   constant AXI_WRITE_SLAVE_INIT_C : AxiWriteSlaveType := ( 
      awready => '0',
      wready  => '0',
      bresp   => "00",
      bvalid  => '0',
      bid     => x"000",
      wacount => "000000",
      wcount  => x"00"
   );

   -- Array
   type AxiWriteSlaveArray is array (natural range<>) of AxiWriteSlaveType;

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
   constant AXI_WRITE_TO_CNTRL_INIT_C : AxiWriteToCntrlType := ( 
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

   -- Array
   type AxiWriteToCntrlArray is array (natural range<>) of AxiWriteToCntrlType;

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
   constant AXI_WRITE_FROM_CNTRL_INIT_C : AxiWriteFromCntrlType := ( 
      gnt     => '0',
      afull   => '0',
      bresp   => "00",
      bvalid  => '0'
   );

   -- Array
   type AxiWriteFromCntrlArray is array (natural range<>) of AxiWriteFromCntrlType;

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
   constant AXI_READ_TO_CNTRL_INIT_C : AxiReadToCntrlType := ( 
      req       => '0',
      address   => x"0000000" & '0',
      avalid    => '0',
      id        => "000",
      length    => "0000",
      afull     => '0'
   );

   -- Array
   type AxiReadToCntrlArray is array (natural range<>) of AxiReadToCntrlType;

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
   constant AXI_READ_FROM_CNTRL_INIT_C : AxiReadFromCntrlType := ( 
      gnt     => '0',
      afull   => '0',
      rdata   => x"0000000000000000",
      rlast   => '0',
      rvalid  => '0',
      rresp   => "00"
   );

   -- Array
   type AxiReadFromCntrlArray is array (natural range<>) of AxiReadFromCntrlType;

   --------------------------------------------------------
   -- Inbound Header To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type IbHeaderToFifoType is record
      data  : slv(63 downto 0); -- Header data
      err   : sl;               -- Error, asserted with EOH
      eoh   : sl;               -- End of header
      htype : slv(3 downto 0);  -- Header type field
      valid : sl;               -- Header data valid
   end record;

   -- Initialization constants
   constant IB_HEADER_TO_FIFO_INIT_C : IbHeaderToFifoType := ( 
      data  => x"0000000000000000",
      err   => '0',
      eoh   => '0',
      htype => "0000",
      valid => '0'
   );

   -- Array
   type IbHeaderToFifoArray is array (natural range<>) of IbHeaderToFifoType;

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
   constant IB_HEADER_FROM_FIFO_INIT_C : IbHeaderFromFifoType := ( 
      full       => '0',
      progFull   => '0',
      almostFull => '0'
   );

   -- Array
   type IbHeaderFromFifoArray is array (natural range<>) of IbHeaderFromFifoType;

   --------------------------------------------------------
   -- Outbound Header To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type ObHeaderToFifoType is record
      read  : sl;  -- Read signal to header
   end record;

   -- Initialization constants
   constant OB_HEADER_TO_FIFO_INIT_C : ObHeaderToFifoType := ( 
      read  => '0'
   );

   -- Array
   type ObHeaderToFifoArray is array (natural range<>) of ObHeaderToFifoType;

   --------------------------------------------------------
   -- Outbound Header From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type ObHeaderFromFifoType is record
      data  : slv(63 downto 0); -- Header data
      eoh   : sl;               -- End of header indication
      htype : slv(3 downto 0);  -- Header type
      code  : slv(1 downto 0);  -- Header code
      valid : sl;               -- Header data is valid
   end record;

   -- Initialization constants
   constant OB_HEADER_FROM_FIFO_INIT_C : ObHeaderFromFifoType := ( 
      data  => x"0000000000000000",
      eoh   => '0',
      htype => "0000",
      code  => "00",
      valid => '0'
   );

   -- Array
   type ObHeaderFromFifoArray is array (natural range<>) of ObHeaderFromFifoType;

   --------------------------------------------------------
   -- PPI Read To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type PpiReadToFifoType is record
      read    : sl;               -- Read from PPI FIFO
   end record;

   -- Initialization constants
   constant PPI_READ_TO_FIFO_INIT_C : PpiReadToFifoType := ( 
      read    => '0'
   );

   -- Array
   type PpiReadToFifoArray is array (natural range<>) of PpiReadToFifoType;

   --------------------------------------------------------
   -- PPI Read From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type PpiReadFromFifoType is record
      data   : slv(63 downto 0); -- PPI Data
      size   : slv(2  downto 0); -- Bytes in transfer when EOF, 0x0=1, 0x7=8
      eof    : sl;               -- End of frame indication
      eoh    : sl;               -- End of header, inbound PPI only
      err    : sl;               -- Frame has error, inbound PPI only
      ftype  : slv(3 downto 0);  -- Frame type
      valid  : sl;               -- Frame data is valid
      ready  : sl;               -- Frame or bulk of data is ready
   end record;

   -- Initialization constants
   constant PPI_READ_FROM_FIFO_INIT_C : PpiReadFromFifoType := ( 
      data   => x"0000000000000000",
      size   => "000",
      eof    => '0',
      eoh    => '0',
      err    => '0',
      ftype  => "0000",
      valid  => '0',
      ready  => '0'
   );

   -- Array
   type PpiReadFromFifoArray is array (natural range<>) of PpiReadFromFifoType;


   --------------------------------------------------------
   -- PPI Write To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type PpiWriteToFifoType is record
      data    : slv(63 downto 0); -- PPI Data
      size    : slv(2  downto 0); -- Bytes in transfer when EOF, 0x0=1, 0x7=8
      eof     : sl;               -- End of frame indication
      eoh     : sl;               -- End of header, inbound PPI only
      err     : sl;               -- Frame is in error, inbound PPI only
      ftype   : slv(3 downto 0);  -- Frame type
      valid   : sl;               -- Frame data is valid
   end record;

   -- Initialization constants
   constant PPI_WRITE_TO_FIFO_INIT_C : PpiWriteToFifoType := ( 
      data    => x"0000000000000000",
      size    => "000",
      eof     => '0',
      eoh     => '0',
      err     => '0',
      ftype   => "0000",
      valid   => '0'
   );

   -- Array
   type PpiWriteToFifoArray is array (natural range<>) of PpiWriteToFifoType;

   --------------------------------------------------------
   -- PPI Write From FIFO Record
   --------------------------------------------------------

   -- Base Record
   type PpiWriteFromFifoType is record
      pause  : sl;  -- PPI can not accept another frame
   end record;

   -- Initialization constants
   constant PPI_WRITE_FROM_FIFO_INIT_C : PpiWriteFromFifoType := ( 
      pause  => '0'
   );

   -- Array
   type PpiWriteFromFifoArray is array (natural range<>) of PpiWriteFromFifoType;

   --------------------------------------------------------
   -- Completion To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type CompToFifoType is record
      read : sl;  -- Read from completion FIFO
   end record;

   -- Initialization constants
   constant COMP_TO_FIFO_INIT_C : CompToFifoType := ( 
      read => '0'
   );

   -- Array
   type CompToFifoArray is array (natural range<>) of CompToFifoType;

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
   constant COMP_FROM_FIFO_INIT_C : CompFromFifoType := ( 
      id       => x"00000000",
      index    => "0000",
      valid    => '0'
   );

   -- Array
   type CompFromFifoArray is array (natural range<>) of CompFromFifoType;


   --------------------------------------------------------
   -- Quad Word To FIFO Record
   --------------------------------------------------------

   -- Base Record
   type QWordToFifoType is record
      data  : slv(63 downto 0);   -- Quad word FIFO data
      valid : sl;                 -- Quad word FIFO valid
   end record;

   -- Initialization constants
   constant QWORD_TO_FIFO_INIT_C : QWordToFifoType := ( 
      data  => x"0000000000000000",
      valid => '0'
   );

   -- Array
   type QWordToFifoArray is array (natural range<>) of QWordToFifoType;

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
   constant QWORD_FROM_FIFO_INIT_C : QWordFromFifoType := ( 
      full       => '0',
      progFull   => '0',
      almostFull => '0'
   );

   -- Array
   type QWordFromFifoArray is array (natural range<>) of QWordFromFifoType;

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
   constant ETH_FROM_ARM_INIT_C : EthFromArmType := ( 
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

   -- Array
   type EthFromArmArray is array (natural range<>) of EthFromArmType;

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
   constant ETH_TO_ARM_INIT_C : EthToArmType := ( 
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

   -- Array
   type EthToArmArray is array (natural range<>) of EthToArmType;

end ArmRceG3Pkg;

