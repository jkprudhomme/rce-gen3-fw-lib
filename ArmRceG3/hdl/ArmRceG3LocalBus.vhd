-------------------------------------------------------------------------------
-- Title         : AXI Bus To Local Bus Bridge
-- File          : ArmRceG3ReadCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- AXI bus slave controller for local bus accesses.
-- Designed to interface to one of the GP master ports on the ARM
-- GP0: 4000_0000 to 7FFF_FFFF
-- GP1: 8000_0000 to BFFF_FFFF
-- Address space is divided equally between 16 possible local bus slaves:
--            GP0 Base      GP0 Top     | GP1 Base      GP1 Top
-- Space 0  : 0x4000_0000 - 0x43FF_FFFF | 0x8000_0000 - 0x83FF_FFFF
-- Space 1  : 0x4400_0000 - 0x47FF_FFFF | 0x8400_0000 - 0x87FF_FFFF
-- Space 2  : 0x4800_0000 - 0x4BFF_FFFF | 0x8800_0000 - 0x8BFF_FFFF
-- Space 3  : 0x4C00_0000 - 0x4FFF_FFFF | 0x8C00_0000 - 0x8FFF_FFFF
-- Space 4  : 0x5000_0000 - 0x53FF_FFFF | 0x9000_0000 - 0x83FF_FFFF
-- Space 5  : 0x5400_0000 - 0x57FF_FFFF | 0x9400_0000 - 0x87FF_FFFF
-- Space 6  : 0x5800_0000 - 0x5BFF_FFFF | 0x9800_0000 - 0x8BFF_FFFF
-- Space 7  : 0x5C00_0000 - 0x5FFF_FFFF | 0x9C00_0000 - 0x8FFF_FFFF
-- Space 8  : 0x6000_0000 - 0x63FF_FFFF | 0xA000_0000 - 0xA3FF_FFFF
-- Space 9  : 0x6400_0000 - 0x67FF_FFFF | 0xA400_0000 - 0xA7FF_FFFF
-- Space 10 : 0x6800_0000 - 0x6BFF_FFFF | 0xA800_0000 - 0xABFF_FFFF
-- Space 11 : 0x6C00_0000 - 0x6FFF_FFFF | 0xAC00_0000 - 0xAFFF_FFFF
-- Space 12 : 0x7000_0000 - 0x73FF_FFFF | 0xB000_0000 - 0xB3FF_FFFF
-- Space 13 : 0x7400_0000 - 0x77FF_FFFF | 0xB400_0000 - 0xB7FF_FFFF
-- Space 14 : 0x7800_0000 - 0x7BFF_FFFF | 0xB800_0000 - 0xBBFF_FFFF
-- Space 15 : 0x7C00_0000 - 0x7FFF_FFFF | 0xBC00_0000 - 0xBFFF_FFFF
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;

entity ArmRceG3LocalBus is
   port (

      -- Clocks & Reset
      axiClk                  : in     std_logic;
      axiClkRst               : in     std_logic;

      -- AXI Master
      axiMasterReadFromArm    : in     AxiReadMasterType;
      axiMasterReadToArm      : out    AxiReadSlaveType;
      axiMasterWriteFromArm   : in     AxiWriteMasterType;
      axiMasterWriteToArm     : out    AxiWriteSlaveType;

      -- Local bus slaves
      localBusMaster          : out    LocalBusMasterVector(15 downto 0);
      localBusSlave           : in     LocalBusSlaveVector(15 downto 0)
   );
end ArmRceG3LocalBus;

architecture structure of ArmRceG3LocalBus is

   -- Local signals
   signal intMasterReadToArm   : AxiReadSlaveType;
   signal intMasterWriteToArm  : AxiWriteSlaveType;
   signal nxtMasterReadToArm   : AxiReadSlaveType;
   signal nxtMasterWriteToArm  : AxiWriteSlaveType;
   signal intLocalBusMaster    : LocalBusMasterVector(15 downto 0);
   signal genLocalBusMaster    : LocalBusMasterVector(15 downto 0);
   signal nxtLocalBusMaster    : LocalBusMasterType;
   signal curLocalBusMaster    : LocalBusMasterType;
   signal curLocalBusSlave     : LocalBusSlaveType;
   signal timeoutCnt           : std_logic_vector(7 downto 0);
   signal timeout              : std_logic;
   signal nxtSlave             : std_logic_vector(3 downto 0);
   signal curSlave             : std_logic_vector(3 downto 0);

   -- States
   signal   curState   : std_logic_vector(2 downto 0);
   signal   nxtState   : std_logic_vector(2 downto 0);
   constant ST_IDLE    : std_logic_vector(2 downto 0) := "001";
   constant ST_WRADDR  : std_logic_vector(2 downto 0) := "010";
   constant ST_WRITE   : std_logic_vector(2 downto 0) := "011";
   constant ST_ACK     : std_logic_vector(2 downto 0) := "100";
   constant ST_RDADDR  : std_logic_vector(2 downto 0) := "101";
   constant ST_READ    : std_logic_vector(2 downto 0) := "110";
   constant ST_READY   : std_logic_vector(2 downto 0) := "111";

