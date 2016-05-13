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
-- This file is part of 'SLAC RCE DTM Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE DTM Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DtmCore is
   generic (
      TPD_G          : time           := 1 ns;
      RCE_DMA_MODE_G : RceDmaModeType := RCE_DMA_PPI_C;
      OLD_BSI_MODE_G : boolean        := false;
      HSIO_MODE_G    : boolean        := false
   );
   port (

      -- I2C
      i2cSda                  : inout sl;
      i2cScl                  : inout sl;

      -- PCI Exress, Unused when HSIO_MODE_G = true
      pciRefClkP              : in    sl;
      pciRefClkM              : in    sl;
      pciRxP                  : in    sl;
      pciRxM                  : in    sl;
      pciTxP                  : out   sl;
      pciTxM                  : out   sl;
      pciResetL               : out   sl;

      -- COB Ethernet, Unused when HSIO_MODE_G = true
      ethRxP                  : in    sl;
      ethRxM                  : in    sl;
      ethTxP                  : out   sl;
      ethTxM                  : out   sl;

      -- Clock Select
      clkSelA                 : out   sl;
      clkSelB                 : out   sl;

      -- Base Ethernet
      ethRxCtrl               : in    slv(1 downto 0);
      ethRxClk                : in    slv(1 downto 0);
      ethRxDataA              : in    Slv(1 downto 0);
      ethRxDataB              : in    Slv(1 downto 0);
      ethRxDataC              : in    Slv(1 downto 0);
      ethRxDataD              : in    Slv(1 downto 0);
      ethTxCtrl               : out   slv(1 downto 0);
      ethTxClk                : out   slv(1 downto 0);
      ethTxDataA              : out   Slv(1 downto 0);
      ethTxDataB              : out   Slv(1 downto 0);
      ethTxDataC              : out   Slv(1 downto 0);
      ethTxDataD              : out   Slv(1 downto 0);
      ethMdc                  : out   Slv(1 downto 0);
      ethMio                  : inout Slv(1 downto 0);
      ethResetL               : out   Slv(1 downto 0);

      -- IPMI
      dtmToIpmiP              : out   slv(1 downto 0);
      dtmToIpmiM              : out   slv(1 downto 0);

      -- Clocks
      sysClk125               : out   sl;
      sysClk125Rst            : out   sl;
      sysClk200               : out   sl;
      sysClk200Rst            : out   sl;

      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF
      axiClk                  : out   sl;
      axiClkRst               : out   sl;
      extAxilReadMaster       : out   AxiLiteReadMasterType;
      extAxilReadSlave        : in    AxiLiteReadSlaveType;
      extAxilWriteMaster      : out   AxiLiteWriteMasterType;
      extAxilWriteSlave       : in    AxiLiteWriteSlaveType;

      -- DMA Interfaces
      dmaClk                  : in    slv(2 downto 0);
      dmaClkRst               : in    slv(2 downto 0);
      dmaState                : out   RceDmaStateArray(2 downto 0);
      dmaObMaster             : out   AxiStreamMasterArray(2 downto 0);
      dmaObSlave              : in    AxiStreamSlaveArray(2 downto 0);
      dmaIbMaster             : in    AxiStreamMasterArray(2 downto 0);
      dmaIbSlave              : out   AxiStreamSlaveArray(2 downto 0);

      -- User Interrupts
      userInterrupt            : in    slv(USER_INT_COUNT_C-1 downto 0)

   );
end DtmCore;

