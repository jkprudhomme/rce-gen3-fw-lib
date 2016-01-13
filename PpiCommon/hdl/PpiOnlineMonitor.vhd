-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : PpiOnlineMonitor.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-09-24
-- Last update: 2014-09-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PPI Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PPI Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;

entity PpiOnlineMonitor is
   generic (
      TPD_G        : time    := 1 ns;
      NUM_TVALID_G : natural := 1;
      CLK_FREQ_G   : real    := 125.0E+6;  -- Units of Hz
      TIMEOUT_G    : real    := 1.0E-3);   -- Units of seconds
   port (
      statusClk  : in  sl;
      statusRst  : in  sl;
      online     : in  sl;
      tValidMon  : in  slv(NUM_TVALID_G-1 downto 0);
      offlineAck : out sl);
end PpiOnlineMonitor;

architecture rtl of PpiOnlineMonitor is

   constant MAX_CNT_C : natural := getTimeRatio(getRealMult(CLK_FREQ_G, TIMEOUT_G), 1.0);
   
   type StateType is (
      OFFLINE_S,
      ONLINE_S,
      FLUSHING_S);    

   type RegType is record
      offlineAck : sl;
      cnt        : natural range 0 to MAX_CNT_C;
      state      : StateType;
   end record RegType;
   
   constant REG_INIT_C : RegType := (
      '0',
      0,
      OFFLINE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal tValid : slv(NUM_TVALID_G-1 downto 0);
   
begin

   SynchronizerVector_Inst : entity work.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => NUM_TVALID_G)    
      port map (
         clk     => statusClk,
         dataIn  => tValidMon,
         dataOut => tValid);  

   comb : process (online, r, statusRst, tValid) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobing signals
      v.offlineAck := '0';

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when OFFLINE_S =>
            -- Check if we have switched to online mode
            if online = '1' then
               -- Next state
               v.state := ONLINE_S;
            end if;
         ----------------------------------------------------------------------
         when ONLINE_S =>
            -- Check if we have switched to offline mode
            if online = '0' then
               -- Next state
               v.state := FLUSHING_S;
            end if;
         ----------------------------------------------------------------------
         when FLUSHING_S =>
            -- Increment the counter
            v.cnt := r.cnt + 1;
            -- Check if we have switched to online mode
            if online = '1' then
               -- Reset the counter
               v.cnt   := 0;
               -- Next state
               v.state := ONLINE_S;
            -- Check the status of the FIFOs
            elsif uOr(tValid) = '1' then
               -- Reset the counter
               v.cnt := 0;
            -- Check if we have flushed out the FIFOs for the timeout
            elsif r.cnt = MAX_CNT_C then
               -- Reset the counter
               v.cnt        := 0;
               -- Strobe the flag
               v.offlineAck := '1';
               -- Next state
               v.state      := OFFLINE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Reset
      if (statusRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      offlineAck <= r.offlineAck;

   end process comb;

   seq : process (statusClk) is
   begin
      if rising_edge(statusClk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
