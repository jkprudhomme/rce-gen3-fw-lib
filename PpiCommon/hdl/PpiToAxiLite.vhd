-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI To AXI-Lite Bridge
-- File          : PpiToAxiLite.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive and transmit AXI bus frames. Supports a local 
-- multi-port AXI4-Lite bus.
--
-- Outbound PPI Message Format
--    Word 0:
--       31:00 = Context Value (echoed)
--       63:32 = Unused (echoed)
--    Word 1:
--       31:00 = Base Address
--       35:32 = First Word Byte Enables (write)
--       39:36 = Last  Word Byte Enables (write) (ignored for length = 0)
--       42:40 = Prot Value (usually not used)
--          43 = Write Bit (set to 1 for writes) 
--       60:56 = Burst length, 0 = 1x32, 1 = 2x32, ... (up to 32)
--       63:61 = Unused
--    Word 2:
--       31:00 = Value 0 (if write)
--       63:32 = Value 1 (if write)
--    (data continues for writes depending on burst length)
--
-- Inbound PPI Message Format
--    Word 0:
--       31:00 = Context Value (echoed)
--       63:32 = Unused (echoed)
--    Word 1: (echoed from outbound frame)
--       31:00 = Base Address
--       35:32 = First Word Byte Enables (write)
--       39:36 = Last  Word Byte Enables (write)
--       42:40 = Prot Value
--          43 = Write Bit (set to 1 for writes) (echoed)
--       60:56 = Burst length, 0 = 1x32, 1 = 2x32, ... (up to 32)
--       63:61 = Unused
--    Word 2:
--       31:00 = Value 0 (if read)
--       63:32 = Value 1 (if read)
--    (data continues for reads depending on burst length)
--    Word n (last 64-bit word sent):
--          00 = UnderFlow Error (too few words for write length)
--          01 = OverFlow Error (too many words fro write length or read)
--       05:04 = Result Value from AXI transaction
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
-- 03/21/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

use work.PpiPkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity PpiToAxiLite is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- PPI Interface
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiIbMaster      : out AxiStreamMasterType;
      ppiIbSlave       : in  AxiStreamSlaveType;
      ppiObMaster      : in  AxiStreamMasterType;
      ppiObSlave       : out AxiStreamSlaveType;

      -- AXI Lite Busses
      axilClk          : in  sl;
      axilClkRst       : in  sl;
      axilWriteMaster  : out AxiLiteWriteMasterType;
      axilWriteSlave   : in  AxiLiteWriteSlaveType;
      axilReadMaster   : out AxiLiteReadMasterType;
      axilReadSlave    : in  AxiLiteReadSlaveType
   );
end PpiToAxiLite;

