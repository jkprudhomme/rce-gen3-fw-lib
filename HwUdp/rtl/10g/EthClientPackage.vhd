-------------------------------------------------------------------------------
-- Title         : Ethernet Client, Core Package File
-- Project       : General Purpose Core
-------------------------------------------------------------------------------
-- File          : EthClientPackage.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 10/18/2010
-------------------------------------------------------------------------------
-- Description:
-- Core package file for general purpose firmware ethenet client.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 10/18/2010: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package EthClientPackage is

    -- Register delay for simulation
   constant tpd:time := 0.1 ns;

     -- Chipscope Logic Analyzer
   component v5_ila port (
      control     : inout std_logic_vector(35 downto 0);
      clk         : in    std_logic;
      trig0       : in    std_logic_vector(63 downto 0)
   ); end component;

   -- Chipscope attributes
   attribute syn_black_box : boolean;
   attribute syn_noprune   : boolean;
   attribute syn_black_box of v5_ila  : component is TRUE;
   attribute syn_noprune   of v5_ila  : component is TRUE;

   -- Type for IP address
   type IPAddrType is array(3 downto 0) of std_logic_vector(7 downto 0);

   -- Type for mac address
   type MacAddrType is array(5 downto 0) of std_logic_vector(7 downto 0);

   -- Ethernet header field constants
   constant EthTypeIPV4 : std_logic_vector(15 downto 0) := x"0800";
   constant EthTypeARP  : std_logic_vector(15 downto 0) := x"0806";

   -- UDP header field constants
   constant UDPProtocol   : std_logic_vector(7 downto 0)  := x"11";

   -- ARP Message container
   type ARPMsgType is array(4 downto 0) of std_logic_vector(63 downto 0);

   -- IPV4/UDP Header container
   type UDPMsgType is array(15 downto 0) of std_logic_vector(7 downto 0);

   component v5_fifo_66x8k port (
      rst           : IN  std_logic;
      din           : IN  std_logic_VECTOR(65 downto 0);
      wr_en         : IN  std_logic;
      wr_clk        : IN  std_logic;
      rd_en         : IN  std_logic;
      rd_clk        : IN  std_logic;
      dout          : OUT std_logic_VECTOR(65 downto 0);
      full          : OUT std_logic;
      empty         : OUT std_logic;
      rd_data_count : OUT std_logic_VECTOR(12 downto 0));
   end component;

   -- Counter FIFO
   component v5_fifo_17x1k port (
      rd_clk:IN  std_logic;
      wr_clk:IN  std_logic;
      din:   IN  std_logic_VECTOR(16 downto 0);
      rd_en: IN  std_logic;
      rst:   IN  std_logic;
      wr_en: IN  std_logic;
      dout:  OUT std_logic_VECTOR(16 downto 0);
      empty: OUT std_logic;
      full:  OUT std_logic
   ); end component;

   -- Counter FIFO
   component v5_fifo_13x1k port (
      rd_clk:IN  std_logic;
      wr_clk:IN  std_logic;
      din:   IN  std_logic_VECTOR(12 downto 0);
      rd_en: IN  std_logic;
      rst:   IN  std_logic;
      wr_en: IN  std_logic;
      dout:  OUT std_logic_VECTOR(12 downto 0);
      empty: OUT std_logic;
      full:  OUT std_logic
   ); end component;

component v5_fifo_13x512
	port (
	clk: IN std_logic;
	rst: IN std_logic;
	din: IN std_logic_VECTOR(12 downto 0);
	wr_en: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(12 downto 0);
	full: OUT std_logic;
	empty: OUT std_logic);
