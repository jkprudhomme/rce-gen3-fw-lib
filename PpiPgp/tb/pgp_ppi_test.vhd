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

entity pgp_ppi_test is end pgp_ppi_test;

-- Define architecture
architecture pgp_ppi_test of pgp_ppi_test is

   signal locClk            : sl;
   signal locClkRst         : sl;
   signal enable            : sl;
   signal txEnable          : sl;
   signal txBusy            : sl;
   signal txLength          : slv(31 downto 0);
   signal prbsTxMaster      : AxiStreamMasterType;
   signal ppiState          : RceDmaStateType;
   signal ppiIbMaster       : AxiStreamMasterType;
   signal ppiIbSlave        : AxiStreamSlaveType;
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

   process ( locClk ) begin
      if rising_edge(locClk) then
         if locClkRst = '1' then
            txEnable <= '0' after 1 ns;
            txLength <= x"00000004" after 1 ns;
         else
            if txBusy = '0' and enable = '1' and txEnable = '0' then
               txEnable <= '1' after 1 ns;
            else
               txEnable <= '0' after 1 ns;
            end if;

            if txEnable = '1' then
               txLength <= txLength + 1 after 2 ns;
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
         mAxisSlave   => AXI_STREAM_SLAVE_FORCE_C,
         mAxisMaster  => prbsTxMaster,
         locClk       => locClk,
         locRst       => locClkRst,
         trig         => txEnable,
         packetLength => txLength,
         busy         => txBusy,
         tDest        => (others=>'0'),
         tId          => (others=>'0')
      );

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

end pgp_ppi_test;

