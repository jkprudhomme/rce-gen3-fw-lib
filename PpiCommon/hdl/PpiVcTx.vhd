-------------------------------------------------------------------------------
-- Title         : PPI To VC Block, Data Transmit
-- File          : PpiVcTx.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to transmit VC Frames.
-- First word of PPI frame contains control data:
--    Bits 07:00 = VC
--    Bits 15:08 = Lane (ignored)
--    Bits 16    = SOF
--    Bits 17    = EOF
--    Bits 18    = EOFE
--    Bits 63:19 = Ignored
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/21/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.VcPkg.all;

entity PpiVcTx is
   generic (
      TPD_G              : time := 1 ns;
      VC_WIDTH_G         : integer range 1 to 4 := 1;-- 3 not allowed
      PPI_ADDR_WIDTH_G   : integer range 2 to 48      := 9;
      PPI_PAUSE_THOLD_G  : integer range 2 to (2**24) := 255;
      PPI_READY_THOLD_G  : integer range 0 to 511     := 0
   );
   port (

      -- PPI Interface
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;
      ppiWriteToFifo   : in  PpiWriteToFifoType;
      ppiWriteFromFifo : out PpiWriteFromFifoType;

      -- TX VC Interface
      vcTxClk          : in  sl;
      vcTxClkRst       : in  sl;
      vcTxQuadIn       : out VcTxQuadInType;
      vcTxQuadOut      : in  VcTxQuadOutType;
 
      -- Flow control from PpiVcRx block
      locBuffFull      : in  sl; -- Routed to vcTxQuadIn record
      locBuffAFull     : in  sl; -- Routed to vcTxQuadIn record
      remBuffFull      : in  slv(3 downto 0); -- For local flow control
      remBuffAFull     : in  slv(3 downto 0); -- For local flow control

      -- Frame Counter
      txFrameCntEn     : out sl
   );

begin
   assert (VC_WIDTH_G /= 3) report "VC_WIDTH_G must not be = 3" severity failure;
end PpiVcTx;

