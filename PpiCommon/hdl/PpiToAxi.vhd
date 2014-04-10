-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI To AXI Bridge
-- File          : PpiToAxi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to receive and transmit AXI bus frames. Supports a local 
-- multi-port AXI4-Lite bus.
--
-- Outbound PPI Message Format
--    Word 0:
--       31:00 = Base Address
--       35:32 = First Word Byte Enables (write)
--       39:36 = Last  Word Byte Enables (write) (ignored for length = 0)
--       42:40 = Prot Value (usually not used)
--          43 = Write Bit (set to 1 for writes) 
--       63:56 = Burst length, 0 = 1x32, 1 = 2x32, ... (up to 256)
--    Word 1:
--       31:00 = Value 0 (if write)
--       63:32 = Value 1 (if write)
--    (data continues for writes depending on burst length)
--
-- Inbound PPI Message Format
--    Word 0: (echoed from outbound frame)
--       31:00 = Base Address
--       35:32 = First Word Byte Enables (write)
--       39:36 = Last  Word Byte Enables (write)
--       42:40 = Prot Value
--          43 = Write Bit (set to 1 for writes) (echoed)
--       63:56 = Burst length, Echo, 0 = 1x32, 1 = 2x32, ...
--    Word 1:
--       31:00 = Value 0 (if read)
--       63:32 = Value 1 (if read)
--    (data continues for reads depending on burst length)
--    Word n (last 64-bit word sent):
--          00 = UnderFlow Error (too few words for write length)
--          01 = OverFlow Error (too many words fro write length or read)
--       05:04 = Result Value from AXI transaction
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

entity PpiToAxi is
   generic (
      TPD_G                  : time                       := 1 ns;
      PPI_ADDR_WIDTH_G       : integer range 2 to 48      := 6;  -- 64 entries
      PPI_PAUSE_THOLD_G      : integer range 1 to (2**24) := 32  -- 32 entries
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

      -- AXI Lite Busses
      axiClk           : in  sl;
      axiClkRst        : in  sl;
      axiWriteMaster   : out AxiLiteWriteMasterType;
      axiWriteSlave    : in  AxiLiteWriteSlaveType;
      axiReadMaster    : out AxiLiteReadMasterType;
      axiReadSlave     : in  AxiLiteReadSlaveType
   );
end PpiToAxi;

