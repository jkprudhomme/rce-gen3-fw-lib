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
   generic (
      DebugEn : Boolean := false
   );
   port (

      -- LEDs
      led                      : out   std_logic_vector(1 downto 0);

      -- I2C
      i2cSda                   : inout std_logic;
      i2cScl                   : inout std_logic;

      -- Clocks
      axiClk                   : out   std_logic;
      axiClkRst                : out   std_logic;
      sysClk125                : out   std_logic;
      sysClk125Rst             : out   std_logic;
      sysClk200                : out   std_logic;
      sysClk200Rst             : out   std_logic;

      -- External Local Bus
      localBusMaster           : out   LocalBusMasterVector(15 downto 15);
      localBusSlave            : in    LocalBusSlaveVector(15 downto 15);

      -- Ethernet
      ethFromArm               : out   EthFromArmType;
      ethToArm                 : in    EthToArmType

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
   signal fclkClk3                 : std_logic;
   signal fclkClk2                 : std_logic;
   signal fclkClk1                 : std_logic;
   signal fclkClk0                 : std_logic;
   signal fclkRst3                 : std_logic;
   signal fclkRst2                 : std_logic;
   signal fclkRst1                 : std_logic;
   signal fclkRst0                 : std_logic;
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
   signal control0                 : std_logic_vector(35 DOWNTO 0);
   signal trig0                    : std_logic_vector(127 DOWNTO 0);
   signal intLocalBusMaster        : LocalBusMasterVector(15 downto 0);
   signal intLocalBusSlave         : LocalBusSlaveVector(15 downto 0);
   signal intLocalBusReset         : std_logic;
   signal scratchPad               : std_logic_vector(31 downto 0);
   signal fifoDebug                : std_logic_vector(127 DOWNTO 0);
   signal iaxiClk                  : std_logic;
   signal iaxiClkRst               : std_logic;
   signal isysClk125               : std_logic;
   signal isysClk125Rst            : std_logic;
   signal isysClk200               : std_logic;
   signal isysClk200Rst            : std_logic;
   signal writeFifoClk             : std_logic_vector(16 downto 0);
   signal writeFifoToFifo          : WriteFifoToFifoVector(16 downto 0);
   signal writeFifoFromFifo        : WriteFifoFromFifoVector(16 downto 0);

begin

   --------------------------------------------
   -- Processor Core
   --------------------------------------------

   U_ArmRceG3Cpu : entity work.ArmRceG3Cpu 
      port map (
         fclkClk3                 => fclkClk3,
         fclkClk2                 => fclkClk2,
         fclkClk1                 => fclkClk1,
         fclkClk0                 => fclkClk0,
         fclkRst3                 => fclkRst3,
         fclkRst2                 => fclkRst2,
         fclkRst1                 => fclkRst1,
         fclkRst0                 => fclkRst0,
         axiClk                   => iaxiClk,
         armInt                   => armInt,
         axiGpMasterReset         => axiGpMasterReset,
         axiGpMasterWriteFromArm  => axiGpMasterWriteFromArm,
         axiGpMasterWriteToArm    => axiGpMasterWriteToArm,
         axiGpMasterReadFromArm   => axiGpMasterReadFromArm,
         axiGpMasterReadToArm     => axiGpMasterReadToArm,
         axiGpSlaveReset          => axiGpSlaveReset,
         axiGpSlaveWriteFromArm   => axiGpSlaveWriteFromArm,
         axiGpSlaveWriteToArm     => axiGpSlaveWriteToArm,
         axiGpSlaveReadFromArm    => axiGpSlaveReadFromArm,
         axiGpSlaveReadToArm      => axiGpSlaveReadToArm,
         axiAcpSlaveReset         => axiAcpSlaveReset,
         axiAcpSlaveWriteFromArm  => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm    => axiAcpSlaveWriteToArm,
         axiAcpSlaveReadFromArm   => axiAcpSlaveReadFromArm,
         axiAcpSlaveReadToArm     => axiAcpSlaveReadToArm,
         axiHpSlaveReset          => axiHpSlaveReset,
         axiHpSlaveWriteFromArm   => axiHpSlaveWriteFromArm,
         axiHpSlaveWriteToArm     => axiHpSlaveWriteToArm,
         axiHpSlaveReadFromArm    => axiHpSlaveReadFromArm,
         axiHpSlaveReadToArm      => axiHpSlaveReadToArm,
         ethFromArm               => ethFromArm,
         ethToArm                 => ethToArm
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

   armInt(15)                 <= '0';

   --------------------------------------------
   -- Clock Generation
   --------------------------------------------
   U_ArmRceG3Clocks: entity work.ArmRceG3Clocks
      port map (
         fclkClk3                 => fclkClk3,
         fclkClk2                 => fclkClk2,
         fclkClk1                 => fclkClk1,
         fclkClk0                 => fclkClk0,
         fclkRst3                 => fclkRst3,
         fclkRst2                 => fclkRst2,
         fclkRst1                 => fclkRst1,
         fclkRst0                 => fclkRst0,
         axiGpMasterReset         => axiGpMasterReset,
         axiGpSlaveReset          => axiGpSlaveReset,
         axiAcpSlaveReset         => axiAcpSlaveReset,
         axiHpSlaveReset          => axiHpSlaveReset,
         axiClk                   => iaxiClk,
         axiClkRst                => iaxiClkRst,
         sysClk125                => isysClk125,
         sysClk125Rst             => isysClk125Rst,
         sysClk200                => isysClk200,
         sysClk200Rst             => isysClk200Rst
      );

   -- Output clocks
   axiClk       <= iaxiClk;
   axiClkRst    <= iaxiClkRst;
   sysClk125    <= isysClk125;
   sysClk125Rst <= isysClk125Rst;
   sysClk200    <= isysClk200;
   sysClk200Rst <= isysClk200Rst;

   --------------------------------------------
   -- Local Bus Controller
   --------------------------------------------
   
   -- GP1: 8000_0000 to BFFF_FFFF
   U_ArmRceG3LocalBus: entity work.ArmRceG3LocalBus 
      port map (
         axiClk                  => iaxiClk,
         axiClkRst               => iaxiClkRst,
         axiMasterReadFromArm    => axiGpMasterReadFromArm(1),
         axiMasterReadToArm      => axiGpMasterReadToArm(1),
         axiMasterWriteFromArm   => axiGpMasterWriteFromArm(1),
         axiMasterWriteToArm     => axiGpMasterWriteToArm(1),
         localBusMaster          => intLocalBusMaster,
         localBusSlave           => intLocalBusSlave
      );

   -- External Local Bus
   localBusMaster                 <= intLocalBusMaster(15 downto 15);
   intLocalBusSlave(15 downto 15) <= localBusSlave;

   -- Unused
   intLocalBusSlave(14 downto 3) <= (others=>LocalBusSlaveInit);

   --------------------------------------------
   -- Local Registers
   --------------------------------------------

   process ( iaxiClk, iaxiClkRst ) begin
      if iaxiClkRst = '1' then
         scratchPad          <= (others=>'0')     after TPD_G;
         intLocalBusSlave(0) <= LocalBusSlaveInit after TPD_G;
      elsif rising_edge(iaxiClk) then

         -- 0x80000000
         if intLocalBusMaster(0).addr(25 downto 2) = x"000000" then
            intLocalBusSlave(0).readData  <= FpgaVersion                  after TPD_G;
            intLocalBusSlave(0).readValid <= intLocalBusMaster(0).readEnable after TPD_G;

         -- 0x80000004
         elsif intLocalBusMaster(0).addr(25 downto 2) = x"000001" then
            if intLocalBusMaster(0).writeEnable = '1' then
               scratchPad <= intLocalBusMaster(0).writeData after TPD_G;   
            end if;
            intLocalBusSlave(0).readData  <= scratchPad                   after TPD_G;
            intLocalBusSlave(0).readValid <= intLocalBusMaster(0).readEnable after TPD_G;

         -- Unsupported
         else
            intLocalBusSlave(0).readData  <= x"deadbeef"                  after TPD_G;
            intLocalBusSlave(0).readValid <= intLocalBusMaster(0).readEnable after TPD_G;
         end if;
      end if;  
   end process;         

   -- LED Debug
   led(0) <= scratchPad(0);
   led(1) <= scratchPad(1);

   --------------------------------------------
   -- I2C Controller
   --------------------------------------------

   -- 0x8400_0000 - 0x87FF_FFFF
   U_ArmRceG3I2c : entity work.ArmRceG3I2c
      port map (
         ponRst            => axiGpMasterReset(1),
         axiClk            => iaxiClk,
         axiClkRst         => iaxiClkRst,
         localBusMaster    => intLocalBusMaster(1),
         localBusSlave     => intLocalBusSlave(1),
         writefifoclk      => writefifoclk(4),
         writefifotofifo   => writefifotofifo(4),
         writefifofromfifo => writefifofromfifo(4),
         i2cSda            => i2cSda,
         i2cScl            => i2cScl
      );

   --------------------------------------------
   -- FIFO Test Interface
   --------------------------------------------

   -- 0x8800_0000 - 0x8BFF_FFFF
   U_ArmRceG3IbCntrl: entity work.ArmRceG3IbCntrl 
      port map (
         axiClk                  => iaxiClk,
         axiClkRst               => iaxiClkRst,
         axiAcpSlaveWriteFromArm => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm   => axiAcpSlaveWriteToArm,
         interrupt               => armInt(14 downto 0),
         localBusMaster          => intLocalBusMaster(2),
         localBusSlave           => intLocalBusSlave(2),
         writefifoclk            => writefifoclk,
         writefifotofifo         => writefifotofifo,
         writefifofromfifo       => writefifofromfifo,
         debug                   => fifoDebug
      );

      -- Unused FIFOs
      writeFifoClk(3  downto  0)   <= (others=>'0');
      writeFifoClk(16 downto  5)   <= (others=>'0');
      writeFifoToFifo(3  downto 0) <= (others=>WriteFifoToFifoInit);
      writeFifoToFifo(16 downto 5) <= (others=>WriteFifoToFifoInit);

   --------------------------------------------
   -- Debug
   --------------------------------------------

   U_Debug : if DebugEn = true generate

      U_icon: zynq_icon
         port map ( 
            CONTROL0 => control0
         );

      U_ila: zynq_ila
         port map (
            CONTROL => control0,
            CLK     => iaxiClk,
            TRIG0   => trig0
         );

      trig0 <= fifoDebug;
   end generate;

end architecture structure;

