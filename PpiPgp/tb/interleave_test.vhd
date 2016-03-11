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

   constant VC_COUNT_G : integer := 2;

   signal locClk            : sl;
   signal locClkRst         : sl;
   signal enable            : sl;
   signal txEnable          : slv(VC_COUNT_G-1 downto 0);
   signal txBusy            : slv(VC_COUNT_G-1 downto 0);
   signal txLength          : Slv32Array(VC_COUNT_G-1 downto 0);
   signal interCount        : slv(31 downto 0);
   signal iprbsTxMasters    : AxiStreamMasterArray(VC_COUNT_G-1 downto 0);
   signal iprbsTxSlaves     : AxiStreamSlaveArray(VC_COUNT_G-1 downto 0);
   signal prbsTxMaster      : AxiStreamMasterType;
   signal ppiState          : RceDmaStateType;
   signal ppiIbMaster       : AxiStreamMasterType;
   signal ppiIbSlave        : AxiStreamSlaveType;
   signal prbsRxMaster      : AxiStreamMasterType;
   signal prbsRxSlave       : AxiStreamSlaveType;
   signal iprbsRxMasters    : AxiStreamMasterArray(VC_COUNT_G-1 downto 0);
   signal iprbsRxSlaves     : AxiStreamSlaveArray(VC_COUNT_G-1 downto 0);
   signal updatedResults    : slv(VC_COUNT_G-1 downto 0);
   signal errMissedPacket   : slv(VC_COUNT_G-1 downto 0);
   signal errLength         : slv(VC_COUNT_G-1 downto 0);
   signal errEofe           : slv(VC_COUNT_G-1 downto 0);
   signal errDataBus        : slv(VC_COUNT_G-1 downto 0);
   signal errWordCnt        : Slv32Array(VC_COUNT_G-1 downto 0);
   signal errbitCnt         : Slv32Array(VC_COUNT_G-1 downto 0);
   signal packetRate        : Slv32Array(VC_COUNT_G-1 downto 0);
   signal packetLength      : Slv32Array(VC_COUNT_G-1 downto 0);

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
      wait for (1 us);
      enable <= '1';
      wait;
   end process;

   U_TxGen: for i in 0 to VC_COUNT_G-1 generate
      process ( locClk ) begin
         if rising_edge(locClk) then
            if locClkRst = '1' then
               txEnable(i) <= '0' after 1 ns;
               txLength(i) <= toSlv(i*4+4,32) after 1 ns;
            else
               if txBusy(i) = '0' and enable = '1' and txEnable(i) = '0' then
                  txEnable(i) <= '1' after 1 ns;
               else
                  txEnable(i) <= '0' after 1 ns;
               end if;

               if txEnable(i) = '1' then
                  txLength(i) <= txLength(i) + 1 after 2 ns;
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
            mAxisSlave   => iprbsTxSlaves(i),
            mAxisMaster  => iprbsTxMasters(i),
            locClk       => locClk,
            locRst       => locClkRst,
            trig         => txEnable(i),
            packetLength => txLength(i),
            busy         => txBusy(i),
            tDest        => (others=>'0'),
            tId          => (others=>'0')
         );
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
   process ( interCount, iprbsTxMasters ) begin
      prbsTxMaster  <= AXI_STREAM_MASTER_INIT_C;

      for i in 0 to VC_COUNT_G-1 loop
         iprbsTxSlaves(i) <= AXI_STREAM_SLAVE_INIT_C;

         if interCount(10 downto 8) = i then
            prbsTxMaster                   <= iprbsTxMasters(i);
            prbsTxMaster.tDest(3 downto 0) <= toSlv(i,4);
            iprbsTxSlaves(i).tReady        <= '1';
         end if;
      end loop;
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
         ppiIbMaster      => ppiIbMaster,
         ppiIbSlave       => ppiIbSlave,
         axisIbClk        => locClk,
         axisIbClkRst     => locClkRst,
         axisIbMaster     => prbsTxMaster,
         axisIbCtrl       => open,
         rxFrameCntEn     => open,
         rxOverflow       => open
      );

   ppiState.online <= '1';

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
         ppiObMaster      => ppiIbMaster,
         ppiObSlave       => ppiIbSlave,
         axisObClk        => locClk,
         axisObClkRst     => locClkRst,
         axisObMaster     => prbsRxMaster,
         axisObSlave      => prbsRxSlave,
         txFrameCntEn     => open
      );

   -- de-interleave 
   process ( prbsRxMaster, iprbsRxSlaves ) is
      variable i : integer;
   begin
      iprbsRxMasters <= (others=>AXI_STREAM_MASTER_INIT_C);
      prbsRxSlave    <= AXI_STREAM_SLAVE_INIT_C;

      i := conv_integer(prbsRxMaster.tDest);

      iprbsRxMasters(i) <= prbsRxMaster;
      prbsRxSlave       <= iprbsRxSlaves(i);

   end process;

   U_RxGen: for i in 0 to VC_COUNT_G-1 generate
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
            sAxisMaster     => iprbsRxMasters(i),
            sAxisSlave      => iprbsRxSlaves(i),
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
            updatedResults  => updatedResults(i),
            busy            => open,
            errMissedPacket => errMissedPacket(i),
            errLength       => errLength(i),
            errDataBus      => errDataBus(i),
            errEofe         => errEofe(i),
            errWordCnt      => errWordCnt(i),
            errbitCnt       => errbitCnt(i),
            packetRate      => packetRate(i),
            packetLength    => packetLength(i)
         ); 
   end generate;

end interleave_test;

