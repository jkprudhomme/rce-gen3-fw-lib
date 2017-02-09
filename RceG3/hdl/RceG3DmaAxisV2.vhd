-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA, AXI Streaming, Multi-Channel
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaAxisV2.vhd
-- Created    : 2017-02-02
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA. AXI streaming.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/25/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;

entity RceG3DmaAxisV2 is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock/Reset
      axiDmaClk       : in  sl;
      axiDmaRst       : in  sl;
      -- AXI ACP Slave
      acpWriteSlave   : in  AxiWriteSlaveType;
      acpWriteMaster  : out AxiWriteMasterType;
      acpReadSlave    : in  AxiReadSlaveType;
      acpReadMaster   : out AxiReadMasterType;
      -- AXI HP Slave
      hpWriteSlave    : in  AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster   : out AxiWriteMasterArray(3 downto 0);
      hpReadSlave     : in  AxiReadSlaveArray(3 downto 0);
      hpReadMaster    : out AxiReadMasterArray(3 downto 0);
      -- User memory access
      userWriteSlave  : out AxiWriteSlaveType;
      userWriteMaster : in  AxiWriteMasterType;
      userReadSlave   : out AxiReadSlaveType;
      userReadMaster  : in  AxiReadMasterType;
      -- Local AXI Lite Bus, 0x600n0000
      axilReadMaster  : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilReadSlave   : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteMaster : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteSlave  : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      -- Interrupts
      interrupt       : out slv(DMA_INT_COUNT_C-1 downto 0);
      -- External DMA Interfaces
      dmaClk          : in  slv(3 downto 0);
      dmaClkRst       : in  slv(3 downto 0);
      dmaState        : out RceDmaStateArray(3 downto 0);
      dmaObMaster     : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave      : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster     : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave      : out AxiStreamSlaveArray(3 downto 0));
end RceG3DmaAxisV2;

architecture mapping of RceG3DmaAxisV2 is

   signal sAxisMaster    : AxiStreamMasterArray(0 downto 0);
   signal sAxisSlave     : AxiStreamSlaveArray(0 downto 0);
   signal mAxisMaster    : AxiStreamMasterArray(0 downto 0);
   signal mAxisSlave     : AxiStreamSlaveArray(0 downto 0);
   signal mAxisCtrl      : AxiStreamCtrlArray(0 downto 0);

begin

   -- HP 2 goes to user space
   userWriteSlave   <= hpWriteSlave(2);
   hpWriteMaster(2) <= userWriteMaster;
   userReadSlave    <= hpReadSlave(2);
   hpReadMaster(2)  <= userReadMaster;

   hpWriteMaster(3) <= AXI_WRITE_MASTER_INIT_C;
   hpReadMaster(3)  <= AXI_READ_MASTER_INIT_C;
   hpWriteMaster(1) <= AXI_WRITE_MASTER_INIT_C;
   hpReadMaster(1)  <= AXI_READ_MASTER_INIT_C;

   dmaState(3 downto 1)    <= (others=>RCE_DMA_STATE_INIT_C);
   dmaObMaster(3 downto 1) <= (others=>AXI_STREAM_MASTER_INIT_C);
   dmaIbSlave(3 downto 1)  <= (others=>AXI_STREAM_SLAVE_INIT_C);

   -- Unused Interrupts
   interrupt(DMA_INT_COUNT_C-1 downto 1) <= (others => '0');

   -- Terminate Unused AXI-Lite Interfaces
   U_EmptyGen: for i in 1 to 8 generate
      U_AxiLiteEmpty : entity work.AxiLiteEmpty
         generic map (
            TPD_G => TPD_G)
         port map (
            axiClk         => axiDmaClk,
            axiClkRst      => axiDmaRst,
            axiReadMaster  => axilReadMaster(i),
            axiReadSlave   => axilReadSlave(i),
            axiWriteMaster => axilWriteMaster(i),
            axiWriteSlave  => axilWriteSlave(i));
   end generate;

   U_DmaTest: entity work.AxiStreamDmaV2 
      generic map (
         TPD_G             => TPD_G,
         DESC_AWIDTH_G     => 12,
         AXIL_BASE_ADDR_G  => x"60000000",
         AXI_READY_EN_G    => true,
         --AXIS_READY_EN_G   : boolean              := false;
         --AXIS_CONFIG_G     : AxiStreamConfigType  := AXI_STREAM_CONFIG_INIT_C;
         AXI_DESC_CONFIG_G => AXI_ACP_INIT_C,
         AXI_DESC_BURST_G  => "01",
         --AXI_DESC_CACHE_G  => "1111",
         AXI_DESC_CACHE_G  => "0000",
         AXI_DMA_CONFIG_G  => AXI_HP_INIT_C,
         AXI_DMA_BURST_G   => "01",
         AXI_DMA_CACHE_G   => "0000")
      port map (
         axiClk            => axiDmaClk,
         axiRst            => axiDmaRst,
         axilReadMaster    => axilReadMaster(0), -- 0x60000000
         axilReadSlave     => axilReadSlave(0),
         axilWriteMaster   => axilWriteMaster(0),
         axilWriteSlave    => axilWriteSlave(0),
         interrupt         => interrupt(0),
         online            => dmaState(0).online,
         acknowledge       => dmaState(0).user,
         sAxisMaster       => sAxisMaster(0),
         sAxisSlave        => sAxisSlave(0),
         mAxisMaster       => mAxisMaster(0),
         mAxisSlave        => mAxisSlave(0),
         mAxisCtrl         => mAxisCtrl(0),
         axiReadMaster(0)  => acpReadMaster,
         axiReadMaster(1)  => hpReadMaster(0),
         axiReadSlave(0)   => acpReadSlave,
         axiReadSlave(1)   => hpReadSlave(0),
         axiWriteMaster(0) => acpWriteMaster,
         axiWriteMaster(1) => hpWriteMaster(0),
         axiWriteSlave(0)  => acpWriteSlave,
         axiWriteSlave(1)  => hpWriteSlave(0),
         axiWriteCtrl(0)   => AXI_CTRL_INIT_C,
         axiWriteCtrl(1)   => AXI_CTRL_INIT_C);

   -- Inbound AXI Stream FIFO
   U_IbFifo : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 500,  -- Unused
         SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
         MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C) 
      port map (
         sAxisClk        => dmaClk(0),
         sAxisRst        => dmaClkRst(0),
         sAxisMaster     => dmaIbMaster(0),
         sAxisSlave      => dmaIbSlave(0),
         sAxisCtrl       => open,
         fifoPauseThresh => (others => '1'),
         mAxisClk        => axiDmaClk,
         mAxisRst        => axiDmaRst,
         mAxisMaster     => sAxisMaster(0),
         mAxisSlave      => sAxisSlave(0));

   -- Outbound AXI Stream FIFO
   U_ObFifo : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 300,  -- 1800 byte buffer before pause and 1696 byte of buffer before FIFO FULL
         SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
         MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C) 
      port map (
         sAxisClk        => axiDmaClk,
         sAxisRst        => axiDmaRst,
         sAxisMaster     => mAxisMaster(0),
         sAxisSlave      => mAxisSlave(0),
         sAxisCtrl       => mAxisCtrl(0),
         fifoPauseThresh => (others => '1'),
         mAxisClk        => dmaClk(0),
         mAxisRst        => dmaClkRst(0),
         mAxisMaster     => dmaObMaster(0),
         mAxisSlave      => dmaObSlave(0));

end mapping;
