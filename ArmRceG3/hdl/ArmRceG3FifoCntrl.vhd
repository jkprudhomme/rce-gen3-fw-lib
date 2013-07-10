-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound FIFOs
-- File          : ArmRceG3FifoCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- FIFO controller for inbound and outbound headers & descritor FIFOs
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

entity ArmRceG3FifoCntrl is
   port (

      -- Clock
      axiClk                  : in  std_logic;

      -- AXI ACP Master
      axiClkRst               : in  std_logic;
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;

      -- Interrupts
      interrupt               : out std_logic_vector(14 downto 0);

      -- Local Bus
      localBusMaster          : in  LocalBusMasterType;
      localBusSlave           : out LocalBusSlaveType;

      -- External FIFO Interfaces
      writeFifoClk            : in  std_logic_vector(16 downto 0);
      writeFifoToFifo         : in  WriteFifoToFifoVector(16 downto 0);
      writeFifoFromFifo       : out WriteFifoFromFifoVector(16 downto 0);

      -- Debug
      debug                   : out std_logic_vector(127 downto 0)
   );
end ArmRceG3FifoCntrl;

architecture structure of ArmRceG3FifoCntrl is

   -- Local signals
   signal axiAcpSlaveWriteToArmFifo : AxiWriteMasterVector(20 downto 0);
   signal intLocalBusSlave          : LocalBusSlaveType;
   signal memConfig                 : Word5Array(31 downto 0);
   signal fifoDin                   : std_logic_vector(35 downto 0);
   signal fifoWrEn                  : std_logic;
   signal fifoWrSel                 : std_logic_vector(4  downto 0);
   signal dirtyClearEn              : std_logic;
   signal dirtyClearSel             : std_logic_vector(4  downto 0);
   signal writeDmaCache             : std_logic_vector(3  downto 0);
   signal fifoEnable                : std_logic_vector(20 downto 0);
   signal writeDmaId                : Word3Array(20 downto 0);
   signal memToggleEnable           : std_logic_vector(14 downto 0);
   signal intEnable                 : std_logic_vector(14 downto 0);
   signal dirtyFlag                 : std_logic_vector(16 downto 0);
   signal dirtyFlagSet              : std_logic_vector(16 downto 0);
   signal dirtyFlagFifoSet          : Word17Array(16 downto 0);
   signal iwriteFifoToFifo          : WriteFifoToFifoVector(20 downto 0);
   signal memPtrWrite               : WriteFifoToFifoVector(3 downto 0);
   signal donePtrWrite              : WriteFifoToFifoVector(3 downto 0);
   signal fifoDebug                 : Word128Array(20 downto 0);
   signal fifoReq                   : std_logic_vector(31 downto 0);
   signal fifoGnt                   : std_logic_vector(31 downto 0);
   signal dbgSelect                 : std_logic_vector(4  downto 0);
   signal arbSelect                 : std_logic_vector(4  downto 0);
   signal arbValid                  : std_logic;
   signal writeDmaBusyOut           : Word8Array(16 downto 0);
   signal writeDmaBusyIn            : std_logic_vector(7 downto   0);
   signal memBaseAddress            : std_logic_vector(31 downto  8);
   signal dmaBaseAddress            : std_logic_vector(31 downto 18);

