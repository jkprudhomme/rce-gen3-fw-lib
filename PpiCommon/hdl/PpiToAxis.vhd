-------------------------------------------------------------------------------
-- Title         : PPI To AXI Stream Block, Outbound Transmit.
-- File          : PpiToAxis.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to transmit outbound AXI Stream Frames.
-- First quad word of PPI frame contains control data:
--    Bits 07:00 = Dest
--    Bits 15:08 = First User
--    Bits 23:16 = Last  User
--    Bits 26    = End of Frame
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

use work.PpiPkg.all;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity PpiToAxis is
   generic (
      TPD_G                : time    := 1 ns;

      -- PPI Settings
      PPI_ADDR_WIDTH_G     : integer := 9;

      -- AXIS Settings
      AXIS_CONFIG_G        : AxiStreamConfigType := AXI_STREAM_CONFIG_INIT_C;
      AXIS_ADDR_WIDTH_G    : integer             := 9;
      AXIS_CASCADE_SIZE_G  : integer             := 1
   );
   port (

      -- PPI Interface
      ppiClk          : in  sl;
      ppiClkRst       : in  sl;
      ppiState        : in  RceDmaStateType;
      ppiObMaster     : in  AxiStreamMasterType;
      ppiObSlave      : out AxiStreamSlaveType;

      -- Outbound AXI Stream Interface
      axisObClk       : in  sl;
      axisObClkRst    : in  sl;
      axisObMaster    : out AxiStreamMasterType;
      axisObSlave     : in  AxiStreamSlaveType;

      -- Frame Counter
      txFrameCntEn    : out sl
   );

begin
end PpiToAxis;

