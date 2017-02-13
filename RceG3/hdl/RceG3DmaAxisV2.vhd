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

   signal locReadMaster  : AxiReadMasterArray(4 downto 0);
   signal locReadSlave   : AxiReadSlaveArray(4 downto 0);
   signal locWriteMaster : AxiWriteMasterArray(4 downto 0);
   signal locWriteSlave  : AxiWriteSlaveArray(4 downto 0);
   signal locWriteCtrl   : AxiCtrlArray(4 downto 0);
   signal intWriteSlave  : AxiWriteSlaveArray(4 downto 0);
   signal intWriteMaster : AxiWriteMasterArray(4 downto 0);
   signal intReadSlave   : AxiReadSlaveArray(4 downto 0);
   signal intReadMaster  : AxiReadMasterArray(4 downto 0);
   signal sAxisMaster    : AxiStreamMasterArray(3 downto 0);
   signal sAxisSlave     : AxiStreamSlaveArray(3 downto 0);
   signal mAxisMaster    : AxiStreamMasterArray(3 downto 0);
   signal mAxisSlave     : AxiStreamSlaveArray(3 downto 0);
   signal mAxisCtrl      : AxiStreamCtrlArray(3 downto 0);
   signal online         : slv(2 downto 0);
   signal acknowledge    : slv(2 downto 0);

