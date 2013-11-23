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

   -- Local signals
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
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         localBusSlave    <= LocalBusSlaveInit             after TPD_G;
         dirtyFlagClrEn   <= '0'                           after TPD_G;
         dirtyFlagClrSel  <= (others=>'0')                 after TPD_G;
         ibHeaderPtrWrite <= (others=>'0')                 after TPD_G;
         ibPpiPtrWrite    <= (others=>'0')                 after TPD_G;
         obHeaderPtrWrite <= (others=>'0')                 after TPD_G;
         genPtrData       <= (others=>'0')                 after TPD_G;
         fifoEnable       <= (others=>'0')                 after TPD_G;
         memBaseAddress   <= (others=>'0')                 after TPD_G;
         writeDmaCache    <= (others=>'0')                 after TPD_G;
         readDmaCache     <= (others=>'0')                 after TPD_G;
         intEnable        <= (others=>'0')                 after TPD_G;
         ppiReadDmaCache  <= (others=>'0')                 after TPD_G;
         ppiWriteDmaCache <= (others=>'0')                 after TPD_G;
         compFifoRd       <= '0'                           after TPD_G;
         compFifoSel      <= (others=>'0')                 after TPD_G;
         freePtrRd        <= '0'                           after TPD_G;
         freePtrSel       <= (others=>'0')                 after TPD_G;
         ppiOnline        <= (others=>'0')                 after TPD_G;
      elsif rising_edge(axiClk) then

         -- Init
         localBusSlave.readValid  <= localBusMaster.readEnable       after TPD_G;
         localBusSlave.readData   <= (others=>'0')                   after TPD_G;
         dirtyFlagClrEn           <= '0'                             after TPD_G;
         dirtyFlagClrSel          <= localBusMaster.addr(4 downto 2) after TPD_G;
         ibHeaderPtrWrite         <= (others=>'0')                   after TPD_G;
         ibPpiPtrWrite            <= (others=>'0')                   after TPD_G;
         obHeaderPtrWrite         <= (others=>'0')                   after TPD_G;
         genPtrData(35 downto 32) <= localBusMaster.addr(5 downto 2) after TPD_G;
         genPtrData(31 downto  0) <= localBusMaster.writeData        after TPD_G;
         compFifoRd               <= '0'                             after TPD_G;
         compFifoSel              <= localBusMaster.addr(5 downto 2) after TPD_G;
         freePtrRd                <= '0'                             after TPD_G;
         freePtrSel               <= localBusMaster.addr(3 downto 2) after TPD_G;

         -- Completion FIFO read space 11 - 0x88000000 - 0x88000028
         if localBusMaster.addr(23 downto 6) = (x"0000" & "00") then
            localBusSlave.readValid  <= compFifoRdValid           after TPD_G;
            compFifoRd               <= localBusMaster.readEnable after TPD_G;
            localBusSlave.readData   <= compFifoData              after TPD_G;

         -- OB Free List FIFO read space 4 - 0x88000040 - 0x8800004C
         elsif localBusMaster.addr(23 downto 4) = x"00004" then
            localBusSlave.readValid  <= freePtrRdValid            after TPD_G;
            freePtrRd                <= localBusMaster.readEnable after TPD_G;
            localBusSlave.readData   <= freePtrData               after TPD_G;

         -- Inbound header free list entries, 64 total (4 * 16) - 0x88000100 - 0x880001FF
         -- Write only
         elsif localBusMaster.addr(23 downto 8) = x"0001" then
            ibHeaderPtrWrite(conv_integer(localBusMaster.addr(7 downto 6))) <= localBusMaster.writeEnable after TPD_G;

         -- Outbound header tx list entries, 64 total (4 * 16) - 0x88000200 - 0x880002FF
         elsif localBusMaster.addr(23 downto 8) = x"0002" then
            obHeaderPtrWrite(conv_integer(localBusMaster.addr(7 downto 6))) <= localBusMaster.writeEnable after TPD_G;

         -- Channel Dirty flags clear, 5 - 0x88000300 - 0x88000310
         -- One per quad word memory channel
         elsif localBusMaster.addr(23 downto 6) = (x"0003" & "00") then
            dirtyFlagClrEn <= localBusMaster.writeEnable after TPD_G;

         -- Dirty/Ready status, 16 bits 0x88000400
         -- Bits 3:0   = inbound header FIFOs
         -- Bits 4     = BSI FIFO
         -- Bits 15:5  = completion FIFOs
         elsif localBusMaster.addr(23 downto 0) = x"000400" then
            localBusSlave.readData(4  downto 0) <= dirtyFlag after TPD_G;
            localBusSlave.readData(15 downto 5) <= compInt   after TPD_G;

         -- Interrupt Enable, 16 bits, 0x88000404
         elsif localBusMaster.addr(23 downto 0) = x"000404" then
            if localBusMaster.writeEnable = '1' then
               intEnable <= localBusMaster.writeData(15 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(15 downto 0) <= intEnable after TPD_G;

         -- AXI Write DMA Cache Config, single location, 0x88000408
         elsif localBusMaster.addr(23 downto 0) = x"000408" then
            if localBusMaster.writeEnable = '1' then
               writeDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(3 downto 0) <= writeDmaCache after TPD_G;

         -- AXI Read DMA Cache Config, single location, 0x8800040C
         elsif localBusMaster.addr(23 downto 0) = x"00040C" then
            if localBusMaster.writeEnable = '1' then
               readDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(3 downto 0) <= readDmaCache after TPD_G;

         -- FIFO Enable, 20 bits - 0x88000410
         -- Bits 3:0   = inbound header FIFOs
         -- Bits 4     = BSI FIFO
         -- Bits 8:5   = outbound header FIFOs
         elsif localBusMaster.addr(23 downto 0) = x"000410" then
            if localBusMaster.writeEnable = '1' then
               fifoEnable <= localBusMaster.writeData(8 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(8 downto 0) <= fifoEnable after TPD_G;

         -- Memory base address 0x88000418
         elsif localBusMaster.addr(23 downto 0) = x"000418" then
            if localBusMaster.writeEnable = '1' then
               memBaseAddress <= localBusMaster.writeData(31 downto 18) after TPD_G;
            end if;
            localBusSlave.readData(31 downto 18) <= memBaseAddress after TPD_G;

         -- PPI Read DMA Cache 0x8800041C
         elsif localBusMaster.addr(23 downto 0) = x"00041C" then
            if localBusMaster.writeEnable = '1' then
               ppiReadDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(3 downto 0) <= ppiReadDmaCache after TPD_G;

         -- PPI Write DMA Cache 0x88000420
         elsif localBusMaster.addr(23 downto 0) = x"000420" then
            if localBusMaster.writeEnable = '1' then
               ppiWriteDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(3 downto 0) <= ppiWriteDmaCache after TPD_G;

         -- PPI online control, 8-bits - 0x88000424 
         elsif localBusMaster.addr(23 downto 0) = x"000424" then 
            if localBusMaster.writeEnable = '1' then
               ppiOnline <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;
            localBusSlave.readData(7 downto 0) <= ppiOnline after TPD_G;

         -- Inbound ppi pointer entries, 64 total (4 * 16) - 0x88000500 - 0x880005FF
         -- Write only
         elsif localBusMaster.addr(23 downto 8) = x"0005" then
            ibPpiPtrWrite(conv_integer(localBusMaster.addr(7 downto 6))) <= localBusMaster.writeEnable after TPD_G;

         -- Unsupported
         else 
            localBusSlave.readData <= x"deadbeef" after TPD_G;
         end if;
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