architecture structure of PpiVcTx is

   -- Local signals
   signal intReadToFifo    : PpiReadToFifoType;
   signal intReadFromFifo  : PpiReadFromFifoType;
   signal intOnline        : sl;
   signal ilocBuffFull     : sl;
   signal ilocBuffAFull    : sl;
   signal iremBuffFull     : slv(3 downto 0);
   signal iremBuffAFull    : slv(3 downto 0);

   type StateType is (S_IDLE, S_FIRST, S_DATA, S_LAST);

   type RegType is record
      state          : StateType;
      pos            : slv(1 downto 0);
      vc             : slv(1 downto 0);
      sof            : sl;
      eof            : sl;
      eofe           : sl;
      txFrameCntEn   : sl;
      ppiReadToFifo  : PpiReadToFifoType;
      vcTxQuadIn     : VcTxQuadInType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => S_IDLE,
      pos            => (others=>'0'),
      vc             => (others=>'0'),
      sof            => '0',
      eof            => '0',
      eofe           => '0',
      txFrameCntEn   => '0',
      ppiReadToFifo  => PpiReadToFifoInit,
      vcTxQuadIn     => VC_TX_QUAD_IN_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   ------------------------------------
   -- Sync Flow Control
   ------------------------------------

   U_FcSyncA : entity work.Synchronizer 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         INIT_G         => "0"
      ) port map (
         clk     => vcTxClk,
         rst     => vcTxClkRst,
         dataIn  => locBuffFull,
         dataOut => ilocBuffFull
      );

   U_FcSyncB : entity work.Synchronizer 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         INIT_G         => "0"
      ) port map (
         clk     => vcTxClk,
         rst     => vcTxClkRst,
         dataIn  => locBuffAFull,
         dataOut => ilocBuffAFull
      );

   U_RxSyncGen : for i in 0 to 3 generate

      U_FcSyncC : entity work.Synchronizer 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            OUT_POLARITY_G => '1',
            RST_ASYNC_G    => false,
            STAGES_G       => 2,
            INIT_G         => "0"
         ) port map (
            clk     => vcTxClk,
            rst     => vcTxClkRst,
            dataIn  => remBuffFull(i),
            dataOut => iremBuffFull(i)
         );

      U_FcSyncD : entity work.Synchronizer 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            OUT_POLARITY_G => '1',
            RST_ASYNC_G    => false,
            STAGES_G       => 2,
            INIT_G         => "0"
         ) port map (
            clk     => vcTxClk,
            rst     => vcTxClkRst,
            dataIn  => remBuffFull(i),
            dataOut => iremBuffAFull(i)
         );
   end generate;


   ------------------------------------
   -- FIFO
   ------------------------------------

   U_InFifo : entity work.PpiFifoAsync
      generic map (
         TPD_G              => TPD_G,
         BRAM_EN_G          => true,
         USE_DSP48_G        => "no",
         SYNC_STAGES_G      => 3,
         ADDR_WIDTH_G       => PPI_ADDR_WIDTH_G,
         PAUSE_THOLD_G      => PPI_PAUSE_THOLD_G,
         READY_THOLD_G      => PPI_READY_THOLD_G,
         FIFO_TYPE_EN_G     => false
      ) port map (
         ppiWrClk         => ppiClk,
         ppiWrClkRst      => ppiClkRst,
         ppiWrOnline      => ppiOnline,
         ppiWriteToFifo   => ppiWriteToFifo,
         ppiWriteFromFifo => ppiWriteFromFifo,
         ppiRdClk         => vcTxClk,
         ppiRdClkRst      => vcTxClkRst,
         ppiRdOnline      => intOnline,
         ppiReadToFifo    => intReadToFifo,
         ppiReadFromFifo  => intReadFromFifo
      );


   ------------------------------------
   -- Data Mover
   ------------------------------------

   -- Sync
   process (vcTxClk) is
   begin
      if (rising_edge(vcTxClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (vcTxClkRst, r, intReadFromFifo, vcTxQuadOut, ilocBuffAFull, ilocBuffFull, 
            iremBuffAFull, iremBuffFull, intOnline ) is
      variable v         : RegType;
      variable nextData  : slv(63 downto 0);
      variable nextEof   : sl;
      variable nextPos   : slv(1 downto 0);
      variable nextRead  : sl;
   begin
      v := r;

      -- Init
      v.ppiReadToFifo.read := '0';
      v.txFrameCntEn       := '0';

      -- Init valid signals and flow control
      for i in 0 to 3 loop
         v.vcTxQuadIn(i).valid        := '0';
         v.vcTxQuadIn(i).locBuffAFull := ilocBuffAFull;
         v.vcTxQuadIn(i).locBuffFull  := ilocBuffFull;
      end loop;

      -- Determine data alignment and EOF
      nextData := (others=>'0');
      nextEof  := '0';
      nextPos  := "00";
      nextRead := '0';

      case VC_WIDTH_G is

         -- 16 bit VC
         when 1 =>
            case r.pos is
               when "00" =>
                  nextData := x"000000000000" & intReadFromFifo.data(15 downto 0); -- 0/1
                  nextEof  := ite(intReadFromFifo.eof = '1' and intReadFromFifo.size <= 1,'1','0');
                  nextRead := nextEof;
                  nextPos  := "01";
               when "01" =>
                  nextData := x"000000000000" & intReadFromFifo.data(31 downto 16); -- 2/3
                  nextEof  := ite(intReadFromFifo.eof = '1' and intReadFromFifo.size <= 3,'1','0');
                  nextRead := nextEof;
                  nextPos  := "10";
               when "10" =>
                  nextData := x"000000000000" & intReadFromFifo.data(47 downto 32); -- 4/5
                  nextEof  := ite(intReadFromFifo.eof = '1' and intReadFromFifo.size <= 5,'1','0');
                  nextRead := nextEof;
                  nextPos  := "11";
               when "11" =>
                  nextData := x"000000000000" & intReadFromFifo.data(63 downto 48); -- 6/7
                  nextEof  := intReadFromFifo.eof;
                  nextRead := '1';
                  nextPos  := "00";
               when others => null;
            end case;

         -- 32 bit VC
         when 2 =>
            case r.pos is
               when "00" =>
                  nextData := x"00000000" & intReadFromFifo.data(31 downto 0); -- 0/1/2/3
                  nextEof  := ite(intReadFromFifo.eof = '1' and intReadFromFifo.size <= 3,'1','0');
                  nextRead := nextEof;
                  nextPos  := "10";
               when "10" =>
                  nextData := x"00000000" & intReadFromFifo.data(63 downto 32); -- 4/5/6/7
                  nextEof  := intReadFromFifo.eof;
                  nextRead := '1';
                  nextPos  := "00";
               when others => null;
            end case;

         -- 64 bit VC
         when 4 =>
            nextData := intReadFromFifo.data;
            nextEof  := intReadFromFifo.eof;
            nextRead := '1';
         when others => null;
      end case;

      -- State Machine
      case r.state is

         -- Idle
         when S_IDLE =>
            if intReadFromFifo.valid = '1' and intReadFromFifo.ready = '1' then
               v.vc                 := intReadFromFifo.data(1 downto 0);
               v.sof                := intReadFromFifo.data(16);
               v.eof                := intReadFromFifo.data(17);
               v.eofe               := intReadFromFifo.data(18);
               v.ppiReadToFifo.read := '1';
               v.pos                := "00";

               -- Not Bad frame, otherwise skip
               if intReadFromFifo.eof /= '1' then
                  v.state := S_FIRST;
               end if;
            end if;

         -- First, put data onto interface
         when S_FIRST =>

            v.vcTxQuadIn(conv_integer(r.vc)).sof     := r.sof;
            v.vcTxQuadIn(conv_integer(r.vc)).data(0) := nextData(15 downto  0);
            v.vcTxQuadIn(conv_integer(r.vc)).data(1) := nextData(31 downto 16);
            v.vcTxQuadIn(conv_integer(r.vc)).data(2) := nextData(47 downto 32);
            v.vcTxQuadIn(conv_integer(r.vc)).data(3) := nextData(63 downto 48);

            v.vcTxQuadIn(conv_integer(r.vc)).valid := (not iremBuffAFull(conv_integer(r.vc)));

            v.ppireadToFifo.read := nextRead;
            v.pos := nextPos;

            if nextEof = '1' then
               v.vcTxQuadIn(conv_integer(r.vc)).eof  := r.eof;
               v.vcTxQuadIn(conv_integer(r.vc)).eofe := r.eofe;
               v.state := S_LAST;
            else
               v.vcTxQuadIn(conv_integer(r.vc)).eof  := '0';
               v.vcTxQuadIn(conv_integer(r.vc)).eofe := '0';
               v.state := S_DATA;
            end if;

         -- Normal Data
         when S_DATA =>
            v.vcTxQuadIn(conv_integer(r.vc)).valid := (not iremBuffFull(conv_integer(r.vc)));

            if vcTxQuadOut(conv_integer(r.vc)).ready = '1' and r.vcTxQuadIn(conv_integer(r.vc)).valid = '1' then
               v.vcTxQuadIn(conv_integer(r.vc)).sof     := '0';
               v.vcTxQuadIn(conv_integer(r.vc)).data(0) := nextData(15 downto  0);
               v.vcTxQuadIn(conv_integer(r.vc)).data(1) := nextData(31 downto 16);
               v.vcTxQuadIn(conv_integer(r.vc)).data(2) := nextData(47 downto 32);
               v.vcTxQuadIn(conv_integer(r.vc)).data(3) := nextData(63 downto 48);

               v.ppireadToFifo.read := nextRead;
               v.pos := nextPos;

               if nextEof = '1' then
                  v.vcTxQuadIn(conv_integer(r.vc)).eof  := r.eof;
                  v.vcTxQuadIn(conv_integer(r.vc)).eofe := r.eofe;
                  v.state := S_LAST;
               end if;
            end if;

         -- Last Transfer
         when S_LAST =>
            if vcTxQuadOut(conv_integer(r.vc)).ready = '1' then

               if r.vcTxQuadIn(conv_integer(r.vc)).eof = '1' then
                  v.txFrameCntEn := '1';
               end if;

               v.vcTxQuadIn(conv_integer(r.vc)).valid := '0';

               v.state := S_IDLE;
            else
               v.vcTxQuadIn(conv_integer(r.vc)).valid := '1';
            end if;

         when others =>
            v.state := S_IDLE;

      end case;

      -- Reset
      if vcTxClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      intReadToFifo <= v.ppiReadToFifo;
      vcTxQuadIn    <= r.vcTxQuadIn;
      txFrameCntEn  <= r.txFrameCntEn;

   end process;

end architecture structure;

