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

entity XMac is 
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
end XMac;


-- Define architecture
architecture XMac of XMac is

   -- Import Block
   component XMacImport
      generic (
         FreeList : natural := 1   -- Free List For MAC
      );
      port (
         macClk                          : in  std_logic;
         macClk2X                        : in  std_logic;
         macRst                          : in  std_logic;
         Import_Clock                    : out std_logic;
         Import_Core_Reset               : in  std_logic;
         Import_Free_List                : out std_logic_vector( 3 downto 0);
         Import_Data_Valid               : out std_logic;
         Import_Data_Last_Line           : out std_logic;
         Import_Data_Last_Valid_Byte     : out std_logic_vector( 2 downto 0);
         Import_Data                     : out std_logic_vector(63 downto 0);
         Import_Data_Pipeline_Full       : in  std_logic;
         Import_Pause                    : in  std_logic;
         phyRxd                          : in  std_logic_vector(63 downto 0);
         phyRxc                          : in  std_logic_vector(7  downto 0);
         phyReady                        : in  std_logic;
         rxCrcIn                         : out std_logic_vector(63 downto 0); 
         rxCrcDataWidth                  : out std_logic_vector(2  downto 0); 
         rxCrcDataValid                  : out std_logic; 
         rxCrcInit                       : out std_logic; 
         rxCrcReset                      : out std_logic; 
         rxCrcOut                        : in  std_logic_vector(31 downto 0); 
         rxPauseSet                      : out std_logic;
         rxPauseValue                    : out std_logic_vector(15 downto 0);
         appendCRC                       : in  std_logic
      );
   end component;

   -- Export Block
   component XMacExport
      port (
         macClk                          : in  std_logic;
         macClk2X                        : in  std_logic;
         macRst                          : in  std_logic;
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
         Import_Pause                    : in  std_logic;
         phyTxd                          : out std_logic_vector(63 downto 0);
         phyTxc                          : out std_logic_vector(7  downto 0);
         phyReady                        : in  std_logic;
         phyIdle                         : out std_logic;
         txCrcIn                         : out std_logic_vector(63 downto 0); 
         txCrcDataWidth                  : out std_logic_vector(2  downto 0); 
         txCrcDataValid                  : out std_logic; 
         txCrcInit                       : out std_logic; 
         txCrcReset                      : out std_logic; 
         txCrcOut                        : in  std_logic_vector(31 downto 0); 
         rxPauseSet                      : in  std_logic;
         rxPauseValue                    : in  std_logic_vector(15 downto 0);
         interFrameGap                   : in  std_logic_vector(3  downto 0);
         pauseTime                       : in  std_logic_vector(15 downto 0);
         macAddress                      : in  std_logic_vector(47 downto 0)
      );
   end component;

   -- Local Signals
   signal rxPauseSet   : std_logic;
   signal rxPauseValue : std_logic_vector(15 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.1 ns;

begin

  -- Import Block
   U_XMacImport: XMacImport generic map ( FreeList => FreeList ) port map (
      macClk                       => macRxClk,
      macClk2X                     => macRxClk2X,
      macRst                       => macRxRst,
      Import_Clock                 => Import_Clock,
      Import_Core_Reset            => Import_Core_Reset,
      Import_Free_List             => Import_Free_List,
      Import_Data_Valid            => Import_Data_Valid,
      Import_Data_Last_Line        => Import_Data_Last_Line,
      Import_Data_Last_Valid_Byte  => Import_Data_Last_Valid_Byte,
      Import_Data                  => Import_Data,
      Import_Data_Pipeline_Full    => Import_Data_Pipeline_Full,
      Import_Pause                 => Import_Pause,
      phyRxd                       => phyRxd,
      phyRxc                       => phyRxc,
      phyReady                     => phyReady,
      rxCrcIn                      => rxCrcIn,
      rxCrcDataWidth               => rxCrcDataWidth,
      rxCrcDataValid               => rxCrcDataValid,
      rxCrcInit                    => rxCrcInit,
      rxCrcReset                   => rxCrcReset,
      rxCrcOut                     => rxCrcOut,
      rxPauseSet                   => rxPauseSet,
      rxPauseValue                 => rxPauseValue,
      appendCRC                    => appendCRC
   );


   -- Export Block
   U_XMacExport: XMacExport port map (
      macClk                         => macTxClk,
      macClk2X                       => macTxClk2X,
      macRst                         => macTxRst,
      Export_Clock                   => Export_Clock,
      Export_Core_Reset              => Export_Core_Reset,
      Export_Data_Valid              => Export_Data_Valid,
      Export_Data_Ready              => Export_Data_Ready,
      Export_Data_SOP                => Export_Data_SOP,
      Export_Data_EOP                => Export_Data_EOP,
      Export_Data_Width              => Export_Data_Width,
      Export_Data                    => Export_Data,
      Export_Advance_Status_Pipeline => Export_Advance_Status_Pipeline,
      Export_Status                  => Export_Status,
      Export_Status_Full             => Export_Status_Full,
      Import_Pause                   => Import_Pause,
      phyTxd                         => phyTxd,
      phyTxc                         => phyTxc,
      phyReady                       => phyReady,
      phyIdle                        => phyIdle,
      txCrcIn                        => txCrcIn,
      txCrcDataWidth                 => txCrcDataWidth,
      txCrcDataValid                 => txCrcDataValid,
      txCrcInit                      => txCrcInit,
      txCrcReset                     => txCrcReset,
      txCrcOut                       => txCrcOut,
      rxPauseSet                     => rxPauseSet,
      rxPauseValue                   => rxPauseValue,
      interFrameGap                  => interFrameGap,
      pauseTime                      => pauseTime,
      macAddress                     => macAddress
   );

end XMac;
