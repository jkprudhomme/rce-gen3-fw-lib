-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA, AXI Streaming
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaAxisChan.vhd
-- Created    : 2017-04-17
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

entity RceG3DmaAxisChan is
   generic (
      TPD_G        : time            := 1 ns;
      AXI_CACHE_G  : slv(3 downto 0) := "0000";
      BYP_SHIFT_G  : boolean         := false;
      AXI_CONFIG_G : AxiConfigType   := AXI_CONFIG_INIT_C);
   port (
      -- Clock/Reset
      axiDmaClk       : in  sl;
      axiDmaRst       : in  sl;
      -- AXI Slave
      axiWriteSlave   : in  AxiWriteSlaveType;
      axiWriteMaster  : out AxiWriteMasterType;
      axiReadSlave    : in  AxiReadSlaveType;
      axiReadMaster   : out AxiReadMasterType;
      -- Local AXI Lite Bus
      axilReadMaster  : in  AxiLiteReadMasterArray(1 downto 0);
      axilReadSlave   : out AxiLiteReadSlaveArray(1 downto 0);
      axilWriteMaster : in  AxiLiteWriteMasterArray(1 downto 0);
      axilWriteSlave  : out AxiLiteWriteSlaveArray(1 downto 0);
      -- Interrupt
      interrupt       : out sl;
      -- External DMA Interface
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      dmaState        : out RceDmaStateType;
      dmaObMaster     : out AxiStreamMasterType;
      dmaObSlave      : in  AxiStreamSlaveType;
      dmaIbMaster     : in  AxiStreamMasterType;
      dmaIbSlave      : out AxiStreamSlaveType);
end RceG3DmaAxisChan;

architecture mapping of RceG3DmaAxisChan is

   signal intReadMaster  : AxiReadMasterType;
   signal intReadSlave   : AxiReadSlaveType;
   signal intWriteMaster : AxiWriteMasterType;
   signal intWriteSlave  : AxiWriteSlaveType;
   signal intWriteCtrl   : AxiCtrlType;
   signal ibAxisMaster   : AxiStreamMasterType;
   signal ibAxisSlave    : AxiStreamSlaveType;
   signal obAxisMaster   : AxiStreamMasterType;
   signal obAxisSlave    : AxiStreamSlaveType;
   signal obAxisCtrl     : AxiStreamCtrlType;

begin

   -- DMA Core
   U_AxiStreamDma : entity work.AxiStreamDma
      generic map (
         TPD_G             => TPD_G,
         FREE_ADDR_WIDTH_G => 12,    -- 4096 entries
         AXIL_COUNT_G      => 2,
         AXIL_BASE_ADDR_G  => x"00000000",
         AXI_READY_EN_G    => false,
         AXIS_READY_EN_G   => false,
         AXIS_CONFIG_G     => RCEG3_AXIS_DMA_CONFIG_C,
         AXI_CONFIG_G      => AXI_CONFIG_G,
         AXI_BURST_G       => "01",
         AXI_CACHE_G       => AXI_CACHE_G,
         PEND_THRESH_G     => 512,   -- 512 = 4 outstanding transactions
         BYP_SHIFT_G       => BYP_SHIFT_G)
      port map (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         interrupt       => interrupt,
         online          => dmaState.online,
         acknowledge     => dmaState.user,
         sAxisMaster     => ibAxisMaster,
         sAxisSlave      => ibAxisSlave,
         mAxisMaster     => obAxisMaster,
         mAxisSlave      => obAxisSlave,
         mAxisCtrl       => obAxisCtrl,
         axiReadMaster   => intReadMaster,
         axiReadSlave    => intReadSlave,
         axiWriteMaster  => intWriteMaster,
         axiWriteSlave   => intWriteSlave,
         axiWriteCtrl    => intWriteCtrl);

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
         sAxisClk        => dmaClk,
         sAxisRst        => dmaClkRst,
         sAxisMaster     => dmaIbMaster,
         sAxisSlave      => dmaIbSlave,
         mAxisClk        => axiDmaClk,
         mAxisRst        => axiDmaRst,
         mAxisMaster     => ibAxisMaster,
         mAxisSlave      => ibAxisSlave);

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
         sAxisMaster     => obAxisMaster,
         sAxisSlave      => obAxisSlave,
         sAxisCtrl       => obAxisCtrl,
         mAxisClk        => dmaClk,
         mAxisRst        => dmaClkRst,
         mAxisMaster     => dmaObMaster,
         mAxisSlave      => dmaObSlave);

   -- Read Path AXI FIFO
   U_AxiReadPathFifo : entity work.AxiReadPathFifo
      generic map (
         TPD_G                  => TPD_G,
         XIL_DEVICE_G           => "7SERIES",
         USE_BUILT_IN_G         => false,
         GEN_SYNC_FIFO_G        => true,
         ALTERA_SYN_G           => false,
         ALTERA_RAM_G           => "M9K",
         ADDR_LSB_G             => 3,
         ID_FIXED_EN_G          => true,
         SIZE_FIXED_EN_G        => true,
         BURST_FIXED_EN_G       => true,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => true,
         PROT_FIXED_EN_G        => true,
         CACHE_FIXED_EN_G       => true,
         ADDR_BRAM_EN_G         => false,
         ADDR_CASCADE_SIZE_G    => 1,
         ADDR_FIFO_ADDR_WIDTH_G => 4,
         DATA_BRAM_EN_G         => false,
         DATA_CASCADE_SIZE_G    => 1,
         DATA_FIFO_ADDR_WIDTH_G => 4,
         AXI_CONFIG_G           => AXI_CONFIG_G)
      port map (
         sAxiClk        => axiDmaClk,
         sAxiRst        => axiDmaRst,
         sAxiReadMaster => intReadMaster,
         sAxiReadSlave  => intReadSlave,
         mAxiClk        => axiDmaClk,
         mAxiRst        => axiDmaRst,
         mAxiReadMaster => axiReadMaster,
         mAxiReadSlave  => axiReadSlave);

   -- Write Path AXI FIFO
   U_AxiWritePathFifo : entity work.AxiWritePathFifo
      generic map (
         TPD_G                    => TPD_G,
         XIL_DEVICE_G             => "7SERIES",
         USE_BUILT_IN_G           => false,
         GEN_SYNC_FIFO_G          => true,
         ALTERA_SYN_G             => false,
         ALTERA_RAM_G             => "M9K",
         ADDR_LSB_G               => 3,
         ID_FIXED_EN_G            => true,
         SIZE_FIXED_EN_G          => true,
         BURST_FIXED_EN_G         => true,
         LEN_FIXED_EN_G           => false,
         LOCK_FIXED_EN_G          => true,
         PROT_FIXED_EN_G          => true,
         CACHE_FIXED_EN_G         => true,
         ADDR_BRAM_EN_G           => true,
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 9,
         DATA_BRAM_EN_G           => true,
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 9,
         DATA_FIFO_PAUSE_THRESH_G => 456,
         RESP_BRAM_EN_G           => false,
         RESP_CASCADE_SIZE_G      => 1,
         RESP_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_CONFIG_G) 
      port map (
         sAxiClk         => axiDmaClk,
         sAxiRst         => axiDmaRst,
         sAxiWriteMaster => intWriteMaster,
         sAxiWriteSlave  => intWriteSlave,
         sAxiCtrl        => intWriteCtrl,
         mAxiClk         => axiDmaClk,
         mAxiRst         => axiDmaRst,
         mAxiWriteMaster => axiWriteMaster,
         mAxiWriteSlave  => axiWriteSlave);

end mapping;

