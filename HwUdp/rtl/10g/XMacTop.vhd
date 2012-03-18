-------------------------------------------------------------------------------
-- Title         : 10G MAC / PIC Interface Top Level
-- Project       : RCE 10G-bit MAC
-------------------------------------------------------------------------------
-- File          : XMac.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 02/11/2008
-------------------------------------------------------------------------------
-- Description:
-- Top level module for 10G MAC core for the RCE.
-------------------------------------------------------------------------------
-- Copyright (c) 2008 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 02/11/2008: created.
-------------------------------------------------------------------------------

LIBRARY ieee;
use work.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.EthClientPackage.all;

entity XMacTop is
   port (
      -- Clock & Reset
      macClk                          : in  std_logic;
      macClk2X                        : in  std_logic;
      macRst                          : in  std_logic;

      -- Import Interface
      Imp_Data_Valid                  : out std_logic;
      Imp_Data_Last_Line              : out std_logic;
      Imp_Data_Last_Valid_Byte        : out std_logic_vector( 2 downto 0);
      Imp_Data                        : out std_logic_vector(63 downto 0);

      -- Export Interface
      Exp_Data_Valid                  : out std_logic;
      Exp_Data_Ready                  : out std_logic;
      Exp_Data_SOP                    : out std_logic;
      Exp_Data_EOP                    : out std_logic;
      Exp_Data_Width                  : out std_logic;
      Exp_Data                        : out std_logic_vector(63 downto 0);
      Exp_Advance_Status_Pipeline     : out std_logic;
      Exp_Status                      : out std_logic_vector(31 downto 0);

      -- XAUI Interface
      phyRxd                          : in  std_logic_vector(63 downto 0);
      phyRxc                          : in  std_logic_vector(7  downto 0);
      phyTxd                          : out std_logic_vector(63 downto 0);
      phyTxc                          : out std_logic_vector(7  downto 0);
      phyReady                        : in  std_logic;
      phyIdle                         : out std_logic;

      -- CRC Interface
      rxCrcIn                         : out std_logic_vector(63 downto 0); 
      rxCrcDataWidth                  : out std_logic_vector(2  downto 0); 
      rxCrcDataValid                  : out std_logic; 
      rxCrcInit                       : out std_logic; 
      rxCrcReset                      : out std_logic; 
      rxCrcOut                        : in  std_logic_vector(31 downto 0); 
      txCrcIn                         : out std_logic_vector(63 downto 0); 
      txCrcDataWidth                  : out std_logic_vector(2  downto 0); 
      txCrcDataValid                  : out std_logic; 
      txCrcInit                       : out std_logic; 
      txCrcReset                      : out std_logic; 
      txCrcOut                        : in  std_logic_vector(31 downto 0); 

      -- UDP Receive interface 
      udpRxValid                      : out std_logic;
      udpRxSOF                        : out std_logic;
      udpRxEOF                        : out std_logic;
      udpRxWidth                      : out std_logic;
      udpRxError                      : out std_logic;
      udpRxData                       : out std_logic_vector(63 downto 0);
      
      -- UDP Transmit interface 1
      eth1TxEmpty                     : in  std_logic;
      eth1TxData                      : in  std_logic_vector(63 downto 0);
      eth1TxType                      : in  std_logic_vector(1  downto 0);
      eth1TxSOF                       : in  std_logic;
      eth1TxEOF                       : in  std_logic;
      eth1TxWidth                     : in  std_logic;
      eth1TxRd                        : out std_logic;

      -- UDP Transmit interface 2
      eth2TxEmpty                     : in  std_logic;
      eth2TxData                      : in  std_logic_vector(63 downto 0);
      eth2TxType                      : in  std_logic_vector(1  downto 0);
      eth2TxSOF                       : in  std_logic;
      eth2TxEOF                       : in  std_logic;
      eth2TxWidth                     : in  std_logic;
      eth2TxRd                        : out std_logic;

     -- DCR Configuration
      appendCRC                       : in  std_logic;
      interFrameGap                   : in  std_logic_vector(3  downto 0);
      pauseTime                       : in  std_logic_vector(15 downto 0);
      macAddress                      : in  std_logic_vector(47 downto 0)
   );
end XMacTop;


-- Define architecture
architecture XMacTop of XMacTop is