architecture structure of PpiToAxis is

   -- Internal AXIS configuration
   constant INT_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,
      TDEST_BITS_C  => AXIS_CONFIG_G.TDEST_BITS_C,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => AXIS_CONFIG_G.TUSER_BITS_C,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C
   );

   -- Local signals
   signal ippiObMaster  : AxiStreamMasterType;
   signal ippiObSlave   : AxiStreamSlaveType;
   signal iaxisObMaster : AxiStreamMasterType;
   signal iaxisObCtrl   : AxiStreamCtrlType;

   type StateType is (HEADER_S, FIRST_S, DATA_S);

   type RegType is record
      state           : StateType;
      dest            : slv(AXIS_CONFIG_G.TDEST_BITS_C-1 downto 0);
      firstUser       : slv(AXIS_CONFIG_G.TUSER_BITS_C-1 downto 0);
      lastUser        : slv(AXIS_CONFIG_G.TUSER_BITS_C-1 downto 0);
      eof             : sl;
      txFrameCntEn    : sl;
      iaxisObMaster   : AxiStreamMasterType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => HEADER_S,
      dest           => (others=>'0'),
      firstUser      => (others=>'0'),
      lastUser       => (others=>'0'),
      eof            => '0',
      txFrameCntEn   => '0',
      iaxisObMaster  => AXI_STREAM_MASTER_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   assert (AXIS_CONFIG_G.TSTRB_EN_C = false)
      report "TSTRB_EN_C must be false" severity failure;

   assert (AXIS_CONFIG_G.TID_BITS_C = 0)
      report "TID_BITS_C must be 0" severity failure;

   assert (AXIS_CONFIG_G.TUSER_MODE_C = TUSER_LAST_C or AXIS_CONFIG_G.TUSER_MODE_C = TUSER_FIRST_LAST_C)
      report "TUSER_MODE_C must be last or first_last" severity failure;


   -------------------------
   -- Input FIFO, SYNC
   -------------------------
   U_InputFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => true,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => PPI_ADDR_WIDTH_G,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 1,
         SLAVE_AXI_CONFIG_G  => PPI_AXIS_CONFIG_INIT_C,
         MASTER_AXI_CONFIG_G => PPI_AXIS_CONFIG_INIT_C
      ) port map (
         sAxisClk    => ppiClk,
         sAxisRst    => ppiClkRst,
         sAxisMaster => ppiObMaster,
         sAxisSlave  => ppiObSlave,
         sAxisCtrl   => open,
         mAxisClk    => ppiClk,
         mAxisRst    => ppiClkRst,
         mAxisMaster => ippiObMaster,
         mAxisSlave  => ippiObSlave
      );


   -------------------------
   -- Data Mover
   -------------------------

   -- Always move when there is space left in axis FIFO
   ippiObSlave.tReady <= (not iaxisObCtrl.pause);

   -- Sync
   process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (ppiClkRst, r, ippiObMaster, ippiObSlave ) is
      variable v : RegType;
   begin
      v := r;

      v.iaxisObMaster.tValid := '0';
      v.txFrameCntEn         := '0';

      case r.state is

         when HEADER_S =>
            v.iaxisObMaster := AXI_STREAM_MASTER_INIT_C;
            v.dest          := ippiObMaster.tData((AXIS_CONFIG_G.TDEST_BITS_C-1)    downto  0);
            v.firstUser     := ippiObMaster.tData((AXIS_CONFIG_G.TUSER_BITS_C-1)+8  downto  8);
            v.lastUser      := ippiObMaster.tData((AXIS_CONFIG_G.TUSER_BITS_C-1)+16 downto 16);
            v.eof           := ippiObMaster.tData(26);

            if ippiObMaster.tValid = '1' and ippiObSlave.tReady = '1' then
               v.state := FIRST_S;
            end if;

         when FIRST_S =>
            v.iaxisObMaster.tData(63 downto 0) := ippiObMaster.tData(63 downto 0);
            v.iaxisObMaster.tKeep              := ippiObMaster.tKeep;

            v.iaxisObMaster.tDest(AXIS_CONFIG_G.TDEST_BITS_C-1 downto 0) := r.dest;

            axiStreamSetUserField (AXIS_CONFIG_G,v.iaxisObMaster,r.firstUser,0);

            if ippiObMaster.tValid = '1' and ippiObSlave.tReady = '1' then
               v.iaxisObMaster.tValid := '1';

               if v.iaxisObMaster.tLast = '1' then
                  axiStreamSetUserField (AXIS_CONFIG_G,v.iaxisObMaster,r.lastUser);

                  v.iaxisObMaster.tLast := r.eof;
                  v.txFrameCntEn        := '1';
                  v.state               := HEADER_S;
               else
                  v.state := DATA_S;
               end if;
            end if;

         when DATA_S =>
            v.iaxisObMaster.tData(63 downto 0) := ippiObMaster.tData(63 downto 0);
            v.iaxisObMaster.tKeep              := ippiObMaster.tKeep;

            v.iaxisObMaster.tUser := (others=>'0');

            if ippiObMaster.tValid = '1' and ippiObSlave.tReady = '1' then
               v.iaxisObMaster.tValid := '1';

               if ippiObMaster.tLast = '1' then
                  axiStreamSetUserField (AXIS_CONFIG_G,v.iaxisObMaster,r.lastUser);

                  v.iaxisObMaster.tLast := r.eof;
                  v.txFrameCntEn        := '1';
                  v.state               := HEADER_S;
               end if;
            end if;

      end case;

      -- Reset
      if ppiClkRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      iaxisObMaster <= r.iaxisObMaster;
      txFrameCntEn  <= r.txFrameCntEn;

   end process;


   -------------------------
   -- Output FIFO, ASYNC
   -------------------------
   U_OutputFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         CASCADE_SIZE_G      => AXIS_CASCADE_SIZE_G,
         FIFO_ADDR_WIDTH_G   => AXIS_ADDR_WIDTH_G,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 1,
         SLAVE_AXI_CONFIG_G  => INT_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_G
      ) port map (
         sAxisClk    => ppiClk,
         sAxisRst    => ppiClkRst,
         sAxisMaster => iaxisObMaster,
         sAxisSlave  => open,
         sAxisCtrl   => iaxisObCtrl,
         mAxisClk    => axisObClk,
         mAxisRst    => axisObClkRst,
         mAxisMaster => axisObMaster,
         mAxisSlave  => axisObSlave
      );

end architecture structure;