architecture STRUCTURE of DtmCore is

   signal iaxiClk             : sl;
   signal iaxiClkRst          : sl;
   signal isysClk125          : sl;
   signal isysClk125Rst       : sl;
   signal isysClk200          : sl;
   signal isysClk200Rst       : sl;
   signal idmaClk             : slv(3 downto 0);
   signal idmaClkRst          : slv(3 downto 0);
   signal idmaState           : RceDmaStateArray(3 downto 0);
   signal idmaObMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave         : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave         : AxiStreamSlaveArray(3 downto 0);
   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal pcieAxilReadMaster  : AxiLiteReadMasterType;
   signal pcieAxilReadSlave   : AxiLiteReadSlaveType;
   signal pcieAxilWriteMaster : AxiLiteWriteMasterType;
   signal pcieAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal armEthTx            : ArmEthTxArray(1 downto 0);
   signal armEthRx            : ArmEthRxArray(1 downto 0);
   signal armEthMode          : slv(31 downto 0);
   signal iethRxP             : sl;
   signal iethRxM             : sl;
   signal iethTxP             : sl;
   signal iethTxM             : sl;
   signal ipciRxP             : sl;
   signal ipciRxM             : sl;
   signal ipciTxP             : sl;
   signal ipciTxM             : sl;

   attribute KEEP_HIERARCHY : string;
   attribute KEEP_HIERARCHY of
      U_RceG3Top,
      U_AxiCrossbar,
      U_ZynqPcieMaster,
      U_ZynqEthernet : label is "TRUE";   
   
begin

   --------------------------------------------------
   -- Outputs
   --------------------------------------------------
   axiClk          <= iaxiClk;
   axiClkRst       <= iaxiClkRst;
   sysClk125       <= isysClk125;
   sysClk125Rst    <= isysClk125Rst;
   sysClk200       <= isysClk200;
   sysClk200Rst    <= isysClk200Rst;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk;
   idmaClkRst(2 downto 0)   <= dmaClkRst;
   dmaState                 <= idmaState(2 downto 0);
   dmaObMaster              <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlave;
   idmaIbMaster(2 downto 0) <= dmaIbMaster;
   dmaIbSlave               <= idmaIbSlave(2 downto 0);


   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top: entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         RCE_DMA_MODE_G => RCE_DMA_MODE_G,
         OLD_BSI_MODE_G => OLD_BSI_MODE_G
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => isysClk125,
         sysClk125Rst        => isysClk125Rst,
         sysClk200           => isysClk200,
         sysClk200Rst        => isysClk200Rst,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave ,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave ,
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         dmaClk              => idmaClk,
         dmaClkRst           => idmaClkRst,
         dmaState            => idmaState,
         dmaObMaster         => idmaObMaster,
         dmaObSlave          => idmaObSlave,
         dmaIbMaster         => idmaIbMaster,
         dmaIbSlave          => idmaIbSlave,
         userInterrupt       => userInterrupt,
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode,
         clkSelA             => open,
         clkSelB             => open
      );

   -- Hard code to 250Mhz
   clkSelA <= '1';
   clkSelB <= '1';


   -------------------------------------
   -- AXI Lite Crossbar
   -- Base: 0xB0000000 - 0xBFFFFFFF
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 1,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            -- Channel 1 = 0xBC000000 - 0xBC00FFFF : PCI Express Registers
            0 => ( baseAddr     => x"BC000000",
                   addrBits     => 16,
                   connectivity => x"FFFF")
         )
      ) port map (
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         sAxiWriteMasters(0) => coreAxilWriteMaster,
         sAxiWriteSlaves(0)  => coreAxilWriteSlave,
         sAxiReadMasters(0)  => coreAxilReadMaster,
         sAxiReadSlaves(0)   => coreAxilReadSlave,
         mAxiWriteMasters(0) => pcieAxilWriteMaster,
         mAxiWriteSlaves(0)  => pcieAxilWriteSlave,
         mAxiReadMasters(0)  => pcieAxilReadMaster,
         mAxiReadSlaves(0)   => pcieAxilReadSlave
      );


   --------------------------------------------------
   -- PCI Express : 0xBC00_0000 - 0xBC00_FFFF
   --------------------------------------------------
   U_ZynqPcieMaster : entity work.ZynqPcieMaster 
      generic map (
         HSIO_MODE_G => HSIO_MODE_G
      ) port map (
         axiClk          => iaxiClk,
         axiClkRst       => iaxiClkRst,
         axiReadMaster   => pcieAxilReadMaster,
         axiReadSlave    => pcieAxilReadSlave,
         axiWriteMaster  => pcieAxilWriteMaster,
         axiWriteSlave   => pcieAxilWriteSlave,
         pciRefClkP      => pciRefClkP,
         pciRefClkM      => pciRefClkM,
         pcieResetL      => pciResetL,
         pcieRxP         => ipciRxP,
         pcieRxM         => ipciRxM,
         pcieTxP         => ipciTxP,
         pcieTxM         => ipciTxM
      );

   U_HsioPciDisGen : if HSIO_MODE_G = false generate
      ipciRxP <= pciRxP;
      ipciRxM <= pciRxM;
      pciTxP  <= ipciTxP;
      pciTxM  <= ipciTxM;
   end generate;

   U_HsioPciEnGen : if HSIO_MODE_G = true generate
      ipciRxP <= '0';
      ipciRxM <= '0';
   end generate;


   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_HsioEthDisGen : if HSIO_MODE_G = false generate
      iethRxP  <= ethRxP;
      iethRxM  <= ethRxM;
      ethTxP   <= iethTxP;
      ethTxM   <= iethTxM;
   end generate;

   U_HsioEthEnGen : if HSIO_MODE_G = true generate
      iethRxP <= pciRxP;
      iethRxM <= pciRxM;
      pciTxP  <= iethTxP;
      pciTxM  <= iethTxM;
   end generate;

   U_ZynqEthernet : entity work.ZynqEthernet 
      port map (
         sysClk125          => isysClk125,
         sysClk200          => isysClk200,
         sysClk200Rst       => isysClk200Rst,
         armEthTx           => armEthTx(0),
         armEthRx           => armEthRx(0),
         ethRxP             => iethRxP,
         ethRxM             => iethRxM,
         ethTxP             => iethTxP,
         ethTxM             => iethTxM
      );

      armEthRx(1)     <= ARM_ETH_RX_INIT_C;
