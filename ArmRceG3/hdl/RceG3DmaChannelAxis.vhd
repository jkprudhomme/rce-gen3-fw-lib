-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA channel, AXI Streaming Architecture
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaChannelAxis.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA. AXI streaming architecture.
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/25/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;

architecture Axis of RceG3DmaChannel is 

   signal axiReadMaster  : AxiReadMasterType;
   signal axiReadSlave   : AxiReadSlaveType;
   signal axiWriteMaster : AxiWriteMasterType;
   signal axiWriteSlave  : AxiWriteSlaveType;
   signal axiWriteCtrl   : AxiCtrlType;
   signal sAxisMaster    : AxiStreamMasterType;
   signal sAxisSlave     : AxiStreamSlaveType;
   signal mAxisMaster    : AxiStreamMasterType;
   signal mAxisSlave     : AxiStreamSlaveType;
   signal mAxisCtrl      : AxiStreamCtrlType;
   signal intInterrupt   : sl;

   constant DMA_AXIS_CONFIG_G : AxiStreamConfigType := (
      TSTRB_EN_C    => AXIS_CONFIG_G.TSTRB_EN_C,
      TDATA_BYTES_C => AXI_HP_INIT_C.DATA_BYPES_C,
      TDEST_BITS_C  => TDEST_BITS_C,
      TID_BITS_C    => TID_BITS_C,
      TKEEP_MODE_C  => TKEEP_MODE_C,
      TUSER_BITS_C  => TUSER_BITS_C,
      TUSER_MODE_C  => TUSER_MODE_C

begin

   ------------------------------------------
   -- DMA Core
   ------------------------------------------

   entity AxiStreamDma is
      generic (
         TPD_G            => TPD_G,
         AXIL_BASE_ADDR_G => AXIL_BASE_ADDR_G,
         AXI_READY_EN_G   => false,
         AXIS_READY_EN_G  => false,
         AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
         AXI_CONFIG_G     => AXI_HP_INIT_C,
         AXI_BURST_G      => "01",
         AXI_CACHE_G      => "1111"
      );
      port (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         interrupt       => intInterrupt,
         sAxisMaster     => sAxisMaster,
         sAxisSlave      => sAxisSlave,
         mAxisMaster     => mAxisMaster,
         mAxisSlave      => mAxisSlave,
         mAxisCtrl       => mAxisCtrl,
         axiReadMaster   => axiReadMaster,
         axiReadSlave    => axiReadSlave,
         axiWriteMaster  => axiWriteMaster,
         axiWriteSlave   => axiWriteSlave,
         axiWriteCtrl    => axiWriteCtrl
      );

   -- Interrupts
   U_Int : process ( intInterrupt ) begin
      interrupt                <= (others=>'0');
      interrupt(CHANNEL_NUM_G) <= intInterrupt;
   end process;

   -- AXI ACP Slave Unused
   acpWriteMaster <= AXI_WRITE_MASTER_INIT_C;
   acpReadMaster  <= AXI_READ_MASTER_INIT_C;
   dmaOnline      <= '1';
   dmaEnable      <= '1';


   -------------------------------------
   -- AXI Stream FIFOS
   -------------------------------------

   -- Inbound FIFO
   U_IbFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         RST_ASYNC_G         => false,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 500
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G
      ) port map (
         sAxisClk        => dmaClk,
         sAxisRst        => dmaClkRst,
         sAxisMaster     => dmaIbMaster,
         sAxisSlave      => dmaIbSlave,
         sAxisCtrl       => open,
         fifoPauseThresh => (others => '1'),
         mAxisClk        => axiDmaClk,
         mAxisRst        => axiDmaRst,
         mAxisMaster     => sAxisMaster,
         mAxisSlave      => sAxisSlave
      );

   -- Outbound FIFO
   U_ObFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         RST_ASYNC_G         => false,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 500
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_G
      ) port map (
         sAxisClk        => axiDmaClk,
         sAxisRst        => axiDmaRst,
         sAxisMaster     => mAxisMaster,
         sAxisSlave      => mAxisSlave,
         sAxisCtrl       => mAxisCtrl,
         fifoPauseThresh => (others => '1'),
         mAxisClk        => dmaClk,
         mAxisRst        => dmaClkRst,
         mAxisMaster     => dmaIbMaster,
         mAxisSlave      => dmaIbSlave
      );


   -------------------------------------
   -- AXI FIFOS
   -------------------------------------

   U_AxiReadPathFifo : entity work.AxiReadPathFifo 
      generic map (
         TPD_G                    => TPD_G,
         RST_ASYNC_G              => false,
         XIL_DEVICE_G             => "7SERIES".
         USE_BUILT_IN_G           => false.
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
         ADDR_BRAM_EN_G           => false, 
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 4,
         DATA_BRAM_EN_G           => false,
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_HP_INIT_C
      ) port map (
         sAxiClk        => axiDmaClk,
         sAxiRst        => axiDmaRst,
         sAxiReadMaster => axiReadMaster,
         sAxiReadSlave  => axiReadSlave,
         mAxiClk        => axiDmaClk,
         mAxiRst        => axiDmaRst,
         mAxiReadMaster => hpReadMaster,
         mAxiReadSlave  => hpReadSlave
      );


   U_AxiWritePathFifo : entity work.AxiWritePathFifo
      generic map (
         TPD_G                    => TPD_G,
         RST_ASYNC_G              => false,
         XIL_DEVICE_G             => "7SERIES".
         USE_BUILT_IN_G           => false.
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
         AXI_CONFIG_G             => AXI_HP_INIT_C
      ) port map (
         sAxiClk         => axiDmaClk,
         sAxiRst         => axiDmaRst,
         sAxiWriteMaster => axiWriteMaster,
         sAxiWriteSlave  => axiWriteSlave,
         sAxiCtrl        => axiWriteCtrl,
         mAxiClk         => axiDmaClk,
         mAxiRst         => axiDmaRst,
         mAxiWriteMaster => hpWriteMaster,
         mAxiWriteSlave  => hpWriteSlave
      );

end Axis;

