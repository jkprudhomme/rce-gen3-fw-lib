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
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity DtmCore is
   generic (
      TPD_G : time := 1 ns
   );
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
      sysClk125               : out   sl;
      sysClk125Rst            : out   sl;
      sysClk200               : out   sl;
      sysClk200Rst            : out   sl;

      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF
      axiClk                  : out   sl;
      axiClkRst               : out   sl;
      localAxiReadMaster      : out   AxiLiteReadMasterType;
      localAxiReadSlave       : in    AxiLiteReadSlaveType;
      localAxiWriteMaster     : out   AxiLiteWriteMasterType;
      localAxiWriteSlave      : in    AxiLiteWriteSlaveType;

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
   signal iaxiClk           : sl;
   signal iaxiClkRst        : sl;
   signal isysClk125        : sl;
   signal isysClk125Rst     : sl;
   signal isysClk200        : sl;
   signal isysClk200Rst     : sl;
   signal iethFromArm       : EthFromArmVector(1 downto 0);
   signal iethToArm         : EthToArmVector(1 downto 0);
   signal iclkSelA          : slv(1 downto 0);
   signal iclkSelB          : slv(1 downto 0);
   signal intAxiReadMaster  : AxiLiteReadMasterArray(1 downto 0);
   signal intAxiReadSlave   : AxiLiteReadSlaveArray(1 downto 0);
   signal intAxiWriteMaster : AxiLiteWriteMasterArray(1 downto 0);
   signal intAxiWriteSlave  : AxiLiteWriteSlaveArray(1 downto 0);
   signal topAxiReadMaster  : AxiLiteReadMasterType;
   signal topAxiReadSlave   : AxiLiteReadSlaveType;
   signal topAxiWriteMaster : AxiLiteWriteMasterType;
   signal topAxiWriteSlave  : AxiLiteWriteSlaveType;

begin

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

   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_ArmRceG3Top: entity work.ArmRceG3Top
      generic map (
         AXI_CLKDIV_G => 5.0
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => isysClk125,
         sysClk125Rst        => isysClk125Rst,
         sysClk200           => isysClk200,
         sysClk200Rst        => isysClk200Rst,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         localAxiReadMaster  => topAxiReadMaster,
         localAxiReadSlave   => topAxiReadSlave ,
         localAxiWriteMaster => topAxiWriteMaster,
         localAxiWriteSlave  => topAxiWriteSlave ,
         obPpiClk            => obPpiClk,
         obPpiToFifo         => obPpiToFifo,
         obPpiFromFifo       => obPpiFromFifo,
         ibPpiClk            => ibPpiClk,
         ibPpiToFifo         => ibPpiToFifo,
         ibPpiFromFifo       => ibPpiFromFifo,
         ethFromArm          => iethFromArm,
         ethToArm            => iethToArm,
         clkSelA             => iclkSelA,
         clkSelB             => iclkSelB
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
   -- PCI Express : 0xBC00_0000 - 0xBC00_FFFF
   --------------------------------------------------

   U_ZynqPcieMaster : entity work.ZynqPcieMaster 
      port map (
         axiClk          => iaxiClk,
         axiClkRst       => iaxiClkRst,
         axiReadMaster   => intAxiReadMaster(1),
         axiReadSlave    => intAxiReadSlave(1),
         axiWriteMaster  => intAxiWriteMaster(1),
         axiWriteSlave   => intAxiWriteSlave(1),
         pciRefClkP      => pciRefClkP,
         pciRefClkM      => pciRefClkM,
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

   -------------------------------------
   -- AXI Lite Crossbar
   -- Base: 0xA0000000 - 0xBFFFFFFF
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 2,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            -- Channel 0 = 0xA0000000 - 0xAFFFFFFF : External Top Level
            0 => ( baseAddr     => x"A0000000",
                   addrBits     => 28,
                   connectivity => x"FFFF"),

            -- Channel 1 = 0xBC000000 - 0xBC00FFFF : PCI Express Registers
            1 => ( baseAddr     => x"BC000000",
                   addrBits     => 16,
                   connectivity => x"FFFF")
         )
      ) port map (
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         sAxiWriteMasters(0) => topAxiWriteMaster,
         sAxiWriteSlaves(0)  => topAxiWriteSlave,
         sAxiReadMasters(0)  => topAxiReadMaster,
         sAxiReadSlaves(0)   => topAxiReadSlave,
         mAxiWriteMasters    => intAxiWriteMaster,
         mAxiWriteSlaves     => intAxiWriteSlave,
         mAxiReadMasters     => intAxiReadMaster,
         mAxiReadSlaves      => intAxiReadSlave
      );

   -- External Connections
   localAxiReadMaster  <= intAxiReadMaster(0);
   intAxiReadSlave(0)  <= localAxiReadSlave;
   localAxiWriteMaster <= intAxiWriteMaster(0);
   intAxiWriteSlave(0) <= localAxiWriteSlave;

end architecture STRUCTURE;

