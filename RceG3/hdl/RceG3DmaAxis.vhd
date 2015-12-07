-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA, AXI Streaming
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaAxis.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA. AXI streaming.
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
use work.RceG3Pkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;

entity RceG3DmaAxis is
   generic (
      TPD_G            : time     := 1 ns
   );
   port (

      -- Clock/Reset
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

      -- User memory access
      userWriteSlave      : out AxiWriteSlaveType;
      userWriteMaster     : in  AxiWriteMasterType;
      userReadSlave       : out AxiReadSlaveType;
      userReadMaster      : in  AxiReadMasterType;

      -- Local AXI Lite Bus
      axilReadMaster      : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilReadSlave       : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteMaster     : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteSlave      : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

      -- Interrupts
      interrupt           : out slv(DMA_INT_COUNT_C-1 downto 0);

      -- External DMA Interfaces
      dmaClk              : in  slv(3 downto 0);
      dmaClkRst           : in  slv(3 downto 0);
      dmaState            : out RceDmaStateArray(3 downto 0);
      dmaObMaster         : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(3 downto 0)
   );
end RceG3DmaAxis;

architecture structure of RceG3DmaAxis is 

   signal locReadMaster    : AxiReadMasterArray(3 downto 0);
   signal locReadSlave     : AxiReadSlaveArray(3 downto 0);
   signal locWriteMaster   : AxiWriteMasterArray(3 downto 0);
   signal locWriteSlave    : AxiWriteSlaveArray(3 downto 0);
   signal locWriteCtrl     : AxiCtrlArray(3 downto 0);
   signal intWriteSlave    : AxiWriteSlaveArray(3 downto 0);
   signal intWriteMaster   : AxiWriteMasterArray(3 downto 0);
   signal intReadSlave     : AxiReadSlaveArray(3 downto 0);
   signal intReadMaster    : AxiReadMasterArray(3 downto 0);
   signal sAxisMaster      : AxiStreamMasterArray(3 downto 0);
   signal sAxisSlave       : AxiStreamSlaveArray(3 downto 0);
   signal mAxisMaster      : AxiStreamMasterArray(3 downto 0);
   signal mAxisSlave       : AxiStreamSlaveArray(3 downto 0);
   signal mAxisCtrl        : AxiStreamCtrlArray(3 downto 0);

   -- Caching enabled for ACP port
   constant AXI_CACHE_C    : Slv4Array(3 downto 0) := ( "0000", "0010", "0000", "0000" );

