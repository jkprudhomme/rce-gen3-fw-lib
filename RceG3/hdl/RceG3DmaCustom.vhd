-------------------------------------------------------------------------------
-- Title      : AXI Streaming DMA Core
-- Project    : CSPAD Concentrator Core
-------------------------------------------------------------------------------
-- File       : RceG3DmaCustom.vhd
-- Author     : M. Kwiatkowski, mkwiatko@slac.stanford.edu
-- Created    : 2015-05-22
-- Last update: 2015-05-22
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- 4 AXI Stream DMA channels for the cspad concentrator.
-- Based on RceG3DmaAxis from Ryan Herbst
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/22/2015: created.
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
use work.SsiPkg.all;

entity RceG3DmaCustom is
   generic (
      TPD_G                   : time               := 1 ns;
      DMA_BUF_START_ADDR_G    : slv(31 downto 0)   := x"3C000000";
      DMA_BUF_SIZE_BITS_G     : integer            := 24;
      MAX_CSPAD_PKT_SIZE_G    : integer            := 1150000
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
end RceG3DmaCustom;

architecture structure of RceG3DmaCustom is 

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
   
   signal obAck            : AxiReadDmaAckArray(1 downto 0);
   signal obReq            : AxiReadDmaReqArray(1 downto 0);
   signal ibAck            : AxiWriteDmaAckArray(3 downto 0);
   signal ibReq            : AxiWriteDmaReqArray(3 downto 0);
   
   constant DMA_BUFF_MAX_ADDR_C : slv(31 downto 0)   := x"40000000";
   
   constant CUSTOM_AXIS_DMA_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 4,
      TDEST_BITS_C  => 4,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);
   
   constant CUSTOM_AXIS_DMA_ADDR_C : Slv32Array(3 downto 0) := ( 
      DMA_BUF_START_ADDR_G+2**DMA_BUF_SIZE_BITS_G*3,
      DMA_BUF_START_ADDR_G+2**DMA_BUF_SIZE_BITS_G*2,
      DMA_BUF_START_ADDR_G+2**DMA_BUF_SIZE_BITS_G,
      DMA_BUF_START_ADDR_G);
   
   constant DMA_BUFF_COUNT_C : integer := (2**DMA_BUF_SIZE_BITS_G)/MAX_CSPAD_PKT_SIZE_G;
   signal wrBuffIndex : IntegerArray(3 downto 0) := (0,0,0,0);
   signal rdBuffIndex : IntegerArray(3 downto 0) := (0,0,0,0);
   signal cntUsedBuff : IntegerArray(3 downto 0) := (0,0,0,0);
   signal buffOffsets : IntegerArray(DMA_BUFF_COUNT_C-1 downto 0);
   
   type BuffAddrArray is array (natural range <>) of slv(DMA_BUF_SIZE_BITS_G-1 downto 0);
   
   signal ibAcqFifoOut        : BuffAddrArray(3 downto 0);
   signal ibAcqFifoWrFull     : slv(3 downto 0);
   signal ibAcqFifoEmpty      : slv(3 downto 0);
   signal ibAcqFifoRd         : slv(3 downto 0);
   signal ibAckDoneD1         : slv(3 downto 0);
   signal ibAckRes            : slv(3 downto 0);
   signal wrPending           : slv(3 downto 0);
   signal wrChannelSel        : IntegerArray(1 downto 0);
   
   type StateType is (S_IDLE_C, S_READ_0_C, S_READ_1_C, S_DONE_0_C, S_DONE_1_C);
   type StateTypeArray is array (natural range <>) of StateType;
   signal state, nextState : StateTypeArray(1 downto 0);
      
