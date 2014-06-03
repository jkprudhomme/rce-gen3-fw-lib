-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI Crossbar
-- File          : PpiCrossbar.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI Crossbar.
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
use work.ArbiterPkg.all;

entity PpiCrossbar is
   generic (
      TPD_G              : time                  := 1 ns;
      NUM_PPI_SLOTS_G    : natural range 1 to 16 := 1;
      NUM_AXI_SLOTS_G    : natural range 1 to 16 := 1;
      NUM_STATUS_WORDS_G : natural range 1 to 32 := 1
   );
   port (

      -- PPI Clock
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;

      -- Inbound/Outbound Upstream
      ibWriteToFifo    : out PpiWriteToFifoType;
      ibWriteFromFifo  : in  PpiWriteFromFifoType;
      obReadToFifo     : out PpiReadToFifoType;
      obReadFromFifo   : in  PpiReadFromFifoType;

      -- Inbound/Outbound Downstream 
      ibReadToFifo     : out PpiReadToFifoArray(NUM_PPI_SLOTS_G-1 downto 0);
      ibReadFromFifo   : in  PpiReadFromFifoArray(NUM_PPI_SLOTS_G-1 downto 0);
      obWriteToFifo    : out PpiWriteToFifoArray(NUM_PPI_SLOTS_G-1 downto 0);
      obWriteFromFifo  : in  PpiWriteFromFifoArray(NUM_PPI_SLOTS_G-1 downto 0);

      -- AXI Lite Busses
      axiClk           : in  sl;
      axiClkRst        : in  sl;
      axiWriteMasters  : out AxiLiteWriteMasterArray(NUM_AXI_SLOTS_G-1 downto 0);
      axiWriteSlaves   : in  AxiLiteWriteSlaveArray(NUM_AXI_SLOTS_G-1 downto 0);
      axiReadMasters   : out AxiLiteReadMasterArray(NUM_AXI_SLOTS_G-1 downto 0);
      axiReadSlaves    : in  AxiLiteReadSlaveArray(NUM_AXI_SLOTS_G-1 downto 0);

      -- Status Bus
      statusClk        : in  sl;
      statusClkRst     : in  sl;
      statusWords      : in  Slv64Array(NUM_STATUS_WORDS_G-1 downto 0);
      statusSend       : in  sl
   );
end PpiCrossbar;

architecture structure of PpiCrossbar is

   constant NUM_INT_SLOTS_C : natural := NUM_PPI_SLOTS_G + 2;

   signal locReadToFifo     : PpiReadToFifoArray(NUM_INT_SLOTS_C-1 downto 0);
   signal locReadFromFifo   : PpiReadFromFifoArray(NUM_INT_SLOTS_C-1 downto 0);
   signal locWriteToFifo    : PpiWriteToFifoArray(NUM_INT_SLOTS_C-1 downto 0);
   signal locWriteFromFifo  : PpiWriteFromFifoArray(NUM_INT_SLOTS_C-1 downto 0);
   signal iaxiWriteMaster   : AxiLiteWriteMasterType;
   signal iaxiWriteSlave    : AxiLiteWriteSlaveType;
   signal iaxiReadMaster    : AxiLiteReadMasterType;
   signal iaxiReadSlave     : AxiLiteReadSlaveType;

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : 
      AxiLiteCrossbarMasterConfigArray(NUM_AXI_SLOTS_G-1 downto 0) := genAxiLiteConfig (NUM_AXI_SLOTS_G, x"00000000", 0);

begin

   -- Inputs
   locReadFromFifo(NUM_PPI_SLOTS_G-1 downto 0)  <= ibReadFromFifo;
   locWriteFromFifo(NUM_PPI_SLOTS_G-1 downto 0) <= obWriteFromFifo;

   -- Outputs
   ibReadToFifo  <= locReadToFifo(NUM_PPI_SLOTS_G-1 downto 0);
   obWriteToFifo <= locWriteToFifo(NUM_PPI_SLOTS_G-1 downto 0);

   -- Outbound Router
   U_ObRouter : entity work.PpiRouter 
      generic map (
         TPD_G             => TPD_G,
         NUM_WRITE_SLOTS_G => NUM_INT_SLOTS_C
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => ppiOnline,
         ppiReadToFifo     => obReadToFifo,
         ppiReadFromFifo   => obReadFromFifo,
         ppiWriteToFifo    => locWriteToFifo,
         ppiWriteFromFifo  => locWriteFromFifo
      );

   -- Inbound Mux
   U_IbMux : entity work.PpiMux
      generic map (
         TPD_G            => TPD_G,
         NUM_READ_SLOTS_G => NUM_INT_SLOTS_C
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => ppiOnline,
         ppiWriteToFifo    => ibWriteToFifo,
         ppiWriteFromFifo  => ibWriteFromFifo,
         ppiReadToFifo     => locReadToFifo,
         ppiReadFromFifo   => locReadFromFifo

      );

   -- AXI Bridge
   U_PpiToAxi : entity work.PpiToAxi
      generic map (
         TPD_G  => TPD_G 
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => ppiOnline,
         ppiWriteToFifo    => locWriteToFifo(NUM_INT_SLOTS_C-2),
         ppiWriteFromFifo  => locWriteFromFifo(NUM_INT_SLOTS_C-2),
         ppiReadToFifo     => locReadToFifo(NUM_INT_SLOTS_C-2),
         ppiReadFromFifo   => locReadFromFifo(NUM_INT_SLOTS_C-2),
         axiClk            => axiClk,
         axiClkRst         => axiClkRst,
         axiWriteMaster    => iaxiWriteMaster,
         axiWriteSlave     => iaxiWriteSlave,
         axiReadMaster     => iaxiReadMaster,
         axiReadSlave      => iaxiReadSlave
      );

   -- AXI Crossbar
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXI_SLOTS_G,
         DEC_ERROR_RESP_G   => AXI_RESP_DECERR_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sAxiWriteMasters(0) => iaxiWriteMaster,
         sAxiWriteSlaves(0)  => iaxiWriteSlave,
         sAxiReadMasters(0)  => iaxiReadMaster,
         sAxiReadSlaves(0)   => iaxiReadSlave,
         mAxiWriteMasters    => axiWriteMasters,
         mAxiWriteSlaves     => axiWriteSlaves,
         mAxiReadMasters     => axiReadMasters,
         mAxiReadSlaves      => axiReadSlaves
      );

   -- Status Bridge
   U_PpiStatus : entity work.PpiStatus
      generic map (
         TPD_G               => TPD_G,
         NUM_STATUS_WORDS_G  => NUM_STATUS_WORDS_G
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiOnline         => ppiOnline,
         ppiWriteToFifo    => locWriteToFifo(NUM_INT_SLOTS_C-1),
         ppiWriteFromFifo  => locWriteFromFifo(NUM_INT_SLOTS_C-1),
         ppiReadToFifo     => locReadToFifo(NUM_INT_SLOTS_C-1),
         ppiReadFromFifo   => locReadFromFifo(NUM_INT_SLOTS_C-1),
         statusClk         => statusClk,
         statusClkRst      => statusClkRst,
         statusWords       => statusWords,
         statusSend        => statusSend
      );

end architecture structure;