begin

   -- HP for channel 0 & 1
   intWriteSlave(1 downto 0) <= hpWriteSlave(1 downto 0);
   hpWriteMaster(1 downto 0) <= intWriteMaster(1 downto 0);
   intReadSlave(1 downto 0)  <= hpReadSlave(1 downto 0);
   hpReadMaster(1 downto 0)  <= intReadMaster(1 downto 0);

   -- ACP for channel 2
   intWriteSlave(2) <= acpWriteSlave;
   acpWriteMaster   <= intWriteMaster(2);
   intReadSlave(2)  <= acpReadSlave;
   acpReadMaster    <= intReadMaster(2);

   -- HP 2 goes to user space
   userWriteSlave   <= hpWriteSlave(2);
   hpWriteMaster(2) <= userWriteMaster;
   userReadSlave    <= hpReadSlave(2);
   hpReadMaster(2)  <= userReadMaster;

   -- HP for channel 3
   intWriteSlave(3) <= hpWriteSlave(3);
   hpWriteMaster(3) <= intWriteMaster(3);
   intReadSlave(3)  <= hpReadSlave(3);
   hpReadMaster(3)  <= intReadMaster(3);

   -- Unused Interrupts
   interrupt(DMA_INT_COUNT_C-1 downto 4) <= (others=>'0');

   -- Terminate Unused AXI-Lite Interfaces
   U_AxiLiteEmpty : entity work.AxiLiteEmpty
      generic map (
         TPD_G  => TPD_G
      ) port map (
         axiClk          => axiDmaClk,
         axiClkRst       => axiDmaRst,
         axiReadMaster   => axilReadMaster(8),
         axiReadSlave    => axilReadSlave(8),
         axiWriteMaster  => axilWriteMaster(8),
         axiWriteSlave   => axilWriteSlave(8)
      );

   ------------------------------------------
   -- DMA Channels
   ------------------------------------------
   U_DmaChanGen : for i in 0 to 3 generate

      -- DMA Core
      U_AxiStreamDma : entity work.AxiStreamDma
         generic map (
            TPD_G             => TPD_G,
            FREE_ADDR_WIDTH_G => 12, -- 4096 entries
            AXIL_COUNT_G      => 2,
            AXIL_BASE_ADDR_G  => x"00000000",
            AXI_READY_EN_G    => false,
            AXIS_READY_EN_G   => false,
            AXIS_CONFIG_G     => RCEG3_AXIS_DMA_CONFIG_C,
            AXI_CONFIG_G      => AXI_HP_INIT_C,
            AXI_BURST_G       => "01",
            AXI_CACHE_G       => AXI_CACHE_C(i)
         ) port map (
            axiClk          => axiDmaClk,
            axiRst          => axiDmaRst,
            axilReadMaster  => axilReadMaster((i*2)+1 downto i*2),
            axilReadSlave   => axilReadSlave((i*2)+1 downto i*2),
            axilWriteMaster => axilWriteMaster((i*2)+1 downto i*2),
            axilWriteSlave  => axilWriteSlave((i*2)+1 downto i*2),
            interrupt       => interrupt(i),
            online          => dmaState(i).online,
            acknowledge     => dmaState(i).user,
            sAxisMaster     => sAxisMaster(i),
            sAxisSlave      => sAxisSlave(i),
            mAxisMaster     => mAxisMaster(i),
            mAxisSlave      => mAxisSlave(i),
            mAxisCtrl       => mAxisCtrl(i),
            axiReadMaster   => locReadMaster(i),
            axiReadSlave    => locReadSlave(i),
            axiWriteMaster  => locWriteMaster(i),
            axiWriteSlave   => locWriteSlave(i),
            axiWriteCtrl    => locWriteCtrl(i)
         );


      -- Inbound AXI Stream FIFO
      U_IbFifo : entity work.AxiStreamFifo 
         generic map (
            TPD_G               => TPD_G,
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
            FIFO_PAUSE_THRESH_G => 500,
            SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
            MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C
         ) port map (
            sAxisClk        => dmaClk(i),
            sAxisRst        => dmaClkRst(i),
            sAxisMaster     => dmaIbMaster(i),
            sAxisSlave      => dmaIbSlave(i),
            sAxisCtrl       => open,
            fifoPauseThresh => (others => '1'),
            mAxisClk        => axiDmaClk,
            mAxisRst        => axiDmaRst,
            mAxisMaster     => sAxisMaster(i),
            mAxisSlave      => sAxisSlave(i)
         );

      -- Outbound AXI Stream FIFO
      U_ObFifo : entity work.AxiStreamFifo 
         generic map (
            TPD_G               => TPD_G,
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
            FIFO_PAUSE_THRESH_G => 475,
            SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
            MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C
         ) port map (
            sAxisClk        => axiDmaClk,
            sAxisRst        => axiDmaRst,
            sAxisMaster     => mAxisMaster(i),
            sAxisSlave      => mAxisSlave(i),
            sAxisCtrl       => mAxisCtrl(i),
            fifoPauseThresh => (others => '1'),
            mAxisClk        => dmaClk(i),
            mAxisRst        => dmaClkRst(i),
            mAxisMaster     => dmaObMaster(i),
            mAxisSlave      => dmaObSlave(i)
         );


      -- Read Path AXI FIFO
      U_AxiReadPathFifo : entity work.AxiReadPathFifo 
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
            sAxiReadMaster => locReadMaster(i),
            sAxiReadSlave  => locReadSlave(i),
            mAxiClk        => axiDmaClk,
            mAxiRst        => axiDmaRst,
            mAxiReadMaster => intReadMaster(i),
            mAxiReadSlave  => intReadSlave(i)
         );


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
            AXI_CONFIG_G             => AXI_HP_INIT_C
         ) port map (
            sAxiClk         => axiDmaClk,
            sAxiRst         => axiDmaRst,
            sAxiWriteMaster => locWriteMaster(i),
            sAxiWriteSlave  => locWriteSlave(i),
            sAxiCtrl        => locWriteCtrl(i),
            mAxiClk         => axiDmaClk,
            mAxiRst         => axiDmaRst,
            mAxiWriteMaster => intWriteMaster(i),
            mAxiWriteSlave  => intWriteSlave(i)
         );
   end generate;

end structure;

