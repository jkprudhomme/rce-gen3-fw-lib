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

   signal ppiClk           : sl;
   signal ppiClkRst        : sl;
   signal pgpRxClk         : sl;
   signal pgpRxClkRst      : sl;
   signal pgpTxClk         : sl;
   signal pgpTxClkRst      : sl;
   signal ppiReadToFifo    : PpiReadToFifoType;
   signal ppiReadFromFifo  : PpiReadFromFifoType;
   signal ppiWriteToFifo   : PpiWriteToFifoType;
   signal ppiWriteFromFifo : PpiWriteFromFifoType;
   signal vcRxCommonOut    : VcRxCommonOutType;
   signal vcRxQuadOut      : VcRxQuadOutType;
   signal locBuffFull      : sl;
   signal locBuffAFull     : sl;
   signal remBuffFull      : slv(3 downto 0);
   signal remBuffAFull     : slv(3 downto 0);
   signal rxFrameCntEn     : sl;
   signal rxDropCountEn    : sl;
   signal rxOverflow       : sl;
   signal vcTxQuadIn       : VcTxQuadInType;
   signal vcTxQuadOut      : VcTxQuadOutType;
   signal tvcTxQuadIn      : VcTxQuadInType;
   signal tvcTxQuadOut     : VcTxQuadOutType;
   signal txFrameCntEn     : sl;
   signal enable           : sl;
   signal gapReg           : slv(3 downto 0);
   signal gapDly           : slv(3 downto 0);

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
      pgpRxClk <= '1';
      wait for 5 ns;
      pgpRxClk <= '0';
      wait for 5 ns;
   end process;

   process begin
      pgpRxClkRst <= '1';
      wait for (50 ns);
      pgpRxClkRst <= '0';
      wait;
   end process;

   process begin
      pgpTxClk <= '1';
      wait for 4 ns;
      pgpTxClk <= '0';
      wait for 4 ns;
   end process;

   process begin
      pgpTxClkRst <= '1';
      wait for (50 ns);
      pgpTxClkRst <= '0';
      wait;
   end process;

   process begin
      enable <= '0';
      wait for (1 us);
      enable <= '1';
      wait;
   end process;


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

   U_VcRx: entity work.PpiVcRx 
      generic map (
         TPD_G                => 1 ns,
         VC_WIDTH_G           => 1,
         PPI_ADDR_WIDTH_G     => 9,
         PPI_PAUSE_THOLD_G    => 255,
         PPI_READY_THOLD_G    => 0,
         PPI_MAX_FRAME_G      => 511,
         HEADER_ADDR_WIDTH_G  => 8,
         HEADER_AFULL_THOLD_G => 100,
         HEADER_FULL_THOLD_G  => 150,
         DATA_ADDR_WIDTH_G    => 9,
         DATA_AFULL_THOLD_G   => 200,
         DATA_FULL_THOLD_G    => 400
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => '1',
         ppiReadToFifo     => ppiReadToFifo,
         ppiReadFromFifo   => ppiReadFromFifo,
         vcRxClk           => pgpRxClk,
         vcRxClkRst        => pgpRxClkRst,
         vcRxCommonOut     => vcRxCommonOut,
         vcRxQuadOut       => vcRxQuadOut,
         locBuffFull       => locBuffFull,
         locBuffAFull      => locBuffAFull,
         remBuffFull       => remBuffFull,
         remBuffAFull      => remBuffAFull,
         rxFrameCntEn      => rxFrameCntEn,
         rxDropCountEn     => rxDropCountEn,
         rxOverflow        => rxOverflow
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
         vcTxClk           => pgpTxClk,
         vcTxClkRst        => pgpTxClkRst,
         vcTxQuadIn        => vcTxQuadIn,
         vcTxQuadOut       => vcTxQuadOut,
         locBuffFull       => locBuffFull,
         locBuffAFull      => locBuffAFull,
         remBuffFull       => remBuffFull,
         remBuffAFull      => remBuffAFull,
         txFrameCntEn      => txFrameCntEn
      );

   -- Transmit data on VCs
   U_LoopGen : for j in 0 to 3 generate
      tvcTxQuadIn(j).locBuffAFull <= '0';
      tvcTxQuadIn(j).locBuffFull  <= '0';
      tvcTxQuadIn(j).eofe         <= '0';
      tvcTxQuadIn(j).valid        <= '0' when gapReg(j) = '1' and gapDly(j) = '0' else enable;
      tvcTxQuadIn(j).sof          <= '1' when tvcTxQuadIn(j).data(0) = 0    else '0';
      tvcTxQuadIn(j).eof          <= '1' when tvcTxQuadIn(j).data(0) = 1500 else '0';
      tvcTxQuadIn(j).data(1 to 3) <= (others=>(others=>'0'));
      vcTxQuadOut(j).ready        <= '1';

      process ( pgpRxClk ) begin
         if rising_edge(pgpRxClk) then
            if pgpRxClkRst = '1' then
               tvcTxQuadIn(j).data(0)  <= (others=>'0') after 1 ns;
               gapReg(j) <= '0' after 1 ns;
               gapDly(j) <= '0' after 1 ns;
            else

               if tvcTxQuadIn(j).data(0)(6) = '1' then
                  gapReg(j) <= '1';
               else
                  gapReg(j) <= '0';
               end if;
               gapDly(j) <= gapReg(j) after 1 ns;

               if tvcTxQuadOut(j).ready = '1' and tvcTxQuadIn(j).valid = '1' then
                  if tvcTxQuadIn(j).data(0) = 1500 then
                     tvcTxQuadIn(j).data(0) <= (others=>'0') after 1 ns;
                  else
                     tvcTxQuadIn(j).data(0) <= tvcTxQuadIn(j).data(0)  + 1 after 1 ns;
                  end if;
               end if;
       
            end if;
         end if;
      end process;
   end generate;

   U_Adapt : entity work.VcAdapter 
      generic map (
         TPD_G => 1 ns
      ) port map (
         vcClk          => pgpRxClk,
         vcClkRst       => pgpRxClkRst,
         vcTxQuadIn     => tvcTxQuadIn,
         vcTxQuadOut    => tvcTxQuadOut,
         vcRxCommonOut  => vcRxCommonOut,
         vcRxQuadOut    => vcRxQuadOut
      );



end tb;

