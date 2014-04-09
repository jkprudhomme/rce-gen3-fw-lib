LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.Vc64Pkg.all;

entity tb is end tb;

-- Define architecture
architecture tb of tb is

   signal ppiClk            : sl;
   signal ppiClkRst         : sl;
   signal pgpClk            : sl;
   signal pgpClkRst         : sl;
   signal ppiReadToFifo     : PpiReadToFifoType;
   signal ppiReadFromFifo   : PpiReadFromFifoType;
   signal ppiWriteToFifo    : PpiWriteToFifoType;
   signal ppiWriteFromFifo  : PpiWriteFromFifoType;
   signal rxFrameCntEn      : sl;
   signal rxDropCountEn     : sl;
   signal rxOverflow        : sl;
   signal txFrameCntEn      : sl;
   signal updatedResults    : slv(3 downto 0);
   signal errMissedPacket   : slv(3 downto 0);
   signal errLength         : slv(3 downto 0);
   signal errEofe           : slv(3 downto 0);
   signal errWordCnt        : Slv32Array(3 downto 0);
   signal errbitCnt         : Slv32Array(3 downto 0);
   signal packetRate        : Slv32Array(3 downto 0);
   signal packetLength      : Slv32Array(3 downto 0);
   signal enable            : sl;
   signal txEnable          : slv(3  downto 0);
   signal txBusy            : slv(3  downto 0);
   signal txLength          : Slv32Array(3 downto 0);
   signal prbsTxCtrl        : Vc64CtrlArray(3 downto 0);
   signal prbsTxData        : Vc64DataArray(3 downto 0);
   signal prbsTxMuxCtrl     : Vc64CtrlType;
   signal prbsTxMuxData     : Vc64DataType;
   signal prbsRxDataCommon  : Vc64DataType;
   signal prbsRxCtrl        : Vc64CtrlArray(3 downto 0);
   signal prbsRxData        : Vc64DataArray(3 downto 0);

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : 
      AxiLiteCrossbarMasterConfigArray(11 downto 0) := genAxiLiteConfig ( 12, x"F0000000", 4 );