architecture structure of PpiToAxi is

   -- Local signals
   signal intReadToFifo    : PpiReadToFifoType;
   signal intReadFromFifo  : PpiReadFromFifoType;
   signal intWriteToFifo   : PpiWriteToFifoType;
   signal intWriteFromFifo : PpiWriteFromFifoType;
   signal intOnline        : sl;

   type StateType is (S_IDLE_C, S_START_C, S_WRITE_C, S_WRITE_AXI_C, S_READ_C, S_READ_AXI_C, S_STATUS_C, S_DUMP_C );

   type RegType is record
      address        : slv(31 downto 0);
      firstStrb      : slv(3  downto 0);
      lastStrb       : slv(3  downto 0);
      prot           : slv(2  downto 0);
      write          : sl;
      ftype          : slv(3  downto 0);
      length         : slv(7  downto 0);
      count          : slv(7  downto 0);
      state          : StateType;
      result         : slv(1  downto 0);
      underflow      : sl;
      overflow       : sl;
      status         : slv(1 downto 0);
      axiWriteMaster : AxiLiteWriteMasterType;
      axiReadMaster  : AxiLiteReadMasterType;
      ppiReadToFifo  : PpiReadToFifoType;
      ppiWriteToFifo : ppiWriteToFifoType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      address        => (others => '0'),
      firstStrb      => (others => '0'),
      lastStrb       => (others => '0'),
      prot           => (others => '0'),
      write          => '0',
      ftype          => (others => '0'),
      length         => (others => '0'),
      count          => (others => '0'),
      state          => S_IDLE_C,
      result         => (others => '0'),
      underflow      => '0',
      overflow       => '0',
      status         => (others => '0'),
      axiWriteMaster => AXI_LITE_WRITE_MASTER_INIT_C,
      axiReadMaster  => AXI_LITE_READ_MASTER_INIT_C,
      ppiReadToFifo  => PPI_READ_TO_FIFO_INIT_C,
      ppiWriteToFifo => PPI_WRITE_TO_FIFO_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   ------------------------------------
   -- FIFOs
   ------------------------------------

   U_InFifo : entity work.PpiFifoAsync
      generic map (
         TPD_G          => TPD_G,
         BRAM_EN_G      => true,
         USE_DSP48_G    => "no",
         SYNC_STAGES_G  => 3,
         ADDR_WIDTH_G   => PPI_ADDR_WIDTH_G,
         PAUSE_THOLD_G  => PPI_PAUSE_THOLD_G,
         READY_THOLD_G  => 0,
         FIFO_TYPE_EN_G => false
      ) port map (
         ppiWrClk         => ppiClk,
         ppiWrClkRst      => ppiClkRst,
         ppiWrOnline      => ppiOnline,
         ppiWriteToFifo   => ppiWriteToFifo,
         ppiWriteFromFifo => ppiWriteFromFifo,
         ppiRdClk         => axiClk,
         ppiRdClkRst      => axiClkRst,
         ppiRdOnline      => intOnline,
         ppiReadToFifo    => intReadToFifo,
         ppiReadFromFifo  => intReadFromFifo
      );

   U_OutFifo : entity work.PpiFifoAsync
      generic map (
         TPD_G          => TPD_G,
         BRAM_EN_G      => true,
         USE_DSP48_G    => "no",
         SYNC_STAGES_G  => 3,
         ADDR_WIDTH_G   => PPI_ADDR_WIDTH_G,
         PAUSE_THOLD_G  => PPI_PAUSE_THOLD_G,
         READY_THOLD_G  => 0,
         FIFO_TYPE_EN_G => false
      ) port map (
         ppiWrClk         => axiClk,
         ppiWrClkRst      => axiClkRst,
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
   -- AXI Messages
   ------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRst, r, intReadFromFifo, intWriteFromFifo, axiReadSlave, axiWriteSlave, intOnline ) is
      variable v         : RegType;
   begin
      v := r;

      -- Init
      v.ppiWriteToFifo.valid := '0';
      v.ppiReadToFifo.read  := '0';

      -- State Machine
      case r.state is

         -- Idle
         when S_IDLE_C =>
            v.axiWriteMaster := AXI_LITE_WRITE_MASTER_INIT_C;
            v.axiReadMaster  := AXI_LITE_READ_MASTER_INIT_C;
            v.ppiReadToFifo  := PPI_READ_TO_FIFO_INIT_C;
            v.ppiWriteToFifo := PPI_WRITE_TO_FIFO_INIT_C;
            v.result         := (others => '0');
            v.underflow      := '0';
            v.overflow       := '0';
            v.count          := (others=>'0');

            -- Value is ready on PPI interface
            if intReadFromFifo.valid = '1' and intReadFromFifo.ready = '1' and intWriteFromFifo.pause = '0' then
               v.address   := intReadFromFifo.data(31 downto  0);
               v.firstStrb := intReadFromFifo.data(35 downto 32);
               v.lastStrb  := intReadFromFifo.data(39 downto 36);
               v.prot      := intReadFromFifo.data(42 downto 40);
               v.write     := intReadFromFifo.data(43);
               v.ftype     := intReadFromFifo.ftype;
               v.length    := intReadFromFifo.data(63 downto 56);
               v.state     := S_START_C;
            end if;

         -- Start Transaction
         when S_START_C =>

            -- Echo Transaction Data
            v.ppiWriteToFifo.data(31 downto  0) := r.address;
            v.ppiWriteToFifo.data(35 downto 32) := r.firstStrb;
            v.ppiWriteToFifo.data(39 downto 36) := r.lastStrb;
            v.ppiWriteToFifo.data(42 downto 40) := r.prot;
            v.ppiWriteToFifo.data(43)           := r.write;
            v.ppiWriteToFifo.data(55 downto 52) := (others=>'0');
            v.ppiWriteToFifo.data(63 downto 56) := r.length;
            v.ppiWriteToFifo.size               := "111";
            v.ppiWriteToFifo.eof                := '0';
            v.ppiWriteToFifo.eoh                := '0';
            v.ppiWriteToFifo.err                := '0';
            v.ppiWriteToFifo.ftype              := r.ftype;
            v.ppiWriteToFifo.valid              := '1';

            -- Setup AXI
            v.axiWriteMaster.awaddr := r.address;
            v.axiReadMaster.araddr  := r.address;
            v.axiWriteMaster.awprot := r.prot;
            v.axiReadMaster.arprot  := r.prot;

            -- Write transaction
            if r.write = '1' then

               -- Should not be EOF
               if intReadFromFifo.eof = '1' then
                  v.underflow := '1';
                  v.state     := S_STATUS_C;
               else
                  v.state     := S_WRITE_C;
               end if;

            -- Read transaction
            else

               -- Should be EOF
               if intReadFromFifo.eof = '0' then
                  v.overflow := '1';
               end if;

               v.state := S_READ_C;
            end if;

            -- Advance FIFO
            v.ppiReadToFifo.read := '1';

         -- Write Transaction
         when S_WRITE_C =>

            -- Determine write strobe
            if r.count = 0 then
               v.axiWriteMaster.wstrb := r.firstStrb;
            elsif r.count = r.length then
               v.axiWriteMaster.wstrb := r.lastStrb;
            else
               v.axiWriteMaster.wstrb := (others=>'1');
            end if;
          
            -- Determine data source 
            if r.count(0) = '0' then
               v.axiWriteMaster.wdata := intReadFromFifo.data(31 downto  0);
            else 
               v.axiWriteMaster.wdata := intReadFromFifo.data(63 downto 32);
            end if;

            -- Check for data overflow 
            if r.count = r.length and intReadFromFifo.eof = '0' then
               v.overflow := '1';
            end if;

            -- Check for data underflow
            if r.count(7 downto 1) /= r.length(7 downto 1) and intReadFromFifo.eof = '1' then
               v.underflow := '1';
            end if;

            -- Advance FIFO
            if r.count(0) = '1' or r.count = r.length then
               v.ppiReadToFifo.read := '1';
            end if;

            -- Process AXI transaction
            v.axiWriteMaster.awvalid := '1';
            v.axiWriteMaster.wvalid  := '1';
            v.axiWriteMaster.bready  := '1';
            v.state                  := S_WRITE_AXI_C;

         -- Write Transaction, AXI
         when S_WRITE_AXI_C =>

            -- Clear control signals on ack
            if axiWriteSlave.awready = '1' then
               v.axiWriteMaster.awvalid := '0';
            end if;
            if axiWriteSlave.wready = '1' then
               v.axiWriteMaster.wvalid := '0';
            end if;
            if axiWriteSlave.bvalid = '1' then
               v.axiWriteMaster.bready := '0';
               v.status := axiWriteSlave.bresp;
            end if;

            -- Transaction is done
            if v.axiWriteMaster.awvalid = '0' and v.axiWriteMaster.wvalid = '0' and v.axiWriteMaster.bready = '0' then
               v.axiWriteMaster.awaddr := r.axiWriteMaster.awaddr + 4;
               v.count                 := r.count + 1;

               if r.underflow = '1' or r.count = r.length then
                  v.state := S_STATUS_C;
               else
                  v.state := S_WRITE_C;
               end if;
            end if;

         -- Read transaction
         when S_READ_C =>

            -- Start AXI transaction
            v.axiReadMaster.arvalid := '1';
            v.axiReadMaster.rready  := '1';
            v.state                 := S_READ_AXI_C;

         -- Read AXI
         when S_READ_AXI_C =>

            -- Clear control signals on ack
            if axiReadSlave.arready = '1' then
               v.axiReadMaster.arvalid := '0';
            end if;
            if axiReadSlave.rvalid = '1' then
               v.axiReadMaster.rready := '0';
            end if;

            -- Store data
            if r.count(0) = '0' then
               v.ppiWriteToFifo.data(31 downto 00) := axiReadSlave.rdata;
            else
               v.ppiWriteToFifo.data(63 downto 32) := axiReadSlave.rdata;
            end if;

            -- Store Status
            v.status := axiReadSlave.rresp;

            -- Transaction is done
            if v.axiReadMaster.arvalid = '0' and v.axiReadMaster.rready = '0' then
               v.axiReadMaster.araddr  := r.axiReadMaster.araddr + 4;
               v.count                 := r.count + 1;

               -- Completed
               if r.count = r.length then
                  v.ppiWriteToFifo.valid := '1';
                  v.state                := S_STATUS_C;
               else
                  v.state := S_READ_C;
               end if;

               -- Even word
               if r.count(0) = '1' then
                  v.ppiWriteToFifo.valid := '1';
               end if;
            end if;

         -- Send Status and complete frame
         when S_STATUS_C =>
            v.ppiWriteToFifo.data(00)           := r.underflow;
            v.ppiWriteToFifo.data(01)           := r.overflow;
            v.ppiWriteToFifo.data(03 downto 02) := (others=>'0');
            v.ppiWriteToFifo.data(05 downto 04) := r.status;
            v.ppiWriteToFifo.data(63 downto 06) := (others=>'0');
            v.ppiWriteToFifo.eof                := '1';
            v.ppiWriteToFifo.eoh                := '1';
            v.ppiWriteToFifo.valid              := '1';

            -- Dump if overflow
            if r.overflow = '1' then
               v.state := S_DUMP_C;
            else
               v.state := S_IDLE_C;
            end if;

         -- Dump until EOF
         when S_DUMP_C =>
            v.ppiReadToFifo.read := '1';

            if intReadFromFifo.eof = '1' then
               v.state := S_IDLE_C;
            end if;

         when others =>
            v.state := S_IDLE_C;

      end case;

      -- Reset
      if axiClkRst = '1' or intOnline = '0' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadMaster  <= r.axiReadMaster;
      axiWriteMaster <= r.axiWriteMaster;
      intReadToFifo  <= v.ppiReadToFifo;
      intWriteToFifo <= r.ppiWriteToFifo;  

   end process;

end architecture structure;

