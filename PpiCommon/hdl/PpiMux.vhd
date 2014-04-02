-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI Multiplexer
-- File          : PpiMux.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to move data from one of a number of downstream FIFOs to 
-- an upstream FIFO.
-- Source is encoded in the type fields.
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
use work.ArbiterPkg.all;

entity PpiMux is
   generic (
      TPD_G            : time                  := 1 ns;
      NUM_READ_SLOTS_G : natural range 1 to 16 := 4
   );
   port (

      -- PPI Clock
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiOnline        : in  sl;

      -- Upstream
      ppiWriteToFifo   : out PpiWriteToFifoType;
      ppiWriteFromFifo : in  PpiWriteFromFifoType;

      -- Downstream 
      ppiReadToFifo    : out PpiReadToFifoArray(NUM_READ_SLOTS_G-1 downto 0);
      ppiReadFromFifo  : in  PpiReadFromFifoArray(NUM_READ_SLOTS_G-1 downto 0)

   );
end PpiMux;

architecture structure of PpiMux is

   constant ACK_NUM_SIZE_C : integer := bitSize(NUM_READ_SLOTS_G-1);

   type StateType is ( S_IDLE, S_MOVE );

   type RegType is record
      state            : StateType;
      acks             : slv(NUM_READ_SLOTS_G-1 downto 0);
      ackNum           : slv(ACK_NUM_SIZE_C-1 downto 0);
      valid            : sl;
      ppiWriteToFifo   : PpiWriteToFifoType;
      ppiReadToFifo    : PpiReadToFifoArray(NUM_READ_SLOTS_G-1 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      state            => S_IDLE,
      acks             => (others=>'0'),
      ackNum           => (others=>'0'),
      valid            => '0',
      ppiWriteToFifo   => PpiWriteToFifoInit,
      ppiReadToFifo    => (others=>PpiReadToFifoInit)
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (ppiClkRst, r, ppiWriteFromFifo, ppiReadFromFifo ) is
      variable v            : RegType;
      variable requests     : slv(NUM_READ_SLOTS_G-1 downto 0);
   begin
      v := r;

      -- Init
      v.ppiWriteToFifo.valid := '0';
      v.ppiWriteToFifo.data  := ppiReadFromFifo(conv_integer(r.ackNum)).data;
      v.ppiWriteToFifo.size  := ppiReadFromFifo(conv_integer(r.ackNum)).size;
      v.ppiWriteToFifo.eof   := ppiReadFromFifo(conv_integer(r.ackNum)).eof;
      v.ppiWriteToFifo.eoh   := ppiReadFromFifo(conv_integer(r.ackNum)).eoh;
      v.ppiWriteToFifo.err   := ppiReadFromFifo(conv_integer(r.ackNum)).err;
      v.ppiWriteToFifo.ftype := conv_std_logic_vector(conv_integer(r.ackNum), 4);
      v.ppiReadToFifo        := (others=>PpiReadToFifoInit);

      -- Format requests
      for i in 0 to NUM_READ_SLOTS_G-1 loop
         requests(i) := ppiReadFromFifo(i).valid and ppiReadFromFifo(i).ready;
      end loop;

      -- State machine
      case r.state is

         -- IDLE
         when S_IDLE =>

            -- Aribrate between requesters
            if ppiWriteFromFifo.pause = '0' and r.valid = '0' then
               arbitrate(requests, r.ackNum, v.ackNum, v.valid, v.acks);
            end if;

            -- Valid request and pause is not asserted
            if ppiWriteFromFifo.pause = '0' and r.valid = '1' then
               v.state := S_MOVE;
            end if;

         -- Read a frame until EOF
         when S_MOVE =>
            v.ppiWriteToFifo.valid                        := ppiReadFromFifo(conv_integer(r.ackNum)).valid;
            v.ppiReadToFifo(conv_integer(r.ackNum)).read  := ppiReadFromFifo(conv_integer(r.ackNum)).valid;
            v.valid := '0';
            
            if v.ppiWriteToFifo.eof = '1' and v.ppiWriteToFifo.valid = '1' then
               v.state := S_IDLE;
            end if;

      end case;

      if (ppiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      rin <= v;

      ppiWriteToFifo <= r.ppiWriteToFifo;
      ppiReadToFifo  <= v.ppiReadToFifo;

   end process comb;

   seq : process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end architecture structure;

