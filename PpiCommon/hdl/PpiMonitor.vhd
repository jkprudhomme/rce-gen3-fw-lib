-------------------------------------------------------------------------------
-- Title      : PPI Inbound Monitor
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiMonitor.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- PPI Error Checking
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
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;
use work.PpiPkg.all;

entity PpiMonitor is
   generic (
      TPD_G          : time                  := 1 ns;
      DEST_CNT_G     : natural range 1 to 16 := 1;
      SUB_CNT_G      : natural range 1 to 16 := 1
   );
   port (
      ppiClk         : in  sl;
      ppiClkRst      : in  sl;
      ppiIbMaster    : in  AxiStreamMasterType;
      ppiIbSlave     : in  AxiStreamSlaveType;

      errorDet       : out sl;
      errorDetCnt    : out slv(31 downto 0)
   );
end PpiMonitor;

architecture structure of PpiMonitor is

   constant TOT_COUNT_C   : natural := DEST_CNT_G * SUB_CNT_G;

   type RegType is record
      inFrame       : sl;
      chanInFrame   : slv(TOT_COUNT_C-1 downto 0);
      currDest      : slv(7 downto 0);
      currSub       : slv(7 downto 0);
      currFirst     : slv(7 downto 0);
      currValid     : sl;
      currEOF       : sl;
      errorDet      : sl;
      errorDetCnt   : slv(31 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      inFrame       => '0',
      chanInFrame   => (others=>'0'),
      currDest      => (others=>'0'),
      currSub       => (others=>'0'),
      currFirst     => (others=>'0'),
      currValid     => '0',
      currEOF       => '0',
      errorDet      => '0',
      errorDetCnt   => (others=>'0')
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -- attribute dont_touch : string;
   -- attribute dont_touch of r           : signal is "true";
   -- attribute dont_touch of errorDet    : signal is "true";
   -- attribute dont_touch of errorDetCnt : signal is "true";

begin

   -- Sync
   process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, ppiClkRst, ppiIbMaster, ppiIbSlave) is
      variable v : RegType;
      variable i : natural;
   begin
      v := r;

      v.currValid := '0';
      v.errorDet  := '0';

      -- Data moving
      if ppiIbMaster.tValid = '1' and ppiIbSlave.tReady = '1' then

         -- Frame ending
         if ppiIbMaster.tLast = '1' then
            v.inFrame   := '0';

         -- Frame starting
         elsif r.inFrame = '0' then
            v.currDest  := ppiIbMaster.tDest;
            v.currSub   := ppiIbMaster.tData(7  downto 0);
            v.currFirst := ppiIbMaster.tData(15 downto 8);
            v.currEOF   := ppiIbMaster.tData(26);
            v.currValid := '1';
            v.inFrame   := '1';
         end if;
      end if;

      i := (conv_integer(r.currDest) * SUB_CNT_G) + conv_integer(r.currSub);

      -- Once per frame
      if r.currValid = '1' then

         -- Update state
         if r.currEOF = '1' then 
            v.chanInFrame(i) := '0';
         else
            v.chanInFrame(i) := '1';
         end if;

         -- Detect issues
         if r.chanInFrame(i) = '0' and v.currFirst(1) = '0' then
            v.errorDet    := '1';
            v.errorDetCnt := r.errorDetCnt + 1;
         end if;
      end if;

      if ppiClkRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      errorDet    <= r.errorDet;
      errorDetCnt <= r.errorDetCnt;

   end process;

end structure;

