-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Inbound FIFOs
-- File          : ArmRceG3IbCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Inbound FIFOs for PPI DMA Engines
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

entity ArmRceG3IbCntrl is
   port (

      -- Clock
      axiClk                  : in  std_logic;

      -- AXI ACP Master
      axiAcpSlaveReset        : in  std_logic;
      axiAcpSlaveWriteFromArm : in  AxiWriteSlaveType;
      axiAcpSlaveWriteToArm   : out AxiWriteMasterType;

      -- Interrupts
      interrupt               : out std_logic_vector(14 downto 0);

      -- Local Bus
      localBusReset           : in  std_logic;
      localBusMaster          : in  LocalBusMasterType;
      localBusSlave           : out LocalBusSlaveType;

      -- FIFO Interface
      writeFifoClk            : in  std_logic_vector(14 downto 0);
      writeFifoToFifo         : in  WriteFifoToFifoVector(14 downto 0);
      writeFifoFromFifo       : out WriteFifoFromFifoVector(14 downto 0);

      -- Debug
      debug                   : out std_logic_vector(127 downto 0)
   );
end ArmRceG3IbCntrl;

architecture structure of ArmRceG3IbCntrl is

   -- Local signals
   signal axiAcpSlaveWriteToArmFifo : AxiWriteMasterVector(14 downto 0);
   signal intLocalBusSlave          : LocalBusSlaveType;
   signal dmaConfig                 : Word32Array(31 downto 0);
   signal fifoDin                   : std_logic_vector(35 downto 0);
   signal fifoWrEn                  : std_logic;
   signal fifoWrSel                 : std_logic_vector(3  downto 0);
   signal dirtyClearEn              : std_logic;
   signal dirtyClearSel             : std_logic_vector(3  downto 0);
   signal writeDmaCache             : std_logic_vector(3  downto 0);
   signal fifoEnable                : std_logic_vector(14 downto 0);
   signal fifoId                    : Word4Array(14 downto 0);
   signal fifoToggleEnable          : std_logic_vector(14 downto 0);
   signal intEnable                 : std_logic_vector(14 downto 0);
   signal dirtyFlag                 : std_logic_vector(14 downto 0);
   signal dirtyFlagSet              : std_logic_vector(14 downto 0);
   signal dirtyFlagFifoSet          : Word15Array(14 downto 0);
   signal iwriteFifoToFifo          : WriteFifoToFifoVector(14 downto 0);
   signal fifoDebug                 : Word128Array(14 downto 0);
   signal fifoReq                   : std_logic_vector(14 downto 0);
   signal fifoGnt                   : std_logic_vector(14 downto 0);
   signal dbgSelect                 : std_logic_vector(3  downto 0);
   signal arbSelect                 : std_logic_vector(2  downto 0);
   signal arbValid                  : std_logic;

