-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block
-- File          : PpiPgpArray.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive and transmit PGP Frames.
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
use work.AxiLitePkg.all;
use work.Vc64Pkg.all;
use work.Pgp2bPkg.all;

entity PpiPgpArray is
   generic (
      TPD_G                : time                       := 1 ns;
      NUM_LANES_G          : integer range 1  to 12     := 12;
      VC_WIDTH_G           : integer range 16 to 64     := 16;   -- Bits: 16, 32 or 64
      PPI_ADDR_WIDTH_G     : integer range 2 to 48      := 9;    -- (2**9) * 64bits = 4096 bytes
      PPI_PAUSE_THOLD_G    : integer range 2 to (2**24) := 256;  -- 256 * 64bits = 2048 bytes
      PPI_READY_THOLD_G    : integer range 0 to 511     := 0;    -- 0 * 64bits = 0 bytes
      PPI_MAX_FRAME_G      : integer range 1 to (2**12) := 1024; -- 1024 bytes
      HEADER_ADDR_WIDTH_G  : integer range 2 to 48      := 8;    -- (2**8) = 256 headers
      HEADER_AFULL_THOLD_G : integer range 1 to (2**24) := 100;  -- 100 headers
      DATA_ADDR_WIDTH_G    : integer range 1 to 48      := 10;   -- (2**10) * 16bits(VC_WIDTH_G) = 2048 bytes
      DATA_AFULL_THOLD_G   : integer range 1 to (2**24) := 520   -- 520 * 16bits(VC_WIDTH_G) = 1040 Bytes
   );
   port (

      -- PPI Interface
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;
      ppiWriteToFifo   : in  PpiWriteToFifoType;
      ppiWriteFromFifo : out PpiWriteFromFifoType;
      ppiReadToFifo    : in  PpiReadToFifoType;
      ppiReadFromFifo  : out PpiReadFromFifoType;

      -- TX PGP Interfaces
      pgpTxClk         : in  slv(NUM_LANES_G-1 downto 0);
      pgpTxClkRst      : in  slv(NUM_LANES_G-1 downto 0);
      pgpTxSwRst       : out slv(NUM_LANES_G-1 downto 0);
      pgpTxIn          : out PgpTxInArray(NUM_LANES_G-1 downto 0);
      pgpTxOut         : in  PgpTxOutArray(NUM_LANES_G-1 downto 0);
      pgpTxData        : out Vc64DataArray(NUM_LANES_G*4-1 downto 0); -- 4 per Tx Lane
      pgpTxCtrl        : in  Vc64CtrlArray(NUM_LANES_G*4-1 downto 0); -- 4 per Tx Lane

      -- RX PGP Interfaces
      pgpRxClk         : in  slv(NUM_LANES_G-1 downto 0);
      pgpRxClkRst      : in  slv(NUM_LANES_G-1 downto 0);
      pgpRxSwRst       : out slv(NUM_LANES_G-1 downto 0);
      pgpRxIn          : out PgpRxInArray(NUM_LANES_G-1 downto 0);
      pgpRxOut         : in  PgpRxOutArray(NUM_LANES_G-1 downto 0);
      pgpRxData        : in  Vc64DataArray(NUM_LANES_G-1 downto 0);   -- Multiplexed RX, 4 VCs
      pgpRxCtrl        : out Vc64CtrlArray(NUM_LANES_G*4-1 downto 0); -- 4 per Rx Lane
      loopBackEn       : out slv(NUM_LANES_G-1 downto 0);

      -- AXI/Status Clocks Interface
      axiStatClk       : in  sl;
      axiStatClkRst    : in  sl;

   );
end PpiPgpArray;

architecture structure of PpiPgpArray is

   signal intWriteToFifo   : PpiWriteToFifoArray(NUM_LANES_G-1 downto 0);
   signal intWriteFromFifo : PpiWriteFromFifoArray(NUM_LANES_G-1 downto 0);
   signal intReadToFifo    : PpiReadToFifoArray(NUM_LANES_G-1 downto 0);
   signal intReadFromFifo  : PpiReadFromFifoArray(NUM_LANES_G-1 downto 0);
   signal axiWriteMaster   : AxiLiteWriteMasterArray(NUM_LANES_G-1 downto 0);
   signal axiWriteSlave    : AxiLiteWriteSlaveArray(NUM_LANES_G-1 downto 0);
   signal axiReadMaster    : AxiLiteReadMasterArray(NUM_LANES_G-1 downto 0);
   signal axiReadSlave     : AxiLiteReadSlaveArray(NUM_LANES_G-1 downto 0);
   signal statusWords      : Slv64Array(7 downto 0);
   signal statusSend       : sl;
   signal pgpStatus        : Slv32Array(NUM_LANES_G-1 downto 0);
   signal pgpStatusSend    : slv(NUM_LANES_G-1 downto 0);
   signal intTxData        : Vc64DataArray(NUM_LANES_G-1 downto 0);
   signal intRxCtrl        : Vc64CtrlArray(NUM_LANES_G-1 downto 0);

