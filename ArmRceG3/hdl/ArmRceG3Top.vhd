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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.Version.all;
use work.ArmRceG3Version.all;

entity ArmRceG3Top is
   generic (
      TPD_G        : time    := 1 ns;
      AXI_CLKDIV_G : real    := 4.7
   );
   port (

      -- I2C
      i2cSda                   : inout sl;
      i2cScl                   : inout sl;

      -- Clocks
      axiClk                   : out   sl;
      axiClkRst                : out   sl;
      sysClk125                : out   sl;
      sysClk125Rst             : out   sl;
      sysClk200                : out   sl;
      sysClk200Rst             : out   sl;

      -- External Local Bus
      localBusMaster           : out   LocalBusMasterVector(15 downto 8);
      localBusSlave            : in    LocalBusSlaveVector(15 downto 8);

      -- PPI Outbound FIFO Interface
      obPpiClk                : in     slv(3 downto 0);
      obPpiToFifo             : in     ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo           : out    ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                : in     slv(3 downto 0);
      ibPpiToFifo             : in     IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo           : out    IbPpiFromFifoVector(3 downto 0);

      -- Ethernet
      ethFromArm              : out    EthFromArmVector(1 downto 0);
      ethToArm                : in     EthToArmVector(1 downto 0);

      -- Programmable Clock Select
      clkSelA                 : out   slv(1 downto 0);
      clkSelB                 : out   slv(1 downto 0)
   );
end ArmRceG3Top;

architecture structure of ArmRceG3Top is

   -- Local signals
   signal fclkClk3                 : sl;
   signal fclkClk2                 : sl;
   signal fclkClk1                 : sl;
   signal fclkClk0                 : sl;
   signal fclkRst3                 : sl;
   signal fclkRst2                 : sl;
   signal fclkRst1                 : sl;
   signal fclkRst0                 : sl;
   signal axiGpMasterReset         : slv(1 downto 0);
   signal axiGpMasterWriteFromArm  : AxiWriteMasterVector(1 downto 0);
   signal axiGpMasterWriteToArm    : AxiWriteSlaveVector(1 downto 0);
   signal axiGpMasterReadFromArm   : AxiReadMasterVector(1 downto 0);
   signal axiGpMasterReadToArm     : AxiReadSlaveVector(1 downto 0);
   signal axiGpSlaveReset          : slv(1 downto 0);
   signal axiGpSlaveWriteFromArm   : AxiWriteSlaveVector(1 downto 0);
   signal axiGpSlaveWriteToArm     : AxiWriteMasterVector(1 downto 0);
   signal axiGpSlaveReadFromArm    : AxiReadSlaveVector(1 downto 0);
   signal axiGpSlaveReadToArm      : AxiReadMasterVector(1 downto 0);
   signal axiAcpSlaveReset         : sl;
   signal axiAcpSlaveWriteFromArm  : AxiWriteSlaveType;
   signal axiAcpSlaveWriteToArm    : AxiWriteMasterType;
   signal axiAcpSlaveReadFromArm   : AxiReadSlaveType;
   signal axiAcpSlaveReadToArm     : AxiReadMasterType;
   signal axiHpSlaveReset          : slv(3 downto 0);
   signal axiHpSlaveWriteFromArm   : AxiWriteSlaveVector(3 downto 0);
   signal axiHpSlaveWriteToArm     : AxiWriteMasterVector(3 downto 0);
   signal axiHpSlaveReadFromArm    : AxiReadSlaveVector(3 downto 0);
   signal axiHpSlaveReadToArm      : AxiReadMasterVector(3 downto 0);
   signal armInt                   : slv(15 downto 0);
   signal intLocalBusMaster        : LocalBusMasterVector(15 downto 0);
   signal intLocalBusSlave         : LocalBusSlaveVector(15 downto 0);
   signal scratchPad               : slv(31 downto 0);
   signal iaxiClk                  : sl;
   signal iaxiClkRst               : sl;
   signal isysClk125               : sl;
   signal isysClk125Rst            : sl;
   signal isysClk200               : sl;
   signal isysClk200Rst            : sl;
   signal bsiToFifo                : QWordToFifoType;
   signal bsiFromFifo              : QWordFromFifoType;
   signal iclkSelA                 : slv(1 downto 0);
   signal iclkSelB                 : slv(1 downto 0);

   -- Mark For Debug
   --attribute mark_debug                             : string;
   --attribute mark_debug of axiGpMasterReset         : signal is "true";
   --attribute mark_debug of axiGpMasterWriteFromArm  : signal is "true";
   --attribute mark_debug of axiGpMasterWriteToArm    : signal is "true";
   --attribute mark_debug of axiGpMasterReadFromArm   : signal is "true";
   --attribute mark_debug of axiGpMasterReadToArm     : signal is "true";
   --attribute mark_debug of axiAcpSlaveReset         : signal is "true";
   --attribute mark_debug of axiAcpSlaveWriteFromArm  : signal is "true";
   --attribute mark_debug of axiAcpSlaveWriteToArm    : signal is "true";
   --attribute mark_debug of axiAcpSlaveReadFromArm   : signal is "true";
   --attribute mark_debug of axiAcpSlaveReadToArm     : signal is "true";
   --attribute mark_debug of axiHpSlaveReset          : signal is "true";
   --attribute mark_debug of axiHpSlaveWriteFromArm   : signal is "true";
   --attribute mark_debug of axiHpSlaveWriteToArm     : signal is "true";
   --attribute mark_debug of axiHpSlaveReadFromArm    : signal is "true";
   --attribute mark_debug of axiHpSlaveReadToArm      : signal is "true";
   --attribute mark_debug of armInt                   : signal is "true";
   --attribute mark_debug of intLocalBusMaster        : signal is "true";
   --attribute mark_debug of intLocalBusSlave         : signal is "true";
   --attribute mark_debug of scratchPad               : signal is "true";
   --attribute mark_debug of bsiToFifo                : signal is "true";
   --attribute mark_debug of bsiFromFifo              : signal is "true";
   --attribute mark_debug of iclkSelA                 : signal is "true";
   --attribute mark_debug of iclkSelB                 : signal is "true";

