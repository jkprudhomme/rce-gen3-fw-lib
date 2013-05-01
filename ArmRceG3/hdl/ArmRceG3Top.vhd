-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Top Level
-- File          : ArmRceG3Top.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level file for ARM based rce generation 3 processor core.
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
use work.Version.all;

entity ArmRceG3Top is
   port (

      -- LEDs
      led1                     : out   std_logic;
      led2                     : out   std_logic;

      -- I2C
      i2cSda                   : inout std_logic;
      i2cScl                   : inout std_logic

   );
end ArmRceG3Top;

architecture structure of ArmRceG3Top is

   component zynq_icon
      PORT (
         CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
      );
   end component;

   component zynq_ila
      PORT (
         CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
         CLK     : IN    STD_LOGIC;
         TRIG0   : IN    STD_LOGIC_VECTOR(127 DOWNTO 0)
      );
   end component;

   -- Local signals
   signal axiGpMasterReset         : std_logic_vector(1 downto 0);
   signal axiGpMasterWriteFromArm  : AxiWriteMasterVector(1 downto 0);
   signal axiGpMasterWriteToArm    : AxiWriteSlaveVector(1 downto 0);
   signal axiGpMasterReadFromArm   : AxiReadMasterVector(1 downto 0);
   signal axiGpMasterReadToArm     : AxiReadSlaveVector(1 downto 0);
   signal axiGpSlaveReset          : std_logic_vector(1 downto 0);
   signal axiGpSlaveWriteFromArm   : AxiWriteSlaveVector(1 downto 0);
   signal axiGpSlaveWriteToArm     : AxiWriteMasterVector(1 downto 0);
   signal axiGpSlaveReadFromArm    : AxiReadSlaveVector(1 downto 0);
   signal axiGpSlaveReadToArm      : AxiReadMasterVector(1 downto 0);
   signal axiAcpSlaveReset         : std_logic;
   signal axiAcpSlaveWriteFromArm  : AxiWriteSlaveType;
   signal axiAcpSlaveWriteToArm    : AxiWriteMasterType;
   signal axiAcpSlaveReadFromArm   : AxiReadSlaveType;
   signal axiAcpSlaveReadToArm     : AxiReadMasterType;
   signal axiHpSlaveReset          : std_logic_vector(3 downto 0);
   signal axiHpSlaveWriteFromArm   : AxiWriteSlaveVector(3 downto 0);
   signal axiHpSlaveWriteToArm     : AxiWriteMasterVector(3 downto 0);
   signal axiHpSlaveReadFromArm    : AxiReadSlaveVector(3 downto 0);
   signal axiHpSlaveReadToArm      : AxiReadMasterVector(3 downto 0);
   signal armInt                   : std_logic_vector(15 downto 0);
   signal sysClk100                : std_logic;
   signal control0                 : std_logic_vector(35 DOWNTO 0);
   signal trig0                    : std_logic_vector(127 DOWNTO 0);
   signal localBusMaster           : LocalBusMasterVector(15 downto 0);
   signal localBusSlave            : LocalBusSlaveVector(15 downto 0);
   signal scratchPad               : std_logic_vector(31 downto 0);
   signal fifoDebug                : std_logic_vector(127 DOWNTO 0);

