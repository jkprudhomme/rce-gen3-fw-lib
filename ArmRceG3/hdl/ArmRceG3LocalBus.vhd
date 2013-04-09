-------------------------------------------------------------------------------
-- Title         : AXI Bus To Local Bus Bridge
-- File          : ArmRceG3ReadCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- AXI bus slave controller for local bus accesses.
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
      axiResetN               : in     std_logic;

      -- AXI Master
      axiMasterReadFromArm    : in     AxiReadMasterType;
      axiMasterReadToArm      : out    AxiReadSlaveType;
      axiMasterWriteFromArm   : in     AxiWriteMasterType;
      axiMasterWriteToArm     : out    AxiWriteSlaveType;

      -- Local bus
      localAddr               : out    std_logic_vector(31 downto 0);
      localReq                : out    std_logic;
      localAck                : in     std_logic;
      localFail               : in     std_logic;
      localWen                : out    std_logic;
      localWrData             : out    std_logic_vector(31 downto 0);
      localRdData             : in     std_logic_vector(31 downto 0)
   );
end ArmRceG3LocalBus;

architecture structure of ArmRceG3LocalBus is

   -- Local signals
   signal intMasterReadToArm   : AxiReadSlaveType;
   signal intMasterWriteToArm  : AxiWriteSlaveType;
   signal nxtMasterReadToArm   : AxiReadSlaveType;
   signal nxtMasterWriteToArm  : AxiWriteSlaveType;
   signal nextAddr             : std_logic_vector(31 downto 0);
   signal nextReq              : std_logic;
   signal nextWen              : std_logic;
   signal intAddr              : std_logic_vector(31 downto 0);
   signal intReq               : std_logic;
   signal intWen               : std_logic;
   signal timeoutCnt           : std_logic_vector(31 downto 0);
   signal timeout              : std_logic;

   -- States
   signal   curState  : std_logic_vector(2 downto 0);
   signal   nxtState  : std_logic_vector(2 downto 0);
   constant ST_IDLE   : std_logic_vector(2 downto 0) := "001";
   constant ST_READ   : std_logic_vector(2 downto 0) := "010";
   constant ST_WAIT   : std_logic_vector(2 downto 0) := "011";
   constant ST_WRITE  : std_logic_vector(2 downto 0) := "100";
   constant ST_ACK    : std_logic_vector(2 downto 0) := "101";

