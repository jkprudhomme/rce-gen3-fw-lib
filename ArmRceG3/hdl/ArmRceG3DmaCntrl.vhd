-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, DMA Controller
-- File          : ArmRceG3DmaCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level DMA controller
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
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

entity ArmRceG3DmaCntrl is
   generic (
      TPD_G             : time                     := 1 ns;
      PPI_READY_THOLD_G : IntegerArray(3 downto 0) := (others=>0)
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- AXI ACP Master
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;
      axiAcpSlaveReadFromArm  : in  AxiReadSlaveType;
      axiAcpSlaveReadToArm    : out AxiReadMasterType;

      -- AXI HP Masters
      axiHpSlaveWriteFromArm  : in  AxiWriteSlaveArray(3 downto 0);
      axiHpSlaveWriteToArm    : out AxiWriteMasterArray(3 downto 0);
      axiHpSlaveReadFromArm   : in  AxiReadSlaveArray(3 downto 0);
      axiHpSlaveReadToArm     : out AxiReadMasterArray(3 downto 0);

      -- Interrupts
      interrupt               : out slv(15 downto 0);

      -- Local AXI Lite Busses
      localAxiReadMaster      : in  AxiLiteReadMasterArray(2 downto 0);
      localAxiReadSlave       : out AxiLiteReadSlaveArray(2 downto 0);
      localAxiWriteMaster     : in  AxiLiteWriteMasterArray(2 downto 0);
      localAxiWriteSlave      : out AxiLiteWriteSlaveArray(2 downto 0);

      -- PPI Clock and online status
      ppiClk                  : in  slv(3 downto 0);
      ppiOnline               : out slv(3 downto 0);

      -- PPI Read Interface
      ppiReadToFifo           : in  PpiReadToFifoArray(3 downto 0);
      ppiReadFromFifo         : out PpiReadFromFifoArray(3 downto 0);

      -- PPI Write Interface
      ppiWriteToFifo          : in  PpiWriteToFifoArray(3 downto 0);
      ppiWriteFromFifo        : out PpiWriteFromFifoArray(3 downto 0);

      -- PPI quad word FIFO
      bsiToFifo               : in  QWordToFifoType;
      bsiFromFifo             : out QWordFromFifoType
   );
end ArmRceG3DmaCntrl;