architecture structure of PpiToAxiLite is

   -- Local signals
   signal intIbMaster      : AxiStreamMasterType;
   signal intIbCtrl        : AxiStreamCtrlType;
   signal intObMaster      : AxiStreamMasterType;
   signal intObSlave       : AxiStreamSlaveType;

   type StateType is (S_IDLE_C, S_CTX_C, S_ADDR_C, S_START_C, 
                      S_WRITE_C, S_WRITE_AXI_C, 
                      S_READ_C, S_READ_AXI_C, 
                      S_STATUS_C, S_DUMP_C );

   type RegType is record
      address         : slv(31 downto 0);
      firstStrb       : slv(3  downto 0);
      lastStrb        : slv(3  downto 0);
      prot            : slv(2  downto 0);
      write           : sl;
      length          : slv(4  downto 0);
      count           : slv(4  downto 0);
      state           : StateType;
      result          : slv(1  downto 0);
      underflow       : sl;
      overflow        : sl;
      status          : slv(1 downto 0);
      axilWriteMaster : AxiLiteWriteMasterType;
      axilReadMaster  : AxiLiteReadMasterType;
      intIbMaster     : AxiStreamMasterType;
      intObSlave      : AxiStreamSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      address         => (others => '0'),
      firstStrb       => (others => '0'),
      lastStrb        => (others => '0'),
      prot            => (others => '0'),
      write           => '0',
      length          => (others => '0'),
      count           => (others => '0'),
      state           => S_IDLE_C,
      result          => (others => '0'),
      underflow       => '0',
      overflow        => '0',
      status          => (others => '0'),
      axilWriteMaster => AXI_LITE_WRITE_MASTER_INIT_C,
      axilReadMaster  => AXI_LITE_READ_MASTER_INIT_C,
      intIbMaster     => AXI_STREAM_MASTER_INIT_C,
      intObSlave      => AXI_STREAM_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   ------------------------------------
   -- FIFOs
   ------------------------------------
   U_InFifo : entity work.AxiStreamFifoV2
      generic map (
         TPD_G                => TPD_G,
         INT_PIPE_STAGES_G    => 1,
         PIPE_STAGES_G        => 1,
         SLAVE_READY_EN_G     => true,
         VALID_THOLD_G        => 1,
         BRAM_EN_G            => true,
         XIL_DEVICE_G         => "7SERIES",
         USE_BUILT_IN_G       => false,
         GEN_SYNC_FIFO_G      => false,
         CASCADE_SIZE_G       => 1,
         FIFO_ADDR_WIDTH_G    => 9,
         FIFO_FIXED_THRESH_G  => true,
         FIFO_PAUSE_THRESH_G  => 500,
         SLAVE_AXI_CONFIG_G   => PPI_AXIS_CONFIG_INIT_C,
         MASTER_AXI_CONFIG_G  => PPI_AXIS_CONFIG_INIT_C 
      ) port map (
         sAxisClk        => ppiClk,
         sAxisRst        => ppiClkRst,
         sAxisMaster     => ppiObMaster,
         sAxisSlave      => ppiObSlave,
         sAxisCtrl       => open,
         mAxisClk        => axilClk,
         mAxisRst        => axilClkRst,
         mAxisMaster     => intObMaster,
         mAxisSlave      => intObSlave
      );

   U_OutFifo : entity work.AxiStreamFifoV2 
      generic map (
         TPD_G                => TPD_G,
         INT_PIPE_STAGES_G    => 1,
         PIPE_STAGES_G        => 1,
         SLAVE_READY_EN_G     => false,
         VALID_THOLD_G        => 1,
         BRAM_EN_G            => true,
         XIL_DEVICE_G         => "7SERIES",
         USE_BUILT_IN_G       => false,
         GEN_SYNC_FIFO_G      => false,
         CASCADE_SIZE_G       => 1,
         FIFO_ADDR_WIDTH_G    => 9,
         FIFO_FIXED_THRESH_G  => true,
         FIFO_PAUSE_THRESH_G  => 255,
         SLAVE_AXI_CONFIG_G   => PPI_AXIS_CONFIG_INIT_C,
         MASTER_AXI_CONFIG_G  => PPI_AXIS_CONFIG_INIT_C 
      ) port map (
         sAxisClk        => axilClk,
         sAxisRst        => axilClkRst,
         sAxisMaster     => intIbMaster,
         sAxisSlave      => open,
         sAxisCtrl       => intIbCtrl,
         mAxisClk        => ppiClk,
         mAxisRst        => ppiClkRst,
         mAxisMaster     => ppiIbMaster,
         mAxisSlave      => ppiIbSlave
      );


   ------------------------------------
   -- AXI Messages
   ------------------------------------

   -- Sync
   process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process ( axilClkRst, r, intObMaster, intIbCtrl, axilReadSlave, axilWriteSlave ) is
      variable v : RegType;
   begin
      v := r;

      -- Init
      v.intIbMaster.tValid := '0';
      v.intObSlave.tReady  := '0';

      -- State Machine
      case r.state is

         -- Idle
         when S_IDLE_C =>
            v.axilWriteMaster := AXI_LITE_WRITE_MASTER_INIT_C;
            v.axilReadMaster  := AXI_LITE_READ_MASTER_INIT_C;
            v.intIbMaster     := AXI_STREAM_MASTER_INIT_C;
            v.intObSlave      := AXI_STREAM_SLAVE_INIT_C;
            v.result          := (others => '0');
            v.underflow       := '0';
            v.overflow        := '0';
            v.count           := (others=>'0');

            -- Value is ready on PPI interface
            if intObMaster.tValid = '1' and intIbCtrl.pause = '0' then
               v.state := S_CTX_C;
            end if;

         when S_CTX_C =>

            -- Echo Transaction Data
            v.intIbMaster       := intObMaster;
            v.intIbMaster.tLast := '0';
            v.intIbMaster.tUser := (others=>'0');
            v.intObSlave.tReady := '1';

            -- Should not be EOF
            if intObMaster.tLast = '1' then
               v.state              := S_IDLE_C;
               v.intIbMaster.tValid := '0';
            else
               v.state := S_ADDR_C;
            end if;

         when S_ADDR_C =>
            v.intIbMaster := AXI_STREAM_MASTER_INIT_C;
            v.intObSlave  := AXI_STREAM_SLAVE_INIT_C;

            -- Value is ready on PPI interface
            if intObMaster.tValid = '1' then
               v.address   := intObMaster.tData(31 downto  0);
               v.firstStrb := intObMaster.tData(35 downto 32);
               v.lastStrb  := intObMaster.tData(39 downto 36);
               v.prot      := intObMaster.tData(42 downto 40);
               v.write     := intObMaster.tData(43);
               v.length    := intObMaster.tData(60 downto 56);
               v.state     := S_START_C;
            end if;

         -- Start Transaction
         when S_START_C =>

            -- Echo Transaction Data
            v.intIbMaster       := intObMaster;
            v.intIbMaster.tLast := '0';
            v.intIbMaster.tUser := (others=>'0');
            v.intObSlave.tReady := '1';

            -- Setup AXI
            v.axilWriteMaster.awaddr := r.address;
            v.axilReadMaster.araddr  := r.address;
            v.axilWriteMaster.awprot := r.prot;
            v.axilReadMaster.arprot  := r.prot;

            -- Write transaction
            if r.write = '1' then

               -- Should not be EOF
               if intObMaster.tLast = '1' then
                  v.underflow := '1';
                  v.state     := S_STATUS_C;
               else
                  v.state     := S_WRITE_C;
               end if;

            -- Read transaction
            else

               -- Should be EOF
               if intObMaster.tLast = '0' then
                  v.overflow := '1';
               end if;

               v.state := S_READ_C;
            end if;


         -- Write Transaction
         when S_WRITE_C =>

            -- Echo Data
            v.intIbMaster        := intObMaster;
            v.intIbMaster.tValid := '0';
            v.intIbMaster.tLast  := '0';
            v.intIbMaster.tUser  := (others=>'0');

            -- Determine write strobe
            if r.count = 0 then
               v.axilWriteMaster.wstrb := r.firstStrb;
            elsif r.count = r.length then
               v.axilWriteMaster.wstrb := r.lastStrb;
            else
               v.axilWriteMaster.wstrb := (others=>'1');
            end if;
          
            -- Determine data source 
            if r.count(0) = '0' then
               v.axilWriteMaster.wdata := intObMaster.tData(31 downto  0);
            else 
               v.axilWriteMaster.wdata := intObMaster.tData(63 downto 32);
            end if;

            -- Advance when FIFO is ready
            if intObMaster.tValid = '1' then

               -- Check for data overflow 
               if r.count = r.length and intObMaster.tLast = '0' then
                  v.overflow := '1';
               end if;

               -- Check for data underflow
               if r.count(4 downto 1) /= r.length(4 downto 1) and intObMaster.tLast = '1' then
                  v.underflow := '1';
               end if;

               -- Advance FIFO
               if r.count(0) = '1' or r.count = r.length then
                  v.intObSlave.tReady  := '1';
                  v.intIbMaster.tValid := '1';
               end if;

               -- Process AXI transaction
               v.axilWriteMaster.awvalid := '1';
               v.axilWriteMaster.wvalid  := '1';
               v.axilWriteMaster.bready  := '1';
               v.state                   := S_WRITE_AXI_C;
            end if;

         -- Write Transaction, AXI
         when S_WRITE_AXI_C =>

            -- Clear control signals on ack
            if axilWriteSlave.awready = '1' then
               v.axilWriteMaster.awvalid := '0';
            end if;
            if axilWriteSlave.wready = '1' then
               v.axilWriteMaster.wvalid := '0';
            end if;
            if axilWriteSlave.bvalid = '1' then
               v.axilWriteMaster.bready := '0';
               v.status := axilWriteSlave.bresp;
            end if;

            -- Transaction is done
            if v.axilWriteMaster.awvalid = '0' and v.axilWriteMaster.wvalid = '0' and v.axilWriteMaster.bready = '0' then
               v.axilWriteMaster.awaddr := r.axilWriteMaster.awaddr + 4;
               v.count                  := r.count + 1;

               if r.underflow = '1' or r.count = r.length then
                  v.state := S_STATUS_C;
               else
                  v.state := S_WRITE_C;
               end if;
            end if;

         -- Read transaction
         when S_READ_C =>

            -- Start AXI transaction
            v.axilReadMaster.arvalid := '1';
            v.axilReadMaster.rready  := '1';
            v.state                  := S_READ_AXI_C;

         -- Read AXI
         when S_READ_AXI_C =>

            -- Clear control signals on ack
            if axilReadSlave.arready = '1' then
               v.axilReadMaster.arvalid := '0';
            end if;
            if axilReadSlave.rvalid = '1' then
               v.axilReadMaster.rready := '0';
            end if;

            -- Store data
            if r.count(0) = '0' then
               v.intIbMaster.tData(31 downto 00) := axilReadSlave.rdata;
               v.intIbMaster.tData(63 downto 32) := (others=>'0');
            else
               v.intIbMaster.tData(63 downto 32) := axilReadSlave.rdata;
            end if;
            v.intIbMaster.tLast := '0';
            v.intIbMaster.tUser := (others=>'0');

            -- Store Status
            v.status := axilReadSlave.rresp;

            -- Transaction is done
            if v.axilReadMaster.arvalid = '0' and v.axilReadMaster.rready = '0' then
               v.axilReadMaster.araddr := r.axilReadMaster.araddr + 4;
               v.count                 := r.count + 1;

               -- Completed
               if r.count = r.length then
                  v.intIbMaster.tValid := '1';
                  v.state              := S_STATUS_C;
               else
                  v.state := S_READ_C;
               end if;

               -- Even word
               if r.count(0) = '1' then
                  v.intIbMaster.tValid := '1';
               end if;
            end if;

         -- Send Status and complete frame
         when S_STATUS_C =>
            v.intIbMaster.tData(00)           := r.underflow;
            v.intIbMaster.tData(01)           := r.overflow;
            v.intIbMaster.tData(03 downto 02) := (others=>'0');
            v.intIbMaster.tData(05 downto 04) := r.status;
            v.intIbMaster.tData(63 downto 06) := (others=>'0');
            v.intIbMaster.tLast               := '1';
            v.intIbMaster.tUser               := (others=>'0');
            v.intIbMaster.tValid              := '1';

            -- Dump if overflow
            if r.overflow = '1' then
               v.state := S_DUMP_C;
            else
               v.state := S_IDLE_C;
            end if;

         -- Dump until EOF
         when S_DUMP_C =>
            v.intObSlave.tReady := '1';

            if intObMaster.tLast = '1' then
               v.state := S_IDLE_C;
            end if;

         when others =>
            v.state := S_IDLE_C;

      end case;

      -- Reset
      if axilClkRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axilReadMaster  <= r.axilReadMaster;
      axilWriteMaster <= r.axilWriteMaster;
      intIbMaster     <= r.intIbMaster;
      intObSlave      <= v.intObSlave;

   end process;

end architecture structure;

