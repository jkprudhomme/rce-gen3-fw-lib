-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA, AXI Streaming, Single Channel
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaAxisV2Chan.vhd
-- Created    : 2017-04-16
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

entity RceG3DmaAxisV2Chan is
   generic (
      TPD_G            : time             := 1 ns;
      AXIL_BASE_ADDR_G : slv(31 downto 0) := x"00000000";
      AXI_CONFIG_G     : AxiConfigType    := AXI_CONFIG_INIT_C);
   port (
      -- Clock/Reset
      axiDmaClk       : in  sl;
      axiDmaRst       : in  sl;
      -- AXI Slave
      axiWriteSlave   : in  AxiWriteSlaveType;
      axiWriteMaster  : out AxiWriteMasterType;
      axiReadSlave    : in  AxiReadSlaveType;
      axiReadMaster   : out AxiReadMasterType;
      -- Local AXI Lite Bus, 0x600n0000
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Interrupt & Online
      interrupt       : out sl;
      -- External DMA Interfaces
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      dmaState        : out RceDmaStateType;
      dmaObMaster     : out AxiStreamMasterType;
      dmaObSlave      : in  AxiStreamSlaveType;
      dmaIbMaster     : in  AxiStreamMasterType;
      dmaIbSlave      : out AxiStreamSlaveType);
end RceG3DmaAxisV2Chan;

architecture mapping of RceG3DmaAxisV2Chan is

   signal locReadSlave   : AxiReadSlaveArray(1 downto 0);
   signal locReadMaster  : AxiReadMasterArray(1 downto 0);
   signal locWriteMaster : AxiWriteMasterArray(1 downto 0);
   signal locWriteSlave  : AxiWriteSlaveArray(1 downto 0);
   signal locWriteCtrl   : AxiCtrlArray(1 downto 0);
   signal intWriteSlave  : AxiWriteSlaveArray(1 downto 0);
   signal intWriteMaster : AxiWriteMasterArray(1 downto 0);
   signal ibAxisMaster   : AxiStreamMasterType;
   signal ibAxisSlave    : AxiStreamSlaveType;
   signal obAxisMaster   : AxiStreamMasterType;
   signal obAxisSlave    : AxiStreamSlaveType;
   signal obAxisCtrl     : AxiStreamCtrlType;
   signal online         : sl;
   signal acknowledge    : sl;

begin

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
         CACHE_FIXED_EN_G       => false,
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
         sAxiReadMaster => locReadMaster(1),
         sAxiReadSlave  => locReadSlave(1),
         mAxiClk        => axiDmaClk,
         mAxiRst        => axiDmaRst,
         mAxiReadMaster => axiReadMaster,
         mAxiReadSlave  => axiReadSlave);

   -- AXI Write FIFOs
   U_AxiFifoGen: for i in 0 to 1 generate

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
            CACHE_FIXED_EN_G         => false,
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
            sAxiWriteMaster => locWriteMaster(i),
            sAxiWriteSlave  => locWriteSlave(i),
            sAxiCtrl        => locWriteCtrl(i),
            mAxiClk         => axiDmaClk,
            mAxiRst         => axiDmaRst,
            mAxiWriteMaster => intWriteMaster(i),
            mAxiWriteSlave  => intWriteSlave(i));

   end generate;

   -- Write Path MUX
   U_WritePathMux: entity work.AxiWritePathMux 
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => 2)
      port map (
         axiClk  => axiDmaClk,
         axiRst  => axiDmaRst,
         sAxiWriteMasters  => intWriteMaster,
         sAxiWriteSlaves   => intWriteSlave,
         mAxiWriteMaster   => axiWriteMaster,
         mAxiWriteSlave    => axiWriteSlave);

   -- 1 channel version 2 DMA engine
   U_AxiStreamDmaV2: entity work.AxiStreamDmaV2 
      generic map (
         TPD_G             => TPD_G,
         DESC_AWIDTH_G     => 12,
         AXIL_BASE_ADDR_G  => AXIL_BASE_ADDR_G,
         AXI_ERROR_RESP_G  => AXI_RESP_OK_C,
         AXI_READY_EN_G    => false,
         AXIS_READY_EN_G   => false,
         AXIS_CONFIG_G     => RCEG3_AXIS_DMA_CONFIG_C,
         AXI_DESC_CONFIG_G => AXI_CONFIG_G,
         AXI_DMA_CONFIG_G  => AXI_CONFIG_G,
         CHAN_COUNT_G      => 1,
         RD_PIPE_STAGES_G  => 1,
         RD_PEND_THRESH_G  => 512)
      port map (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         interrupt       => interrupt,
         online(0)       => online,
         acknowledge(0)  => acknowledge,
         sAxisMaster(0)  => ibAxisMaster,
         sAxisSlave(0)   => ibAxisSlave,
         mAxisMaster(0)  => obAxisMaster,
         mAxisSlave(0)   => obAxisSlave,
         mAxisCtrl(0)    => obAxisCtrl,
         axiReadMaster   => locReadMaster,
         axiReadSlave    => locReadSlave,
         axiWriteMaster  => locWriteMaster,
         axiWriteSlave   => locWriteSlave,
         axiWriteCtrl    => locWriteCtrl);

   locReadSlave(0) <= AXI_READ_SLAVE_INIT_C;

   -- DMA State synchronization
   U_OnlineSync: entity work.Synchronizer 
      generic map ( TPD_G => TPD_G )
      port map (
         clk     => dmaClk,
         rst     => dmaClkRst,
         dataIn  => online,
         dataOut => dmaState.online);

   U_UserSync: entity work.SynchronizerOneShot
      generic map (
         TPD_G         => TPD_G,
         PULSE_WIDTH_G => 10)
      port map (
         clk     => dmaClk,
         rst     => dmaClkRst,
         dataIn  => acknowledge,
         dataOut => dmaState.user);

end mapping;
