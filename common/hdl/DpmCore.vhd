-------------------------------------------------------------------------------
-- Title         : Common DPM Core Module
-- File          : DpmCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 11/14/2013
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for DPM
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity DpmCore is
   port (

      -- I2C
      i2cSda                   : inout sl;
      i2cScl                   : inout sl;

      -- Ethernet
      ethRxP                   : in    slv(0 downto 0);
      ethRxM                   : in    slv(0 downto 0);
      ethTxP                   : out   slv(0 downto 0);
      ethTxM                   : out   slv(0 downto 0);

      -- Reference Clocks
      locRefClkP               : in    slv(1 downto 0);
      locRefClkM               : in    slv(1 downto 0);
      locRefClk                : out   slv(1 downto 0);
      dtmRefClkP               : in    sl;
      dtmRefClkM               : in    sl;
      dtmRefClk                : out   sl;

      -- Clocks
      axiClk                   : out   sl;
      axiClkRst                : out   sl;
      sysClk125                : out   sl;
      sysClk125Rst             : out   sl;
      sysClk200                : out   sl;
      sysClk200Rst             : out   sl;

      -- DTM Signals
      dtmClkP                  : in    slv(1  downto 0);
      dtmClkM                  : in    slv(1  downto 0);
      dtmClk                   : out   slv(1  downto 0);
      dtmFbP                   : out   sl;
      dtmFbM                   : out   sl;
      dtmFb                    : in    sl;

      -- External Local Bus
      localBusMaster           : out   LocalBusMasterVector(15 downto 8);
      localBusSlave            : in    LocalBusSlaveVector(15 downto 8);

      -- PPI Outbound FIFO Interface
      obPpiClk                : in     slv(3 downto 0);
      obPpiToFifo             : in     ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo           : out    ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                : in     slv(3 downto 0);
      ibPpiToFifo             : in     IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo           : out    IbPpiFromFifoVector(3 downto 0);

      -- Clock Select
      clkSelA                 : out    slv(1 downto 0);
      clkSelB                 : out    slv(1 downto 0)
   );
end DpmCore;

architecture STRUCTURE of DpmCore is

   -- Local Signals
   signal ilocalBusSlave     : LocalBusSlaveVector(15 downto 8);
   signal ilocalBusMaster    : LocalBusMasterVector(15 downto 8);
   signal iaxiClk            : sl;
   signal iaxiClkRst         : sl;
   signal isysClk125         : sl;
   signal isysClk125Rst      : sl;
   signal isysClk200         : sl;
   signal isysClk200Rst      : sl;
   signal iethFromArm        : EthFromArmVector(1 downto 0);
   signal iethToArm          : EthToArmVector(1 downto 0);
   signal ilocRefClk         : slv(1 downto 0);
   signal idtmRefClk         : sl;
   signal idtmClk            : slv(1 downto 0);
   signal idtmFb             : sl;

begin

   --------------------------------------------------
   -- LVDS Input/Output Conversion
   --------------------------------------------------

   -- Local Ref Clk 0
   U_LocRefClk0 : IBUFDS_GTE2
      port map(
         O       => ilocRefClk(0),
         ODIV2   => open,
         I       => locRefClkP(0),
         IB      => locRefClkM(0),
         CEB     => '0'
      );

   -- Local Ref Clk 1
   U_LocRefClk1 : IBUFDS_GTE2
      port map(
         O       => ilocRefClk(1),
         ODIV2   => open,
         I       => locRefClkP(1),
         IB      => locRefClkM(1),
         CEB     => '0'
      );

   -- DTM Ref Clk
   U_DtmRefClk : IBUFDS_GTE2
      port map(
         O       => idtmRefClk,
         ODIV2   => open,
         I       => dtmRefClkP,
         IB      => dtmRefClkM,
         CEB     => '0'
      );

   -- DTM Clock 0
   U_DtmClk0 : IBUFDS 
      generic map ( DIFF_TERM => true ) 
      port map ( 
         I  => dtmClkP(0), 
         IB => dtmClkM(0), 
         O  => idtmClk(0) 
      );

   -- DTM Clock 1
   U_DtmClk1 : IBUFDS 
      generic map ( DIFF_TERM => true ) 
      port map ( 
         I  => dtmClkP(1), 
         IB => dtmClkM(1), 
         O  => idtmClk(1) 
      );

   -- DTM Feedback
   U_DtmFb : OBUFDS 
      port map ( 
         O  => dtmFbP,     
         OB => dtmFbM,     
         I  => dtmFb     
      );


   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   locRefClk       <= ilocRefClk;
   dtmRefClk       <= idtmRefClk;
   dtmClk          <= idtmClk;
   axiClk          <= iaxiClk;
   axiClkRst       <= iaxiClkRst;
   sysClk125       <= isysClk125;
   sysClk125Rst    <= isysClk125Rst;
   sysClk200       <= isysClk200;
   sysClk200Rst    <= isysClk200Rst;
   localBusMaster  <= ilocalBusMaster;
   ilocalBusSlave  <= localBusSlave; 

   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_ArmRceG3Top: entity work.ArmRceG3Top
      generic map (
         AXI_CLKDIV_G => 4.7
      ) port map (
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         axiClk             => iaxiClk,
         axiClkRst          => iaxiClkRst,
         sysClk125          => isysClk125,
         sysClk125Rst       => isysClk125Rst,
         sysClk200          => isysClk200,
         sysClk200Rst       => isysClk200Rst,
         localBusMaster     => ilocalBusMaster,
         localBusSlave      => ilocalBusSlave,
         obPpiClk           => obPpiClk,
         obPpiToFifo        => obPpiToFifo,
         obPpiFromFifo      => obPpiFromFifo,
         ibPpiClk           => ibPpiClk,
         ibPpiToFifo        => ibPpiToFifo,
         ibPpiFromFifo      => ibPpiFromFifo,
         ethFromArm         => iethFromArm,
         ethToArm           => iethToArm,
         clkSelA            => clkSelA,
         clkSelB            => clkSelB
      );

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_ZynqEthernet : entity work.ZynqEthernet 
      port map (
         sysClk125          => isysClk125,
         sysClk200          => isysClk200,
         sysClk200Rst       => isysClk200Rst,
         ethFromArm         => iethFromArm(0),
         ethToArm           => iethToArm(0),
         ethRxP             => ethRxP(0),
         ethRxM             => ethRxM(0),
         ethTxP             => ethTxP(0),
         ethTxM             => ethTxM(0)
      );

   iethToArm(1) <= EthToArmInit;

end architecture STRUCTURE;