begin

   process begin
      ppiClk <= '1';
      wait for 2.5 ns;
      ppiClk <= '0';
      wait for 2.5 ns;
   end process;

   process begin
      ppiClkRst <= '1';
      wait for (50 ns);
      ppiClkRst <= '0';
      wait;
   end process;

   process begin
      pgpClk <= '1';
      wait for 5 ns;
      pgpClk <= '0';
      wait for 5 ns;
   end process;

   process begin
      pgpClkRst <= '1';
      wait for (50 ns);
      pgpClkRst <= '0';
      wait;
   end process;

   process begin
      enable <= '0';
      wait for (1 us);
      enable <= '1';
      wait;
   end process;

   U_TxGen: for i in 0 to 3 generate 

      process ( pgpClk ) begin
         if rising_edge(pgpClk) then
            if pgpClkRst = '1' then
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

      U_Vc64PrbsTx : entity work.Vc64PrbsTx
         generic map (
            TPD_G              => 1 ns,
            RST_ASYNC_G        => false,
            ALTERA_SYN_G       => false,
            ALTERA_RAM_G       => "M9K",
            XIL_DEVICE_G       => "7SERIES",  --Xilinx only generic parameter    
            BRAM_EN_G          => true,
            USE_BUILT_IN_G     => false,  --if set to true, this module is only Xilinx compatible only!!!
            GEN_SYNC_FIFO_G    => false,
            PIPE_STAGES_G      => 0,
            FIFO_SYNC_STAGES_G => 3,
            FIFO_ADDR_WIDTH_G  => 9,
            FIFO_AFULL_THRES_G => 256     -- Almost full at 1/2 capacity
         ) port map (
            vcTxCtrl     => prbsTxCtrl(i), -- In
            vcTxData     => prbsTxData(i), -- Out
            vcTxClk      => pgpClk,
            vcTxRst      => pgpClkRst,
            trig         => txEnable(i),
            packetLength => txLength(i),
            busy         => txBusy(i),
            locClk       => pgpClk,
            locRst       => pgpClkRst 
         );

   end generate;

   -- Add Mux Here
   U_Mux : entity work.Vc64Mux
      generic map (
         TPD_G         => 1 ns,
         IB_VC_COUNT_G => 4
      ) port map (
         vcClk        => pgpClk,
         vcClkRst     => pgpClkRst,
         ibVcData     => prbsTxData,
         ibVcCtrl     => prbsTxCtrl,
         obVcData     => prbsTxMuxData,
         obVcCtrl     => prbsTxMuxCtrl
      );

   U_VcRx: entity work.PpiVcIb 
      generic map (
         TPD_G                => 1 ns,
         VC_WIDTH_G           => 16,
         PPI_ADDR_WIDTH_G     => 9,
         PPI_PAUSE_THOLD_G    => 255,
         PPI_READY_THOLD_G    => 0,
         PPI_MAX_FRAME_G      => 1023,
         HEADER_ADDR_WIDTH_G  => 8,
         HEADER_AFULL_THOLD_G => 100,
         DATA_ADDR_WIDTH_G    => 10,
         DATA_AFULL_THOLD_G   => 520
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => '1',
         ppiReadToFifo     => ppiReadToFifo,
         ppiReadFromFifo   => ppiReadFromFifo,
         ibVcClk           => pgpClk,
         ibVcClkRst        => pgpClkRst,
         ibVcData          => prbsTxMuxData,
         ibVcCtrl          => prbsTxMuxCtrl,
         rxFrameCntEn      => rxFrameCntEn,
         rxDropCountEn     => rxDropCountEn,
         rxOverflow        => rxOverflow
      );

   U_Route: entity work.PpiRouter 
      generic map (
         TPD_G             => 1 ns,
         NUM_WRITE_SLOTS_G => 1
      ) port map (
         ppiClk              => ppiClk,
         ppiClkRst           => ppiClkRst,
         ppiOnline           => '1',
         ppiReadToFifo       => ppiReadToFifo,
         ppiReadFromFifo     => ppiReadFromFifo,
         ppiWriteToFifo(0)   => ppiWriteToFifo,
         ppiWriteFromFifo(0) => ppiWriteFromFifo
      );

   U_VcTx: entity work.PpiVcOb 
      generic map (
         TPD_G              => 1 ns,
         VC_WIDTH_G         => 16,
         VC_COUNT_G         => 4,
         PPI_ADDR_WIDTH_G   => 9,
         PPI_PAUSE_THOLD_G  => 255,
         PPI_READY_THOLD_G  => 0
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => '1',
         ppiWriteToFifo    => ppiWriteToFifo,
         ppiWriteFromFifo  => ppiWriteFromFifo,
         obVcClk           => pgpClk,
         obVcClkRst        => pgpClkRst,
         obVcData          => prbsRxDataCommon,
         obVcCtrl          => prbsRxCtrl,
         remOverflow       => open,
         txFrameCntEn      => txFrameCntEn
      );


   -- Decode common VC
   process ( prbsRxDataCommon ) begin
      prbsRxData <= vc64DeMux(prbsRxDataCommon,4);
   end process;

   -- PRBS receiver
   U_RxGen: for i in 0 to 3 generate 
      U_Vc64PrbsRx: entity work.Vc64PrbsRx 
         generic map (
            TPD_G              => 1 ns,
            LANE_NUMBER_G      => 0,
            VC_NUMBER_G        => i,
            RST_ASYNC_G        => false,
            ALTERA_SYN_G       => false,
            ALTERA_RAM_G       => "M9K",
            XIL_DEVICE_G       => "7SERIES",  --Xilinx only generic parameter    
            BRAM_EN_G          => true,
            USE_BUILT_IN_G     => false,  --if set to true, this module is only Xilinx compatible only!!!
            GEN_SYNC_FIFO_G    => false,
            PIPE_STAGES_G      => 0,
            FIFO_SYNC_STAGES_G => 3,
            FIFO_ADDR_WIDTH_G  => 9,
            FIFO_AFULL_THRES_G => 256     -- Almost full at 1/2 capacity
         ) port map (
            vcRxData             => prbsRxData(i),
            vcRxCtrl             => prbsRxCtrl(i),
            vcRxClk              => pgpClk,
            vcRxRst              => pgpClkRst,
            vcTxCtrl             => VC64_CTRL_FORCE_C,
            vcTxData             => open,
            vcTxClk              => pgpClk,
            vcTxRst              => pgpClkRst,
            updatedResults       => updatedResults(i),
            busy                 => open,
            errMissedPacket      => errMissedPacket(i),
            errLength            => errLength(i),
            errEofe              => errEofe(i),
            errWordCnt           => errWordCnt(i),
            errbitCnt            => errbitCnt(i),
            packetRate           => packetRate(i),
            packetLength         => packetLength(i)
         ); 
   end generate;

end tb;