begin

   --------------------------------------------
   -- Processor Core
   --------------------------------------------
   U_ArmRceG3Cpu : entity work.ArmRceG3Cpu 
      generic map (
         TPD_G => TPD_G
      ) port map (
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

   --------------------------------------------
   -- Clock Generation
   --------------------------------------------
   U_ArmRceG3Clocks: entity work.ArmRceG3Clocks
      generic map (
         TPD_G        => TPD_G,
         AXI_CLKDIV_G => AXI_CLKDIV_G
      ) port map (
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
      generic map (
         TPD_G => TPD_G
      ) port map (
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
   localBusMaster                 <= intLocalBusMaster(15 downto 8);
   intLocalBusSlave(15 downto 8)  <= localBusSlave;

   -- Unused
   intLocalBusSlave(7  downto 3) <= (others=>LocalBusSlaveInit);

   --------------------------------------------
   -- Local Registers
   --------------------------------------------

   process ( iaxiClk, iaxiClkRst ) 
      variable c : character;
   begin
      if iaxiClkRst = '1' then
         scratchPad          <= (others=>'0')     after TPD_G;
         intLocalBusSlave(0) <= LocalBusSlaveInit after TPD_G;
         iclkSelA            <= (others=>'0')     after TPD_G;
         iclkSelB            <= (others=>'0')     after TPD_G;
      elsif rising_edge(iaxiClk) then
         intLocalBusSlave(0).readValid <= intLocalBusMaster(0).readEnable after TPD_G;
         intLocalBusSlave(0).readData  <= x"deadbeef"                     after TPD_G;

         -- 0x80000000
         if intLocalBusMaster(0).addr(23 downto 0) = x"000000" then
            intLocalBusSlave(0).readData <= FPGA_VERSION_C after TPD_G;

         -- 0x80000004
         elsif intLocalBusMaster(0).addr(23 downto 2) = x"000004" then
            if intLocalBusMaster(0).writeEnable = '1' then
               scratchPad <= intLocalBusMaster(0).writeData after TPD_G;   
            end if;
            intLocalBusSlave(0).readData <= scratchPad after TPD_G;

         -- 0x80000008
         elsif intLocalBusMaster(0).addr(23 downto 0) = x"000008" then
            intLocalBusSlave(0).readData <= ArmRceG3Version after TPD_G;

         -- 0x80000010
         elsif intLocalBusMaster(0).addr(23 downto 0) = x"000010" then
            if intLocalBusMaster(0).writeEnable = '1' then
               iclkSelA(0) <= intLocalBusMaster(0).writeData(0) after TPD_G;   
               iclkSelB(0) <= intLocalBusMaster(0).writeData(1) after TPD_G;   
            end if;

            intLocalBusSlave(0).readData(0)           <= iclkSelA(0)   after TPD_G;
            intLocalBusSlave(0).readData(1)           <= iclkSelB(0)   after TPD_G;
            intLocalBusSlave(0).readData(31 downto 2) <= (others=>'0') after TPD_G;

         -- 0x80000014
         elsif intLocalBusMaster(0).addr(23 downto 0) = x"000014" then
            if intLocalBusMaster(0).writeEnable = '1' then
               iclkSelA(1) <= intLocalBusMaster(0).writeData(0) after TPD_G;   
               iclkSelB(1) <= intLocalBusMaster(0).writeData(1) after TPD_G;   
            end if;

            intLocalBusSlave(0).readData(0)           <= iclkSelA(1)   after TPD_G;
            intLocalBusSlave(0).readData(1)           <= iclkSelB(1)   after TPD_G;
            intLocalBusSlave(0).readData(31 downto 2) <= (others=>'0') after TPD_G;

         -- 0x80001000
         elsif intLocalBusMaster(0).addr(23 downto 8) = x"0010" then
            intLocalBusSlave(0).readData <= (others=>'0') after TPD_G;

            for x in 0 to 3 loop
               if (conv_integer(intLocalBusMaster(0).addr(7 downto 0))+x+1) <= BUILD_STAMP_C'length then
                  c := BUILD_STAMP_C(conv_integer(intLocalBusMaster(0).addr(7 downto 0))+x+1);
                  intLocalBusSlave(0).readData(x*8+7 downto x*8) <= conv_std_logic_vector(character'pos(c),8) after TPD_G;
               end if;
            end loop;
         end if;
      end if;  
   end process;

   clkSelA <= iclkSelA;
   clkSelB <= iclkSelB;

   --------------------------------------------
   -- I2C Controller
   --------------------------------------------

   -- 0x8400_0000 - 0x87FF_FFFF
   U_ArmRceG3I2c : entity work.ArmRceG3I2c
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk            => iaxiClk,
         axiClkRst         => iaxiClkRst,
         localBusMaster    => intLocalBusMaster(1),
         localBusSlave     => intLocalBusSlave(1),
         bsiToFifo         => bsiToFifo,
         bsiFromFifo       => bsiFromFifo,
         i2cSda            => i2cSda,
         i2cScl            => i2cScl
      );

   --------------------------------------------
   -- DMA Controller
   --------------------------------------------

   -- 0x8800_0000 - 0x8BFF_FFFF
   U_ArmRceG3DmaCntrl : entity work.ArmRceG3DmaCntrl 
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk                   => iaxiClk,
         axiClkRst                => iaxiClkRst,
         axiAcpSlaveWriteFromArm  => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm    => axiAcpSlaveWriteToArm,
         axiAcpSlaveReadFromArm   => axiAcpSlaveReadFromArm,
         axiAcpSlaveReadToArm     => axiAcpSlaveReadToArm,
         axiHpSlaveWriteFromArm   => axiHpSlaveWriteFromArm,
         axiHpSlaveWriteToArm     => axiHpSlaveWriteToArm,
         axiHpSlaveReadFromArm    => axiHpSlaveReadFromArm,
         axiHpSlaveReadToArm      => axiHpSlaveReadToArm,
         interrupt                => armInt,
         localBusMaster           => intLocalBusMaster(2),
         localBusSlave            => intLocalBusSlave(2),
         obPpiClk                 => obPpiClk,
         obPpiToFifo              => obPpiToFifo,
         obPpiFromFifo            => obPpiFromFifo,
         ibPpiClk                 => ibPpiClk,
         ibPpiToFifo              => ibPpiToFifo,
         ibPpiFromFifo            => ibPpiFromFifo,
         bsiToFifo                => bsiToFifo,
         bsiFromFifo              => bsiFromFifo
      );

end architecture structure;