end component;

   -- Top Level
   component EthInterface port ( 
      sysClk        : in     std_logic;                     -- 125Mhz master clock
      sysRst        : in     std_logic;                     -- Synchronous reset input
      gtpClk        : in     std_logic;                     -- 125Mhz master clock
      gtpClkRst     : in     std_logic;                     -- Synchronous reset input
      ethTxEmpty    : in     std_logic;                     -- TX FIFO Empty
      ethTxSOF      : in     std_logic;
      ethTxEOF      : in     std_logic;
      ethTxWidth    : in     std_logic;
      ethTxData     : in     std_logic_vector(63 downto 0);
      ethTxType     : in     std_logic_vector(1  downto 0);
      ethTxRd       : out    std_logic;                     -- TX FIFO Read
      udpTxValid    : out    std_logic;
      udpTxEOF      : out    std_logic;
      udpTxReady    : in     std_logic;
      udpTxData     : out    std_logic_vector(63 downto 0);
      udpTxLength   : out    std_logic_vector(15 downto 0);
      deviceID      : in     std_logic_vector(1  downto 0);
      csControl     : inout  std_logic_vector(35 downto 0)  -- Chip Scope Control
      );
   end component;

   component EthClient
      generic ( 
         UdpPort : integer := 8192
      );
      port (
         emacClk         : in  std_logic;
         emacClkRst      : in  std_logic;
         emacRxData      : in  std_logic_vector(63 downto 0);
         emacRxValid     : in  std_logic;
         emacRxLast      : in  std_logic;
         emacTxData      : out std_logic_vector(63 downto 0);
         emacTxValid     : out std_logic;
         emacTxReady     : in  std_logic;
         emacTxSOF       : out std_logic;
         emacTxWidth     : out std_logic;
         emacTxEOF       : out std_logic;
         ipAddr          : in  IPAddrType;
         macAddr         : in  MacAddrType;
         udpTxValid      : in  std_logic;
         udpTxEOF        : in  std_logic;
         udpTxReady      : out std_logic;
         udpTxLength     : in  std_logic_vector(15 downto 0);
         udpTxData       : in  std_logic_vector(63 downto 0);
         udpRxValid      : out std_logic;
         udpRxSOF        : out std_logic;
         udpRxEOF        : out std_logic;
         udpRxWidth      : out std_logic;
         udpRxError      : out std_logic;
         udpRxData       : out std_logic_vector(63 downto 0);
         cScopeCtrl1     : inout std_logic_vector(35 downto 0);
         cScopeCtrl2     : inout std_logic_vector(35 downto 0)
      );
   end component;

   -- ARP Processor
   component EthClientArp port (
      emacClk    : in  std_logic;
      emacClkRst : in  std_logic;
      ipAddr     : in  IPAddrType;
      macAddr    : in  MacAddrType;
      rxData     : in  std_logic_vector(63 downto 0);
      rxLast     : in  std_logic;
      rxValid    : in  std_logic;
      rxSrc      : in  MacAddrType;
      txValid    : out std_logic;
      txReady    : in  std_logic;
      txSOF      : out std_logic;
      txEOF      : out std_logic;
      txData     : out std_logic_vector(63 downto 0);
      txWidth    : out std_logic;
      txDst      : out MacAddrType;
      cScopeCtrl : inout std_logic_vector(35 downto 0)
   );
   end component;

   -- UDP interface
   component EthClientUdp 
      generic ( 
         UdpPort : integer := 8192
      );
      port (
         emacClk     : in  std_logic;
         emacClkRst  : in  std_logic;
         ipAddr      : in  IPAddrType;
         rxData      : in  std_logic_vector(63 downto 0);
         rxLast      : in  std_logic;
         rxValid     : in  std_logic;
         rxSrc       : in  MacAddrType;
         txValid     : out std_logic;
         txReady     : in  std_logic;
         txSOF       : out std_logic;
         txEOF       : out std_logic;
         txData      : out std_logic_vector(63 downto 0);
         txWidth     : out std_logic;
         txDst       : out MacAddrType;
         udpTxValid  : in  std_logic;
         udpTxEOF    : in  std_logic;
         udpTxReady  : out std_logic;
         udpTxData   : in  std_logic_vector(63  downto 0);
         udpTxLength : in  std_logic_vector(15 downto 0);
         udpRxValid  : out std_logic;
         udpRxSOF    : out std_logic;
         udpRxEOF    : out std_logic;
         udpRxWidth  : out std_logic;
         udpRxError  : out std_logic;
         udpRxData   : out std_logic_vector(63 downto 0);
         cScopeCtrl  : inout std_logic_vector(35 downto 0)
      );
   end component;

   -- MGT Wrapper
   component EthMgtWrap
      generic (
         UdpPort : integer := 8192
      );
      port (
         emacClk         : in  std_logic;
         emacClkRst      : in  std_logic;
         ipAddr          : in  IPAddrType;
         macAddr         : in  MacAddrType;
         udpTxValid      : in  std_logic;
         udpTxReady      : out std_logic;
         udpTxData       : in  std_logic_vector(7  downto 0);
         udpTxLength     : in  std_logic_vector(15 downto 0);
         udpRxValid      : out std_logic;
         udpRxData       : out std_logic_vector(7 downto 0);
         udpRxGood       : out std_logic;
         udpRxError      : out std_logic;
         mgtRxN          : in  std_logic;
         mgtRxP          : in  std_logic;
         mgtTxN          : out std_logic;
         mgtTxP          : out std_logic;
         cScopeCtrl1     : inout std_logic_vector(35 downto 0);
         cScopeCtrl2     : inout std_logic_vector(35 downto 0)
      );
   end component;

   -- Loopback block
   component EthClientLoop port (
      emacClk         : in  std_logic;
      emacClkRst      : in  std_logic;
      cScopeCtrl      : inout std_logic_vector(35 downto 0);
      udpTxValid      : out std_logic;
      udpTxReady      : in  std_logic;
      udpTxData       : out std_logic_vector(7  downto 0);
      udpTxLength     : out std_logic_vector(15 downto 0);
      udpRxValid      : in  std_logic;
      udpRxData       : in  std_logic_vector(7 downto 0);
      udpRxGood       : in  std_logic;
      udpRxError      : in  std_logic
   );
   end component;

   -- Tester block
   component EthClientTest port (
      sysClk          : in    std_logic;
      sysRst          : in    std_logic;
      emacClk         : in    std_logic;
      emacClkRst      : in    std_logic;
      cScopeCtrl      : inout std_logic_vector(35 downto 0);
      ethTxEmpty      : out   std_logic;                     -- TX FIFO Empty
      ethTxSOF        : out   std_logic;
      ethTxEOF        : out   std_logic;
      ethTxData       : out   std_logic_vector(15 downto 0);
      ethTxType       : out   std_logic_vector(1  downto 0);
      ethTxRd         : in    std_logic;                     -- TX FIFO Read
      ethRxValid      : in    std_logic;
      ethRxData       : in    std_logic_vector(7 downto 0);
      ethRxGood       : in    std_logic;
      ethRxError      : in    std_logic
   );
   end component;

   component EthClientGtp is 
      generic (
         UdpPort      : integer := 8192         -- Enable short non-EOF cells
      );
      port (

         -- System clock, reset & control
         gtpClk       : in  std_logic;          -- 125Mhz master clock
         gtpClkOut    : out std_logic;          -- 125Mhz gtp clock out
         gtpClkRef    : in  std_logic;          -- 125Mhz reference clock
         gtpClkRst    : in  std_logic;          -- Synchronous reset input

         -- Ethernet Constants
         ipAddr       : in  IPAddrType;
         macAddr      : in  MacAddrType;

         -- UDP Transmit interface
         udpTxValid   : in  std_logic;
         udpTxEOF     : in  std_logic;
         udpTxReady   : out std_logic;
         udpTxData    : in  std_logic_vector(63 downto 0);
         udpTxLength  : in  std_logic_vector(15 downto 0);

         -- UDP Receive interface
         udpRxValid   : out std_logic;
         udpRxSOF     : out std_logic;
         udpRxEOF     : out std_logic;
         udpRxWidth   : out std_logic;
         udpRxData    : out std_logic_vector(63 downto 0);
         udpRxGood    : out std_logic;
         udpRxError   : out std_logic;

         -- GTP Signals
         gtpRxN       : in  std_logic;          -- GTP Serial Receive Negative
         gtpRxP       : in  std_logic;          -- GTP Serial Receive Positive
         gtpTxN       : out std_logic;          -- GTP Serial Transmit Negative
         gtpTxP       : out std_logic;          -- GTP Serial Transmit Positive

         -- Debug
         cScopeCtrl1    : inout std_logic_vector(35 downto 0);
         cScopeCtrl2    : inout std_logic_vector(35 downto 0)
      );
   end component;

   component EthClientGtpRxRst is 
      port (

         -- Clock and reset
         gtpRxClk          : in  std_logic;
         gtpRxRst          : in  std_logic;

         -- RX Side is ready
         gtpRxReady        : out std_logic;
         
         -- GTP Status
         gtpLockDetect     : in  std_logic;
         gtpRxElecIdle     : in  std_logic;
         gtpRxBuffStatus   : in  std_logic_vector(1  downto 0);
         gtpRstDone        : in  std_logic;

         -- Reset Control
         gtpRxElecIdleRst  : out std_logic;
         gtpRxReset        : out std_logic;
         gtpRxCdrReset     : out std_logic;

         -- Debug
         cScopeCtrl        : inout std_logic_vector(35 downto 0)
       
      );
   end component;

   component EthClientGtpTxRst is 
      port (

         -- Clock and reset
         gtpTxClk          : in  std_logic;
         gtpTxRst          : in  std_logic;

         -- TX Side is ready
         gtpTxReady        : out std_logic;

         -- GTP Status
         gtpLockDetect     : in  std_logic;
         gtpTxBuffStatus   : in  std_logic_vector(1  downto 0);
         gtpRstDone        : in  std_logic;

         -- Reset Control
         gtpTxReset        : out std_logic
      );
   end component;

end EthClientPackage;

