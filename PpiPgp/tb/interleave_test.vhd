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

entity interleave_test is end interleave_test;

-- Define architecture
architecture interleave_test of interleave_test is

   constant VC_COUNT_G  : integer := 2;
   constant PPI_COUNT_G : integer := 2;
   constant EP_COUNT_G  : integer := VC_COUNT_G*PPI_COUNT_G;

   signal locClk            : sl;
   signal locClkRst         : sl;
   signal sloClk            : sl;
   signal sloClkRst         : sl;
   signal enable            : sl;
   signal txEnable          : slv(EP_COUNT_G-1 downto 0);
   signal txBusy            : slv(EP_COUNT_G-1 downto 0);
   signal txLength          : Slv32Array(EP_COUNT_G-1 downto 0);
   signal interCount        : slv(31 downto 0);
   signal iprbsTxMasters    : AxiStreamMasterArray(EP_COUNT_G-1 downto 0);
   signal iprbsTxSlaves     : AxiStreamSlaveArray(EP_COUNT_G-1 downto 0);
   signal prbsTxMasters     : AxiStreamMasterArray(PPI_COUNT_G-1 downto 0);
   signal prbsTxCtrls       : AxiStreamCtrlArray(PPI_COUNT_G-1 downto 0);
   signal ppiState          : RceDmaStateType;
   signal ppiIbMasters      : AxiStreamMasterArray(PPI_COUNT_G-1 downto 0);
   signal ppiIbSlaves       : AxiStreamSlaveArray(PPI_COUNT_G-1 downto 0);
   signal ppiMaster         : AxiStreamMasterType;
   signal ppiSlave          : AxiStreamSlaveType;
   signal ppiObMasters      : AxiStreamMasterArray(PPI_COUNT_G-1 downto 0);
   signal ppiObSlaves       : AxiStreamSlaveArray(PPI_COUNT_G-1 downto 0);
   signal prbsRxMasters     : AxiStreamMasterArray(PPI_COUNT_G-1 downto 0);
   signal prbsRxSlaves      : AxiStreamSlaveArray(PPI_COUNT_G-1 downto 0);
   signal iprbsRxMasters    : AxiStreamMasterArray(EP_COUNT_G-1 downto 0);
   signal iprbsRxSlaves     : AxiStreamSlaveArray(EP_COUNT_G-1 downto 0);
   signal updatedResults    : slv(EP_COUNT_G-1 downto 0);
   signal errMissedPacket   : slv(EP_COUNT_G-1 downto 0);
   signal errLength         : slv(EP_COUNT_G-1 downto 0);
   signal errEofe           : slv(EP_COUNT_G-1 downto 0);
   signal errDataBus        : slv(EP_COUNT_G-1 downto 0);
   signal errWordCnt        : Slv32Array(EP_COUNT_G-1 downto 0);
   signal errbitCnt         : Slv32Array(EP_COUNT_G-1 downto 0);
   signal packetRate        : Slv32Array(EP_COUNT_G-1 downto 0);
   signal packetLength      : Slv32Array(EP_COUNT_G-1 downto 0);

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
      sloClk <= '1';
      wait for 100 ns;
      sloClk <= '0';
      wait for 100 ns;
   end process;

   process begin
      sloClkRst <= '1';
      wait for (1000 ns);
      sloClkRst <= '0';
      wait;
   end process;
   process begin
      enable <= '0';
      wait for (10 us);
      enable <= '1';
      wait;
   end process;

   U_TxPpiGen: for i in 0 to PPI_COUNT_G-1 generate
      U_TxVcGen: for j in 0 to VC_COUNT_G-1 generate
         process ( sloClk ) begin
            if rising_edge(sloClk) then
               if sloClkRst = '1' then
                  txEnable(i*VC_COUNT_G+j) <= '0' after 1 ns;
                  txLength(i*VC_COUNT_G+j) <= toSlv(j*4+4,32) after 1 ns;
               else
                  if txBusy(i*VC_COUNT_G+j) = '0' and enable = '1' and txEnable(i*VC_COUNT_G+j) = '0' then
                     txEnable(i*VC_COUNT_G+j) <= '1' after 1 ns;
                  else
                     txEnable(i*VC_COUNT_G+j) <= '0' after 1 ns;
                  end if;

                  if txEnable(i*VC_COUNT_G+j) = '1' then
                     txLength(i*VC_COUNT_G+j) <= txLength(i*VC_COUNT_G+j) + 1 after 2 ns;
                  end if;

               end if;
            end if;
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
               mAxisSlave   => iprbsTxSlaves(i*VC_COUNT_G+j),
               mAxisMaster  => iprbsTxMasters(i*VC_COUNT_G+j),
               locClk       => sloClk,
               locRst       => sloClkRst,
               trig         => txEnable(i*VC_COUNT_G+j),
               packetLength => txLength(i*VC_COUNT_G+j),
               busy         => txBusy(i*VC_COUNT_G+j),
               tDest        => (others=>'0'),
               tId          => (others=>'0')
            );
      end generate;
   end generate;

   -- Interleave count
   process ( locClk ) begin
      if rising_edge(locClk) then
         if locClkRst = '1' then
            interCount <= (others=>'0') after 1 ns;
         else
            interCount <= interCount + 1 after 1 ns;
         end if;
      end if;
   end process;

   -- Interleave control
   process ( interCount, iprbsTxMasters, prbsTxCtrls ) begin
      prbsTxMasters <= (others=>AXI_STREAM_MASTER_INIT_C);

      for i in 0 to PPI_COUNT_G-1 loop
         for j in 0 to VC_COUNT_G-1 loop
            iprbsTxSlaves(i*VC_COUNT_G+j) <= AXI_STREAM_SLAVE_INIT_C;

            if prbsTxCtrls(i).pause = '0' and interCount(8 downto 8) = j then
               prbsTxMasters(i)                     <= iprbsTxMasters(i*VC_COUNT_G+j);
               prbsTxMasters(i).tDest(3 downto 0)   <= toSlv(j,4);
               iprbsTxSlaves(i*VC_COUNT_G+j).tReady <= '1';
            end if;
         end loop;
      end loop;
   end process;

   ppiState.online <= '1';

   U_PpiAGen: for i in 0 to PPI_COUNT_G-1 generate

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
            ppiIbMaster      => ppiIbMasters(i),
            ppiIbSlave       => ppiIbSlaves(i),
            axisIbClk        => locClk,
            axisIbClkRst     => locClkRst,
            axisIbMaster     => prbsTxMasters(i),
            axisIbCtrl       => prbsTxCtrls(i),
            rxFrameCntEn     => open,
            rxOverflow       => open
         );
   end generate;

   -- Inbound Mux
   U_IbMux : entity work.AxiStreamMux
      generic map (
         TPD_G        => 1 ns,
         NUM_SLAVES_G => PPI_COUNT_G
         ) port map (
            axisClk      => locClk,
            axisRst      => locClkRst,
            sAxisMasters => ppiIbMasters,
            sAxisSlaves  => ppiIbSlaves,
            mAxisMaster  => ppiMaster,
            mAxisSlave   => ppiSlave

            );

   -- Outbound DeMux
   U_ObDeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => 1 ns,
         NUM_MASTERS_G => PPI_COUNT_G
         ) port map (
            axisClk      => locClk,
            axisRst      => locClkRst,
            sAxisMaster  => ppiMaster,
            sAxisSlave   => ppiSlave,
            mAxisMasters => ppiObMasters,
            mAxisSlaves  => ppiObSlaves
            );

   U_PpiBGen: for i in 0 to PPI_COUNT_G-1 generate

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
            ppiObMaster      => ppiObMasters(i),
            ppiObSlave       => ppiObSlaves(i),
            axisObClk        => locClk,
            axisObClkRst     => locClkRst,
            axisObMaster     => prbsRxMasters(i),
            axisObSlave      => prbsRxSlaves(i),
            txFrameCntEn     => open
         );
   end generate;

   -- de-interleave 
   process ( prbsRxMasters, iprbsRxSlaves, interCount ) is
      variable j : integer;
   begin
      iprbsRxMasters <= (others=>AXI_STREAM_MASTER_INIT_C);
      prbsRxSlaves   <= (others=>AXI_STREAM_SLAVE_INIT_C);

      for i in 0 to PPI_COUNT_G-1 loop

         j := conv_integer(prbsRxMasters(i).tDest);

         --if interCount(10 downto 8) = 0 then
            iprbsRxMasters(i*VC_COUNT_G+j) <= prbsRxMasters(i);
            prbsRxSlaves(i) <= iprbsRxSlaves(i*VC_COUNT_G+j);
         --end if;
      end loop;
   end process;

   U_RxPpiGen: for i in 0 to PPI_COUNT_G-1 generate
      U_RxVcGen: for j in 0 to VC_COUNT_G-1 generate

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
               sAxisMaster     => iprbsRxMasters(i*VC_COUNT_G+j),
               sAxisSlave      => iprbsRxSlaves(i*VC_COUNT_G+j),
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
               updatedResults  => updatedResults(i*VC_COUNT_G+j),
               busy            => open,
               errMissedPacket => errMissedPacket(i*VC_COUNT_G+j),
               errLength       => errLength(i*VC_COUNT_G+j),
               errDataBus      => errDataBus(i*VC_COUNT_G+j),
               errEofe         => errEofe(i*VC_COUNT_G+j),
               errWordCnt      => errWordCnt(i*VC_COUNT_G+j),
               errbitCnt       => errbitCnt(i*VC_COUNT_G+j),
               packetRate      => packetRate(i*VC_COUNT_G+j),
               packetLength    => packetLength(i*VC_COUNT_G+j)
            ); 
      end generate;
   end generate;

end interleave_test;

