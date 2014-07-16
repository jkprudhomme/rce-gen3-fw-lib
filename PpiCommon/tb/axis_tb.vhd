LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.Pgp2bPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

entity axis_tb is end axis_tb;

-- Define architecture
architecture axis_tb of axis_tb is

   signal locClk            : sl;
   signal locClkRst         : sl;
   signal enable            : sl;
   signal txEnable          : slv(3  downto 0);
   signal txBusy            : slv(3  downto 0);
   signal txLength          : Slv32Array(3 downto 0);
   signal prbsTxMasters     : AxiStreamMasterArray(3 downto 0);
   signal prbsTxSlaves      : AxiStreamSlaveArray(3 downto 0);
   signal prbsTxMaster      : AxiStreamMasterType;
   signal prbsTxSlave       : AxiStreamSlaveType;
   signal ppiState          : RceDmaStateType;
   signal ppiMaster         : AxiStreamMasterType;
   signal ppiSlave          : AxiStreamSlaveType;
   signal prbsRxMasters     : AxiStreamMasterArray(3 downto 0);
   signal prbsRxSlaves      : AxiStreamSlaveArray(3 downto 0);
   signal prbsRxMaster      : AxiStreamMasterType;
   signal prbsRxSlave       : AxiStreamSlaveType;
   signal updatedResults    : slv(3 downto 0);
   signal errMissedPacket   : slv(3 downto 0);
   signal errLength         : slv(3 downto 0);
   signal errEofe           : slv(3 downto 0);
   signal errDataBus        : slv(3 downto 0);
   signal errWordCnt        : Slv32Array(3 downto 0);
   signal errbitCnt         : Slv32Array(3 downto 0);
   signal packetRate        : Slv32Array(3 downto 0);
   signal packetLength      : Slv32Array(3 downto 0);

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

   U_TxGen: for i in 0 to 3 generate 

      process ( locClk ) begin
         if rising_edge(locClk) then
            if locClkRst = '1' then
               txEnable(i) <= '0' after 1 ns;

               case i is 
                  when 0      => txLength(i) <= x"00000700" after 1 ns;
                  when 1      => txLength(i) <= x"00000800" after 1 ns;
                  when 2      => txLength(i) <= x"00000900" after 1 ns;
                  when 3      => txLength(i) <= x"00000A00" after 1 ns;
                  when others => txLength(i) <= x"00000001" after 1 ns;
               end case;
            else
               if txBusy(i) = '0' and enable = '1' and txEnable(i) = '0' then
                  txEnable(i) <= '1' after 1 ns;
               else
                  txEnable(i) <= '0' after 1 ns;
               end if;

               if txEnable(i) = '1' then
                  txLength(i) <= txLength(i) + 1 after 1 ns;
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
            mAxisSlave   => prbsTxSlaves(i),
            mAxisMaster  => prbsTxMasters(i),
            locClk       => locClk,
            locRst       => locClkRst,
            trig         => txEnable(i),
            packetLength => txLength(i),
            busy         => txBusy(i),
            tDest        => conv_std_logic_vector(i,8),
            tId          => (others=>'0')
         );
   end generate;

   U_AxiStreamMux: entity work.AxiStreamMux
      generic map (
         TPD_G        => 1 ns,
         NUM_SLAVES_G => 4
      ) port map (
         axisClk      => locClk,
         axisRst      => locClkRst,
         sAxisMasters => prbsTxMasters,
         sAxisSlaves  => prbsTxSlaves,
         mAxisMaster  => prbsTxMaster,
         mAxisSlave   => prbsTxSlave
      );

   ppiState.enable <= '1';
   ppiState.online <= '1';

   U_AxisToPpi : entity work.AxisToPpi
      generic map (
         TPD_G                => 1 ns,
         AXIS_CONFIG_G        => SSI_PGP2B_CONFIG_C,
         AXIS_READY_EN_G      => true,
         AXIS_ADDR_WIDTH_G    => 9,
         AXIS_PAUSE_THRESH_G  => 500,
         AXIS_CASCADE_SIZE_G  => 1,
         AXIS_ERROR_EN_G      => true,
         AXIS_ERROR_BIT_G     => SSI_EOFE_C,
         DATA_ADDR_WIDTH_G    => 12,
         HEADER_ADDR_WIDTH_G  => 9,
         PPI_MAX_FRAME_SIZE_G => 1024
      ) port map (
         ppiClk          => locClk,
         ppiClkRst       => locClkRst,
         ppiState        => ppiState,
         ppiIbMaster     => ppiMaster,
         ppiIbSlave      => ppiSlave,
         axisIbClk       => locClk,
         axisIbClkRst    => locClkRst,
         axisIbMaster    => prbsTxMaster,
         axisIbSlave     => prbsTxSlave,
         axisIbCtrl      => open,
         rxFrameCntEn    => open,
         rxOverflow      => open
      );

   U_PpiToAxis : entity work.PpiToAxis
      generic map (
         TPD_G                => 1 ns,
         PPI_ADDR_WIDTH_G     => 9,
         AXIS_CONFIG_G        => SSI_PGP2B_CONFIG_C,
         AXIS_ADDR_WIDTH_G    => 9,
         AXIS_CASCADE_SIZE_G  => 1
      ) port map (
         ppiClk          => locClk,
         ppiClkRst       => locClkRst,
         ppiState        => ppiState,
         ppiObMaster     => ppiMaster,
         ppiObSlave      => ppiSlave,
         axisObClk       => locClk,
         axisObClkRst    => locClkRst,
         axisObMaster    => prbsRxMaster,
         axisObSlave     => prbsRxSlave,
         txFrameCntEn    => open
      );

   U_AxiStreamDeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => 1 ns,
         NUM_MASTERS_G => 4
      ) port map (
         axisClk      => locClk,
         axisRst      => locClkRst,
         sAxisMaster  => prbsRxMaster,
         sAxisSlave   => prbsRxSlave,
         mAxisMasters => prbsRxMasters,
         mAxisSlaves  => prbsRxSlaves
      );

   -- PRBS receiver
   U_RxGen: for i in 0 to 3 generate 
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
            sAxisMaster     => prbsRxMasters(i),
            sAxisSlave      => prbsRxSlaves(i),
            sAxisCtrl       => open,
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

end axis_tb;

