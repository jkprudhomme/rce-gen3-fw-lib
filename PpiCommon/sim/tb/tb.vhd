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
use work.VcPkg.all;

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
   signal vcRxCommonOut     : VcRxCommonOutType;
   signal vcRxQuadOut       : VcRxQuadOutType;
   signal prbsVcRxCommonOut : VcRxCommonOutType;
   signal prbsVcRxQuadOut   : VcRxQuadOutType;
   signal rxFrameCntEn      : sl;
   signal rxDropCountEn     : sl;
   signal rxOverflow        : sl;
   signal vcTxQuadIn        : VcTxQuadInType;
   signal vcTxQuadOut       : VcTxQuadOutType;
   signal prbsVcTxQuadIn    : VcTxQuadInType;
   signal prbsVcTxQuadOut   : VcTxQuadOutType;
   signal txFrameCntEn      : sl;
   signal updatedResults    : slv(3 downto 0);
   signal errMissedPacket   : slv(3 downto 0);
   signal errLength         : slv(3 downto 0);
   signal errEofe           : slv(3 downto 0);
   signal errWordCnt        : Slv32Array(3 downto 0);
   signal errbitCnt         : Slv32Array(3 downto 0);
   signal packetRate        : Slv32Array(3 downto 0);
   signal packetLength      : Slv32Array(3 downto 0);
   signal prbsRxBuffFull    : slv(3 downto 0);
   signal prbsRxBuffAFull   : slv(3 downto 0);
   signal prbsTxBuffFull    : sl;
   signal prbsTxBuffAFull   : sl;
   signal prbsTxVcRxOut     : VcRxOutType;
   signal enable            : sl;
   signal txEnable          : slv(3  downto 0);
   signal txBusy            : slv(3  downto 0);
   signal txLength          : Slv32Array(3 downto 0);

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
      U_VcPrbsTx : entity work.VcPrbsTx 
         generic map (
            TPD_G              => 1 ns,
            RST_ASYNC_G        => false,
            GEN_SYNC_FIFO_G    => false,
            BRAM_EN_G          => true,
            FIFO_ADDR_WIDTH_G  => 9,
            USE_DSP48_G        => "no",
            ALTERA_SYN_G       => false,
            ALTERA_RAM_G       => "M9K",
            USE_BUILT_IN_G     => false,  --if set to true, this module is only Xilinx compatible only!!!
            LITTLE_ENDIAN_G    => false,
            XIL_DEVICE_G       => "7SERIES",  --Xilinx only generic parameter    
            FIFO_SYNC_STAGES_G => 3,
            FIFO_INIT_G        => "0",
            FIFO_FULL_THRES_G  => 256,    -- Almost full at 1/2 capacity
            FIFO_EMPTY_THRES_G => 0
         ) port map (
            trig         => txEnable(i),
            packetLength => txLength(i),
            busy         => txBusy(i),
            vcTxIn       => prbsVcTxQuadIn(i),
            vcTxOut      => prbsVcTxQuadOut(i),
            vcRxOut      => prbsTxVcRxOut,
            locClk       => pgpClk,
            locRst       => pgpClkRst,
            vcTxClk      => pgpClk,
            vcTxRst      => pgpClkRst
         );


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
   end generate;

   process ( prbsTxBuffFull, prbsTxBuffAFull ) begin
      prbsTxVcRxOut              <= VC_RX_OUT_INIT_C;
      prbsTxVcRxOut.remBuffFull  <= prbsTxBuffFull;
      prbsTxVcRxOut.remBuffAFull <= prbsTxBuffAFull;
   end process;

   U_TxAdapt : entity work.VcAdapter 
      generic map (
         TPD_G => 1 ns
      ) port map (
         vcClk          => pgpClk,
         vcClkRst       => pgpClkRst,
         vcTxQuadIn     => prbsVcTxQuadIn,
         vcTxQuadOut    => prbsVcTxQuadOut,
         vcRxCommonOut  => vcRxCommonOut,
         vcRxQuadOut    => vcRxQuadOut
      );

   U_VcRx: entity work.PpiVcRx 
      generic map (
         TPD_G                => 1 ns,
         VC_WIDTH_G           => 1,
         PPI_ADDR_WIDTH_G     => 9,
         PPI_PAUSE_THOLD_G    => 255,
         PPI_READY_THOLD_G    => 0,
         PPI_MAX_FRAME_G      => 1023,
         HEADER_ADDR_WIDTH_G  => 8,
         HEADER_AFULL_THOLD_G => 100,
         HEADER_FULL_THOLD_G  => 150,
         DATA_ADDR_WIDTH_G    => 10,
         DATA_AFULL_THOLD_G   => 520,
         DATA_FULL_THOLD_G    => 750
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => '1',
         ppiReadToFifo     => ppiReadToFifo,
         ppiReadFromFifo   => ppiReadFromFifo,
         vcRxClk           => pgpClk,
         vcRxClkRst        => pgpClkRst,
         vcRxCommonOut     => vcRxCommonOut,
         vcRxQuadOut       => vcRxQuadOut,
         locBuffFull       => prbsTxBuffFull,
         locBuffAFull      => prbsTxbuffAFull,
         remBuffFull       => open,
         remBuffAFull      => open,
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

   U_VcTx: entity work.PpiVcTx 
      generic map (
         TPD_G              => 1 ns,
         VC_WIDTH_G         => 1,
         PPI_ADDR_WIDTH_G   => 9,
         PPI_PAUSE_THOLD_G  => 255,
         PPI_READY_THOLD_G  => 0
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => '1',
         ppiWriteToFifo    => ppiWriteToFifo,
         ppiWriteFromFifo  => ppiWriteFromFifo,
         vcTxClk           => pgpClk,
         vcTxClkRst        => pgpClkRst,
         vcTxQuadIn        => vcTxQuadIn,
         vcTxQuadOut       => vcTxQuadOut,
         locBuffFull       => '0',
         locBuffAFull      => '0',
         remBuffFull       => prbsRxBuffFull,
         remBuffAFull      => prbsRxBuffAFull,
         txFrameCntEn      => txFrameCntEn
      );

   U_RxAdapt : entity work.VcAdapter 
      generic map (
         TPD_G => 1 ns
      ) port map (
         vcClk          => pgpClk,
         vcClkRst       => pgpClkRst,
         vcTxQuadIn     => vcTxQuadIn,
         vcTxQuadOut    => VcTxQuadOut,
         vcRxCommonOut  => prbsVcRxCommonOut,
         vcRxQuadOut    => prbsVcRxQuadOut
      );

   U_RxGen: for i in 0 to 3 generate 
      U_VcPrbsRx: entity work.VcPrbsRx 
         generic map (
            TPD_G              => 1 ns,
            LANE_NUMBER_G      => 0,
            VC_NUMBER_G        => i,
            RST_ASYNC_G        => false,
            GEN_SYNC_FIFO_G    => false,
            BRAM_EN_G          => true,
            FIFO_ADDR_WIDTH_G  => 9,
            USE_DSP48_G        => "no",
            ALTERA_SYN_G       => false,
            ALTERA_RAM_G       => "M9K",
            USE_BUILT_IN_G     => false,  --if set to true, this module is only Xilinx compatible only!!!
            LITTLE_ENDIAN_G    => false,
            XIL_DEVICE_G       => "7SERIES",  --Xilinx only generic parameter    
            FIFO_SYNC_STAGES_G => 3,
            FIFO_INIT_G        => "0",
            FIFO_FULL_THRES_G  => 256,    -- Almost full at 1/2 capacity
            FIFO_EMPTY_THRES_G => 0
         ) port map (
            vcRxOut              => prbsVcRxQuadOut(i),
            vcRxCommonOut        => prbsVcRxCommonOut,
            vcTxIn_locBuffAFull  => prbsRxBuffAFull(i),
            vcTxIn_locBuffFull   => prbsRxBuffFull(i),
            vcTxIn               => open,
            vcTxOut              => (others => '1'),
            vcRxOut_remBuffAFull => '0',
            vcRxOut_remBuffFull  => '0',
            updatedResults       => updatedResults(i),
            busy                 => open,
            errMissedPacket      => errMissedPacket(i),
            errLength            => errLength(i),
            errEofe              => errEofe(i),
            errWordCnt           => errWordCnt(i),
            errbitCnt            => errbitCnt(i),
            packetRate           => packetRate(i),
            packetLength         => packetLength(i),
            vcRxClk              => pgpClk,
            vcRxRst              => pgpClkRst,
            vcTxClk              => pgpClk,
            vcTxRst              => pgpClkRst
         ); 
   end generate;

end tb;

