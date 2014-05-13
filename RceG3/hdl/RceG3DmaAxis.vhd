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
      TPD_G                 : time                  := 1 ns;
      AXIL_BASE_ADDR_G      : slv(31 downto 0)      := x"00000000";
      RCE_DMA_COUNT_G       : integer range 1 to 16 := 4;
      RCE_DMA_AXIS_CONFIG_G : AxiStreamConfigType   := AXI_STREAM_CONFIG_INIT_C
   );
   port (

      -- Clock/Reset
      axiDmaClk           : in  sl;
      axiDmaRst           : in  sl;

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
      dmaObMaster         : out AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaObSlave          : in  AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaIbMaster         : in  AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
      dmaIbSlave          : out AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0)
   );
end RceG3DmaAxis;

architecture structure of RceG3DmaAxis is 

   constant HP_BRANCHES_C : integerArray(3 downto 0) := (
      0 => (RCE_DMA_COUNT_G+3)/4,
      1 => (RCE_DMA_COUNT_G+2)/4,
      2 => (RCE_DMA_COUNT_G+1)/4,
      3 => (RCE_DMA_COUNT_G)/4);

   constant HP_BASE_C : integerArray(3 downto 0) := (
      0 => 0,
      1 => (RCE_DMA_COUNT_G+3)/4,
      2 => (RCE_DMA_COUNT_G+2)/4,
      3 => (RCE_DMA_COUNT_G+1)/4);

   constant MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(RCE_DMA_COUNT_G-1 downto 0) := 
      genAxiLiteConfig ( RCE_DMA_COUNT_G, AXIL_BASE_ADDR_G, 16, 12);

   constant DMA_AXIS_CONFIG_G : AxiStreamConfigType := (
      TSTRB_EN_C    => RCE_DMA_AXIS_CONFIG_G.TSTRB_EN_C,
      TDATA_BYTES_C => AXI_HP_INIT_C.DATA_BYTES_C,
      TDEST_BITS_C  => RCE_DMA_AXIS_CONFIG_G.TDEST_BITS_C,
      TID_BITS_C    => RCE_DMA_AXIS_CONFIG_G.TID_BITS_C,
      TKEEP_MODE_C  => RCE_DMA_AXIS_CONFIG_G.TKEEP_MODE_C,
      TUSER_BITS_C  => RCE_DMA_AXIS_CONFIG_G.TUSER_BITS_C,
      TUSER_MODE_C  => RCE_DMA_AXIS_CONFIG_G.TUSER_MODE_C);

   signal ihpWriteSlaves   : AxiWriteSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpWriteMasters  : AxiWriteMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpReadSlaves    : AxiReadSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal ihpReadMasters   : AxiReadMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilReadMaster  : AxiLiteReadMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilReadSlave   : AxiLiteReadSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilWriteMaster : AxiLiteWriteMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal iaxilWriteSlave  : AxiLiteWriteSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal locReadMaster    : AxiReadMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal locReadSlave     : AxiReadSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal locWriteMaster   : AxiWriteMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal locWriteSlave    : AxiWriteSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal locWriteCtrl     : AxiCtrlArray(RCE_DMA_COUNT_G-1 downto 0);
   signal sAxisMaster      : AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal sAxisSlave       : AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal mAxisMaster      : AxiStreamMasterArray(RCE_DMA_COUNT_G-1 downto 0);
   signal mAxisSlave       : AxiStreamSlaveArray(RCE_DMA_COUNT_G-1 downto 0);
   signal mAxisCtrl        : AxiStreamCtrlArray(RCE_DMA_COUNT_G-1 downto 0);