begin

   -- PPI Crossbar
   U_PpiCrossbar : entity work.PpiCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_PPI_SLOTS_G    => NUM_LANES_G,
         NUM_AXI_SLOTS_G    => NUM_LANES_G,
         NUM_STATUS_WORDS_G => NUM_LANES_G*2
      ) port map (
         ppiClk             => sysClk200,
         ppiClkRst          => sysClk200Rst,
         ppiOnline          => ppiOnline,
         ibWriteToFifo      => ppiWriteToFifo,
         ibWriteFromFifo    => ppiWriteFromFifo,
         obReadToFifo       => ppiReadToFifo,
         obReadFromFifo     => ppiReadFromFifo,
         ibReadToFifo       => intReadToFifo,
         ibReadFromFifo     => intReadFromFifo,
         ibWriteToFifo      => intWriteToFifo,
         ibWriteFromFifo    => intWriteFromFifo,
         axiClk             => axiStatClk,
         axiClkRst          => axiStatClkRst,
         axiWriteMasters    => axiWriteMaster,
         axiWriteSlaves     => axiWriteSlave,
         axiReadMasters     => axiReadMaster,
         axiReadSlaves      => axiReadSlave,
         statusClk          => axiStatClk,
         statusClkRst       => axiStatClkRst,
         statusWords        => statusWords,
         statusSend         => statusSend
      );

   -- Combine status send
   statusSend <= uor(pgpStatusSend);

   -- Pack status words
   process ( pgpStatus ) begin
      statusWords <= (others=>(others=>'0'));

      -- Process each lane
      for i in 0 to NUM_LANES_G-1 loop
         if pgpStatusSend(i) = '1' then
            statusWords(i/2)((i rem 2)*32+31 downto (i rem 2)*32) <= pgpStatus(i);
         end if;
      end loop;
   end if;

   -- PGP Lane Controllers
   U_LaneGen : for i in 0 to NUM_LANES_G-1 generate 
      U_PpiPgpLane : entity work.PpiPgpLane 
         generic map (
            TPD_G                 => TPD_G,
            VC_WIDTH_G            => VC_WIDTH_G,
            PPI_ADDR_WIDTH_G      => PPI_ADDR_WIDTH_G,
            PPI_PAUSE_THOLD_G     => PPI_PAUSE_THOLD_G,
            PPI_READY_THOLD_G     => PPI_READY_THOLD_G,
            PPI_MAX_FRAME_G       => PPI_MAX_FRAME_G,
            HEADER_ADDR_WIDTH_G   => HEADER_ADDR_WIDTH_G,
            HEADER_AFULL_THOLD_G  => HEADER_AFULL_THOLD_G,
            DATA_ADDR_WIDTH_G     => DATA_ADDR_WIDTH_G,
            DATA_AFULL_THOLD_G    => DATA_AFULL_THOLD_G
         ) port map (
            ppiClk            => ppiClk,
            ppiClkRst         => ppiClkRst,
            ppiOnline         => ppiOnline,
            ppiWriteToFifo    => intWriteToFifo(i),
            ppiWriteFromFifo  => intWriteFromFifo(i),
            ppiReadToFifo     => intReadToFifo(i),
            ppiReadFromFifo   => intReadFromFifo(i),
            pgpTxClk          => pgpTxClk(i),
            pgpTxClkRst       => pgpTxClkRst(i),
            pgpTxSwRst        => pgpTxSwRst(i),
            pgpTxIn           => pgpTxIn(i),
            pgpTxOut          => pgpTxOut(i),
            pgpTxData         => intTxData(i), -- Multiplexed 4 VCs
            pgpTxCtrl         => pgpTxCtrl(i),
            pgpRxClk          => pgpRxClk(i),
            pgpRxClkRst       => pgpRxClkRst(i),
            pgpRxSwRst        => pgpRxSwRst(i),
            pgpRxIn           => pgpRxIn(i),
            pgpRxOut          => pgpRxOut(i),
            pgpRxData         => pgpRxData(i),
            pgpRxCtrl         => intRxCtrl(i), -- Common for all VCs
            loopBackEn        => loopBackEn(i),
            axiStatClk        => axiStatClk,
            axiStatClkRst     => axiStatClkRst,
            axiWriteMaster    => axiWriteMaster(i),
            axiWriteSlave     => axiWriteSlave(i),
            axiReadMaster     => axiReadMaster(i),
            axiReadSlave      => axiReadSlave(i),
            statusWord        => pgpStatus(i),
            statusSend        => pgpStatusSend(i),
         );

      -- Demux tx channels, replicate rx channels
      process ( intTxData, intRxCtrl ) begin

         -- demux tx channels
         pgpTxData(i*4+3 downto i*4) <= vc64DeMux(intTxData(i),4);

         -- replicate rx control
         for j in 0 to 3
            pgpRxCtrl(i*4+j downto i*4) <= intRxCtrl(i);
         end loop;

      end process;

   end generate;

end architecture structure;

