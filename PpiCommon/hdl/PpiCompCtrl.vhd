-------------------------------------------------------------------------------
-- Title      : PPI Completion Controller
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiCompCtrl.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Completion control block for PPI.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PPI Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PPI Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/27/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.ArbiterPkg.all;
use work.PpiPkg.all;

entity PpiCompCtrl is
   generic (
      TPD_G           : time     := 1 ns;
      CHAN_ID_G       : integer  := 0
   );
   port (

      -- Clock/Reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- Incoming
      compValid       : in  slv(7 downto 0);
      compSel         : in  SlV32Array(7 downto 0);
      compDin         : in  Slv31Array(7 downto 0);
      compRead        : out slv(7 downto 0);

      -- FIFO
      compFifoWrite   : out sl;
      compFifoDin     : out slv(31 downto 0);
      compFifoAFull   : in  sl
   );
end PpiCompCtrl;

architecture structure of PpiCompCtrl is

   type StateType is (IDLE_S, WRITE_S, READ_S);

   type RegType is record
      state         : StateType;
      compFifoWrite : sl;
      compFifoDin   : slv(31 downto 0);
      compRead      : slv(7 downto 0);
      srcSel        : slv(2 downto 0);
      srcAcks       : slv(7 downto 0);
      req           : slv(7 downto 0);
      valid         : sl;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state         => IDLE_S,
      compFifoWrite => '0',
      compFifoDin   => (others=>'0'),
      compRead      => (others=>'0'),
      srcSel        => (others=>'0'),
      srcAcks       => (others=>'0'),
      req           => (others=>'0'),
      valid         => '0'
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, axiRst, compValid, compSel, compDin, compFifoAFull ) is
      variable v   : RegType;
   begin
      v := r;

      v.compFifoWrite := '0';
      v.compRead      := (others=>'0');

      case r.state is

         when IDLE_S =>
            v.req := (others=>'0');

            -- format requests
            for i in 0 to 7 loop
               if compValid(i) = '1' and compSel(i)(bitSize(PPI_COMP_CNT_C-1)-1 downto 0) = CHAN_ID_G then
                  v.req(i) := '1';
               end if;
            end loop;

            -- Aribrate between requesters
            if r.valid = '0' then
               arbitrate(r.req, r.srcSel, v.srcSel, v.valid, v.srcAcks);
            end if;

            -- Valid request
            if r.valid = '1' and compFifoAFull = '0' then
               v.state := WRITE_S;
            end if;

         when WRITE_S => 
            v.compFifoWrite := '1';
            v.compFifoDin   := compDin(conv_integer(r.srcSel)) & "0";
            v.state         := READ_S;
            v.req           := (others=>'0');
            v.valid         := '0';

            v.compRead(conv_integer(r.srcSel)) := '1';

         when READ_S =>
            v.state := IDLE_S;
            v.req   := (others=>'0');
            v.valid := '0';

      end case;

      if axiRst = '1' then
         v := REG_INIT_C;
      end if;

      rin <= v;

      -- Outputs
      compRead      <= r.compRead;
      compFifoWrite <= r.compFifoWrite;
      compFifoDin   <= r.compFifoDin;

   end process;

end structure;

