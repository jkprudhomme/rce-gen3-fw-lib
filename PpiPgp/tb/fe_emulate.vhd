------------------------------------------------------------------------------
-- This file is part of 'SLAC PGP2B Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC PGP2B Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------
LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.Pgp2bPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.SsiPkg.all;
use work.RceG3Pkg.all;
use work.PpiPkg.all;

entity fe_emulate is end fe_emulate;

-- Define architecture
architecture fe_emulate of fe_emulate is

   signal locClk            : sl;
   signal locClkRst         : sl;
   signal enable            : sl;
   signal txCount           : slv(31 downto 0);
   signal nxtCount          : slv(31 downto 0);
   signal txEnable          : sl;
   signal txLength          : slv(31 downto 0);
   signal prbsTxMaster      : AxiStreamMasterType;
   signal prbsTxSlave       : AxiStreamSlaveType;
   signal laneTxMaster      : AxiStreamMasterType;
   signal laneTxCtrl        : AxiStreamCtrlType;
   signal ppiState          : RceDmaStateType;
   signal ppiMaster         : AxiStreamMasterType;
   signal ppiSlave          : AxiStreamSlaveType;
   signal laneRxMaster      : AxiStreamMasterType;
   signal laneRxSlave       : AxiStreamSlaveType;
   signal prbsRxMaster      : AxiStreamMasterType;
   signal prbsRxSlave       : AxiStreamSlaveType;
   signal updatedResults    : sl;
   signal errMissedPacket   : sl;
   signal errLength         : sl;
   signal errEofe           : sl;
   signal errDataBus        : sl;
   signal errWordCnt        : slv(31 downto 0);
   signal errbitCnt         : slv(31 downto 0);
   signal packetRate        : slv(31 downto 0);
   signal packetLength      : slv(31 downto 0);
   signal regData           : slv(15 downto 0);
   signal regValid          : sl;

