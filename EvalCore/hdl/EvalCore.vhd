-------------------------------------------------------------------------------
-- Title         : Eval Core Module
-- File          : EvalCore.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 11/14/2013
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for Eval
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Eval Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Eval Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity EvalCore is
   generic (
      TPD_G          : time           := 1 ns;
      RCE_DMA_MODE_G : RceDmaModeType := RCE_DMA_PPI_C;
      OLD_BSI_MODE_G : boolean        := false
   );
   port (
      i2cSda                  : inout sl;
      i2cScl                  : inout sl;

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
end EvalCore;

architecture STRUCTURE of EvalCore is

   signal iaxiClk             : sl;
   signal iaxiClkRst          : sl;
   signal isysClk125          : sl;
   signal isysClk125Rst       : sl;
   signal isysClk200          : sl;
   signal isysClk200Rst       : sl;
   signal idmaClk             : slv(3 downto 0);
   signal idmaClkRst          : slv(3 downto 0);
   signal idmaCtrl            : slv(3 downto 0);
   signal idmaState           : RceDmaStateArray(3 downto 0);
   signal idmaObMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave         : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave         : AxiStreamSlaveArray(3 downto 0);
   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType;

begin

   -- Core
   U_RceG3Top: entity work.RceG3Top
      generic map (
         TPD_G           => TPD_G,
         RCE_DMA_MODE_G  => RCE_DMA_MODE_G,
         OLD_BSI_MODE_G  => OLD_BSI_MODE_G,
         DMA_CLKDIV_G    => 10.0,
         DMA_CLKDIV_EN_G => true
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
         armEthTx            => open,
         armEthRx            => (others=>ARM_ETH_RX_INIT_C),
         armEthMode          => (others=>'0'),
         clkSelA             => open,
         clkSelB             => open
      );

   -- Clock Outputs
   axiClk        <= iaxiClk;
   axiClkRst     <= iaxiClkRst;
   axiClk        <= iaxiClk;
   axiClkRst     <= iaxiClkRst;
   sysClk125     <= isysClk125;
   sysClk125Rst  <= isysClk125Rst;
   sysClk200     <= isysClk200;
   sysClk200Rst  <= isysClk200Rst;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk;
   idmaClkRst(2 downto 0)   <= dmaClkRst;
   dmaState                 <= idmaState(2 downto 0);
   dmaObMaster              <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlave;
   idmaIbMaster(2 downto 0) <= dmaIbMaster;
   dmaIbSlave               <= idmaIbSlave(2 downto 0);

   -- Unused DMA Interface
   idmaClk(3)      <= isysClk125;
   idmaClkRst(3)   <= isysClk125Rst;
   idmaObSlave(3)  <= AXI_STREAM_SLAVE_INIT_C;
   idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;

   -- Terminate Unused AXI-Lite Interface
   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G  => TPD_G
      ) port map (
         axiClk          => iaxiClk,
         axiClkRst       => iaxiClkRst,
         axiReadMaster   => coreAxilReadMaster,
         axiReadSlave    => coreAxilReadSlave,
         axiWriteMaster  => coreAxilWriteMaster,
         axiWriteSlave   => coreAxilWriteSlave
      );

end architecture STRUCTURE;

