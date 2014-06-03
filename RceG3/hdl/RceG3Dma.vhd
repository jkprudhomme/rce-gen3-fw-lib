-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, DMA Controllers
-- File          : RceG3Dma.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level Wrapper for DMA controllers
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity RceG3Dma is
   generic (
      TPD_G           : time           := 1 ns;
      RCE_DMA_MODE_G  : RceDmaModeType := RCE_DMA_PPI_C
   );
   port (

      -- AXI BUS Clock
      axiDmaClk           : in  sl;
      axiDmaRst           : in  sl;

      -- AXI ACP Slave
      acpWriteSlave       : in  AxiWriteSlaveType;
      acpWriteMaster      : out AxiWriteMasterType;
      acpReadSlave        : in  AxiReadSlaveType;
      acpReadMaster       : out AxiReadMasterType;

      -- AXI HP Slave
      hpWriteSlave        : in  AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster       : out AxiWriteMasterArray(3 downto 0);
      hpReadSlave         : in  AxiReadSlaveArray(3 downto 0);
      hpReadMaster        : out AxiReadMasterArray(3 downto 0);

      -- Local AXI Lite Bus
      dmaAxilReadMaster   : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilReadSlave    : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteMaster  : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteSlave   : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

      -- Interrupts
      dmaInterrupt        : out slv(DMA_INT_COUNT_C-1 downto 0);

      -- External DMA Interfaces
      dmaClk              : in  slv(3 downto 0);
      dmaClkRst           : in  slv(3 downto 0);
      dmaState            : out RceDmaStateArray(3 downto 0);
      dmaObMaster         : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(3 downto 0)
   );
end RceG3Dma;

architecture structure of RceG3Dma is

begin


   ------------------------------------
   -- PPI DMA Controllers
   ------------------------------------
   U_PpiDmaGen : if RCE_DMA_MODE_G = RCE_DMA_PPI_C generate

      U_RceG3DmaPpi : entity work.RceG3DmaPpi
         generic map (
            TPD_G            => TPD_G
         ) port map (
            axiDmaClk        => axiDmaClk,
            axiDmaRst        => axiDmaRst,
            acpWriteSlave    => acpWriteSlave,
            acpWriteMaster   => acpWriteMaster,
            acpReadSlave     => acpReadSlave,
            acpReadMaster    => acpReadMaster,
            hpWriteSlave     => hpWriteSlave,
            hpWriteMaster    => hpWriteMaster,
            hpReadSlave      => hpReadSlave,
            hpReadMaster     => hpReadMaster,
            axilReadMaster   => dmaAxilReadMaster,
            axilReadSlave    => dmaAxilReadSlave,
            axilWriteMaster  => dmaAxilWriteMaster,
            axilWriteSlave   => dmaAxilWriteSlave,
            interrupt        => dmaInterrupt,
            dmaClk           => dmaClk,
            dmaClkRst        => dmaClkRst,
            dmaState         => dmaState,
            dmaObMaster      => dmaObMaster,
            dmaObSlave       => dmaObSlave,
            dmaIbMaster      => dmaIbMaster,
            dmaIbSlave       => dmaIbSlave
         );
   end generate;


   ------------------------------------
   -- AXI Streaming DMA Controllers
   ------------------------------------
   U_AxisDmaGen : if RCE_DMA_MODE_G = RCE_DMA_AXIS_C generate

      U_RceG3DmaAxis : entity work.RceG3DmaAxis
         generic map (
            TPD_G            => TPD_G
         ) port map (
            axiDmaClk        => axiDmaClk,
            axiDmaRst        => axiDmaRst,
            acpWriteSlave    => acpWriteSlave,
            acpWriteMaster   => acpWriteMaster,
            acpReadSlave     => acpReadSlave,
            acpReadMaster    => acpReadMaster,
            hpWriteSlave     => hpWriteSlave,
            hpWriteMaster    => hpWriteMaster,
            hpReadSlave      => hpReadSlave,
            hpReadMaster     => hpReadMaster,
            axilReadMaster   => dmaAxilReadMaster,
            axilReadSlave    => dmaAxilReadSlave,
            axilWriteMaster  => dmaAxilWriteMaster,
            axilWriteSlave   => dmaAxilWriteSlave,
            interrupt        => dmaInterrupt,
            dmaClk           => dmaClk,
            dmaClkRst        => dmaClkRst,
            dmaState         => dmaState,
            dmaObMaster      => dmaObMaster,
            dmaObSlave       => dmaObSlave,
            dmaIbMaster      => dmaIbMaster,
            dmaIbSlave       => dmaIbSlave
         );
   end generate;

end architecture structure;