begin

   axiMasterReadToArm   <= intMasterReadToArm;
   axiMasterWriteToArm  <= intMasterWriteToArm;
   localAddr            <= intAddr;
   localReq             <= intReq;
   localWen             <= intWen;

   -- Sync states
   process ( axiClk, axiResetN ) begin
      if axiResetN = '0' then
         curState             <= ST_IDLE             after tpd;
         intMasterReadToArm   <= AxiReadSlaveInit    after tpd;
         intMasterWriteToArm  <= AxiWriteSlaveInit   after tpd;
         intAddr              <= (others=>'0')       after tpd;
         intReq               <= '0'                 after tpd;
         intWen               <= '0'                 after tpd;
         localWrData          <= (others=>'0')       after tpd;
         timeoutCnt           <= (others=>'0')       after tpd;
         timeout              <= '0'                 after tpd;
      elsif rising_edge(axiClk) then
         curState             <= nxtState            after tpd;
         intMasterReadToArm   <= nxtMasterReadToArm  after tpd;
         intMasterWriteToArm  <= nxtMasterWriteToArm after tpd;
         intAddr              <= nextAddr            after tpd;
         intReq               <= nextReq             after tpd;
         intWen               <= nextWen             after tpd;

         if axiMasterWriteFromArm.wvalid = '1' then
            localWrData <= axiMasterWriteFromArm.wdata(31 downto 0) after tpd;
         end if;

         if nextReq = '0' then
            timeoutCnt  <= (others=>'0')  after tpd;
            timeout     <= '0'            after tpd;
         elsif timeoutCnt = x"FFFFFFFF" then
            timeout     <= '1'            after tpd;
         else
            timeoutCnt  <= timeoutCnt + 1 after tpd;
            timeout     <= '0'            after tpd;
         end if;
      end if;
   end process;

   -- ASync states
   process ( curState, axiMasterReadFromArm, axiMasterWriteFromArm, intMasterReadToArm, intMasterWriteToArm,
             intAddr, intReq, intWen, timeout, localRdData, localAck, localFail ) begin

      -- Init signals
      nxtMasterReadToArm        <= intMasterReadToArm;
      nxtMasterWriteToArm       <= intMasterWriteToArm;
      nxtMasterReadToArm.rvalid <= '0';
      nxtMasterReadToArm.rdata  <= x"00000000" & localRdData;
      nextAddr                  <= intAddr;
      nextReq                   <= intReq;
      nextWen                   <= intWen;
      nxtState                  <= curState;

      -- State machine
      case curState is 

         when ST_IDLE =>

            -- Read request
            if axiMasterReadFromArm.arvalid = '1' and axiMasterReadFromArm.arlen = 0 and axiMasterReadFromArm.arsize = "010" then
               nxtMasterReadToArm.rid     <= axiMasterReadFromArm.arid;
               nxtMasterReadToArm.arready <= '1';
               nextAddr                   <= axiMasterReadFromArm.araddr;
               nextReq                    <= '1';
               nextWen                    <= '0';
               nxtState                   <= ST_READ;

            -- Write request
            elsif axiMasterWriteFromArm.awvalid = '1' and axiMasterWriteFromArm.awlen = 0 and axiMasterWriteFromArm.awsize = "010" then
               nxtMasterWriteToArm.bid     <= axiMasterWriteFromArm.awid;
               nxtMasterWriteToArm.awready <= '1';
               nxtMasterWriteToArm.wready  <= '1';
               nextAddr                    <= axiMasterWriteFromArm.awaddr;
               nxtState                    <= ST_WAIT;
            end if;

         when ST_READ =>
            nxtMasterReadToArm.arready <= '0';
            nxtMasterReadToArm.rlast   <= '1';

            -- Timeout
            if timeout = '1' then
               nextReq                   <= '0';
               nxtMasterReadToArm.rvalid <= '1';
               nxtMasterReadToArm.rresp  <= "10";
               nxtState                  <= ST_IDLE;

            -- Slave done
            elsif localAck = '1' then
               nextReq                   <= '0';
               nxtMasterReadToArm.rvalid <= '1';
               nxtState                  <= ST_IDLE;

               -- Error
               if localFail = '1' then
                  nxtMasterReadToArm.rresp <= "10";
               else
                  nxtMasterReadToArm.rresp <= "00";
               end if;
            end if;

         when ST_WAIT =>
            nxtMasterWriteToArm.awready <= '0';

            -- Last is asserted
            if axiMasterWriteFromArm.wlast = '1' then
               nxtMasterWriteToArm.wready <= '0';
               nextReq                    <= '1';
               nextWen                    <= '1';
               nxtState                   <= ST_WRITE;
            end if;

         when ST_WRITE =>

            -- Timeout
            if timeout = '1' then
               nextReq                    <= '0';
               nextWen                    <= '0';
               nxtMasterWriteToArm.bvalid <= '1';
               nxtMasterWriteToArm.bresp  <= "10";
               nxtState                   <= ST_ACK;

            -- Slave done
            elsif localAck = '1' then
               nextReq                    <= '0';
               nextWen                    <= '0';
               nxtMasterWriteToArm.bvalid <= '1';
               nxtState                   <= ST_ACK;

               -- Error
               if localFail = '1' then
                  nxtMasterWriteToArm.bresp <= "10";
               else
                  nxtMasterWriteToArm.bresp <= "00";
               end if;
            end if;

         when ST_ACK =>

            if axiMasterWriteFromArm.bready = '1' then
               nxtMasterWriteToArm.bvalid <= '0';
               nxtState                   <= ST_IDLE;
            end if;

         when others =>
            nxtState <= ST_IDLE;
      end case;
   end process;

end architecture structure;