begin

   -- Outputs
   localBusSlave <= intLocalBusSlave;
   interrupt     <= dirtyFlag and intEnable;

   --------------------------------------------
   -- Registers: 0x8800_0000 - 0x8BFF_FFFF
   --------------------------------------------
   process ( axiClk, localBusReset ) begin
      if localBusReset = '1' then
         intLocalBusSlave <= LocalBusSlaveInit       after TPD_G;
         dmaConfig        <= (others=>(others=>'0')) after TPD_G;
         fifoWrEn         <= '0'                     after TPD_G;
         fifoWrSel        <= (others=>'0')           after TPD_G;
         fifoDin          <= (others=>'0')           after TPD_G;
         dirtyClearEn     <= '0'                     after TPD_G;
         dirtyClearSel    <= (others=>'0')           after TPD_G;
         writeDmaCache    <= (others=>'0')           after TPD_G;
         fifoEnable       <= (others=>'0')           after TPD_G;
         fifoToggleEnable <= (others=>'0')           after TPD_G;
         intEnable        <= (others=>'0')           after TPD_G;
         dbgSelect        <= (others=>'0')           after TPD_G;
      elsif rising_edge(axiClk) then
         intLocalBusSlave.readValid <= localBusMaster.readEnable after TPD_G;

         -- FIFO DMA Configuration, 2 per FIFO - 0x88000000 - 0x8800007F
         if localBusMaster.addr(23 downto 16) = x"00" then
            if localBusMaster.writeEnable = '1' then
               dmaConfig(conv_integer(localBusMaster.addr(6 downto 2))) <= localBusMaster.writeData after TPD_G;
            end if;
            intLocalBusSlave.readData <= dmaConfig(conv_integer(localBusMaster.addr(6 downto 2))) after TPD_G;

         -- FIFO test writes - 0x88010000 - 0x880103FF
         elsif localBusMaster.addr(23 downto 16) = x"01" then
            fifoWrEn                  <= localBusMaster.writeEnable      after TPD_G;
            fifoWrSel                 <= localBusMaster.addr(9 downto 6) after TPD_G;
            fifoDin(35 downto 32)     <= localBusMaster.addr(5 downto 2) after TPD_G;
            fifoDin(31 downto  0)     <= localBusMaster.writeData        after TPD_G;
            intLocalBusSlave.readData <= x"deadbeef"                     after TPD_G;

         -- Channel Dirty flags clear, 16 - 0x88020000 - 0x8802003F
         elsif localBusMaster.addr(23 downto 16) = x"02" then
            dirtyClearEn              <= localBusMaster.writeEnable      after TPD_G;
            dirtyClearSel             <= localBusMaster.addr(5 downto 2) after TPD_G;
            intLocalBusSlave.readData <= x"deadbeef"                     after TPD_G;

         -- AXI Write DMA Cache Config 0x88030000
         elsif localBusMaster.addr(23 downto 0) = x"030000" then
            if localBusMaster.writeEnable = '1' then
               writeDmaCache <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000000" & writeDmaCache after TPD_G;

         -- FIFO Enable 0x88030004
         elsif localBusMaster.addr(23 downto 0) = x"030004" then
            if localBusMaster.writeEnable = '1' then
               fifoEnable <= localBusMaster.writeData(14 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000" & "0" & fifoEnable after TPD_G;

         -- FIFO Toggle Enable 0x88030008
         elsif localBusMaster.addr(23 downto 0) = x"030008" then
            if localBusMaster.writeEnable = '1' then
               fifoToggleEnable <= localBusMaster.writeData(14 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000" & "0" & fifoToggleEnable after TPD_G;

         -- Dirty status 0x8803000C
         elsif localBusMaster.addr(23 downto 0) = x"03000C" then
            intLocalBusSlave.readData <= x"0000" & "0" & dirtyFlag after TPD_G;

         -- Interrupt Enable 0x88030010
         elsif localBusMaster.addr(23 downto 0) = x"030010" then
            if localBusMaster.writeEnable = '1' then
               intEnable <= localBusMaster.writeData(14 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000" & "0" & intEnable after TPD_G;

         -- Debug select 0x88030014
         elsif localBusMaster.addr(23 downto 0) = x"030014" then
            if localBusMaster.writeEnable = '1' then
               dbgSelect <= localBusMaster.writeData(3 downto 0) after TPD_G;
            end if;
            intLocalBusSlave.readData <= x"0000000" & dbgSelect after TPD_G;

         -- Unsupported
         else
            fifoWrEn                   <= '0'         after TPD_G;
            dirtyClearEn               <= '0'         after TPD_G;
            intLocalBusSlave.readData  <= x"deadbeef" after TPD_G;
         end if;
      end if;  
   end process;         

   -----------------------------------------
   -- Dirty flags & interrupts
   -----------------------------------------

   -- Combine sets from FPGAs
   dirtyFlagSet <= dirtyFlagFifoSet(0)  or dirtyFlagFifoSet(1)  or dirtyFlagFifoSet(2)  or dirtyFlagFifoSet(3)
                or dirtyFlagFifoSet(4)  or dirtyFlagFifoSet(5)  or dirtyFlagFifoSet(6)  or dirtyFlagFifoSet(7)
                or dirtyFlagFifoSet(8)  or dirtyFlagFifoSet(9)  or dirtyFlagFifoSet(10) or dirtyFlagFifoSet(11)
                or dirtyFlagFifoSet(12) or dirtyFlagFifoSet(13) or dirtyFlagFifoSet(14);

   U_DirtyGen: for i in 0 to 14 generate
      process ( axiClk, axiAcpSlaveReset ) begin
         if axiAcpSlaveReset = '1' then
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
         REQ_SIZE_G => 8
      ) port map (
         clk      => axiClk,
         aRst     => '0',
         sRst     => axiAcpSlaveReset,
         req      => fifoReq(7 downto 0),
         selected => arbSelect,
         valid    => arbValid,
         ack      => fifoGnt(7 downto 0)
      );

   fifoGnt(14 downto 8) <= (others=>'0');
 
   -- Mux ACP bus mastership
   axiAcpSlaveWriteToArm <= axiAcpSlaveWriteToArmFifo(conv_integer(arbSelect));

   -----------------------------------------
   -- FIFOs
   -----------------------------------------

   -- First four FIFOs are 72-bit FIFOs
   U_GenBurstFifo: for i in 0 to 3 generate

      U_Fifo: entity work.ArmRceG3IbBurst 
         port map (
            axiClk                  => axiClk,
            axiAcpSlaveReset        => axiAcpSlaveReset,
            axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
            axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArmFifo(i),
            fifoReq                 => fifoReq(i),
            fifoGnt                 => fifoGnt(i),
            memDirty                => dirtyFlag,
            memDirtySet             => dirtyFlagFifoSet(i),
            fifoId                  => fifoId(i),
            fifoEnable              => fifoEnable(i),
            memToggleEn             => fifoToggleEnable(i),
            memConfig               => dmaConfig(i*2+1 downto i*2),
            writeDmaCache           => writeDmaCache,
            --writeFifoClk            => writeFifoClk(i),
            writeFifoClk            => axiClk,
            writeFifoToFifo         => iwriteFifoToFifo(i),
            writeFifoFromFifo       => writeFifoFromFifo(i),
            debug                   => fifoDebug(i)
         );

      fifoId(i) <= conv_std_logic_vector(i,4);

      -- Debug writes, for initial testing
      iwriteFifoToFifo(i).data  <= fifoDin(35 downto 32) & "0000" & fifoDin(31 downto 0) & fifoDin(31 downto 0);
      iwriteFifoToFifo(i).write <= '1' when fifoWrSel = i and fifoWrEn = '1' else '0';

   end generate;

   -- Fifos 5 - 7 are single entry FIFOs
   U_GenSingleFifo: for i in 4 to 7 generate

      U_Fifo: entity work.ArmRceG3IbSingle
         port map (
            axiClk                  => axiClk,
            axiAcpSlaveReset        => axiAcpSlaveReset,
            axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
            axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArmFifo(i),
            fifoReq                 => fifoReq(i),
            fifoGnt                 => fifoGnt(i),
            memDirty                => dirtyFlag,
            memDirtySet             => dirtyFlagFifoSet(i),
            fifoId                  => fifoId(i),
            fifoEnable              => fifoEnable(i),
            memToggleEn             => fifoToggleEnable(i),
            memConfig               => dmaConfig(i*2+1 downto i*2),
            writeDmaCache           => writeDmaCache,
            --writeFifoClk            => writeFifoClk(i),
            writeFifoClk            => axiClk,
            writeFifoToFifo         => iwriteFifoToFifo(i),
            writeFifoFromFifo       => writeFifoFromFifo(i),
            debug                   => fifoDebug(i)
         );

      fifoId(i) <= conv_std_logic_vector(i,4);

      -- Debug writes, for initial testing
      iwriteFifoToFifo(i).data  <= x"000000000" & fifoDin;
      iwriteFifoToFifo(i).write <= '1' when fifoWrSel = i and fifoWrEn = '1' else '0';

   end generate;

   -- Fifos 8 - 14 are not supported yet
   U_GenEmptyifo: for i in 8 to 14 generate
      iwriteFifoToFifo(i).data     <= (others=>'0');
      iwriteFifoToFifo(i).write    <= '0';
      axiAcpSlaveWriteToArmFifo(i) <= AxiWriteMasterInit;
      fifoReq(i)                   <= '0';
      dirtyFlagFifoSet(i)          <= (others=>'0');
      writeFifoFromFifo(i)         <= WriteFifoFromFifoInit;
      fifoDebug(i)                 <= (others=>'0');
   end generate;

   ---------------------------
   -- Debug
   ---------------------------
   debug(127)            <= arbValid;
   debug(126 downto 124) <= arbSelect;
   debug(123 downto   0) <= fifoDebug(conv_integer(dbgSelect))(123 downto 0);

end architecture structure;

