-------------------------------------------------------------------------------
-- Title      : Common DTM Core Module
-- File       : DtmCore.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2013-11-14
-- Last update: 2014-01-17
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for DTM
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DtmCore is
   port (

      -- I2C
      i2cSda       : inout sl;
      i2cScl       : inout sl;

      -- PCI Exress
      pciRefClkP   : in    sl;
      pciRefClkM   : in    sl;
      pciRxP       : in    sl;
      pciRxM       : in    sl;
      pciTxP       : out   sl;
      pciTxM       : out   sl;
      pciResetL    : out   sl;

      -- COB Ethernet
      ethRxP      : in    sl;
      ethRxM      : in    sl;
      ethTxP      : out   sl;
      ethTxM      : out   sl;

      -- Clock Select
      clkSelA     : out   sl;
      clkSelB     : out   sl;

      -- Base Ethernet
      ethRxCtrl   : in    slv(1 downto 0);
      ethRxClk    : in    slv(1 downto 0);
      ethRxDataA  : in    Slv(1 downto 0);
      ethRxDataB  : in    Slv(1 downto 0);
      ethRxDataC  : in    Slv(1 downto 0);
      ethRxDataD  : in    Slv(1 downto 0);
      ethTxCtrl   : out   slv(1 downto 0);
      ethTxClk    : out   slv(1 downto 0);
      ethTxDataA  : out   Slv(1 downto 0);
      ethTxDataB  : out   Slv(1 downto 0);
      ethTxDataC  : out   Slv(1 downto 0);
      ethTxDataD  : out   Slv(1 downto 0);
      ethMdc      : out   Slv(1 downto 0);
      ethMio      : inout Slv(1 downto 0);
      ethResetL   : out   Slv(1 downto 0);

      -- IPMI
      dtmToIpmiP   : out   slv(1 downto 0);
      dtmToIpmiM   : out   slv(1 downto 0);

      -- Clocks
      axiClk                   : out   sl;
      axiClkRst                : out   sl;
      sysClk125                : out   sl;
      sysClk125Rst             : out   sl;
      sysClk200                : out   sl;
      sysClk200Rst             : out   sl;

      -- External Local Bus
      localBusMaster           : out   LocalBusMasterVector(14 downto 8);
      localBusSlave            : in    LocalBusSlaveVector(14 downto 8);

      -- PPI Outbound FIFO Interface
      obPpiClk                : in     slv(3 downto 0);
      obPpiToFifo             : in     ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo           : out    ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                : in     slv(3 downto 0);
      ibPpiToFifo             : in     IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo           : out    IbPpiFromFifoVector(3 downto 0)
   );
end DtmCore;

architecture STRUCTURE of DtmCore is

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
   signal iclkSelA           : slv(1 downto 0);
   signal iclkSelB           : slv(1 downto 0);
   signal pciRefClk          : sl;

begin

   --------------------------------------------------
   -- Top Level In/Out
   --------------------------------------------------

   -- PCI Ref Clk 
   U_PciRefClk : IBUFDS_GTE2
      port map(
         O       => pciRefClk,
         ODIV2   => open,
         I       => pciRefClkP,
         IB      => pciRefClkM,
         CEB     => '0'
      );

   --------------------------------------------------
   -- Outputs
   --------------------------------------------------
   clkSelA         <= iclkSelA(0);
   clkSelB         <= iclkSelB(0);
   axiClk          <= iaxiClk;
   axiClkRst       <= iaxiClkRst;
   sysClk125       <= isysClk125;
   sysClk125Rst    <= isysClk125Rst;
   sysClk200       <= isysClk200;
   sysClk200Rst    <= isysClk200Rst;
   localBusMaster  <= ilocalBusMaster(14 downto 8);

   ilocalBusSlave(14 downto 8) <= localBusSlave; 

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
         clkSelA            => iclkSelA,
         clkSelB            => iclkSelB
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
         ethRxP             => ethRxP,
         ethRxM             => ethRxM,
         ethTxP             => ethTxP,
         ethTxM             => ethTxM
      );

   --------------------------------------------------
   -- PCI Express
   --------------------------------------------------

   U_ZynqPcieMaster : entity work.ZynqPcieMaster 
      port map (
         axiClk          => iaxiClk,
         axiClkRst       => iaxiClkRst,
         localBusMaster  => ilocalBusMaster(15),
         localBusSlave   => ilocalBusSlave(15),
         pciRefClk       => pciRefClk,
         pcieResetL      => pciResetL,
         pcieRxP         => pciRxP,
         pcieRxM         => pciRxM,
         pcieTxP         => pciTxP,
         pcieTxM         => pciTxM
      );

   --------------------------------------------------
   -- Base Ethernet
   --------------------------------------------------
   
   U_GmiiToRgmiiSwitch : entity work.GmiiToRgmiiSwitch 
      generic map (
         SELECT_CH1_G => false
      ) port map (
         sysClk200    => isysClk200,
         sysClk200Rst => isysClk200Rst,
         ethFromArm   => iethFromArm(1),
         ethToArm     => iethToArm(1),         
         ethRxCtrl    => ethRxCtrl,
         ethRxClk     => ethRxClk,
         ethRxDataA   => ethRxDataA,
         ethRxDataB   => ethRxDataB,
         ethRxDataC   => ethRxDataC,
         ethRxDataD   => ethRxDataD,
         ethTxCtrl    => ethTxCtrl,
         ethTxClk     => ethTxClk,
         ethTxDataA   => ethTxDataA,
         ethTxDataB   => ethTxDataB,
         ethTxDataC   => ethTxDataC,
         ethTxDataD   => ethTxDataD,
         ethMdc       => ethMdc,
         ethMio       => ethMio,
         ethResetL    => ethResetL
      );      

   --------------------------------------------------
   -- Unused
   --------------------------------------------------

   dtmToIpmiP(0) <= 'Z';
   dtmToIpmiP(1) <= 'Z';
   dtmToIpmiM(0) <= 'Z';
   dtmToIpmiM(1) <= 'Z';

end architecture STRUCTURE;