begin

   -- User interface not supported
   userWriteSlave  <= AXI_WRITE_SLAVE_INIT_C;
   userReadSlave   <= AXI_READ_SLAVE_INIT_C;

   -- MAP ACP Port
   intWriteSlave(0) <= acpWriteSlave;
   acpWriteMaster   <= intWriteMaster(0);
   intReadSlave(0)  <= acpReadSlave;
   acpReadMaster    <= intReadMaster(0);

   -- MAP HP Ports
   intWriteSlave(4 downto 1) <= hpWriteSlave;
   hpWriteMaster             <= intWriteMaster(4 downto 1);
   intReadSlave(4 downto 1)  <= hpReadSlave;
   hpReadMaster              <= intReadMaster(4 downto 1);

   -- Unused Interrupts
   interrupt(DMA_INT_COUNT_C-1 downto 4) <= (others => '0');
   interrupt(2 downto 1) <= (others => '0');

   -- Terminate Unused AXI-Lite Interfaces
   U_EmptyGen: for i in 1 to 5 generate
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

   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G => TPD_G)
      port map (
         axiClk         => axiDmaClk,
         axiClkRst      => axiDmaRst,
         axiReadMaster  => axilReadMaster(8),
         axiReadSlave   => axilReadSlave(8),
         axiWriteMaster => axilWriteMaster(8),
         axiWriteSlave  => axilWriteSlave(8));

   -- AXI Stream FIFOs
   U_AxisFifoGen: for i in 0 to 3 generate

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
            sAxisClk        => dmaClk(i),
            sAxisRst        => dmaClkRst(i),
            sAxisMaster     => dmaIbMaster(i),
            sAxisSlave      => dmaIbSlave(i),
            sAxisCtrl       => open,
            fifoPauseThresh => (others => '1'),
            mAxisClk        => axiDmaClk,
            mAxisRst        => axiDmaRst,
            mAxisMaster     => sAxisMaster(i),
            mAxisSlave      => sAxisSlave(i));

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
            sAxisMaster     => mAxisMaster(i),
            sAxisSlave      => mAxisSlave(i),
            sAxisCtrl       => mAxisCtrl(i),
            fifoPauseThresh => (others => '1'),
            mAxisClk        => dmaClk(i),
            mAxisRst        => dmaClkRst(i),
            mAxisMaster     => dmaObMaster(i),
            mAxisSlave      => dmaObSlave(i));
   end generate;

   -- AXI FIFOs
   U_AxiFifoGen: for i in 0 to 4 generate

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
            AXI_CONFIG_G           => ite(i=0,AXI_ACP_INIT_C,AXI_HP_INIT_C)) 
         port map (
            sAxiClk        => axiDmaClk,
            sAxiRst        => axiDmaRst,
            sAxiReadMaster => locReadMaster(i),
            sAxiReadSlave  => locReadSlave(i),
            mAxiClk        => axiDmaClk,
            mAxiRst        => axiDmaRst,
            mAxiReadMaster => intReadMaster(i),
            mAxiReadSlave  => intReadSlave(i));

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
            AXI_CONFIG_G             => ite(i=0,AXI_ACP_INIT_C,AXI_HP_INIT_C)) 
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

   -- 3 channel version 2 DMA engine
   U_V2Gen: entity work.AxiStreamDmaV2 
      generic map (
         TPD_G             => TPD_G,
         DESC_AWIDTH_G     => 12,
         AXIL_BASE_ADDR_G  => x"00060000",
         AXI_ERROR_RESP_G  => AXI_RESP_OK_C,
         AXI_READY_EN_G    => false,
         AXIS_READY_EN_G   => false,
         AXIS_CONFIG_G     => RCEG3_AXIS_DMA_CONFIG_C,
         AXI_DESC_CONFIG_G => AXI_ACP_INIT_C,
         AXI_DESC_BURST_G  => "01",
         AXI_DESC_CACHE_G  => "1111",
         AXI_DMA_CONFIG_G  => AXI_HP_INIT_C,
         AXI_DMA_BURST_G   => "01",
         AXI_DMA_CACHE_G   => "0000",
         CHAN_COUNT_G      => 3,
         RD_PIPE_STAGES_G  => 1,
         RD_PEND_THRESH_G  => 512)
      port map (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         axilReadMaster  => axilReadMaster(0),
         axilReadSlave   => axilReadSlave(0),
         axilWriteMaster => axilWriteMaster(0),
         axilWriteSlave  => axilWriteSlave(0),
         interrupt       => interrupt(0),
         online          => online,
         acknowledge     => acknowledge,
         sAxisMaster     => sAxisMaster(2 downto 0),
         sAxisSlave      => sAxisSlave(2 downto 0),
         mAxisMaster     => mAxisMaster(2 downto 0),
         mAxisSlave      => mAxisSlave(2 downto 0),
         mAxisCtrl       => mAxisCtrl(2 downto 0),
         axiReadMaster   => locReadMaster(3 downto 0),
         axiReadSlave    => locReadSlave(3 downto 0),
         axiWriteMaster  => locWriteMaster(3 downto 0),
         axiWriteSlave   => locWriteSlave(3 downto 0),
         axiWriteCtrl    => locWriteCtrl(3 downto 0));

   -- DMA State synchronization
   U_StateGen: for i in 0 to 2 generate
      U_OnlineSync: entity work.Synchronizer 
         generic map ( TPD_G => TPD_G )
         port map (
            clk     => dmaClk(i),
            rst     => dmaClkRst(i),
            dataIn  => online(i),
            dataOut => dmaState(i).online);

      U_UserSync: entity work.SynchronizerOneShot
         generic map (
            TPD_G         => TPD_G,
            PULSE_WIDTH_G => 10)
         port map (
            clk     => dmaClk(i),
            rst     => dmaClkRst(i),
            dataIn  => acknowledge(i),
            dataOut => dmaState(i).user);
   end generate;

   -- Version 1 DMA Core For Ethernet
   U_V1Gen : entity work.AxiStreamDma
      generic map (
         TPD_G             => TPD_G,
         FREE_ADDR_WIDTH_G => 12,    -- 4096 entries
         AXIL_COUNT_G      => 2,
         AXIL_BASE_ADDR_G  => x"00000000", -- Not used
         AXI_READY_EN_G    => false,
         AXIS_READY_EN_G   => false,
         AXIS_CONFIG_G     => RCEG3_AXIS_DMA_CONFIG_C,
         AXI_CONFIG_G      => AXI_HP_INIT_C,
         AXI_BURST_G       => "01",
         AXI_CACHE_G       => "0000",
         PEND_THRESH_G     => 512,
         BYP_SHIFT_G       => false)
      port map (
         axiClk          => axiDmaClk,
         axiRst          => axiDmaRst,
         axilReadMaster  => axilReadMaster(7 downto 6),
         axilReadSlave   => axilReadSlave(7 downto 6),
         axilWriteMaster => axilWriteMaster(7 downto 6),
         axilWriteSlave  => axilWriteSlave(7 downto 6),
         interrupt       => interrupt(3),
         online          => dmaState(3).online,
         acknowledge     => dmaState(3).user,
         sAxisMaster     => sAxisMaster(3),
         sAxisSlave      => sAxisSlave(3),
         mAxisMaster     => mAxisMaster(3),
         mAxisSlave      => mAxisSlave(3),
         mAxisCtrl       => mAxisCtrl(3),
         axiReadMaster   => locReadMaster(4),
         axiReadSlave    => locReadSlave(4),
         axiWriteMaster  => locWriteMaster(4),
         axiWriteSlave   => locWriteSlave(4),
         axiWriteCtrl    => locWriteCtrl(4));

end mapping;
