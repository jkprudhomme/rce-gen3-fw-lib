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

entity ArmRceG3DmaCntrl is
   generic (
      TPD_G : time := 1 ns
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
      axiHpSlaveWriteFromArm  : in  AxiWriteSlaveVector(3 downto 0);
      axiHpSlaveWriteToArm    : out AxiWriteMasterVector(3 downto 0);
      axiHpSlaveReadFromArm   : in  AxiReadSlaveVector(3 downto 0);
      axiHpSlaveReadToArm     : out AxiReadMasterVector(3 downto 0);

      -- Interrupts
      interrupt               : out slv(15 downto 0);

      -- Local Bus
      localBusMaster          : in  LocalBusMasterType;
      localBusSlave           : out LocalBusSlaveType;

      -- PPI Outbound FIFO Interface
      obPpiClk                : in  slv(3 downto 0);
      obPpiToFifo             : in  ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo           : out ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                : in  slv(3 downto 0);
      ibPpiToFifo             : in  IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo           : out IbPpiFromFifoVector(3 downto 0);

      -- PPI quad word FIFO
      bsiToFifo               : in  QWordToFifoType;
      bsiFromFifo             : out QWordFromFifoType
   );
end ArmRceG3DmaCntrl;

architecture structure of ArmRceG3DmaCntrl is

   -- Number of registers
   constant LocalBusCount_C   : integer := 15;

   -- Local signals
   signal intLocalBusMaster   : LocalBusMasterVector(LocalBusCount_C-1 downto 0);
   signal intLocalBusSlave    : LocalBusSlaveVector(LocalBusCount_C-1 downto 0);
   signal obFifoToFifo        : ObHeaderToFifoVector(3 downto 0);
   signal obFifoFromFifo      : ObHeaderFromFifoVector(3 downto 0);
   signal ibFifoToFifo        : IbHeaderToFifoVector(3 downto 0);
   signal ibFifoFromFifo      : IbHeaderFromFifoVector(3 downto 0);
   signal dirtyFlag           : slv(4  downto 0);
   signal dirtyFlagClrEn      : sl;
   signal dirtyFlagClrSel     : slv(2  downto 0);
   signal ibHeaderPtrWrite    : slv(3  downto 0);
   signal obHeaderPtrWrite    : slv(3  downto 0);
   signal ibPpiPtrWrite       : slv(3  downto 0);
   signal genPtrData          : slv(35 downto 0); 
   signal fifoEnable          : slv(8  downto  0);
   signal memBaseAddress      : slv(31 downto 18);
   signal writeDmaCache       : slv(3 downto 0);
   signal readDmaCache        : slv(3 downto 0);
   signal intEnable           : slv(15  downto 0);
   signal ppiReadDmaCache     : slv(3 downto 0);
   signal ppiWriteDmaCache    : slv(3 downto 0);
   signal compFromFifo        : CompFromFifoVector(7 downto 0);
   signal compToFifo          : CompToFifoVector(7 downto 0);
   signal compFifoSel         : slv(3  downto 0);
   signal compFifoRd          : sl;
   signal compInt             : slv(10 downto 0);
   signal compFifoData        : slv(31 downto 0);
   signal compFifoRdValid     : sl;
   signal ppiOnline           : slv(7 downto 0);
   signal freePtrSel          : slv(1  downto 0);
   signal freePtrRd           : sl;
   signal freePtrData         : slv(31 downto 0);
   signal freePtrRdValid      : sl;