begin


   ------------------------------------
   -- HP Branching
   ------------------------------------
   U_HpGen : for i in 0 to 3 generate

      U_HpEn : if HP_BRANCHES_C(i) > 0 generate

         U_HpReadPathMux : entity work.AxiReadPathMux 
            generic map (
               TPD_G        => TPD_G,
               NUM_SLAVES_G => HP_BRANCHES_C(i)
            ) port map (
               axiClk          => axiDmaClk,
               axiRst          => axiDmaRst,
               sAxiReadMasters => ihpReadMasters((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               sAxiReadSlaves  => ihpReadSlaves((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               mAxiReadMaster  => hpReadMaster(i),
               mAxiReadSlave   => hpReadSlave(i)
            );

         U_HpWritePathMux : entity work.AxiWritePathMux
            generic map (
               TPD_G        => TPD_G,
               NUM_SLAVES_G => HP_BRANCHES_C(i)
            ) port map (
               axiClk           => axiDmaClk,
               axiRst           => axiDmaRst,
               sAxiWriteMasters => ihpWriteMasters((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               sAxiWriteSlaves  => ihpWriteSlaves((HP_BASE_C(i)+HP_BRANCHES_C(i))-1 downto HP_BASE_C(i)),
               mAxiWriteMaster  => hpWriteMaster(i),
               mAxiWriteSlave   => hpWriteSlave(i)
            );
      end generate;

      U_HpDis : if HP_BRANCHES_C(i) = 0 generate
         ihpReadSlaves(i)  <= AXI_READ_SLAVE_INIT_C;
         ihpWriteSlaves(i) <= AXI_WRITE_SLAVE_INIT_C;
      end generate;

   end generate;


   ------------------------------------
   -- AXI-Lite Crossbar
   ------------------------------------
   U_AxiLiteCrossbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => RCE_DMA_COUNT_G,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         MASTERS_CONFIG_G   => MASTERS_CONFIG_C
      ) port map (
         axiClk              => axiDmaClk,
         axiClkRst           => axiDmaRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiReadMasters     => iaxilReadMaster,
         mAxiReadSlaves      => iaxilReadSlave,
         mAxiWriteMasters    => iaxilWriteMaster,
         mAxiWriteSlaves     => iaxilWriteSlave
      );


   ------------------------------------------
   -- DMA Channels
   ------------------------------------------
   U_DmaChanGen : for i in 0 to RCE_DMA_COUNT_G-1 generate

      -- DMA Core
      U_AxiStreamDma : entity work.AxiStreamDma
         generic map (
            TPD_G            => TPD_G,
            AXIL_BASE_ADDR_G => MASTERS_CONFIG_C(i).baseAddr,
            AXI_READY_EN_G   => false,
            AXIS_READY_EN_G  => false,
            AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
            AXI_CONFIG_G     => AXI_HP_INIT_C,
            AXI_BURST_G      => "01",
            AXI_CACHE_G      => "1111"
         ) port map (
            axiClk          => axiDmaClk,
            axiRst          => axiDmaRst,
            axilReadMaster  => iaxilReadMaster(i),
            axilReadSlave   => iaxilReadSlave(i),
            axilWriteMaster => iaxilWriteMaster(i),
            axilWriteSlave  => iaxilWriteSlave(i),
            interrupt       => interrupt(i),
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
            FIFO_PAUSE_THRESH_G => 500,
            SLAVE_AXI_CONFIG_G  => RCE_DMA_AXIS_CONFIG_G,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G
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
            FIFO_PAUSE_THRESH_G => 500,
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
            MASTER_AXI_CONFIG_G => RCE_DMA_AXIS_CONFIG_G
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
            RST_ASYNC_G              => false,
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
            mAxiReadMaster => ihpReadMasters(i),
            mAxiReadSlave  => ihpReadSlaves(i)
         );


      -- Write Path AXI FIFO
      U_AxiWritePathFifo : entity work.AxiWritePathFifo
         generic map (
            TPD_G                    => TPD_G,
            RST_ASYNC_G              => false,
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
            mAxiWriteMaster => ihpWriteMasters(i),
            mAxiWriteSlave  => ihpWriteSlaves(i)
         );
   end generate;


   ------------------------------------------
   -- Unused Interrupts
   ------------------------------------------
   U_UnusedIntGen : for i in RCE_DMA_COUNT_G to 15 generate
      interrupt(i) <= '0';
   end generate;

end structure;

