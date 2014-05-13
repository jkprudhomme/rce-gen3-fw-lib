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

use work.all;
use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity RceG3Dma is
   generic (
      TPD_G                 : time                  := 1 ns;
      AXIL_BASE_ADDR_G      : slv(31 downto 0)      := x"00000000";
      RCE_DMA_MODE_G        : RceDmaModeType        := RCE_DMA_PPI_C;
      RCE_DMA_COUNT_G       : integer range 1 to 16 := 4;
      RCE_DMA_AXIS_CONFIG_G : AxiStreamConfigType   := AXI_STREAM_CONFIG_INIT_C
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
      axilReadMaster      : in  AxiLiteReadMasterType;
      axilReadSlave       : out AxiLiteReadSlaveType;
      axilWriteMaster     : in  AxiLiteWriteMasterType;
      axilWriteSlave      : out AxiLiteWriteSlaveType;

      -- Interrupts
      interrupt           : out slv(15 downto 0);

      -- External DMA Interfaces
      dmaClk              : in  slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaClkRst           : in  slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaOnline           : out slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaEnable           : out slv(RCE_DMA_COUNT_G-1 downto 0);
      dmaObMaster         : out AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0)
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
            TPD_G            => TPD_G,
            AXIL_BASE_ADDR_G => AXIL_BASE_ADDR_G
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
            axilReadMaster   => axilReadMaster,
            axilReadSlave    => axilReadSlave,
            axilWriteMaster  => axilWriteMaster,
            axilWriteSlave   => axilWriteSlave,
            interrupt        => interrupt,
            dmaClk           => dmaClk,
            dmaClkRst        => dmaClkRst,
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
            TPD_G                 => TPD_G,
            AXIL_BASE_ADDR_G      => AXIL_BASE_ADDR_G,
            RCE_DMA_COUNT_G       => RCE_DMA_COUNT_G,
            RCE_DMA_AXIS_CONFIG_G => RCE_DMA_AXIS_CONFIG_G
         ) port map (
            axiDmaClk        => axiDmaClk,
            axiDmaRst        => axiDmaRst,
            hpWriteSlave     => hpWriteSlave,
            hpWriteMaster    => hpWriteMaster,
            hpReadSlave      => hpReadSlave,
            hpReadMaster     => hpReadMaster,
            axilReadMaster   => axilReadMaster,
            axilReadSlave    => axilReadSlave,
            axilWriteMaster  => axilWriteMaster,
            axilWriteSlave   => axilWriteSlave,
            interrupt        => interrupt,
            dmaClk           => dmaClk,
            dmaClkRst        => dmaClkRst,
            dmaObMaster      => dmaObMaster,
            dmaObSlave       => dmaObSlave,
            dmaIbMaster      => dmaIbMaster,
            dmaIbSlave       => dmaIbSlave
         );

      -- AXI ACP Slave Unused
      acpWriteMaster <= AXI_WRITE_MASTER_INIT_C;
      acpReadMaster  <= AXI_READ_MASTER_INIT_C;

      -- Always online
      dmaOnline <= (others=>'1');
      dmaEnable <= (others=>'1');
   end generate;

end architecture structure;