begin

   -- check generic settings
   assert DMA_BUF_START_ADDR_G+(2**DMA_BUF_SIZE_BITS_G)*4 <= DMA_BUFF_MAX_ADDR_C
      report "RceG3DmaCustom: DMA buffer exceed maximum memory address"
      severity failure;
   
   assert DMA_BUFF_COUNT_C >= 2
      report "RceG3DmaCustom: DMA buffer size is not sufficient for selected MAX_CSPAD_PKT_SIZE_G"
      severity failure;
   
   -- initialize buffer offsets
   U_BuffOffGen: for i in 0 to DMA_BUFF_COUNT_C-1 generate
      buffOffsets(i) <= i*MAX_CSPAD_PKT_SIZE_G;
   end generate;

   -- HP for channel all 4 channels
   intWriteSlave <= hpWriteSlave;
   hpWriteMaster <= intWriteMaster;
   intReadSlave  <= hpReadSlave;
   hpReadMaster  <= intReadMaster;

   -- ACP unused
   acpWriteMaster <= AXI_WRITE_MASTER_INIT_C;
   acpReadMaster  <= AXI_READ_MASTER_INIT_C;

   -- Unused Interrupts
   -- All unused for now
   interrupt(DMA_INT_COUNT_C-1 downto 0) <= (others=>'0');

   -- Unused DMA channels
   dmaState                <= (others=>RCE_DMA_STATE_INIT_C);
   dmaObMaster(3 downto 2) <= (others=>AXI_STREAM_MASTER_INIT_C);

   -- Terminate Unused AXI-Lite Interfaces
   -- SW independent DMA therefore all unused for now
   U_AxiLiteGen : for i in 0 to 8 generate
      U_AxiLiteEmpty : entity work.AxiLiteEmpty
         generic map (
            TPD_G  => TPD_G
         ) port map (
            axiClk          => axiDmaClk,
            axiClkRst       => axiDmaRst,
            axiReadMaster   => axilReadMaster(i),
            axiReadSlave    => axilReadSlave(i),
            axiWriteMaster  => axilWriteMaster(i),
            axiWriteSlave   => axilWriteSlave(i)
         );
   end generate;
   
   ------------------------------------------
   -- Generate 4 DMA Write Channels
   ------------------------------------------
   U_DmaWriteGen : for i in 0 to 3 generate
      
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
            GEN_SYNC_FIFO_G     => true,
            ALTERA_SYN_G        => false,
            ALTERA_RAM_G        => "M9K",
            CASCADE_SIZE_G      => 1,
            FIFO_ADDR_WIDTH_G   => 9,
            FIFO_FIXED_THRESH_G => true,
            FIFO_PAUSE_THRESH_G => 500,
            SLAVE_AXI_CONFIG_G  => CUSTOM_AXIS_DMA_CONFIG_C,
            MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C
         ) port map (
            sAxisClk        => dmaClk(i),
            sAxisRst        => dmaClkRst(i),
            sAxisMaster     => dmaIbMaster(i),
            sAxisSlave      => dmaIbSlave(i),
            sAxisCtrl       => open,
            fifoPauseThresh => (others => '1'),
            mAxisClk        => dmaClk(i),
            mAxisRst        => dmaClkRst(i),
            mAxisMaster     => sAxisMaster(i),
            mAxisSlave      => sAxisSlave(i)
         );
      
      -- DMA writer instance
      U_WrDMA : entity work.AxiStreamDmaWrite
         generic map (
            TPD_G             => TPD_G,
            AXI_READY_EN_G    => false,
            AXIS_CONFIG_G     => RCEG3_AXIS_DMA_CONFIG_C,
            AXI_CONFIG_G      => AXI_HP_INIT_C,
            AXI_BURST_G       => "01",
            AXI_CACHE_G       => "0000"
         ) port map (
            axiClk            => dmaClk(i),
            axiRst            => dmaClkRst(i),
            -- DMA Control Interface
            dmaReq            => ibReq(i),
            dmaAck            => ibAck(i),
            -- Streaming Interface 
            axisMaster        => sAxisMaster(i),
            axisSlave         => sAxisSlave(i),
            -- AXI Interface
            axiWriteMaster    => locWriteMaster(i),
            axiWriteSlave     => locWriteSlave(i),
            axiWriteCtrl      => locWriteCtrl(i)
         );      
      
      -- DMA writer request when SOF
      -- Do not start writer if all buffers are in use
      process (dmaClk(i))
      begin
         if rising_edge(dmaClk(i)) then
            if dmaClkRst(i) = '1' or ibAck(i).done = '1' then
               wrPending(i) <= '0';
            elsif ssiGetUserSof(RCEG3_AXIS_DMA_CONFIG_C, sAxisMaster(i)) = '1' and cntUsedBuff(i) < DMA_BUFF_COUNT_C-2 then
               wrPending(i) <= '1';
            end if;
         end if;
      end process;
      ibReq(i).request <= wrPending(i) and not ibAck(i).done;
      ibReq(i).drop <= '0';
      
      -- Track write buffer index
      process (dmaClk(i))
      begin
         if rising_edge(dmaClk(i)) then
            if dmaClkRst(i) = '1' then
               wrBuffIndex(i) <= 0 after TPD_G;
            elsif ibAck(i).done = '1' and wrBuffIndex(i) + 1 <= DMA_BUFF_COUNT_C-1 then
               wrBuffIndex(i) <= wrBuffIndex(i) + 1 after TPD_G;
            elsif ibAck(i).done = '1' and wrBuffIndex(i) + 1 > DMA_BUFF_COUNT_C-1 then
               wrBuffIndex(i) <= 0 after TPD_G;
            end if;
         end if;
      end process;
      
      ibReq(i).address <= CUSTOM_AXIS_DMA_ADDR_C(i) + buffOffsets(wrBuffIndex(i));
      ibReq(i).maxSize <= conv_std_logic_vector(MAX_CSPAD_PKT_SIZE_G, 32);
      
      -- FIFO to store acknowledged bytes written by the DMA writer
      U_WrDMA_Acq_FIFO: entity work.Fifo 
      generic map (
         RST_POLARITY_G    => '1',
         DATA_WIDTH_G      => DMA_BUF_SIZE_BITS_G,
         ADDR_WIDTH_G      => 8,
         GEN_SYNC_FIFO_G   => true,
         FWFT_EN_G         => true
      )
      port map ( 
         rst               => dmaClkRst(i),
         wr_clk            => dmaClk(i),
         wr_en             => ibAck(i).done,
         din               => ibAck(i).size(DMA_BUF_SIZE_BITS_G-1 downto 0),
         wr_data_count     => open,
         wr_ack            => open,
         overflow          => open,
         prog_full         => open,
         almost_full       => open,
         full              => ibAcqFifoWrFull(i),
         not_full          => open,
         rd_clk            => dmaClk(i),
         rd_en             => ibAcqFifoRd(i),
         dout              => ibAcqFifoOut(i),
         rd_data_count     => open,
         valid             => open,
         underflow         => open,
         prog_empty        => open,
         almost_empty      => open,
         empty             => ibAcqFifoEmpty(i)
      );

      -- Write Path AXI FIFO
      U_AxiWritePathFifo : entity work.AxiWritePathFifo
         generic map (
            TPD_G                    => TPD_G,
            XIL_DEVICE_G             => "7SERIES",
            USE_BUILT_IN_G           => false,
            GEN_SYNC_FIFO_G          => false,
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
            sAxiClk         => dmaClk(i),
            sAxiRst         => dmaClkRst(i),
            sAxiWriteMaster => locWriteMaster(i),
            sAxiWriteSlave  => locWriteSlave(i),
            sAxiCtrl        => locWriteCtrl(i),
            mAxiClk         => axiDmaClk,
            mAxiRst         => axiDmaRst,
            mAxiWriteMaster => intWriteMaster(i),
            mAxiWriteSlave  => intWriteSlave(i)
         );
   end generate;

   ------------------------------------------
   -- Generate 2 DMA Readers
   ------------------------------------------
   U_DmaReadGen : for i in 0 to 1 generate
      
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
            GEN_SYNC_FIFO_G     => true,
            ALTERA_SYN_G        => false,
            ALTERA_RAM_G        => "M9K",
            CASCADE_SIZE_G      => 1,
            FIFO_ADDR_WIDTH_G   => 9,
            FIFO_FIXED_THRESH_G => true,
            FIFO_PAUSE_THRESH_G => 475,
            SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
            MASTER_AXI_CONFIG_G => CUSTOM_AXIS_DMA_CONFIG_C
         ) port map (
            sAxisClk        => dmaClk(i),
            sAxisRst        => dmaClkRst(i),
            sAxisMaster     => mAxisMaster(i),
            sAxisSlave      => mAxisSlave(i),
            sAxisCtrl       => mAxisCtrl(i),
            fifoPauseThresh => (others => '1'),
            mAxisClk        => dmaClk(i),
            mAxisRst        => dmaClkRst(i),
            mAxisMaster     => dmaObMaster(i),
            mAxisSlave      => dmaObSlave(i)
         );
         
         
      U_RdDMA : entity work.AxiStreamDmaRead 
         generic map (
            TPD_G            => TPD_G,
            AXIS_READY_EN_G  => false,
            AXIS_CONFIG_G    => RCEG3_AXIS_DMA_CONFIG_C,
            AXI_CONFIG_G     => AXI_HP_INIT_C,
            AXI_BURST_G      => "01",
            AXI_CACHE_G      => "0000"
         ) port map (
            axiClk          => dmaClk(i),
            axiRst          => dmaClkRst(i),
            dmaReq          => obReq(i),
            dmaAck          => obAck(i),
            axisMaster      => mAxisMaster(i),
            axisSlave       => mAxisSlave(i),
            axisCtrl        => mAxisCtrl(i),
            axiReadMaster   => locReadMaster(i),
            axiReadSlave    => locReadSlave(i)
         );
      
      -- one read channel handles data from two write channels
      process (state(i), ibAcqFifoEmpty(i*2), ibAcqFifoEmpty(i*2+1), obAck(i).done)
      begin
         
         wrChannelSel(i) <= 0;
         obReq(i).request <= '0';
         ibAcqFifoRd(i*2) <= '0';
         ibAcqFifoRd(i*2+1) <= '0';
         nextState(i) <= state(i);
         
         case state(i) is

            when S_IDLE_C =>
               if ibAcqFifoEmpty(i*2) = '0' then
                  nextState(i) <= S_READ_0_C;
                  wrChannelSel(i) <= 0;
               elsif ibAcqFifoEmpty(i*2+1) = '0' then
                  nextState(i) <= S_READ_1_C;
                  wrChannelSel(i) <= 1;
               end if;
            
            when S_READ_0_C =>
               obReq(i).request <= '1';
               wrChannelSel(i) <= 0;
               if obAck(i).done = '1' then
                  obReq(i).request <= '0';
                  ibAcqFifoRd(i*2) <= '1';
                  nextState(i) <= S_DONE_0_C;
               end if;
            
            when S_DONE_0_C =>
               wrChannelSel(i) <= 0;
               if ibAcqFifoEmpty(i*2+1) = '0' then
                  nextState(i) <= S_READ_1_C;
               elsif ibAcqFifoEmpty(i*2) = '0' then
                  nextState(i) <= S_READ_0_C;
               else
                  nextState(i) <= S_IDLE_C;
               end if;
            
            when S_READ_1_C =>
               obReq(i).request <= '1';
               wrChannelSel(i) <= 1;
               if obAck(i).done = '1' then
                  obReq(i).request <= '0';
                  ibAcqFifoRd(i*2+1) <= '1';
                  nextState(i) <= S_DONE_1_C;
               end if;
            
            when S_DONE_1_C =>
               wrChannelSel(i) <= 1;
               if ibAcqFifoEmpty(i*2) = '0' then
                  nextState(i) <= S_READ_0_C;
               elsif ibAcqFifoEmpty(i*2+1) = '0' then
                  nextState(i) <= S_READ_1_C;
               else
                  nextState(i) <= S_IDLE_C;
               end if;
            
         end case;
      
      end process;
      
      obReq(i).address <= CUSTOM_AXIS_DMA_ADDR_C(i*2) + buffOffsets(rdBuffIndex(i*2)) when wrChannelSel(i) = 0 else CUSTOM_AXIS_DMA_ADDR_C(i*2+1) + buffOffsets(rdBuffIndex(i*2+1));
      obReq(i).size(31 downto DMA_BUF_SIZE_BITS_G) <= (others=>'0');
      obReq(i).size(DMA_BUF_SIZE_BITS_G-1 downto 0) <= ibAcqFifoOut(i*2) when wrChannelSel(i) = 0 else ibAcqFifoOut(i*2+1);
      obReq(i).firstUser <= "00000010";
      obReq(i).lastUser <= (others=>'0');
      obReq(i).dest <= (others=>'0');
      obReq(i).id <= (others=>'0');
      
      process (dmaClk(i))
      begin
         if rising_edge(dmaClk(i)) then
            if dmaClkRst(i) = '1' then
               state(i) <= S_IDLE_C after TPD_G;
            else
               state(i) <= nextState(i) after TPD_G;
            end if;
         end if;
      end process;
      
      
      -- Separetly for each write channel track
      -- read address and memory buffer usage
      U_DmaRdAddrGen : for j in 0 to 1 generate
         
         -- Read buffer index
         process (dmaClk(i))
         begin
            if rising_edge(dmaClk(i)) then
               if dmaClkRst(i) = '1' then
                  rdBuffIndex(i*2+j) <= 0 after TPD_G;
               elsif obAck(i).done = '1' and wrChannelSel(i) = j and rdBuffIndex(i*2+j) + 1 <= DMA_BUFF_COUNT_C-1 then
                  rdBuffIndex(i*2+j) <= rdBuffIndex(i*2+j) + 1 after TPD_G;
               elsif obAck(i).done = '1' and wrChannelSel(i) = j and rdBuffIndex(i*2+j) + 1 > DMA_BUFF_COUNT_C-1 then
                  rdBuffIndex(i*2+j) <= 0 after TPD_G;
               end if;
            end if;
         end process;
         
         -- Buffer usage counter
         process (dmaClk(i))
         begin
            if rising_edge(dmaClk(i)) then
               if dmaClkRst(i) = '1' then
                  cntUsedBuff(i*2+j) <= 0 after TPD_G;
               elsif obAck(i).done = '1' and wrChannelSel(i) = j then   -- subtract when reader is done
                  cntUsedBuff(i*2+j) <= cntUsedBuff(i*2+j) - 1 after TPD_G;
               elsif ibAckRes(i*2+j) = '1' then                         -- add when writer is done
                  cntUsedBuff(i*2+j) <= cntUsedBuff(i*2+j) + 1 after TPD_G;
               end if;
            end if;
         end process;
         
         -- Memory usage counter signal 
         -- protected against simultaneous arrival of done from both writer and reader
         process (dmaClk(i))
         begin
            if rising_edge(dmaClk(i)) then
               if dmaClkRst(i) = '1' then
                  ibAckDoneD1(i*2+j) <= '0' after TPD_G;
               else
                  ibAckDoneD1(i*2+j) <= ibAck(i*2+j).done after TPD_G;
               end if;
            end if;
         end process;
         
         ibAckRes(i*2+j) <= (ibAck(i*2+j).done and obAck(i).done) or (ibAckDoneD1(i*2+j) and not obAck(i).done);
         
         -- Generate back pressure signals when the reader is too slow
         --process (dmaClk(i))
         --begin
         --   if rising_edge(dmaClk(i)) then
         --      if dmaClkRst(i) = '1' then
         --         dmaState(i*2+j).user <= '0' after TPD_G;
         --         dmaState(i*2+j).online <= '0' after TPD_G;
         --      elsif ibAckRes(i*2+j) = '1' or (obAck(i).done = '1' and wrChannelSel(i) = j) then
         --         if cntUsedBuff(i*2+j) >= DMA_BUFF_COUNT_C/2 then
         --            dmaState(i*2+j).user <= '1' after TPD_G;
         --            dmaState(i*2+j).online <= '1' after TPD_G;
         --         else
         --            dmaState(i*2+j).user <= '0' after TPD_G;
         --            dmaState(i*2+j).online <= '0' after TPD_G;
         --         end if;
         --      end if;
         --   end if;
         --end process;
      
      end generate;


      -- Read Path AXI FIFO
      U_AxiReadPathFifo : entity work.AxiReadPathFifo 
         generic map (
            TPD_G                    => TPD_G,
            XIL_DEVICE_G             => "7SERIES",
            USE_BUILT_IN_G           => false,
            GEN_SYNC_FIFO_G          => false,
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
            sAxiClk        => dmaClk(i),
            sAxiRst        => dmaClkRst(i),
            sAxiReadMaster => locReadMaster(i),
            sAxiReadSlave  => locReadSlave(i),
            mAxiClk        => axiDmaClk,
            mAxiRst        => axiDmaRst,
            mAxiReadMaster => intReadMaster(i),
            mAxiReadSlave  => intReadSlave(i)
         );
      
   end generate;

end structure;

