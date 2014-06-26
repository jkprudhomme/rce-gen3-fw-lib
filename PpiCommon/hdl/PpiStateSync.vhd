-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI State Sync
-- File          : PpiStateSync.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to sync DMA state across clock domains
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

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;

entity PpiStateSync is
   generic (
      TPD_G  : time := 1 ns
   );
   port (

      -- PPI Interface
      ppiState  : in  RceDmaStateType;

      -- Local Interface
      locClk    : in  sl;
      locClkRst : in  sl;
      locState  : out RceDmaStateType
   );
end PpiStateSync;

architecture structure of PpiStateSync is

begin

   U_Sync: entity work.SynchronizerVector
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         WIDTH_G        => 2,
         INIT_G         => "0"
      ) port map (
         clk        => locClk,
         rst        => locClkRst,
         dataIn(0)  => ppiState.online,
         dataIn(1)  => ppiState.enable,
         dataOut(0) => locState.online,
         dataOut(1) => locState.enable
      );

end architecture structure;