begin

   led1 <= scratchPad(0);
   led2 <= scratchPad(1);

   --------------------------------------------
   -- Processor Core
   --------------------------------------------

   U_ArmRceG3Cpu : entity work.ArmRceG3Cpu 
      port map (
         fclkClk3                 => open,
         fclkClk2                 => open,
         fclkClk1                 => open,
         fclkClk0                 => sysClk100,
         fclkRst3                 => open,
         fclkRst2                 => open,
         fclkRst1                 => open,
         fclkRst0                 => open,
         armInt                   => armInt,
         axiGpMasterClk1          => sysClk100,
         axiGpMasterClk0          => sysClk100,
         axiGpMasterReset         => axiGpMasterReset,
         axiGpMasterWriteFromArm  => axiGpMasterWriteFromArm,
         axiGpMasterWriteToArm    => axiGpMasterWriteToArm,
         axiGpMasterReadFromArm   => axiGpMasterReadFromArm,
         axiGpMasterReadToArm     => axiGpMasterReadToArm,
         axiGpSlaveClk1           => sysClk100,
         axiGpSlaveClk0           => sysClk100,
         axiGpSlaveReset          => axiGpSlaveReset,
         axiGpSlaveWriteFromArm   => axiGpSlaveWriteFromArm,
         axiGpSlaveWriteToArm     => axiGpSlaveWriteToArm,
         axiGpSlaveReadFromArm    => axiGpSlaveReadFromArm,
         axiGpSlaveReadToArm      => axiGpSlaveReadToArm,
         axiAcpSlaveClk           => sysClk100,
         axiAcpSlaveReset         => axiAcpSlaveReset,
         axiAcpSlaveWriteFromArm  => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm    => axiAcpSlaveWriteToArm,
         axiAcpSlaveReadFromArm   => axiAcpSlaveReadFromArm,
         axiAcpSlaveReadToArm     => axiAcpSlaveReadToArm,
         axiHpSlaveClk3           => sysClk100,
         axiHpSlaveClk2           => sysClk100,
         axiHpSlaveClk1           => sysClk100,
         axiHpSlaveClk0           => sysClk100,
         axiHpSlaveReset          => axiHpSlaveReset,
         axiHpSlaveWriteFromArm   => axiHpSlaveWriteFromArm,
         axiHpSlaveWriteToArm     => axiHpSlaveWriteToArm,
         axiHpSlaveReadFromArm    => axiHpSlaveReadFromArm,
         axiHpSlaveReadToArm      => axiHpSlaveReadToArm
      );

   --axiGpMasterWriteFromArm(0)
   --axiGpMasterReadFromArm(0)
   axiGpMasterWriteToArm(0)   <= AxiWriteSlaveInit;
   axiGpMasterReadToArm(0)    <= AxiReadSlaveInit;

   --axiGpSlaveWriteFromArm
   --axiGpSlaveReadFromArm
   axiGpSlaveWriteToArm       <= (others=>AxiWriteMasterInit);
   axiGpSlaveReadToArm        <= (others=>AxiReadMasterInit);

   axiAcpSlaveReadToArm       <= AxiReadMasterInit;

   --axiHpSlaveWriteFromArm
   --axiHpSlaveReadFromArm
   axiHpSlaveWriteToArm       <= (others=>AxiWriteMasterInit);
   axiHpSlaveReadToArm        <= (others=>AxiReadMasterInit);

   armInt(15 downto 0)        <= (others=>'0');

   --------------------------------------------
   -- Register Controller
   --------------------------------------------
   
   -- GP1: 8000_0000 to BFFF_FFFF
   U_ArmRceG3LocalBus: entity work.ArmRceG3LocalBus 
      port map (
         axiClk                  => sysClk100,
         axiClkRst               => axiGpMasterReset(1),
         axiMasterReadFromArm    => axiGpMasterReadFromArm(1),
         axiMasterReadToArm      => axiGpMasterReadToArm(1),
         axiMasterWriteFromArm   => axiGpMasterWriteFromArm(1),
         axiMasterWriteToArm     => axiGpMasterWriteToArm(1),
         localBusMaster          => localBusMaster,
         localBusSlave           => localBusSlave
      );

   localBusSlave(15 downto 3) <= (others=>LocalBusSlaveInit);

   --------------------------------------------
   -- Local Registers
   --------------------------------------------

   process ( sysClk100, axiGpMasterReset ) begin
      if axiGpMasterReset(1) = '1' then
         scratchPad       <= (others=>'0')     after TPD_G;
         localBusSlave(0) <= LocalBusSlaveInit after TPD_G;
      elsif rising_edge(sysClk100) then

         -- 0x80000000
         if localBusMaster(0).addr(25 downto 2) = x"000000" then
            localBusSlave(0).readData  <= FpgaVersion                  after TPD_G;
            localBusSlave(0).readValid <= localBusMaster(0).readEnable after TPD_G;

         -- 0x80000004
         elsif localBusMaster(0).addr(25 downto 2) = x"000001" then
            if localBusMaster(0).writeEnable = '1' then
               scratchPad <= localBusMaster(0).writeData after TPD_G;   
            end if;
            localBusSlave(0).readData  <= scratchPad                   after TPD_G;
            localBusSlave(0).readValid <= localBusMaster(0).readEnable after TPD_G;

         -- Unsupported
         else
            localBusSlave(0).readData  <= x"deadbeef"                  after TPD_G;
            localBusSlave(0).readValid <= localBusMaster(0).readEnable after TPD_G;
         end if;
      end if;  
   end process;         

   --------------------------------------------
   -- I2C Controller
   --------------------------------------------

   -- 0x8400_0000 - 0x87FF_FFFF
   U_ArmRceG3I2c : entity work.ArmRceG3I2c
      port map (
         ponRst         => axiGpMasterReset(1),
         localClk       => sysClk100,
         localClkRst    => axiGpMasterReset(1),
         localBusMaster => localBusMaster(1),
         localBusSlave  => localBusSlave(1),
         i2cIrq         => open,
         i2cSda         => i2cSda,
         i2cScl         => i2cScl
      );

   --------------------------------------------
   -- FIFO Test Interface
   --------------------------------------------

   -- 0x8800_0000 - 0x8BFF_FFFF
   U_ArmRceG3Fifos: entity work.ArmRceG3Fifos 
      port map (
         axiClk                  => sysClk100,
         axiClkRst               => axiAcpSlaveReset,
         axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArm,
         localBusMaster          => localBusMaster(2),
         localBusSlave           => localBusSlave(2),
         debug                   => fifoDebug
      );

   --------------------------------------------
   -- Debug
   --------------------------------------------

   U_icon: zynq_icon
      port map ( 
         CONTROL0 => control0
      );

   U_ila: zynq_ila
      port map (
         CONTROL => control0,
         CLK     => sysClk100,
         TRIG0   => trig0
      );

   trig0(127)          <= axiGpMasterReadToArm(1).arready;
   trig0(126)          <= axiGpMasterReadToArm(1).rvalid;
   trig0(125)          <= axiGpMasterReadFromArm(1).arvalid;
   trig0(124)          <= axiGpMasterReadFromArm(1).rready;
   trig0(123)          <= axiGpMasterWriteFromArm(1).awvalid;
   trig0(122)          <= axiGpMasterWriteFromArm(1).wlast;
   trig0(121)          <= axiGpMasterWriteFromArm(1).wvalid;
   trig0(120)          <= axiGpMasterWriteFromArm(1).bready;
   trig0(119)          <= axiGpMasterWriteToArm(1).awready;
   trig0(118)          <= axiGpMasterWriteToArm(1).wready;
   trig0(117)          <= axiGpMasterWriteToArm(1).bvalid;
   trig0(116)          <= localBusMaster(2).addrValid;
   trig0(115)          <= localBusMaster(2).readEnable;
   trig0(114)          <= localBusMaster(2).writeEnable;
   trig0(113)          <= localBusSlave(2).readValid;
   trig0(112 downto 0) <= fifoDebug(112 downto 0);

end architecture structure;