component XMac
   generic (
      FreeList : natural := 1  -- Free List For MAC
   );
   port (
     
      -- Clock & Reset
      macTxClk                        : in  std_logic;
      macTxClk2X                      : in  std_logic;
      macTxRst                        : in  std_logic;
      macRxClk                        : in  std_logic;
      macRxClk2X                      : in  std_logic;
      macRxRst                        : in  std_logic;

      -- Import Interface
      Import_Clock                    : out std_logic;
      Import_Core_Reset               : in  std_logic;
      Import_Free_List                : out std_logic_vector( 3 downto 0);
      Import_Data_Valid               : out std_logic;
      Import_Data_Last_Line           : out std_logic;
      Import_Data_Last_Valid_Byte     : out std_logic_vector( 2 downto 0);
      Import_Data                     : out std_logic_vector(63 downto 0);
      Import_Data_Pipeline_Full       : in  std_logic;
      Import_Pause                    : in  std_logic;

      -- Export Interface
      Export_Clock                    : out std_logic;
      Export_Core_Reset               : in  std_logic;
      Export_Data_Valid               : in  std_logic;
      Export_Data_Ready               : out std_logic;
      Export_Data_SOP                 : in  std_logic;
      Export_Data_EOP                 : in  std_logic;
      Export_Data_Width               : in  std_logic;
      Export_Data                     : in  std_logic_vector(63 downto 0);
      Export_Advance_Status_Pipeline  : out std_logic;
      Export_Status                   : out std_logic_vector(31 downto 0);
      Export_Status_Full              : in  std_logic;

      -- XAUI Interface
      phyRxd                          : in  std_logic_vector(63 downto 0);
      phyRxc                          : in  std_logic_vector(7  downto 0);
      phyTxd                          : out std_logic_vector(63 downto 0);
      phyTxc                          : out std_logic_vector(7  downto 0);
      phyReady                        : in  std_logic;
      phyIdle                         : out std_logic;

      -- CRC Interface
      rxCrcIn                         : out std_logic_vector(63 downto 0); 
      rxCrcDataWidth                  : out std_logic_vector(2  downto 0); 
      rxCrcDataValid                  : out std_logic; 
      rxCrcInit                       : out std_logic; 
      rxCrcReset                      : out std_logic; 
      rxCrcOut                        : in  std_logic_vector(31 downto 0); 
      txCrcIn                         : out std_logic_vector(63 downto 0); 
      txCrcDataWidth                  : out std_logic_vector(2  downto 0); 
      txCrcDataValid                  : out std_logic; 
      txCrcInit                       : out std_logic; 
      txCrcReset                      : out std_logic; 
      txCrcOut                        : in  std_logic_vector(31 downto 0); 

      -- DCR Configuration
      appendCRC                       : in  std_logic;
      interFrameGap                   : in  std_logic_vector(3  downto 0);
      pauseTime                       : in  std_logic_vector(15 downto 0);
      macAddress                      : in  std_logic_vector(47 downto 0)
   );
end component;

