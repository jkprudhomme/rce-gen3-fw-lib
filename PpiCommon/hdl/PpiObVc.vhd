-------------------------------------------------------------------------------
-- Title         : PPI To VC Block, Outbound Transmit.
-- File          : PpiObVc.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to transmit outbound VC Frames.
-- First word of PPI frame contains control data:
--    Bits 03:00 = VC
--    Bits 8     = SOF
--    Bits 9     = EOF
--    Bits 10    = EOFE
--    Bits 63:11 = Ignored
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

entity PpiObVc is
   generic (
      TPD_G              : time := 1 ns;
      VC_WIDTH_G         : integer range 16 to 64     := 16;  -- 16, 32 or 64
      VC_COUNT_G         : integer range 1  to 16     := 4;   -- Number of VCs
      PPI_ADDR_WIDTH_G   : integer range 2 to 48      := 9;   -- (2**9) * 64 bits = 4096 bytes
      PPI_PAUSE_THOLD_G  : integer range 2 to (2**24) := 256; -- 256 * 64 bits = 2048 bytes
      PPI_READY_THOLD_G  : integer range 0 to 511     := 0    -- 0 * 64 bits = 0 bytes
   );
   port (

      -- PPI Interface
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;
      ppiWriteToFifo   : in  PpiWriteToFifoType;
      ppiWriteFromFifo : out PpiWriteFromFifoType;

      -- TX VC Interface
      obVcClk          : in  sl;
      obVcClkRst       : in  sl;
      obVcData         : out VcStreamDataType;
      obVcCtrl         : in  VcStreamCtrlArray(VC_COUNT_G-1 downto 0);

      -- Frame Counter
      txFrameCntEn     : out sl
   );

begin
   assert (VC_WIDTH_G /= 3) report "VC_WIDTH_G must not be = 3" severity failure;
end PpiObVc;

architecture structure of PpiObVc is

   -- Local signals
   signal intReadToFifo    : PpiReadToFifoType;
   signal intReadFromFifo  : PpiReadFromFifoType;
   signal intOnline        : sl;
   signal intVcCtrl        : VcStreamCtrlArray(15 downto 0);

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
      obVcData       : VcTxQuadInType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => S_IDLE,
      pos            => (others=>'0'),
      vc             => (others=>'0'),
      sof            => '0',
      eof            => '0',
      eofe           => '0',
      txFrameCntEn   => '0',
      ppiReadToFifo  => PPI_READ_TO_FIFO_INIT_C,
      obVcData       => VC_STREAM_DATA_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   ------------------------------------
   -- Connect VC control
   ------------------------------------
   intVcCtrl(VC_COUNT_G-1 downto 0) <= obVcCtrl;

   U_CtrlGen: if VC_COUNT_G /= 16 generate
      process ( obVcCtrl ) begin
         for i in VC_COUNT_G to VC_COUNT_G-1 loop
            intVcCtrl(i).full       <= '0';
            intVcCtrl(i).almostFull <= '0';
            intVcCtrl(i).ready      <= '1';
         end loop;
      end process;
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
         ppiRdClk         => obVcClk,
         ppiRdClkRst      => obVcClkRst,
         ppiRdOnline      => intOnline,
         ppiReadToFifo    => intReadToFifo,
         ppiReadFromFifo  => intReadFromFifo
      );


   ------------------------------------
   -- Data Mover
   ------------------------------------

   -- Sync
   process (obVcClk) is
   begin
      if (rising_edge(obVcClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (obVcClkRst, r, intReadFromFifo, intVcCtrl, intOnline ) is
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

      -- Init valid signal
      v.obVcData.valid := '0';

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
               v.vc                 := intReadFromFifo.data(3 downto 0);
               v.sof                := intReadFromFifo.data(8);
               v.eof                := intReadFromFifo.data(9);
               v.eofe               := intReadFromFifo.data(10);
               v.ppiReadToFifo.read := '1';
               v.pos                := "00";

               -- Not Bad frame, otherwise skip
               if intReadFromFifo.eof /= '1' then
                  v.state := S_FIRST;
               end if;
            end if;

         -- First, put data onto interface
         when S_FIRST =>
            v.obVcData.sof       := r.sof;
            v.obVcData.data      := nextData;
            v.obVcData.valid     := (not intVcCtrl(conv_integer(r.vc)).almostFull);
            v.obVcData.vc        := r.vc;
            v.ppireadToFifo.read := nextRead;
            v.pos                := nextPos;

            if nextEof = '1' then
               v.obVcData.eof  := r.eof;
               v.obVcData.eofe := r.eofe;
               v.state         := S_LAST;
            else
               v.obVcData.eof  := '0';
               v.obVcData.eofe := '0';
               v.state         := S_DATA;
            end if;

         -- Normal Data
         when S_DATA =>
            v.obVcData.valid := (not intVcCtrl(conv_integer(r.vc)).full);

            if intVcCtrl(conv_integer(r.vc)).ready = '1' and r.obVcData.valid = '1' then
               v.obVcData.sof       := '0';
               v.obVcData.data      := nextData;
               v.ppireadToFifo.read := nextRead;
               v.pos                := nextPos;

               if nextEof = '1' then
                  v.obVcData.eof  := r.eof;
                  v.obVcData.eofe := r.eofe;
                  v.state         := S_LAST;
               end if;
            end if;

         -- Last Transfer
         when S_LAST =>
            if intVcCtrl(conv_integer(r.vc)).ready = '1' then
               v.txFrameCntEn   := r.obVcDdata.eof;
               v.obVcData.valid := '0';
               v.state          := S_IDLE;
            end if;

         when others =>
            v.state := S_IDLE;

      end case;

      -- Reset
      if obVcClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      intReadToFifo <= v.ppiReadToFifo;
      obVcData      <= r.obVcData;
      txFrameCntEn  <= r.txFrameCntEn;

   end process;

end architecture structure;

