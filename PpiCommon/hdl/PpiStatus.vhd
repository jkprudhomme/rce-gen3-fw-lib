-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI Status Monitoring
-- File          : PpiStatus.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to transmit status messages.
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

entity PpiStatus is
   generic (
      TPD_G                  : time                       := 1 ns;
      PPI_ADDR_WIDTH_G       : integer range 2 to 48      := 6;
      PPI_PAUSE_THOLD_G      : integer range 1 to (2**24) := 32;
      NUM_STATUS_WORDS_G     : natural range 1 to 32      := 1
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

      -- Status Busses
      statusClk        : in  sl;
      statusClkRst     : in  sl;
      statusWords      : in  Slv64Array(NUM_STATUS_WORDS_G-1 downto 0);
      statusSend       : in  sl
   );
end PpiStatus;

architecture structure of PpiStatus is

   -- Local signals
   signal intWriteToFifo   : PpiWriteToFifoType;
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal swReqIn          : sl;
   signal swReqEdge        : sl;
   signal statusSendEdge   : sl;
   signal intOnline        : sl;
   signal intOnlineEdge    : sl;

   type StateType is (S_IDLE, S_FIRST, S_MESSAGE, S_LAST );

   type RegType is record
      count          : slv(7  downto 0);
      state          : StateType;
      ppiWriteToFifo : ppiWriteToFifoType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      count          => (others => '0'),
      state          => S_IDLE,
      ppiWriteToFifo => PpiWriteToFifoInit
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   ------------------------------------
   -- Generate status request pulse
   ------------------------------------
   swReqIn                <= ppiWriteToFifo.valid and ppiWriteToFifo.eof;
   ppiWriteFromFifo.pause <= '0';

   U_SwSync : entity work.SynchronizerOneShot
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1'
      ) port map (
         clk     => statusClk,
         dataIn  => swReqIn,
         dataOut => swReqEdge
      );

   -- Online Sync
   U_OnlineSync : entity work.SynchronizerEdge 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         INIT_G         => "0"
      ) port map (
         clk         => statusClk,
         rst         => statusClkRst,
         dataIn      => ppiOnline,
         dataOut     => intOnline,
         risingEdge  => intOnlineEdge,
         fallingEdge => open
      );

   U_ReqSync : entity work.SynchronizerOneShot
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '1'
      ) port map (
         clk     => statusClk,
         dataIn  => statusSend,
         dataOut => statusSendEdge
      );


   ------------------------------------
   -- FIFO
   ------------------------------------
   U_OutFifo : entity work.PpiFifoAsync
      generic map (
         TPD_G          => TPD_G,
         BRAM_EN_G      => true,
         USE_DSP48_G    => "no",
         SYNC_STAGES_G  => 3,
         ADDR_WIDTH_G   => PPI_ADDR_WIDTH_G,
         PAUSE_THOLD_G  => PPI_PAUSE_THOLD_G,
         FIFO_TYPE_EN_G => false
      ) port map (
         ppiWrClk         => statusClk,
         ppiWrClkRst      => statusClkRst,
         ppiWrOnline      => '0',
         ppiWriteToFifo   => intWriteToFifo,
         ppiWriteFromFifo => intWriteFromFifo,
         ppiRdClk         => ppiClk,
         ppiRdClkRst      => ppiClkRst,
         ppiRdOnline      => open,
         ppiReadToFifo    => ppiReadToFifo,
         ppiReadFromFifo  => ppiReadFromFifo
      );


   ------------------------------------
   -- Status Messages
   ------------------------------------

   -- Sync
   process (statusClk) is
   begin
      if (rising_edge(statusClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (statusClkRst, r, intWriteFromFifo, swReqEdge, statusSendEdge, intOnline, intOnlineEdge ) is
      variable v         : RegType;
   begin
      v := r;

      -- Init
      v.ppiWriteToFifo      := PpiWriteToFifoInit;
      v.ppiWriteToFifo.size := "111";

      -- State Machine
      case r.state is

         -- Idle
         when S_IDLE =>
            v.ppiWriteToFifo := PpiWriteToFifoInit;
            v.count          := (others=>'0');

            -- When to send a message, transition to online, sw request or firmware request
            if intOnlineEdge = '1' or swReqEdge = '1' or statusSendEdge = '1' then
               v.state := S_FIRST;
            end if;

         -- First Word
         when S_FIRST =>

            -- Proceeed when pause is de-asserted
            if intWriteFromFifo.pause = '0' then
               v.ppiWriteToFifo.data  := (others=>'0');
               v.ppiWriteToFifo.valid := '1';
            end if;

         -- Status message
         when S_MESSAGE =>
            v.ppiWriteToFifo.data  := statusWords(conv_integer(r.count));
            v.ppiWriteToFifo.valid := '1';
            v.count                := r.count + 1;

            if r.count = (NUM_STATUS_WORDS_G - 1) then
               v.state := S_LAST;
            end if;

         -- Last Word
         when S_LAST =>
            v.ppiWriteToFifo.data  := (others=>'0');
            v.ppiWriteToFifo.eof   := '1';
            v.ppiWriteToFifo.eoh   := '1';
            v.ppiWriteToFifo.valid := '1';
            v.state                := S_IDLE;

         when others =>
            v.state := S_IDLE;

      end case;

      -- Reset
      if statusClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      intWriteToFifo <= r.ppiWriteToFifo;  

   end process;

end architecture structure;