component XMacArbiter is
   port (

      -- Ethernet clock & reset
      macClk        : in  std_logic;                        -- 125Mhz master clock
      macRst        : in  std_logic;                        -- Synchronous reset input

      -- Data from Device 1
      part1Valid    : in  std_logic;
      part1EOF      : in  std_logic;
      part1Ready    : out std_logic;
      part1Data     : in  std_logic_vector(63 downto 0);
      part1Length   : in  std_logic_vector(15 downto 0);

      -- Data from Device 2
      part2Valid    : in  std_logic;
      part2EOF      : in  std_logic;
      part2Ready    : out std_logic;
      part2Data     : in  std_logic_vector(63 downto 0);
      part2Length   : in  std_logic_vector(15 downto 0);
      
      -- UDP Transmit interface
      udpTxValid    : out std_logic;
      udpTxEOF      : out std_logic;
      udpTxReady    : in  std_logic;
      udpTxData     : out std_logic_vector(63 downto 0);
      udpTxLength   : out std_logic_vector(15 downto 0);
      
      -- Debug
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

   -- Local Signals
   signal ipAddr                   : IPAddrType;
   signal macAddr                  : MacAddrType;
   signal Import_Data_Valid        : std_logic;
   signal Import_Data_Last_Line    : std_logic;
   signal Import_Data              : std_logic_vector(63 downto 0);
   signal Export_Data_Valid        : std_logic;
   signal Export_Data_Ready        : std_logic;
   signal Export_Data_SOP          : std_logic;
   signal Export_Data_EOP          : std_logic;
   signal Export_Data_Width        : std_logic;
   signal Export_Data              : std_logic_vector(63 downto 0);
   signal emacRxValid              : std_logic;
   signal emacRxData               : std_logic_vector(63 downto 0);
   signal emacRxLast               : std_logic;
   signal emacTxReady              : std_logic;
   signal emacTxData               : std_logic_vector(63 downto 0);
   signal emacTxSOF                : std_logic;
   signal emacTxEOF                : std_logic;
   signal emacTxWidth              : std_logic;
   signal emacTxValid              : std_logic;
   signal udpTxValid               : std_logic;
   signal udpTxEOF                 : std_logic;
   signal udpTxReady               : std_logic;
   signal udpTxData                : std_logic_vector(63 downto 0);
   signal udpTxLength              : std_logic_vector(15 downto 0);
   signal udp1TxValid              : std_logic;
   signal udp1TxEOF                : std_logic;
   signal udp1TxReady              : std_logic;
   signal udp1TxData               : std_logic_vector(63 downto 0);
   signal udp1TxLength             : std_logic_vector(15 downto 0);
   signal udp2TxValid              : std_logic;
   signal udp2TxEOF                : std_logic;
   signal udp2TxReady              : std_logic;
   signal udp2TxData               : std_logic_vector(63 downto 0);
   signal udp2TxLength             : std_logic_vector(15 downto 0);

begin
   emacRxValid        <= Import_Data_Valid;
   emacRxLast         <= Import_Data_Last_Line;
   emacRxData         <= Import_Data;
   Imp_Data_Valid     <= Import_Data_Valid;
   Imp_Data_Last_Line <= Import_Data_Last_Line;
   Imp_Data           <= Import_Data;
   
   Export_Data_Valid  <= emacTxValid;
   emacTxReady        <= Export_Data_Ready;
   Export_Data_SOP    <= emacTxSOF;
   Export_Data_EOP    <= emacTxEOF;
   Export_Data_Width  <= emacTxWidth;
   Export_Data        <= emacTxData;
   Exp_Data_Valid     <= Export_Data_Valid;
   Exp_Data_SOP       <= Export_Data_SOP;
   Exp_Data_EOP       <= Export_Data_EOP;
   Exp_Data_Width     <= Export_Data_Width;
   Exp_Data           <= Export_Data;
   
   -- Mac Core
   U_XMac: XMac port map (
      macRxClk                       => macClk,
      macRxClk2X                     => macClk2X,
      macRxRst                       => macRst,
      Import_Core_Reset              => '0',
      Import_Data_Valid              => Import_Data_Valid,
      Import_Data_Last_Line          => Import_Data_Last_Line,
      Import_Data_Last_Valid_Byte    => Imp_Data_Last_Valid_Byte,
      Import_Data                    => Import_Data,
      Import_Data_Pipeline_Full      => '0',
      Import_Pause                   => '0',
      phyRxd                         => phyRxd,
      phyRxc                         => phyRxc,
      phyReady                       => phyReady,
      rxCrcIn                        => rxCrcIn,
      rxCrcDataWidth                 => rxCrcDataWidth,
      rxCrcDataValid                 => rxCrcDataValid,
      rxCrcInit                      => rxCrcInit,
      rxCrcReset                     => rxCrcReset,
      rxCrcOut                       => rxCrcOut,
      appendCRC                      => appendCRC,

      macTxClk                       => macClk,
      macTxClk2X                     => macClk2X,
      macTxRst                       => macRst,
      Export_Core_Reset              => '0',
      Export_Data_Valid              => Export_Data_Valid,
      Export_Data_Ready              => Export_Data_Ready,
      Export_Data_SOP                => Export_Data_SOP,
      Export_Data_EOP                => Export_Data_EOP,
      Export_Data_Width              => Export_Data_Width,
      Export_Data                    => Export_Data,
      Export_Advance_Status_Pipeline => Exp_Advance_Status_Pipeline,
      Export_Status                  => Exp_Status,
      Export_Status_Full             => '0',
      phyTxd                         => phyTxd,
      phyTxc                         => phyTxc,
      phyIdle                        => phyIdle,
      txCrcIn                        => txCrcIn,
      txCrcDataWidth                 => txCrcDataWidth,
      txCrcDataValid                 => txCrcDataValid,
      txCrcInit                      => txCrcInit,
      txCrcReset                     => txCrcReset,
      txCrcOut                       => txCrcOut,
      interFrameGap                  => interFrameGap,
      pauseTime                      => pauseTime,
      macAddress                     => macAddress
   );
   
    -- IP Address, 192.168.0.1
    ipAddr(3) <= x"c0";
    ipAddr(2) <= x"A8";
    ipAddr(1) <= x"00";
    ipAddr(0) <= x"01";

    -- MAC Address
    macAddr(0) <= x"08";
    macAddr(1) <= x"00";
    macAddr(2) <= x"56";
    macAddr(3) <= x"00";
    macAddr(4) <= x"03";
    macAddr(5) <= x"01";
    
   -- Ethernet core
   U_EthClient : EthClient
   port map (
      emacClk         => macClk,
      emacClkRst      => macRst,
      emacRxData      => emacRxData,
      emacRxValid     => emacRxValid,
      emacRxLast      => emacRxLast,
      emacTxData      => emacTxData,
      emacTxValid     => emacTxValid,
      emacTxReady     => emacTxReady,
      emacTxSOF       => emacTxSOF,
      emacTxWidth     => emacTxWidth,
      emacTxEOF       => emacTxEOF,
      ipAddr          => ipAddr,
      macAddr         => macAddr,
      udpTxValid      => udpTxValid,
      udpTxEOF        => udpTxEOF,
      udpTxReady      => udpTxReady,
      udpTxData       => udpTxData,
      udpTxLength     => udpTxLength,
      udpRxValid      => udpRxValid,
      udpRxSOF        => udpRxSOF,
      udpRxEOF        => udpRxEOF,
      udpRxWidth      => udpRxWidth,
      udpRxError      => udpRxError,
      udpRxData       => udpRxData
   );
   
   -- Data Chunker 1
   U_EthInterface1 : EthInterface port map (
      sysClk      => macClk,       sysRst      => macRst,
      gtpClk      => macClk,       gtpClkRst   => macRst,
      ethTxRd     => eth1TxRd,     ethTxEmpty  => eth1TxEmpty,
      ethTxSOF    => eth1TxSOF,    ethTxEOF    => eth1TxEOF,
      ethTxData   => eth1TxData,   ethTxType   => eth1TxType,
      ethTxWidth  => eth1TxWidth,  deviceID    => "00",
      udpTxValid  => udp1TxValid,  udpTxLength => udp1TxLength,
      udpTxEOF    => udp1TxEOF,    udpTxReady  => udp1TxReady,
      udpTxData   => udp1TxData
   );
   
   -- Data Chunker 2
   U_EthInterface2 : EthInterface port map (
      sysClk      => macClk,       sysRst      => macRst,
      gtpClk      => macClk,       gtpClkRst   => macRst,
      ethTxRd     => eth2TxRd,     ethTxEmpty  => eth2TxEmpty,
      ethTxSOF    => eth2TxSOF,    ethTxEOF    => eth2TxEOF,
      ethTxData   => eth2TxData,   ethTxType   => eth2TxType,
      ethTxWidth  => eth2TxWidth,  deviceID    => "01",
      udpTxValid  => udp2TxValid,  udpTxLength => udp2TxLength,
      udpTxEOF    => udp2TxEOF,    udpTxReady  => udp2TxReady,
      udpTxData   => udp2TxData
   );
   
   -- Data Arbiter
   U_XMacArbiter : XMacArbiter port map (
      macClk      => macClk,       macRst      => macRst,
      part1Valid  => udp1TxValid,  part1Length => udp1TxLength,
      part1EOF    => udp1TxEOF,    part1Ready  => udp1TxReady,
      part1Data   => udp1TxData,
      part2Valid  => udp2TxValid,  part2Length => udp2TxLength,
      part2EOF    => udp2TxEOF,    part2Ready  => udp2TxReady,
      part2Data   => udp2TxData,
      udpTxValid  => udpTxValid,   udpTxLength => udpTxLength,
      udpTxEOF    => udpTxEOF,     udpTxReady  => udpTxReady,
      udpTxData   => udpTxData
   );
end XMacTop;