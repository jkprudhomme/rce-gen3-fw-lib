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
use work.AxiLitePkg.all;

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

      -- External Axi Bus, 0xA0000000 - 0xBFFFFFFF
      localAxiReadMaster       : out   AxiLiteReadMasterType;
      localAxiReadSlave        : in    AxiLiteReadSlaveType;
      localAxiWriteMaster      : out   AxiLiteWriteMasterType;
      localAxiWriteSlave       : in    AxiLiteWriteSlaveType;

      -- PPI Outbound FIFO Interface
      obPpiClk                 : in    slv(3 downto 0);
      obPpiToFifo              : in    ObPpiToFifoVector(3 downto 0);
      obPpiFromFifo            : out   ObPpiFromFifoVector(3 downto 0);

      -- PPI Inbound FIFO Interface
      ibPpiClk                 : in    slv(3 downto 0);
      ibPpiToFifo              : in    IbPpiToFifoVector(3 downto 0);
      ibPpiFromFifo            : out   IbPpiFromFifoVector(3 downto 0);

      -- Ethernet
      ethFromArm               : out   EthFromArmVector(1 downto 0);
      ethToArm                 : in    EthToArmVector(1 downto 0);

      -- Programmable Clock Select
      clkSelA                  : out   slv(1 downto 0);
      clkSelB                  : out   slv(1 downto 0)
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
   signal axiGpMasterWriteFromArm  : AxiWriteMasterVector(1 downto 0);
   signal axiGpMasterWriteToArm    : AxiWriteSlaveVector(1 downto 0);
   signal axiGpMasterReadFromArm   : AxiReadMasterVector(1 downto 0);
   signal axiGpMasterReadToArm     : AxiReadSlaveVector(1 downto 0);
   signal axiGpSlaveWriteFromArm   : AxiWriteSlaveVector(1 downto 0);
   signal axiGpSlaveWriteToArm     : AxiWriteMasterVector(1 downto 0);
   signal axiGpSlaveReadFromArm    : AxiReadSlaveVector(1 downto 0);
   signal axiGpSlaveReadToArm      : AxiReadMasterVector(1 downto 0);
   signal axiAcpSlaveWriteFromArm  : AxiWriteSlaveType;
   signal axiAcpSlaveWriteToArm    : AxiWriteMasterType;
   signal axiAcpSlaveReadFromArm   : AxiReadSlaveType;
   signal axiAcpSlaveReadToArm     : AxiReadMasterType;
   signal axiHpSlaveWriteFromArm   : AxiWriteSlaveVector(3 downto 0);
   signal axiHpSlaveWriteToArm     : AxiWriteMasterVector(3 downto 0);
   signal axiHpSlaveReadFromArm    : AxiReadSlaveVector(3 downto 0);
   signal axiHpSlaveReadToArm      : AxiReadMasterVector(3 downto 0);
   signal armInt                   : slv(15 downto 0);
   signal iaxiClk                  : sl;
   signal iaxiClkRst               : sl;
   signal isysClk125               : sl;
   signal isysClk125Rst            : sl;
   signal isysClk200               : sl;
   signal isysClk200Rst            : sl;
   signal bsiToFifo                : QWordToFifoType;
   signal bsiFromFifo              : QWordFromFifoType;
   signal intAxiReadMaster         : AxiLiteReadMasterArray(4 downto 0);
   signal intAxiReadSlave          : AxiLiteReadSlaveArray(4 downto 0);
   signal intAxiWriteMaster        : AxiLiteWriteMasterArray(4 downto 0);
   signal intAxiWriteSlave         : AxiLiteWriteSlaveArray(4 downto 0);

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
         axiGpMasterWriteFromArm  => axiGpMasterWriteFromArm,
         axiGpMasterWriteToArm    => axiGpMasterWriteToArm,
         axiGpMasterReadFromArm   => axiGpMasterReadFromArm,
         axiGpMasterReadToArm     => axiGpMasterReadToArm,
         axiGpSlaveWriteFromArm   => axiGpSlaveWriteFromArm,
         axiGpSlaveWriteToArm     => axiGpSlaveWriteToArm,
         axiGpSlaveReadFromArm    => axiGpSlaveReadFromArm,
         axiGpSlaveReadToArm      => axiGpSlaveReadToArm,
         axiAcpSlaveWriteFromArm  => axiAcpSlaveWriteFromArm,
         axiAcpSlaveWriteToArm    => axiAcpSlaveWriteToArm,
         axiAcpSlaveReadFromArm   => axiAcpSlaveReadFromArm,
         axiAcpSlaveReadToArm     => axiAcpSlaveReadToArm,
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
   -- Local AXI Bus
   --------------------------------------------
   
   -- GP1: 8000_0000 to BFFF_FFFF
   U_ArmRceG3LocalAxi: entity work.ArmRceG3LocalAxi 
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk                  => iaxiClk,
         axiClkRst               => iaxiClkRst,
         axiGpMasterReadFromArm  => axiGpMasterReadFromArm(1),
         axiGpMasterReadToArm    => axiGpMasterReadToArm(1),
         axiGpMasterWriteFromArm => axiGpMasterWriteFromArm(1),
         axiGpMasterWriteToArm   => axiGpMasterWriteToArm(1),
         localAxiReadMaster      => intAxiReadMaster,
         localAxiReadSlave       => intAxiReadSlave,
         localAxiWriteMaster     => intAxiWriteMaster,
         localAxiWriteSlave      => intAxiWriteSlave,
         clkSelA                 => clkSelA,
         clkSelB                 => clkSelB
      );

   -- External Axi Bus, 0xA0000000 - 0xBFFFFFFF
   localAxiReadMaster  <= intAxiReadMaster(4);
   intAxiReadSlave(4)  <= localAxiReadSlave;
   localAxiWriteMaster <= intAxiWriteMaster(4);
   intAxiWriteSlave(4) <= localAxiWriteSlave;


   --------------------------------------------
   -- I2C Controller -- 0x84000000 - 0x84000FFF
   --------------------------------------------
   U_ArmRceG3I2c : entity work.ArmRceG3I2c
      generic map (
         TPD_G => TPD_G
      ) port map (
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         localAxiReadMaster  => intAxiReadMaster(0),
         localAxiReadSlave   => intAxiReadSlave(0),
         localAxiWriteMaster => intAxiWriteMaster(0),
         localAxiWriteSlave  => intAxiWriteSlave(0),
         bsiToFifo           => bsiToFifo,
         bsiFromFifo         => bsiFromFifo,
         i2cSda              => i2cSda,
         i2cScl              => i2cScl
      );

   --------------------------------------------
   -- DMA Controller
   -- 0x88000000 - 0x88000FFF : DMA Control Registers
   -- 0x88001000 - 0x880010FF : DMA Control Completion FIFOs
   -- 0x88001100 - 0x880011FF : DMA Control Free List FIFOs
   --------------------------------------------
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
         localAxiReadMaster       => intAxiReadMaster(3 downto 1),
         localAxiReadSlave        => intAxiReadSlave(3 downto 1),
         localAxiWriteMaster      => intAxiWriteMaster(3 downto 1),
         localAxiWriteSlave       => intAxiWriteSlave(3 downto 1),
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

