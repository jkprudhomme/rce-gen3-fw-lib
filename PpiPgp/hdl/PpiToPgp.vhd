-------------------------------------------------------------------------------
-- Title         : PPI To PGP Block, Outbound Transmit.
-- File          : PpiToPgp.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to transmit outbound AXI Stream Frames.
-- First quad word of PPI frame contains control data:
--    Bits 03:00 = Dest
--    Bit  09    = SOF
--    Bit  16    = EOFE
--    Bits 26    = EOF
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.SsiPkg.all;
use work.Pgp2bPkg.all;
use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity PpiToPgp is
   generic (
      TPD_G                : time    := 1 ns;

      -- PPI Settings
      PPI_ADDR_WIDTH_G     : integer := 9;

      -- AXIS Settings
      AXIS_ADDR_WIDTH_G    : integer  := 9;
      AXIS_CASCADE_SIZE_G  : integer  := 1
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
end PpiToPgp;

architecture structure of PpiToPgp is

   constant FIFO_PAUSE_C : integer := (2**AXIS_ADDR_WIDTH_G) - 10;

   -- Local signals
   signal ippiObMaster  : AxiStreamMasterType;
   signal ippiObSlave   : AxiStreamSlaveType;
   signal iaxisObMaster : AxiStreamMasterType;
   signal iaxisObCtrl   : AxiStreamCtrlType;

   type StateType is (HEADER_S, DATA0_S, DATA1_S, DATA2_S, DATA3_S);

   type RegType is record
      state           : StateType;
      dest            : slv(3 downto 0);
      sof             : sl;
      eofe            : sl;
      first           : sl;
      eof             : sl;
      txFrameCntEn    : sl;
      iaxisObMaster   : AxiStreamMasterType;
      ippiObSlave     : AxiStreamSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => HEADER_S,
      dest           => (others=>'0'),
      sof            => '0',
      eofe           => '0',
      first          => '0',
      eof            => '0',
      txFrameCntEn   => '0',
      iaxisObMaster  => AXI_STREAM_MASTER_INIT_C,
      ippiObSlave    => AXI_STREAM_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

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
         mAxisClk    => ppiClk,
         mAxisRst    => ppiClkRst,
         mAxisMaster => ippiObMaster,
         mAxisSlave  => ippiObSlave
      );


   -------------------------
   -- Data Mover
   -------------------------


   -- Sync
   process (ppiClk) is
   begin
      if (rising_edge(ppiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (ppiClkRst, r, ippiObMaster, iaxisObCtrl ) is
      variable v : RegType;
   begin
      v := r;

      v.iaxisObMaster.tValid := '0';
      v.iaxisObMaster.tUser  := (others=>'0');
      v.ippiObSlave.tReady   := '0';
      v.txFrameCntEn         := '0';

      case r.state is

         when HEADER_S =>
            v.iaxisObMaster := AXI_STREAM_MASTER_INIT_C;
            v.dest          := ippiObMaster.tData(3 downto 0);
            v.sof           := ippiObMaster.tData(9);
            v.eofe          := ippiObMaster.tData(16);
            v.eof           := ippiObMaster.tData(26);
            v.first         := '1';

            if ippiObMaster.tValid = '1' and iaxisObCtrl.pause = '0' then
               v.state              := DATA0_S;
               v.ippiObSlave.tReady := '1';
            end if;

         when DATA0_S =>
            if ippiObMaster.tValid = '1' and iaxisObCtrl.pause = '0' then
               v.iaxisObMaster.tData(15 downto 0) := ippiObMaster.tData(15 downto 0);

               if r.first = '1' then
                  v.iaxisObMaster.tDest(3 downto 0) := r.dest;
                  ssiSetUserSof(SSI_PGP2B_CONFIG_C,v.iaxisObMaster,r.sof);
               end if;

               v.iaxisObMaster.tValid := '1';
               v.first := '0';

               if ippiObMaster.tLast = '1' and ippiObMaster.tKeep(7 downto 2) = 0 then
                  ssiSetUserEofe(SSI_PGP2B_CONFIG_C,v.iaxisObMaster,r.eofe);

                  v.iaxisObMaster.tLast := r.eof;
                  v.txFrameCntEn        := '1';
                  v.ippiObSlave.tReady  := '1';
                  v.state               := HEADER_S;
               else
                  v.state := DATA1_S;
               end if;
            end if;

         when DATA1_S =>
            v.iaxisObMaster.tData(15 downto 0) := ippiObMaster.tData(31 downto 16);

            v.iaxisObMaster.tValid := '1';

            if ippiObMaster.tLast = '1' and ippiObMaster.tKeep(7 downto 4) = 0 then
               ssiSetUserEofe(SSI_PGP2B_CONFIG_C,v.iaxisObMaster,r.eofe);

               v.iaxisObMaster.tLast := r.eof;
               v.txFrameCntEn        := '1';
               v.ippiObSlave.tReady  := '1';
               v.state               := HEADER_S;
            else
               v.state := DATA2_S;
            end if;

         when DATA2_S =>
            v.iaxisObMaster.tData(15 downto 0) := ippiObMaster.tData(47 downto 32);

            v.iaxisObMaster.tValid := '1';

            if ippiObMaster.tLast = '1' and ippiObMaster.tKeep(7 downto 6) = 0 then
               ssiSetUserEofe(SSI_PGP2B_CONFIG_C,v.iaxisObMaster,r.eofe);

               v.iaxisObMaster.tLast := r.eof;
               v.txFrameCntEn        := '1';
               v.ippiObSlave.tReady  := '1';
               v.state               := HEADER_S;
            else
               v.state := DATA3_S;
            end if;

         when DATA3_S =>
            v.iaxisObMaster.tData(15 downto 0) := ippiObMaster.tData(63 downto 48);

            v.iaxisObMaster.tValid := '1';
            v.ippiObSlave.tReady   := '1';

            if ippiObMaster.tLast = '1' then
               ssiSetUserEofe(SSI_PGP2B_CONFIG_C,v.iaxisObMaster,r.eofe);

               v.iaxisObMaster.tLast := r.eof;
               v.txFrameCntEn        := '1';
               v.state               := HEADER_S;
            else
               v.state := DATA0_S;
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
      ippiObSlave   <= v.ippiObSlave;
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
         FIFO_PAUSE_THRESH_G => FIFO_PAUSE_C,
         SLAVE_AXI_CONFIG_G  => SSI_PGP2B_CONFIG_C,
         MASTER_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C
      ) port map (
         sAxisClk    => ppiClk,
         sAxisRst    => ppiClkRst,
         sAxisMaster => iaxisObMaster,
         sAxisCtrl   => iaxisObCtrl,
         mAxisClk    => axisObClk,
         mAxisRst    => axisObClkRst,
         mAxisMaster => axisObMaster,
         mAxisSlave  => axisObSlave
      );

end architecture structure;