begin

   -- Interrupts
   interrupt <= (compInt & dirtyFlag) and intEnable;

   --------------------------------------------
   -- Registers: 0x8800_0000 - 0x8BFF_FFFF
   --------------------------------------------

   -- Register Mux
   U_LocalBusDec: entity work.ArmRceG3LocalBusDec 
      generic map (
         TPD_G   => TPD_G,
         COUNT_G => LocalBusCount_C
      ) port map (
         axiClk            => axiClk,
         axiClkRst         => axiClkRst,
         usLocalBusMaster  => localBusMaster,
         usLocalBusSlave   => localBusSlave,
         dsLocalBusMaster  => intLocalBusMaster,
         dsLocalBusSlave   => intLocalBusSlave
      );

   -- Register Block
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         intLocalBusSlave  <= (others=>LocalBusSlaveInit) after TPD_G;
         dirtyFlagClrEn    <= '0'                         after TPD_G;
         dirtyFlagClrSel   <= (others=>'0')               after TPD_G;
         ibHeaderPtrWrite  <= (others=>'0')               after TPD_G;
         ibPpiPtrWrite     <= (others=>'0')               after TPD_G;
         obHeaderPtrWrite  <= (others=>'0')               after TPD_G;
         genPtrData        <= (others=>'0')               after TPD_G;
         fifoEnable        <= (others=>'0')               after TPD_G;
         memBaseAddress    <= (others=>'0')               after TPD_G;
         writeDmaCache     <= (others=>'0')               after TPD_G;
         readDmaCache      <= (others=>'0')               after TPD_G;
         intEnable         <= (others=>'0')               after TPD_G;
         ppiReadDmaCache   <= (others=>'0')               after TPD_G;
         ppiWriteDmaCache  <= (others=>'0')               after TPD_G;
         compFifoRd        <= '0'                         after TPD_G;
         compFifoSel       <= (others=>'0')               after TPD_G;
         freePtrRd         <= '0'                         after TPD_G;
         freePtrSel        <= (others=>'0')               after TPD_G;
         ppiOnline         <= (others=>'0')               after TPD_G;
      elsif rising_edge(axiClk) then

         -- Init
         intLocalBusSlave <= (others=>LocalBusSlaveInit) after TPD_G;

         -- Generic 
         genPtrData(35 downto 32) <= intLocalBusMaster(0).addr(5 downto 2) after TPD_G;
         genPtrData(31 downto  0) <= intLocalBusMaster(0).writeData        after TPD_G;

         -- Completion FIFO read space 11 - 0x88000000 - 0x88000028
         intLocalBusSlave(0).addrMask  <= x"03FFFFC0"                           after TPD_G;
         intLocalBusSlave(0).addrBase  <= x"00000000"                           after TPD_G;
         intLocalBusSlave(0).readValid <= compFifoRdValid                       after TPD_G;
         intLocalBusSlave(0).readData  <= compFifoData                          after TPD_G;
         compFifoRd                    <= intLocalBusMaster(0).readEnable       after TPD_G;
         compFifoSel                   <= intLocalBusMaster(0).addr(5 downto 2) after TPD_G;
         
         -- OB Free List FIFO read space 4 - 0x88000040 - 0x8800004C
         intLocalBusSlave(1).addrMask  <= x"03FFFFF0"                           after TPD_G;
         intLocalBusSlave(1).addrBase  <= x"00000040"                           after TPD_G;
         intLocalBusSlave(1).readValid <= freePtrRdValid                        after TPD_G;
         intLocalBusSlave(1).readData  <= freePtrData                           after TPD_G;
         freePtrRd                     <= intLocalBusMaster(1).readEnable       after TPD_G;
         freePtrSel                    <= intLocalBusMaster(1).addr(3 downto 2) after TPD_G;

         -- Inbound header free list entries, 64 total (4 * 16) - 0x88000100 - 0x880001FF
         -- Write only
         intLocalBusSlave(2).addrMask  <= x"03FFFF00"                     after TPD_G;
         intLocalBusSlave(2).addrBase  <= x"00000100"                     after TPD_G;
         intLocalBusSlave(2).readValid <= intLocalBusMaster(2).readEnable after TPD_G;
         intLocalBusSlave(2).readData  <= (others=>'0')                   after TPD_G;

         ibHeaderPtrWrite                                                      <= (others=>'0')                    after TPD_G;
         ibHeaderPtrWrite(conv_integer(intLocalBusMaster(2).addr(7 downto 6))) <= intLocalBusMaster(2).writeEnable after TPD_G;

         -- Outbound header tx list entries, 64 total (4 * 16) - 0x88000200 - 0x880002FF
         intLocalBusSlave(3).addrMask  <= x"03FFFF00"                     after TPD_G;
         intLocalBusSlave(3).addrBase  <= x"00000200"                     after TPD_G;
         intLocalBusSlave(3).readValid <= intLocalBusMaster(3).readEnable after TPD_G;
         intLocalBusSlave(3).readData  <= (others=>'0')                   after TPD_G;

         obHeaderPtrWrite                                                      <= (others=>'0')                    after TPD_G;
         obHeaderPtrWrite(conv_integer(intLocalBusMaster(3).addr(7 downto 6))) <= intLocalBusMaster(3).writeEnable after TPD_G;

         -- Channel Dirty flags clear, 5 - 0x88000300 - 0x88000310
         -- One per quad word memory channel
         intLocalBusSlave(4).addrMask  <= x"03FFFFE0"                           after TPD_G;
         intLocalBusSlave(4).addrBase  <= x"00000300"                           after TPD_G;
         intLocalBusSlave(4).readValid <= intLocalBusMaster(4).readEnable       after TPD_G;
         intLocalBusSlave(4).readData  <= (others=>'0')                         after TPD_G;
         dirtyFlagClrEn                <= intLocalBusMaster(4).writeEnable      after TPD_G;
         dirtyFlagClrSel               <= intLocalBusMaster(4).addr(4 downto 2) after TPD_G;

         -- Dirty/Ready status, 16 bits 0x88000400
         -- Bits 3:0   = inbound header FIFOs
         -- Bits 4     = BSI FIFO
         -- Bits 15:5  = completion FIFOs
         intLocalBusSlave(5).addrMask              <= x"03FFFFFC"                     after TPD_G;
         intLocalBusSlave(5).addrBase              <= x"00000400"                     after TPD_G;
         intLocalBusSlave(5).readValid             <= intLocalBusMaster(5).readEnable after TPD_G;
         intLocalBusSlave(5).readData(15 downto 5) <= compInt                         after TPD_G;
         intLocalBusSlave(5).readData(4  downto 0) <= dirtyFlag                       after TPD_G;

         -- Interrupt Enable, 16 bits, 0x88000404
         intLocalBusSlave(6).addrMask              <= x"03FFFFFC"                     after TPD_G;
         intLocalBusSlave(6).addrBase              <= x"00000404"                     after TPD_G;
         intLocalBusSlave(6).readValid             <= intLocalBusMaster(6).readEnable after TPD_G;
         intLocalBusSlave(6).readData(15 downto 0) <= intEnable                       after TPD_G;

         if intLocalBusMaster(6).writeEnable = '1' then
            intEnable <= intLocalBusMaster(6).writeData(15 downto 0) after TPD_G;
         end if;

         -- AXI Write DMA Cache Config, single location, 0x88000408
         intLocalBusSlave(7).addrMask             <= x"03FFFFFC"                     after TPD_G;
         intLocalBusSlave(7).addrBase             <= x"00000408"                     after TPD_G;
         intLocalBusSlave(7).readValid            <= intLocalBusMaster(7).readEnable after TPD_G;
         intLocalBusSlave(7).readData(3 downto 0) <= writeDmaCache                   after TPD_G;

         if intLocalBusMaster(7).writeEnable = '1' then
            writeDmaCache <= intLocalBusMaster(7).writeData(3 downto 0) after TPD_G;
         end if;

         -- AXI Read DMA Cache Config, single location, 0x8800040C
         intLocalBusSlave(8).addrMask             <= x"03FFFFFC"                     after TPD_G;
         intLocalBusSlave(8).addrBase             <= x"0000040C"                     after TPD_G;
         intLocalBusSlave(8).readValid            <= intLocalBusMaster(8).readEnable after TPD_G;
         intLocalBusSlave(8).readData(3 downto 0) <= readDmaCache                    after TPD_G;

         if intLocalBusMaster(8).writeEnable = '1' then
            readDmaCache <= intLocalBusMaster(8).writeData(3 downto 0) after TPD_G;
         end if;

         -- FIFO Enable, 20 bits - 0x88000410
         -- Bits 3:0   = inbound header FIFOs
         -- Bits 4     = BSI FIFO
         -- Bits 8:5   = outbound header FIFOs
         intLocalBusSlave(9).addrMask             <= x"03FFFFFC"                     after TPD_G;
         intLocalBusSlave(9).addrBase             <= x"00000410"                     after TPD_G;
         intLocalBusSlave(9).readValid            <= intLocalBusMaster(9).readEnable after TPD_G;
         intLocalBusSlave(9).readData(8 downto 0) <= fifoEnable                      after TPD_G;

         if intLocalBusMaster(9).writeEnable = '1' then
            fifoEnable <= intLocalBusMaster(9).writeData(8 downto 0) after TPD_G;
         end if;

         -- Memory base address 0x88000418
         intLocalBusSlave(10).addrMask               <= x"03FFFFFC"                      after TPD_G;
         intLocalBusSlave(10).addrBase               <= x"00000418"                      after TPD_G;
         intLocalBusSlave(10).readValid              <= intLocalBusMaster(10).readEnable after TPD_G;
         intLocalBusSlave(10).readData(31 downto 18) <= memBaseAddress                   after TPD_G;

         if intLocalBusMaster(10).writeEnable = '1' then
            memBaseAddress <= intLocalBusMaster(10).writeData(31 downto 18) after TPD_G;
         end if;

         -- PPI Read DMA Cache 0x8800041C
         intLocalBusSlave(11).addrMask             <= x"03FFFFFC"                      after TPD_G;
         intLocalBusSlave(11).addrBase             <= x"00000418"                      after TPD_G;
         intLocalBusSlave(11).readValid            <= intLocalBusMaster(11).readEnable after TPD_G;
         intLocalBusSlave(11).readData(3 downto 0) <= ppiReadDmaCache                  after TPD_G;

         if intLocalBusMaster(11).writeEnable = '1' then
            ppiReadDmaCache <= intLocalBusMaster(10).writeData(3 downto 0) after TPD_G;
         end if;

         -- PPI Write DMA Cache 0x88000420
         intLocalBusSlave(12).addrMask             <= x"03FFFFFC"                      after TPD_G;
         intLocalBusSlave(12).addrBase             <= x"00000420"                      after TPD_G;
         intLocalBusSlave(12).readValid            <= intLocalBusMaster(12).readEnable after TPD_G;
         intLocalBusSlave(12).readData(3 downto 0) <= ppiWriteDmaCache                 after TPD_G;

         if intLocalBusMaster(12).writeEnable = '1' then
            ppiWriteDmaCache <= intLocalBusMaster(12).writeData(3 downto 0) after TPD_G;
         end if;

         -- PPI online control, 8-bits - 0x88000424 
         intLocalBusSlave(13).addrMask             <= x"03FFFFFC"                      after TPD_G;
         intLocalBusSlave(13).addrBase             <= x"00000424"                      after TPD_G;
         intLocalBusSlave(13).readValid            <= intLocalBusMaster(13).readEnable after TPD_G;
         intLocalBusSlave(13).readData(7 downto 0) <= ppiOnline                        after TPD_G;

         if intLocalBusMaster(13).writeEnable = '1' then
            ppiOnline <= intLocalBusMaster(13).writeData(7 downto 0) after TPD_G;
         end if;

         -- Inbound ppi pointer entries, 64 total (4 * 16) - 0x88000500 - 0x880005FF
         -- Write only
         intLocalBusSlave(14).addrMask             <= x"03FFFF00"                      after TPD_G;
         intLocalBusSlave(14).addrBase             <= x"00000500"                      after TPD_G;
         intLocalBusSlave(14).readValid            <= intLocalBusMaster(14).readEnable after TPD_G;
         intLocalBusSlave(14).readData             <= (others=>'0')                    after TPD_G;

         ibPpiPtrWrite(conv_integer(intLocalBusMaster(14).addr(7 downto 6))) <= intLocalBusMaster(14).writeEnable after TPD_G;

      end if;  
   end process;         


   -----------------------------------------
   -- Inbound FIFO controller
   -----------------------------------------
   U_IbCntrl : entity work.ArmRceG3IbCntrl
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk                   => axiClk,
         axiClkRst                => axiClkRst,
         axiAcpSlaveWriteFromArm  => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm    => axiAcpSlaveWriteToArm,
         dirtyFlag                => dirtyFlag,
         dirtyFlagClrEn           => dirtyFlagClrEn,
         dirtyFlagClrSel          => dirtyFlagClrSel,
         headerPtrWrite           => ibHeaderPtrWrite,
         headerPtrData            => genPtrData,
         fifoEnable               => fifoEnable(4 downto 0),
         memBaseAddress           => memBaseAddress,
         writeDmaCache            => writeDmaCache,
         ibHeaderClk              => ibPpiClk,
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
         axiClkRst               => axiClkRst,
         axiAcpSlaveReadFromArm  => axiAcpSlaveReadFromArm,
         axiAcpSlaveReadToArm    => axiAcpSlaveReadToArm,
         headerPtrWrite          => obHeaderPtrWrite,
         headerPtrData           => genPtrData,
         freePtrSel              => freePtrSel,
         freePtrRd               => freePtrRd,
         freePtrData             => freePtrData,
         freePtrRdValid          => freePtrRdValid,
         memBaseAddress          => memBaseAddress,
         fifoEnable              => fifoEnable(8 downto 5),
         readDmaCache            => readDmaCache,
         obHeaderToFifo          => obFifoToFifo,
         obHeaderFromFifo        => obFifoFromFifo
      );


   --------------------------------------------------
   -- Inbound PPI DMA Controllers
   --------------------------------------------------
   U_IbDmaGen : for i in 0 to 3 generate

      U_IbDma: entity work.ArmRceG3IbPpi 
         generic map (
            TPD_G      => TPD_G
         ) port map (
            axiClk                   => axiClk,
            axiClkRst                => axiClkRst,
            axiHpSlaveWriteFromArm   => axiHpSlaveWriteFromArm(i),
            axiHpSlaveWriteToArm     => axiHpSlaveWriteToArm(i),
            ibHeaderToFifo           => ibFifoToFifo(i),
            ibHeaderFromFifo         => ibFifoFromFifo(i),
            ppiPtrWrite              => ibPpiPtrWrite(i),
            ppiPtrData               => genPtrData,
            writeDmaCache            => ppiWriteDmaCache,
            ppiOnline                => ppiOnline(i),
            compFromFifo             => compFromFifo(i),
            compToFifo               => compToFifo(i),
            ibPpiClk                 => ibPpiClk(i),
            ibPpiToFifo              => ibPpiToFifo(i),
            ibPpiFromFifo            => ibPpiFromFifo(i)
         );

   end generate;

   --------------------------------------------------
   -- Outbound PPI DMA Controllers
   --------------------------------------------------
   U_ObDmaGen : for i in 0 to 3 generate

      U_ObDma: entity work.ArmRceG3ObPpi 
         generic map (
            TPD_G      => TPD_G
         ) port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRst,
            axiHpSlaveReadFromArm   => axiHpSlaveReadFromArm(i),
            axiHpSlaveReadToArm     => axiHpSlaveReadToArm(i),
            obHeaderToFifo          => obFifoToFifo(i),
            obHeaderFromFifo        => obFifoFromFifo(i),
            readDmaCache            => ppiReadDmaCache,
            ppiOnline               => ppiOnline(i+4),
            compFromFifo            => compFromFifo(i+4),
            compToFifo              => compToFifo(i+4),
            obPpiClk                => obPpiClk(i),
            obPpiToFifo             => obPpiToFifo(i),
            obPpiFromFifo           => obPpiFromFifo(i)
         );

   end generate;

   --------------------------------------------------
   -- Completion Data Mover
   --------------------------------------------------
   U_Comp : entity work.ArmRceG3DmaComp 
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk           => axiClk,
         axiClkRst        => axiClkRst,
         compFromFifo     => compFromFifo,
         compToFifo       => compToFifo,
         compFifoSel      => compFifoSel,
         compFifoData     => compFifoData,
         compFifoRd       => compFifoRd,
         compFifoRdValid  => compFifoRdValid,
         compInt          => compInt
      );

end architecture structure;

