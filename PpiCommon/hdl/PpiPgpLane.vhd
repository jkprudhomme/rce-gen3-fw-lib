-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block
-- File          : PpiPgpLane.vhd
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
use work.VcPkg.all;
use work.Pgp2CoreTypesPkg.all;

entity PpiPgpLane is
   generic (
      TPD_G                : time                       := 1 ns;
      VC_WIDTH_G           : integer range 1 to 4       := 1; -- 3 not allowed
      PPI_ADDR_WIDTH_G     : integer range 2 to 48      := 9;
      PPI_PAUSE_THOLD_G    : integer range 2 to (2**24) := 255;
      PPI_READY_THOLD_G    : integer range 0 to 511     := 0;
      PPI_MAX_FRAME_G      : integer range 1 to (2**12) := 256*8;
      HEADER_ADDR_WIDTH_G  : integer range 2 to 48      := 8;
      HEADER_AFULL_THOLD_G : integer range 1 to (2**24) := 100;
      HEADER_FULL_THOLD_G  : integer range 1 to (2**24) := 150;
      DATA_ADDR_WIDTH_G    : integer range 1 to 48      := 9;
      DATA_AFULL_THOLD_G   : integer range 1 to (2**24) := 200;
      DATA_FULL_THOLD_G    : integer range 1 to (2**24) := 400
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

      -- TX PGP Interface
      pgpTxClk         : in  sl;
      pgpTxClkRst      : in  sl;
      pgpTxSwRst       : out sl;
      pgpTxIn          : out PgpTxInType;
      pgpTxOut         : in  PgpTxOutType;
      pgpVcTxQuadIn    : out VcTxQuadInType;
      pgpVcTxQuadOut   : in  VcTxQuadOutType;

      -- RX PGP Interface
      pgpRxClk         : in  sl;
      pgpRxClkRst      : in  sl;
      pgpRxSwRst       : out sl;
      pgpRxIn          : out PgpRxInType;
      pgpRxOut         : in  PgpRxOutType;
      pgpVcRxCommonOut : in  VcRxCommonOutType;
      pgpVcRxQuadOut   : in  VcRxQuadOutType;
     
      -- AXI/Status Clocks Interface
      axiStatClk       : in  sl;
      axiStatClkRst    : in  sl;

      -- AXI Interface
      axiWriteMaster   : in  AxiLiteWriteMasterType;
      axiWriteSlave    : out AxiLiteWriteSlaveType;
      axiReadMaster    : in  AxiLiteReadMasterType;
      axiReadSlave     : out AxiLiteReadSlaveType;

      -- Status Bus
      statusWords      : out Slv64Array(1 downto 0);
      statusSend       : out sl
   );
end PpiPgpLane;

architecture structure of PpiPgpLane is

   -- Local Signals
   signal rxFrameCntEn  : sl;
   signal txFrameCntEn  : sl;
   signal locBuffFull   : sl;
   signal locBuffAFull  : sl;
   signal remBuffFull   : slv(3 downto 0);
   signal remBuffAFull  : slv(3 downto 0);
   signal rxDropCountEn : sl;
   signal rxOverflow    : sl;

begin

   -- Controller
   U_PpiPgpCntrl: entity work.PpiPgpCntrl 
      generic map (
         TPD_G   => TPD_G
      ) port map (
         ppiOnline         => ppiOnline,
         pgpTxClk          => pgpTxClk,
         pgpTxClkRst       => pgpTxClkRst,
         pgpTxSwRst        => pgpTxSwRst,
         pgpTxIn           => pgpTxIn,
         pgpTxOut          => pgpTxOut,
         txFrameCntEn      => txFrameCntEn,
         pgpRxClk          => pgpRxClk,
         pgpRxClkRst       => pgpRxClkRst,
         pgpRxSwRst        => pgpRxSwRst,
         pgpRxIn           => pgpRxIn,
         pgpRxOut          => pgpRxOut,
         rxFrameCntEn      => rxFrameCntEn,
         rxDropCountEn     => rxDropCountEn,
         rxOverflow        => rxOverflow,
         axiStatClk        => axiStatClk,
         axiStatClkRst     => axiStatClkRst,
         axiWriteMaster    => axiWriteMaster,
         axiWriteSlave     => axiWriteSlave,
         axiReadMaster     => axiReadMaster,
         axiReadSlave      => axiReadSlave,
         statusWords       => statusWords,
         statusSend        => statusSend
      );


   -- Transmit Data
   U_PgpTx : entity work.PpiVcTx
      generic map (
         TPD_G              => TPD_G,
         VC_WIDTH_G         => VC_WIDTH_G,
         PPI_ADDR_WIDTH_G   => PPI_ADDR_WIDTH_G,
         PPI_PAUSE_THOLD_G  => PPI_PAUSE_THOLD_G,
         PPI_READY_THOLD_G  => PPI_READY_THOLD_G
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => ppiOnline,
         ppiWriteToFifo    => ppiWriteToFifo,
         ppiWriteFromFifo  => ppiWriteFromFifo,
         vcTxClk           => pgpTxClk,
         vcTxClkRst        => pgpTxClkRst,
         vcTxQuadIn        => pgpVcTxQuadIn,
         vcTxQuadOut       => pgpVcTxQuadOut,
         locBuffFull       => locBuffFull,
         locBuffAFull      => locBuffAFull,
         remBuffFull       => remBuffFull,
         remBuffAFull      => remBuffAFull,
         txFrameCntEn      => txFrameCntEn
      );


   -- Receive Data
   U_PgpRx : entity work.PpiVcRx 
      generic map (
         TPD_G                 => TPD_G,
         VC_WIDTH_G            => VC_WIDTH_G,
         PPI_ADDR_WIDTH_G      => PPI_ADDR_WIDTH_G,
         PPI_PAUSE_THOLD_G     => PPI_PAUSE_THOLD_G,
         PPI_READY_THOLD_G     => PPI_READY_THOLD_G,
         PPI_MAX_FRAME_G       => PPI_MAX_FRAME_G,
         HEADER_ADDR_WIDTH_G   => HEADER_ADDR_WIDTH_G,
         HEADER_AFULL_THOLD_G  => HEADER_AFULL_THOLD_G,
         HEADER_FULL_THOLD_G   => HEADER_FULL_THOLD_G,
         DATA_ADDR_WIDTH_G     => DATA_ADDR_WIDTH_G,
         DATA_AFULL_THOLD_G    => DATA_AFULL_THOLD_G,
         DATA_FULL_THOLD_G     => DATA_FULL_THOLD_G
      ) port map (
         ppiClk           => ppiClk,
         ppiClkRst        => ppiClkRst,
         ppiOnline        => ppiOnline,
         ppiReadToFifo    => ppiReadToFifo,
         ppiReadFromFifo  => ppiReadFromFifo,
         vcRxClk          => pgpRxClk,
         vcRxClkRst       => pgpRxClkRst,
         vcRxCommonOut    => pgpVcRxCommonOut,
         vcRxQuadOut      => pgpVcRxQuadOut,
         locBuffFull      => locBuffFull,
         locBuffAFull     => locBuffAFull,
         remBuffFull      => remBuffFull,
         remBuffAFull     => remBuffAFull,
         rxFrameCntEn     => rxFrameCntEn,
         rxDropCountEn    => rxDropCountEn,
         rxOverflow       => rxOverflow
      );

end architecture structure;