architecture structure of ArmRceG3DmaCntrl is

   -- Local signals
   signal obFifoToFifo        : ObHeaderToFifoArray(3 downto 0);
   signal obFifoFromFifo      : ObHeaderFromFifoArray(3 downto 0);
   signal ibFifoToFifo        : IbHeaderToFifoArray(3 downto 0);
   signal ibFifoFromFifo      : IbHeaderFromFifoArray(3 downto 0);
   signal dirtyFlag           : slv(4  downto 0);
   signal compFromFifo        : CompFromFifoArray(7 downto 0);
   signal compToFifo          : CompToFifoArray(7 downto 0);
   signal compInt             : slv(10 downto 0);
   signal axiClkRstInt        : sl := '1';

   type RegType is record
      dirtyFlagClrEn      : sl;
      dirtyFlagClrSel     : slv(2  downto 0);
      ibHeaderPtrWrite    : slv(3  downto 0);
      ibPpiPtrWrite       : slv(3  downto 0);
      obHeaderPtrWrite    : slv(3  downto 0);
      genPtrData          : slv(35 downto 0); 
      fifoEnable          : slv(8  downto  0);
      memBaseAddress      : slv(31 downto 18);
      writeDmaCache       : slv(3 downto 0);
      readDmaCache        : slv(3 downto 0);
      intEnable           : slv(15  downto 0);
      ppiReadDmaCache     : slv(3 downto 0);
      ppiWriteDmaCache    : slv(3 downto 0);
      ppiOnline           : slv(3 downto 0);
      axiClkRstSw         : sl;
      localAxiReadSlave   : AxiLiteReadSlaveType;
      localAxiWriteSlave  : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      dirtyFlagClrEn      => '0',
      dirtyFlagClrSel     => (others=>'0'),
      ibHeaderPtrWrite    => (others=>'0'),
      ibPpiPtrWrite       => (others=>'0'),
      obHeaderPtrWrite    => (others=>'0'),
      genPtrData          => (others=>'0'),
      fifoEnable          => (others=>'0'),
      memBaseAddress      => (others=>'0'),
      writeDmaCache       => (others=>'0'),
      readDmaCache        => (others=>'0'),
      intEnable           => (others=>'0'),
      ppiReadDmaCache     => (others=>'0'),
      ppiWriteDmaCache    => (others=>'0'),
      ppiOnline           => (others=>'0'),
      axiClkRstSw         => '0',
      localAxiReadSlave   => AXI_LITE_READ_SLAVE_INIT_C,
      localAxiWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal is "true";

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst or r.axiClkRstSw after TPD_G;
      end if;
   end process;

   -- Interrupts
   interrupt <= (compInt & dirtyFlag) and r.intEnable;

   --------------------------------------------
   -- Registers: 0x8800_0000 - 0x8BFF_FFFF
   --------------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRstInt, localAxiReadMaster(0), localAxiWriteMaster(0), compInt, dirtyFlag, r ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      -- Init
      v.genPtrData(35 downto 32) := localAxiWriteMaster(0).awaddr(5 downto 2);
      v.genPtrData(31 downto  0) := localAxiWriteMaster(0).wdata;
      v.ibHeaderPtrWrite         := (others=>'0');
      v.obHeaderPtrWrite         := (others=>'0');
      v.dirtyFlagClrEn           := '0';
      v.dirtyFlagClrSel          := localAxiWriteMaster(0).awaddr(4 downto 2);
      v.ibPpiPtrWrite            := (others=>'0');

      axiSlaveWaitTxn(localAxiWriteMaster(0), localAxiReadMaster(0), v.localAxiWriteSlave, v.localAxiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (localAxiWriteMaster(0).awaddr(11 downto 8)) is

            -- Inbound header free list entries, 64 total (4 * 16) - 0x88000100 - 0x880001FF
            when X"1" =>
               v.ibHeaderPtrWrite(conv_integer(localAxiWriteMaster(0).awaddr(7 downto 6))) := '1';

            -- Outbound header tx list entries, 64 total (4 * 16) - 0x88000200 - 0x880002FF
            when X"2" =>
               v.obHeaderPtrWrite(conv_integer(localAxiWriteMaster(0).awaddr(7 downto 6))) := '1';

            -- Channel Dirty flags clear, 5 - 0x88000300 - 0x88000310
            -- One per quad word memory channel
            when X"3" =>
               v.dirtyFlagClrEn := '1';

            -- Single entry registers, 0x880004xx
            when X"4" =>
               case (localAxiWriteMaster(0).awaddr(7 downto 0)) is

                  -- Interrupt Enable, 16 bits, 0x88000404
                  when X"04" =>
                     v.intEnable := localAxiWriteMaster(0).wdata(15 downto 0);

                  -- AXI Write DMA Cache Config, single location, 0x88000408
                  when X"08" =>
                     v.writeDmaCache := localAxiWriteMaster(0).wdata(3 downto 0);

                  -- AXI Read DMA Cache Config, single location, 0x8800040C
                  when X"0C" =>
                     v.readDmaCache := localAxiWriteMaster(0).wdata(3 downto 0);

                  -- FIFO Enable, 20 bits - 0x88000410
                  -- Bits 3:0   = inbound header FIFOs
                  -- Bits 4     = BSI FIFO
                  -- Bits 8:5   = outbound header FIFOs
                  -- Bits 31    = Reset
                  when X"10" =>
                     v.fifoEnable  := localAxiWriteMaster(0).wdata(8 downto 0);
                     v.axiClkRstSw := localAxiWriteMaster(0).wdata(31);

                  -- Memory base address 0x88000418
                  when X"18" =>
                     v.memBaseAddress := localAxiWriteMaster(0).wdata(31 downto 18);

                  -- PPI Read DMA Cache 0x8800041C
                  when X"1C" =>
                     v.ppiReadDmaCache := localAxiWriteMaster(0).wdata(3 downto 0);

                  -- PPI Write DMA Cache 0x88000420
                  when X"20" =>
                     v.ppiWriteDmaCache := localAxiWriteMaster(0).wdata(3 downto 0);

                  -- PPI online control, 8-bits - 0x88000424 
                  when X"24" =>
                     v.ppiOnline := localAxiWriteMaster(0).wdata(3 downto 0);

                  when others => null;
               end case;

            -- Inbound ppi pointer entries, 64 total (4 * 16) - 0x88000500 - 0x880005FF
            when X"5" =>
               v.ibPpiPtrWrite(conv_integer(localAxiWriteMaster(0).awaddr(7 downto 6))) := '1';

            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.localAxiWriteSlave );
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.localAxiReadSlave.rdata := (others => '0');

         -- Decode address and perform write
         case (localAxiReadMaster(0).araddr(11 downto 0)) is

            -- Dirty/Ready status, 16 bits 0x88000400
            -- Bits 3:0   = inbound header FIFOs
            -- Bits 4     = BSI FIFO
            -- Bits 15:5  = completion FIFOs
            when X"400" =>
               v.localAxiReadSlave.rdata(15 downto 5) := compInt;
               v.localAxiReadSlave.rdata(4  downto 0) := dirtyFlag;

            -- Interrupt Enable, 16 bits, 0x88000404
            when X"404" =>
               v.localAxiReadSlave.rdata(15 downto 0) := r.intEnable;

            -- AXI Write DMA Cache Config, single location, 0x88000408
            when X"408" =>
               v.localAxiReadSlave.rdata(3 downto 0) := r.writeDmaCache;

            -- AXI Read DMA Cache Config, single location, 0x8800040C
            when X"40C" =>
               v.localAxiReadSlave.rdata(3 downto 0) := r.readDmaCache;

            -- FIFO Enable, 20 bits - 0x88000410
            -- Bits 3:0   = inbound header FIFOs
            -- Bits 4     = BSI FIFO
            -- Bits 8:5   = outbound header FIFOs
            -- Bits 31    = Reset
            when X"410" =>
               v.localAxiReadSlave.rdata(8 downto 0) := r.fifoEnable;
               v.localAxiReadSlave.rdata(31)         := r.axiClkRstSw;

            -- Memory base address 0x88000418
            when X"418" =>
               v.localAxiReadSlave.rdata(31 downto 18) := r.memBaseAddress;

            -- PPI Read DMA Cache 0x8800041C
            when X"41C" =>
               v.localAxiReadSlave.rdata(3 downto 0) := r.ppiReadDmaCache;

            -- PPI Write DMA Cache 0x88000420
            when X"420" =>
               v.localAxiReadSlave.rdata(3 downto 0) := r.ppiWriteDmaCache;

            -- PPI online control, 8-bits - 0x88000424 
            when X"424" =>
               v.localAxiReadSlave.rdata(3 downto 0) := r.ppiOnline;

            when others => null;
         end case;

         -- Send Axi Response
         axiSlaveReadResponse(v.localAxiReadSlave);
      end if;

      -- Reset
      if (axiClkRstInt = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      localAxiReadSlave(0)  <= r.localAxiReadSlave;
      localAxiWriteSlave(0) <= r.localAxiWriteSlave;
      
   end process;


   -----------------------------------------
   -- Inbound FIFO controller
   -----------------------------------------
   U_IbCntrl : entity work.ArmRceG3IbCntrl
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk                   => axiClk,
         axiClkRst                => axiClkRstInt,
         axiAcpSlaveWriteFromArm  => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm    => axiAcpSlaveWriteToArm,
         dirtyFlag                => dirtyFlag,
         dirtyFlagClrEn           => r.dirtyFlagClrEn,
         dirtyFlagClrSel          => r.dirtyFlagClrSel,
         headerPtrWrite           => r.ibHeaderPtrWrite,
         headerPtrData            => r.genPtrData,
         fifoEnable               => r.fifoEnable(4 downto 0),
         memBaseAddress           => r.memBaseAddress,
         writeDmaCache            => r.writeDmaCache,
         ibHeaderClk              => ppiClk,
         ibHeaderToFifo           => ibFifoToFifo,
         ibHeaderFromFifo         => ibFifoFromFifo,
         qwordToFifo              => bsiToFifo,
         qwordFromFifo            => bsiFromFifo
      );


   -----------------------------------------
   -- Outbound FIFO controller
   -----------------------------------------
   U_ObCntrl : entity work.ArmRceG3ObCntrl
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk                  => axiClk,
         axiClkRst               => axiClkRstInt,
         axiAcpSlaveReadFromArm  => axiAcpSlaveReadFromArm,
         axiAcpSlaveReadToArm    => axiAcpSlaveReadToArm,
         headerPtrWrite          => r.obHeaderPtrWrite,
         headerPtrData           => r.genPtrData,
         localAxiReadMaster      => localAxiReadMaster(2),
         localAxiReadSlave       => localAxiReadSlave(2),
         localAxiWriteMaster     => localAxiWriteMaster(2),
         localAxiWriteSlave      => localAxiWriteSlave(2),
         memBaseAddress          => r.memBaseAddress,
         fifoEnable              => r.fifoEnable(8 downto 5),
         readDmaCache            => r.readDmaCache,
         obHeaderToFifo          => obFifoToFifo,
         obHeaderFromFifo        => obFifoFromFifo
      );


   --------------------------------------------------
   -- PPI DMA Controllers
   --------------------------------------------------
   U_DmaGen : for i in 0 to 3 generate

      U_IbDma: entity work.ArmRceG3IbPpi 
         generic map (
            TPD_G      => TPD_G
         ) port map (
            axiClk                   => axiClk,
            axiClkRst                => axiClkRstInt,
            axiHpSlaveWriteFromArm   => axiHpSlaveWriteFromArm(i),
            axiHpSlaveWriteToArm     => axiHpSlaveWriteToArm(i),
            ibHeaderToFifo           => ibFifoToFifo(i),
            ibHeaderFromFifo         => ibFifoFromFifo(i),
            ppiPtrWrite              => r.ibPpiPtrWrite(i),
            ppiPtrData               => r.genPtrData,
            writeDmaCache            => r.ppiWriteDmaCache,
            compFromFifo             => compFromFifo(i),
            compToFifo               => compToFifo(i),
            ppiClk                   => ppiClk(i),
            ppiWriteToFifo           => ppiWriteToFifo(i),
            ppiWriteFromFifo         => ppiWriteFromFifo(i)
         );

      U_ObDma: entity work.ArmRceG3ObPpi 
         generic map (
            TPD_G             => TPD_G,
            PPI_READY_THOLD_G => PPI_READY_THOLD_G(i)
         ) port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRstInt,
            axiHpSlaveReadFromArm   => axiHpSlaveReadFromArm(i),
            axiHpSlaveReadToArm     => axiHpSlaveReadToArm(i),
            obHeaderToFifo          => obFifoToFifo(i),
            obHeaderFromFifo        => obFifoFromFifo(i),
            readDmaCache            => r.ppiReadDmaCache,
            compFromFifo            => compFromFifo(i+4),
            compToFifo              => compToFifo(i+4),
            ppiClk                  => ppiClk(i),
            ppiReadToFifo           => ppiReadToFifo(i),
            ppiReadFromFifo         => ppiReadFromFifo(i)
         );

      -- Synchronize the online bit
      U_OnlineGen : entity work.RstSync
         generic map (
            TPD_G           => TPD_G,
            IN_POLARITY_G   => '0',
            OUT_POLARITY_G  => '0',
            RELEASE_DELAY_G => 16
         )
         port map (
           clk      => ppiClk(i),
           asyncRst => r.ppiOnline(i),
           syncRst  => ppiOnline(i)
         );

   end generate;


   --------------------------------------------------
   -- Completion Data Mover
   --------------------------------------------------
   U_Comp : entity work.ArmRceG3DmaComp 
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRstInt,
         compFromFifo        => compFromFifo,
         compToFifo          => compToFifo,
         localAxiReadMaster  => localAxiReadMaster(1),
         localAxiReadSlave   => localAxiReadSlave(1),
         localAxiWriteMaster => localAxiWriteMaster(1),
         localAxiWriteSlave  => localAxiWriteSlave(1),
         compInt             => compInt
      );

end architecture structure;