--   end generate;

--   U_HsioEnGen : if HSIO_MODE_G = true generate
--      ethTxP <= '1';
--      ethTxM <= '0';
--
--      U_GmiiToRgmii : entity work.GmiiToRgmiiDual 
--         port map (
--            sysClk200     => isysClk200,
--            sysClk200Rst  => isysClk200Rst,
--            armEthTx      => armEthTx,
--            armEthRx      => armEthRx,
--            ethRxCtrl     => ethRxCtrl,
--            ethRxClk      => ethRxClk,
--            ethRxDataA    => ethRxDataA,
--            ethRxDataB    => ethRxDataB,
--            ethRxDataC    => ethRxDataC,
--            ethRxDataD    => ethRxDataD,
--            ethTxCtrl     => ethTxCtrl,
--            ethTxClk      => ethTxClk,
--            ethTxDataA    => ethTxDataA,
--            ethTxDataB    => ethTxDataB,
--            ethTxDataC    => ethTxDataC,
--            ethTxDataD    => ethTxDataD,
--            ethMdc        => ethMdc,
--            ethMio        => ethMio,
--            ethResetL     => ethResetL
--         );
--   end generate;

   armEthMode      <= x"00000001"; -- 1 Gig on lane 0
   idmaClk(3)      <= isysClk125;
   idmaClkRst(3)   <= isysClk125Rst;
   idmaObSlave(3)  <= AXI_STREAM_SLAVE_INIT_C;
   idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;


   --------------------------------------------------
   -- Unused
   --------------------------------------------------

   dtmToIpmiP(0) <= 'Z';
   dtmToIpmiP(1) <= 'Z';
   dtmToIpmiM(0) <= 'Z';
   dtmToIpmiM(1) <= 'Z';

end architecture STRUCTURE;