begin

   -- Outputs
   localBusSlave <= intLocalBusSlave;
   interrupt     <= dirtyFlag(14 downto 0) and intEnable;

   --------------------------------------------
   -- Registers: 0x8800_0000 - 0x8BFF_FFFF
   --------------------------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         intLocalBusSlave <= LocalBusSlaveInit       after TPD_G;
         memConfig        <= (others=>(others=>'0')) after TPD_G;
         fifoWrEn         <= '0'                     after TPD_G;
         fifoWrSel        <= (others=>'0')           after TPD_G;
         fifoDin          <= (others=>'0')           after TPD_G;
         dirtyClearEn     <= '0'                     after TPD_G;
         dirtyClearSel    <= (others=>'0')           after TPD_G;
         writeDmaCache    <= (others=>'0')           after TPD_G;
         fifoEnable       <= (others=>'0')           after TPD_G;
         memToggleEnable  <= (others=>'0')           after TPD_G;
         intEnable        <= (others=>'0')           after TPD_G;
         dbgSelect        <= (others=>'0')           after TPD_G;
         memBaseAddress   <= (others=>'0')           after TPD_G;
         dmaBaseAddress   <= (others=>'0')           after TPD_G;
      elsif rising_edge(axiClk) then
         intLocalBusSlave.readValid <= localBusMaster.readEnable after TPD_G;

         -- FIFO Memory Configuration, 32 total (15 * 2 + 2) - 0x88000000 - 0x8800007F
         -- Single entry FIFOs only
         -- 2 locations for first 15, 1 locations for upper 2
         if localBusMaster.addr(23 downto 8) = x"0000" and localBusMaster.addr(7) = '0' then
            if localBusMaster.writeEnable = '1' then
               memConfig(conv_integer(localBusMaster.addr(6 downto 2))) 
                  <= localBusMaster.writeData(4 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData 
               <= x"000000" & "000" & memConfig(conv_integer(localBusMaster.addr(6 downto 2))) after TPD_G;

         -- FIFO test writes, 21 FIFOs, 16 locations each - 0x88010000 - 0x8801053F
         -- Header and descriptor FIFOs
         -- First four entries (0 - 3) are for header free list FIFOs
         -- Next  four entries (4 - 7) are for header data test writes
         -- Entries 8 - 20 are for test writes to single entry FIFOs 4 - 16
         elsif localBusMaster.addr(23 downto 16) = x"01" and localBusMaster.addr(15 downto 11) = "00000" and 
               localBusMaster.addr(10 downto 6) < 21 then
            fifoWrEn                  <= localBusMaster.writeEnable       after TPD_G;
            fifoWrSel                 <= localBusMaster.addr(10 downto 6) after TPD_G;
            fifoDin(35 downto 32)     <= localBusMaster.addr(5  downto 2) after TPD_G;
            fifoDin(31 downto  0)     <= localBusMaster.writeData         after TPD_G;
            intLocalBusSlave.readData <= x"deadbeef"                      after TPD_G;

         -- Channel Dirty flags clear, 17 - 0x88020000 - 0x88020043
         -- One per DMA channel
         -- Channels 0 - 14 are associated with interrupts
         elsif localBusMaster.addr(23 downto 8) = x"0200" and localBusMaster.addr(7 downto 2) < 17 then
            dirtyClearEn              <= localBusMaster.writeEnable      after TPD_G;
            dirtyClearSel             <= localBusMaster.addr(6 downto 2) after TPD_G;
            intLocalBusSlave.readData <= x"deadbeef"                     after TPD_G;

         -- AXI Write DMA Cache Config, single location, 0x88030000
         elsif localBusMaster.addr(23 downto 0) = x"030000" then
            if localBusMaster.writeEnable = '1' then
               writeDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000000" & writeDmaCache after TPD_G;

         -- FIFO Enable, 21 bits - 0x88030004
         -- Lower 4 bits are for burst FIFOs
         -- Bits 4 - 20 are for single entry FIFOs
         elsif localBusMaster.addr(23 downto 0) = x"030004" then
            if localBusMaster.writeEnable = '1' then
               fifoEnable <= localBusMaster.writeData(20 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"00" & "000" & fifoEnable after TPD_G;

         -- FIFO Toggle Enable, 15 bits, 0x88030008
         -- One per single entry FIFOs 0 - 14
         elsif localBusMaster.addr(23 downto 0) = x"030008" then
            if localBusMaster.writeEnable = '1' then
               memToggleEnable <= localBusMaster.writeData(14 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000" & "0" & memToggleEnable after TPD_G;

         -- Dirty status, 17 bits 0x8803000C
         -- One per memory channel
         -- Channels 0 - 14 are associated with interrupts
         elsif localBusMaster.addr(23 downto 0) = x"03000C" then
            intLocalBusSlave.readData <= x"000" & "000" & dirtyFlag after TPD_G;

         -- Interrupt Enable, 15 bits, 0x88030010
         -- Memory channels 0 - 14 are associated with interrupts
         elsif localBusMaster.addr(23 downto 0) = x"030010" then
            if localBusMaster.writeEnable = '1' then
               intEnable <= localBusMaster.writeData(14 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000" & "0" & intEnable after TPD_G;

         -- Debug select 0x88030014
         -- Header and descriptor FIFOs
         -- First four entries (0 - 3) are for header burst FIFOs
         -- Entries 4 - 20 are for single entry FIFOs
         elsif localBusMaster.addr(23 downto 0) = x"030014" then
            if localBusMaster.writeEnable = '1' then
               dbgSelect <= localBusMaster.writeData(4 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"000000" & "000" & dbgSelect after TPD_G;

         -- Memory base address 0x88030018
         elsif localBusMaster.addr(23 downto 0) = x"030018" then
            if localBusMaster.writeEnable = '1' then
               memBaseAddress <= localBusMaster.writeData(31 downto 8) after TPD_G;
            end if;
            intLocalBusSlave.readData <= memBaseAddress & x"00" after TPD_G;

         -- DMA base address 0x8803001C
         elsif localBusMaster.addr(23 downto 0) = x"03001C" then
            if localBusMaster.writeEnable = '1' then
               dmaBaseAddress <= localBusMaster.writeData(31 downto 18) after TPD_G;
            end if;
            intLocalBusSlave.readData <= dmaBaseAddress & "00" & x"0000" after TPD_G;

         -- Unsupported
         else
            fifoWrEn                   <= '0'         after TPD_G;
            dirtyClearEn               <= '0'         after TPD_G;
            intLocalBusSlave.readData  <= x"deadbeef" after TPD_G;
         end if;
      end if;  
   end process;         

   -----------------------------------------
   -- Dirty flags
   -----------------------------------------

   -- Combine sets from FPGAs
   dirtyFlagSet <= dirtyFlagFifoSet(0)  or dirtyFlagFifoSet(1)  or dirtyFlagFifoSet(2)  or dirtyFlagFifoSet(3)
                or dirtyFlagFifoSet(4)  or dirtyFlagFifoSet(5)  or dirtyFlagFifoSet(6)  or dirtyFlagFifoSet(7)
                or dirtyFlagFifoSet(8)  or dirtyFlagFifoSet(9)  or dirtyFlagFifoSet(10) or dirtyFlagFifoSet(11)
                or dirtyFlagFifoSet(12) or dirtyFlagFifoSet(13) or dirtyFlagFifoSet(14) or dirtyFlagFifoSet(15)
                or dirtyFlagFifoSet(16);

   U_DirtyGen: for i in 0 to 16 generate
      process ( axiClk, axiClkRst ) begin
         if axiClkRst = '1' then
            dirtyFlag(i) <= '0' after TPD_G;
         elsif rising_edge(axiClk) then
            if dirtyClearEn = '1' and dirtyClearSel = i then
               dirtyFlag(i) <= '0' after TPD_G;
            elsif dirtyFlagSet(i) = '1' then
               dirtyFlag(i) <= '1' after TPD_G;
            end if;
         end if;
      end process;
   end generate;

   -----------------------------------------
   -- Arbitration 
   -----------------------------------------
   U_Arbiter : entity work.Arbiter 
      generic map (
         TPD_G      => 1 ns,
         USE_SRST_G => true,
         USE_ARST_G => false,
         REQ_SIZE_G => 32
      ) port map (
         clk      => axiClk,
         aRst     => '0',
         sRst     => axiClkRst,
         req      => fifoReq,
         selected => arbSelect,
         valid    => arbValid,
         ack      => fifoGnt
      );

   -- Channels 21 to 31 are not used
   fifoReq(31 downto 21) <= (others=>'0');
 
   -- Mux ACP bus mastership
   axiAcpSlaveWriteToArm <= axiAcpSlaveWriteToArmFifo(conv_integer(arbSelect));

   -----------------------------------------
   -- Configure DMA IDs
   -----------------------------------------

   -- Header FIFOs get dedicated IDs
   writeDmaId(0)  <= "000";
   writeDmaId(1)  <= "001";
   writeDmaId(2)  <= "010";
   writeDmaId(3)  <= "011";

   -- Spread header completion FIFOs across available IDs
   writeDmaId(4)  <= "100";
   writeDmaId(5)  <= "101";
   writeDmaId(6)  <= "110";
   writeDmaId(7)  <= "111";

   -- Distribute remaining FIFOs across IDs
   writeDmaId(8)  <= "100";
   writeDmaId(9)  <= "101";
   writeDmaId(10) <= "110";
   writeDmaId(11) <= "111";
   writeDmaId(12) <= "100";
   writeDmaId(13) <= "101";
   writeDmaId(14) <= "110";
   writeDmaId(15) <= "111";
   writeDmaId(16) <= "100";
   writeDmaId(17) <= "101";
   writeDmaId(18) <= "110";
   writeDmaId(19) <= "111";
   writeDmaId(20) <= "100";

   -- Combine dma ID busy Signals
   writeDmaBusyIn <= writeDmaBusyOut(0)  or writeDmaBusyOut(1)  or writeDmaBusyOut(2)  or writeDmaBusyOut(3)  or 
                     writeDmaBusyOut(4)  or writeDmaBusyOut(5)  or writeDmaBusyOut(6)  or writeDmaBusyOut(7)  or 
                     writeDmaBusyOut(8)  or writeDmaBusyOut(9)  or writeDmaBusyOut(10) or writeDmaBusyOut(11) or 
                     writeDmaBusyOut(12) or writeDmaBusyOut(13) or writeDmaBusyOut(14) or writeDmaBusyOut(15) or 
                     writeDmaBusyOut(16);

   ------------------------------------------------------
   -- Header FIFOs and Pending Ingress FIFOs, 0 - 3
   ------------------------------------------------------
   U_GenPif: for i in 0 to 3 generate

      -- Header burst FIFO
      U_HeaderFifo: entity work.ArmRceG3IbHeaderFifo
         port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRst,
            axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
            axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArmFifo(i),
            fifoReq                 => fifoReq(i),
            fifoGnt                 => fifoGnt(i),
            memPtrWrite             => memPtrWrite(i),
            donePtrWrite            => donePtrWrite(i),
            dmaBaseAddress          => dmaBaseAddress,
            fifoEnable              => fifoEnable(i),
            writeDmaId              => writeDmaId(i),
            writeDmaCache           => writeDmaCache,
            --writeFifoClk            => writeFifoClk(i),
            --writeFifoToFifo         => writeFifoToFifo(i),
            writeFifoClk            => axiClk,              -- Test Mode
            writeFifoToFifo         => iwriteFifoToFifo(i), -- Test Mode
            writeFifoFromFifo       => writeFifoFromFifo(i),
            debug                   => fifoDebug(i)
         );

      -- Free list writes
      memPtrWrite(i).data(71 downto 36) <= (others=>'0');
      memPtrWrite(i).data(35 downto  0) <= fifoDin;
      memPtrWrite(i).write              <= fifoWrEn when fifoWrSel = i else '0';

      -- Header test data writes 
      iwriteFifoToFifo(i).data  <= fifoDin(35 downto 32) & "0000" & fifoDin(31 downto 0) & fifoDin(31 downto 0);
      iwriteFifoToFifo(i).write <= '1' when fifoWrSel = (4+i) and fifoWrEn = '1' else '0';

      -- Header completion FIFOs
      U_DescFifo: entity work.ArmRceG3IbDescFifo
         generic map (
            UseAsyncFifo => false
         );
         port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRst,
            axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
            axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArmFifo(4+i),
            fifoReq                 => fifoReq(4+i),
            fifoGnt                 => fifoGnt(4+i),
            memDirty                => dirtyFlag,
            memDirtySet             => dirtyFlagFifoSet(i),
            writeDmaBusyOut         => writeDmaBusyOut(i),
            writeDmaBusyIn          => writeDmaBusyIn,
            fifoEnable              => fifoEnable(4+i),
            writeDmaId              => writeDmaId(4+i),
            writeDmaCache           => writeDmaCache,
            memToggleEn             => memToggleEnable(i),
            memConfig               => memConfig(i*2+1 downto i*2),
            memBaseAddress          => memBaseAddress,
            writeFifoClk            => '0',
            writeFifoToFifo         => donePtrWrite(i),
            writeFifoFromFifo       => open,
            debug                   => fifoDebug(4+i)
         );

   end generate;

   -----------------------------------------
   -- Transaction Completion FIFOs, 4 - 14
   -----------------------------------------
   U_GenTcom: for i in 4 to 14 generate

      -- Transaction completion FIFOs
      U_DescFifo: entity work.ArmRceG3IbDescFifo
         port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRst,
            axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
            axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArmFifo(4+i),
            fifoReq                 => fifoReq(4+i),
            fifoGnt                 => fifoGnt(4+i),
            memDirty                => dirtyFlag,
            memDirtySet             => dirtyFlagFifoSet(i),
            writeDmaBusyOut         => writeDmaBusyOut(i),
            writeDmaBusyIn          => writeDmaBusyIn,
            fifoEnable              => fifoEnable(4+i),
            writeDmaId              => writeDmaId(4+i),
            writeDmaCache           => writeDmaCache,
            memToggleEn             => memToggleEnable(i),
            memConfig               => memConfig(i*2+1 downto i*2),
            memBaseAddress          => memBaseAddress,
            --writeFifoClk            => writeFifoClk(i),
            --writeFifoToFifo         => writeFifoToFifo(i),
            writeFifoClk            => axiClk,              -- Test Mode
            writeFifoToFifo         => iwriteFifoToFifo(i), -- Test Mode
            writeFifoFromFifo       => writeFifoFromFifo(i),
            debug                   => fifoDebug(4+i)
         );

      -- Test data writes 
      iwriteFifoToFifo(i).data(71 downto 36) <= (others=>'0');
      iwriteFifoToFifo(i).data(35 downto  0) <= fifoDin;
      iwriteFifoToFifo(i).write              <= fifoWrEn when fifoWrSel = (i+4) else '0';

   end generate;

   -----------------------------------------
   -- Egress Free List FIFOs, 15 - 16
   -----------------------------------------
   U_GenFlist: for i in 15 to 16 generate

      -- Egress free list FIFOs
      U_DescFifo: entity work.ArmRceG3IbDescFifo
         port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRst,
            axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
            axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArmFifo(4+i),
            fifoReq                 => fifoReq(4+i),
            fifoGnt                 => fifoGnt(4+i),
            memDirty                => dirtyFlag,
            memDirtySet             => dirtyFlagFifoSet(i),
            writeDmaBusyOut         => writeDmaBusyOut(i),
            writeDmaBusyIn          => writeDmaBusyIn,
            fifoEnable              => fifoEnable(4+i),
            writeDmaId              => writeDmaId(4+i),
            writeDmaCache           => writeDmaCache,
            memToggleEn             => '0',
            memConfig(0)            => memConfig(15+i),
            memConfig(1)            => memConfig(15+i),
            memBaseAddress          => memBaseAddress,
            --writeFifoClk            => writeFifoClk(i),
            --writeFifoToFifo         => writeFifoToFifo(i),
            writeFifoClk            => axiClk,              -- Test Mode
            writeFifoToFifo         => iwriteFifoToFifo(i), -- Test Mode
            writeFifoFromFifo       => writeFifoFromFifo(i),
            debug                   => fifoDebug(4+i)
         );

      -- Test data writes 
      iwriteFifoToFifo(i).data(71 downto 36) <= (others=>'0');
      iwriteFifoToFifo(i).data(35 downto  0) <= fifoDin;
      iwriteFifoToFifo(i).write              <= fifoWrEn when fifoWrSel = (i+4) else '0';

   end generate;

   ---------------------------
   -- Debug
   ---------------------------
   debug(127)            <= arbValid;
   debug(126 downto 122) <= arbSelect;
   debug(121 downto   0) <= fifoDebug(conv_integer(dbgSelect))(121 downto 0);

end architecture structure;