begin

   process begin
      locClk <= '1';
      wait for 2.5 ns;
      locClk <= '0';
      wait for 2.5 ns;
   end process;

   process begin
      locClkRst <= '1';
      wait for (50 ns);
      locClkRst <= '0';
      wait;
   end process;

   process begin
      enable <= '0';
      wait for (10 us);
      enable <= '1';
      wait;
   end process;


   U_SsiPrbsTx : entity work.SsiPrbsTx
      generic map (
         TPD_G                      => 1 ns,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         XIL_DEVICE_G               => "7SERIES",  --Xilinx only generic parameter    
         BRAM_EN_G                  => true,
         USE_BUILT_IN_G             => false,  --if set to true, this module is only Xilinx compatible only!!!
         GEN_SYNC_FIFO_G            => false,
         CASCADE_SIZE_G             => 1,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 16),
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 256,    -- Almost full at 1/2 capacity
         MASTER_AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_PIPE_STAGES_G   => 0
      ) port map (
         mAxisClk     => locClk,
         mAxisRst     => locClkRst,
         mAxisSlave   => prbsTxSlave,
         mAxisMaster  => prbsTxMaster,
         locClk       => locClk,
         locRst       => locClkRst,
         trig         => txEnable,
         packetLength => txLength,
         busy         => open,
         tDest        => (others=>'0'),
         tId          => (others=>'0')
      );


   process ( locClk ) begin
      if rising_edge(locClk) then
         if locClkRst = '1' then
            txCount <= (others=>'0') after 1 ns;
         else
            txCount <= nxtCount after 1 ns;
         end if;
      end if;
   end process;

   process ( txCount, laneTxCtrl, prbsTxMaster ) begin
      laneTxMaster <= AXI_STREAM_MASTER_INIT_C after 1 ns;
      prbsTxSlave  <= AXI_STREAM_SLAVE_INIT_C  after 1 ns;
      txEnable     <= '0'                      after 1 ns;
      txLength     <= toSlv(1024,32)           after 1 ns;
      nxtCount     <= txCount + 1              after 1 ns;

      if txCount = 180 then
         nxtCount <= txCount + 1 after 1 ns;
         txEnable <= '1'         after 1 ns;

      elsif txCount = 200 then
         laneTxMaster.tData(15 downto 0) <= x"1111"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;
         laneTxMaster.tUser(1)           <= '1'                  after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 201 then
         laneTxMaster.tData(15 downto 0) <= x"2222"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 202 then
         laneTxMaster.tData(15 downto 0) <= x"3333"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 203 then
         laneTxMaster.tData(15 downto 0) <= x"4444"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 204 then
         laneTxMaster.tData(15 downto 0) <= x"5555"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 205 then
         laneTxMaster.tData(15 downto 0) <= x"6666"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount > 210 and txCount < 220 then
         laneTxMaster       <= prbsTxMaster         after 1 ns;
         prbsTxSlave.tReady <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 220 then
         laneTxMaster.tData(15 downto 0) <= x"7777"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount = 221 then
         laneTxMaster.tData(15 downto 0) <= x"8888"              after 1 ns;
         laneTxMaster.tDest              <= x"01"                after 1 ns;
         laneTxMaster.tValid             <= not laneTxCtrl.pause after 1 ns;
         laneTxMaster.tLast              <= '1'                  after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;

      elsif txCount > 230 then
         laneTxMaster       <= prbsTxMaster         after 1 ns;
         prbsTxSlave.tReady <= not laneTxCtrl.pause after 1 ns;

         if laneTxCtrl.pause = '0' then
            nxtCount <= txCount + 1 after 1 ns;
         else
            nxtCount <= txCount after 1 ns;
         end if;
      end if;
   end process;

   U_PgpToPpi: entity work.PgpToPpi
      generic map (
         TPD_G                 => 1 ns,
         AXIS_ADDR_WIDTH_G     => 9,
         AXIS_PAUSE_THRESH_G   => 400,
         AXIS_CASCADE_SIZE_G   => 1,
         DATA_ADDR_WIDTH_G     => 12,
         HEADER_ADDR_WIDTH_G   => 9,
         PPI_MAX_FRAME_SIZE_G  => 2048
      ) port map (
         ppiClk           => locClk,
         ppiClkRst        => locClkRst,
         ppiState         => ppiState,
         ppiIbMaster      => ppiMaster,
         ppiIbSlave       => ppiSlave,
         axisIbClk        => locClk,
         axisIbClkRst     => locClkRst,
         axisIbMaster     => laneTxMaster,
         axisIbCtrl       => laneTxCtrl,
         rxFrameCntEn     => open,
         rxOverflow       => open
      );

   U_PpiToPgp: entity work.PpiToPgp
      generic map (
         TPD_G                 => 1 ns,
         PPI_ADDR_WIDTH_G      => 9,
         AXIS_ADDR_WIDTH_G     => 9,
         AXIS_CASCADE_SIZE_G   => 1
      ) port map (
         ppiClk           => locClk,
         ppiClkRst        => locClkRst,
         ppiState         => ppiState,
         ppiObMaster      => ppiMaster,
         ppiObSlave       => ppiSlave,
         axisObClk        => locClk,
         axisObClkRst     => locClkRst,
         axisObMaster     => laneRxMaster,
         axisObSlave      => laneRxSlave,
         txFrameCntEn     => open
      );

   -- de-interleave 
   process ( laneRxMaster, prbsRxSlave ) begin
      prbsRxMaster <= AXI_STREAM_MASTER_INIT_C;
      laneRxSlave  <= AXI_STREAM_SLAVE_INIT_C;
      regData      <= (others=>'0');
      regValid     <= '0';
      prbsRxMaster <= laneRxMaster;

      if laneRxMaster.tDest /= 0 then
         prbsRxMaster.tValid <= '0';
         regData             <= laneRxMaster.tData(15 downto 0);
         regValid            <= laneRxMaster.tValid;
         laneRxSlave.tReady  <= '1';
      else
         regValid    <= '0';
         laneRxSlave <= prbsRxSlave;
      end if;
   end process;

   U_SsiPrbsRx: entity work.SsiPrbsRx 
      generic map (
         TPD_G                      => 1 ns,
         STATUS_CNT_WIDTH_G         => 32,
         AXI_ERROR_RESP_G           => AXI_RESP_SLVERR_C,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         CASCADE_SIZE_G             => 1,
         XIL_DEVICE_G               => "7SERIES",  --Xilinx only generic parameter    
         BRAM_EN_G                  => true,
         USE_BUILT_IN_G             => false,  --if set to true, this module is only Xilinx compatible only!!!
         GEN_SYNC_FIFO_G            => false,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 16),
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 256,    -- Almost full at 1/2 capacity
         SLAVE_AXI_STREAM_CONFIG_G  => SSI_PGP2B_CONFIG_C,
         SLAVE_AXI_PIPE_STAGES_G    => 0,
         MASTER_AXI_STREAM_CONFIG_G => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_PIPE_STAGES_G   => 0
      ) port map (
         sAxisClk        => locClk,
         sAxisRst        => locClkRst,
         sAxisMaster     => prbsRxMaster,
         sAxisSlave      => prbsRxSlave,
         mAxisClk        => locClk,
         mAxisRst        => locClkRst,
         mAxisMaster     => open,
         mAxisSlave      => AXI_STREAM_SLAVE_FORCE_C,
         axiClk          => '0',
         axiRst          => '0',
         axiReadMaster   => AXI_LITE_READ_MASTER_INIT_C,
         axiReadSlave    => open,
         axiWriteMaster  => AXI_LITE_WRITE_MASTER_INIT_C,
         axiWriteSlave   => open,
         updatedResults  => updatedResults,
         busy            => open,
         errMissedPacket => errMissedPacket,
         errLength       => errLength,
         errDataBus      => errDataBus,
         errEofe         => errEofe,
         errWordCnt      => errWordCnt,
         errbitCnt       => errbitCnt,
         packetRate      => packetRate,
         packetLength    => packetLength
      ); 

end fe_emulate;