begin

   -- Outputs
   axiMasterReadToArm   <= intMasterReadToArm;
   axiMasterWriteToArm  <= intMasterWriteToArm;
   localBusMaster       <= intLocalBusMaster;

   -- Sync states
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         curState             <= ST_IDLE                      after TPD_G;
         curSlave             <= (others=>'0')                after TPD_G;
         intMasterReadToArm   <= AxiReadSlaveInit             after TPD_G;
         intMasterWriteToArm  <= AxiWriteSlaveInit            after TPD_G;
         intLocalBusMaster    <= (others=>LocalBusMasterInit) after TPD_G;
         timeoutCnt           <= (others=>'0')                after TPD_G;
         timeout              <= '0'                          after TPD_G;
      elsif rising_edge(axiClk) then
         curState             <= nxtState            after TPD_G;
         curSlave             <= nxtSlave            after TPD_G;
         intMasterReadToArm   <= nxtMasterReadToArm  after TPD_G;
         intMasterWriteToArm  <= nxtMasterWriteToArm after TPD_G;
         intLocalBusMaster    <= genLocalBusMaster   after TPD_G;

         -- Timeout counter
         if curState /= ST_READ then
            timeoutCnt  <= (others=>'1')  after TPD_G;
            timeout     <= '0'            after TPD_G;
         elsif timeoutCnt = 0 then
            timeout     <= '1'            after TPD_G;
         else
            timeoutCnt  <= timeoutCnt - 1 after TPD_G;
            timeout     <= '0'            after TPD_G;
         end if;
      end if;
   end process;

   -- Determine current master channel
   curLocalBusSlave  <= localBusSLave(conv_integer(curSlave));
   curLocalBusMaster <= intLocalBusMaster(conv_integer(curSlave));
   
   -- Generate state of master channel, allow for register duplication
   U_GenDecode: for i in 0 to 15 generate
      genLocalBusMaster(i).addr        <= nxtLocalBusMaster.addr;
      genLocalBusMaster(i).addrValid   <= nxtLocalBusMaster.addrValid   when curSlave = i else '0';
      genLocalBusMaster(i).readEnable  <= nxtLocalBusMaster.readEnable  when curSlave = i else '0';
      genLocalBusMaster(i).writeEnable <= nxtLocalBusMaster.writeEnable when curSlave = i else '0';
      genLocalBusMaster(i).writeData   <= nxtLocalBusMaster.writeData;
   end generate;

   -- ASync states
   process ( curState, axiMasterReadFromArm, axiMasterWriteFromArm, intMasterReadToArm, 
             intMasterWriteToArm, curLocalBusMaster, curlocalBusSlave, timeout, curSlave ) begin

      -- Init signals
      nxtMasterReadToArm            <= intMasterReadToArm;
      nxtMasterReadToArm.arready    <= '0';
      nxtMasterReadToArm.rvalid     <= '0';
      nxtMasterReadToArm.rlast      <= '1';
      nxtMasterReadToArm.rlast      <= '1';
      nxtMasterWriteToArm           <= intMasterWriteToArm;
      nxtMasterWriteToArm.awready   <= '0';
      nxtLocalBusMaster             <= curLocalBusMaster;
      nxtLocalBusMaster.addrValid   <= '0';
      nxtLocalBusMaster.readEnable  <= '0';
      nxtLocalBusMaster.writeEnable <= '0';
      nxtState                      <= curState;
      nxtSlave                      <= curSlave;

      -- State machine
      case curState is 

         when ST_IDLE =>

            -- Write request
            if axiMasterWriteFromArm.awvalid = '1' then
               nxtSlave                    <= axiMasterWriteFromArm.awaddr(29 downto 26);
               nxtMasterWriteToArm.awready <= '1';
               nxtState                    <= ST_WRADDR;

            -- Read request
            elsif axiMasterReadFromArm.arvalid = '1' then
               nxtSlave                   <= axiMasterReadFromArm.araddr(29 downto 26);
               nxtMasterReadToArm.arready <= '1';
               nxtState                   <= ST_RDADDR;
            end if;

         -- Write Address
         when ST_WRADDR =>
            nxtMasterWriteToArm.bid     <= axiMasterWriteFromArm.awid;
            nxtMasterWriteToArm.wready  <= '1';
            nxtLocalBusMaster.addr      <= axiMasterWriteFromArm.awaddr;
            nxtLocalBusMaster.addrValid <= '1';
            nxtState                    <= ST_WRITE;

         -- Write Data
         when ST_WRITE =>
            if axiMasterWriteFromArm.wlast = '1' then
               nxtMasterWriteToArm.wready    <= '0';
               nxtLocalBusMaster.writeEnable <= '1';
               nxtLocalBusMaster.writeData   <= axiMasterWriteFromArm.wdata(31 downto 0);
               nxtMasterWriteToArm.bvalid    <= '1';
               nxtState                      <= ST_ACK;
            end if;

         -- Ack Write
         when ST_ACK =>
            if axiMasterWriteFromArm.bready = '1' then
               nxtMasterWriteToArm.bvalid <= '0';
               nxtState                   <= ST_IDLE;
            end if;

         -- Read Address
         when ST_RDADDR =>
            nxtMasterReadToArm.rid       <= axiMasterReadFromArm.arid;
            nxtLocalBusMaster.addr       <= axiMasterReadFromArm.araddr;
            nxtLocalBusMaster.addrValid  <= '1';
            nxtLocalBusMaster.readEnable <= '1';
            nxtState                     <= ST_READ;

         -- Wait for read data
         when ST_READ =>

            -- Slave done
            if curLocalBusSlave.readValid = '1' then
               nxtMasterReadToArm.rvalid <= '1';
               nxtMasterReadToArm.rdata  <= x"00000000" & curLocalBusSlave.readData;
               nxtState                  <= ST_READY;

            -- Timeout
            elsif timeout = '1' then
               nxtMasterReadToArm.rvalid <= '1';
               nxtMasterReadToArm.rdata  <= x"deadbeefdeadbeef";
               nxtState                  <= ST_READY;
            end if;

         -- Wait for read ready
         when ST_READY =>
            if axiMasterReadFromArm.rready = '1' then
               nxtState <= ST_IDLE;
            else
               nxtMasterReadToArm.rvalid <= '1';
            end if;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

end architecture structure;

