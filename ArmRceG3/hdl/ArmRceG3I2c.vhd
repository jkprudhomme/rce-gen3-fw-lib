-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, I2C Slave
-- File          : ArmRceG3I2c.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/29/2013
-------------------------------------------------------------------------------
-- Description:
-- I2C Slave block for IPMI operations:
-- 
--   BRAM registers 0-511
--     register 0   : "RST" - reset, not used in Zynq
--     register 510 : "IOW" - interrupt on write address
--     register 511 : "RSP" - response register
--
--   I2C write to BRAM RST register initiates reset (Not used in Zynq)
--     Reset is asserted when I2C transaction is complete
--     Reset is held for 8 DCR clock cycles (8 is arbitrary)
--   I2C write to BRAM register 1-511 initiates interrupt
--     When I2C transaction is complete:
--       Register address (1B view) is recorded in BRAM IOW
--       BRAM RSP register is set
--       Interrupt is asserted
--     Interrupt is held until DCR access writes to BRAM RSP register
--
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/29/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.i2cPkg.all;
use work.StdRtlPkg.all;

entity ArmRceG3I2c is
   port (
      ponRst      : in  std_logic;

      -- Local bus interface
      localClk       : in  std_logic;
      localClkRst    : in  std_logic;
      localBusMaster : in  LocalBusMasterType;
      localBusSlave  : out LocalBusSlaveType;
      i2cIrq         : out std_logic;

      -- IIC Interface
      i2cSda      : inout std_logic;
      i2cScl      : inout std_logic
   );
end ArmRceG3I2c;

architecture IMP of ArmRceG3I2c is

   signal i2cBramRd   : std_logic;
   signal i2cBramWr   : std_logic;
   signal i2cBramAddr : std_logic_vector(15 downto 0);
   signal i2cBramDout : std_logic_vector( 7 downto 0);
   signal i2cBramDin  : std_logic_vector( 7 downto 0);
   signal cpuBramWr   : std_logic;
   signal cpuBramAddr : std_logic_vector(8  downto 0);
   signal cpuBramDout : std_logic_vector(31 downto 0);
   signal cpuBramDin  : std_logic_vector(31 downto 0);
   signal i2cIn       : i2c_in_type;
   signal i2cOut      : i2c_out_type;

   type StateType is (WAIT_WR_S, WR_DATA_S, WR_ADDR_L, WR_ADDR_H, WR_FF_S);
   type SysRegType is record
      startup   : sl;
      interrupt : slv(3 downto 0);
      cpuReset  : slv(7 downto 0);
      state     : StateType;
      addr      : slv(15 downto 0);
      wrEn      : sl;
      wrData    : slv(7 downto 0);
   end record SysRegType;

   signal sysR, sysRin : SysRegType;
 
   type ApuRegType is record
      interrupt : slv(1 downto 0);
      empty     : sl;
   end record ApuRegType;

   signal apuR, apuRin : ApuRegType;
   
   constant TPD_G : time := 1 ns;
 
begin

   -------------------------
   -- I2c Slave
   -------------------------
   U_i2cb: entity work.i2cRegSlave 
      generic map (
         TPD_G                => TPD_G,
         TENBIT_G             => 0,
         I2C_ADDR_G           => 73, -- "1001001";
         OUTPUT_EN_POLARITY_G => 0,
         FILTER_G             => 4,
         ADDR_SIZE_G          => 2, -- in bytes
         DATA_SIZE_G          => 1, -- in bytes
         ENDIANNESS_G         => 0  -- 0=LE, 1=BE
      ) port map (
         sRst   => '0',
         aRst   => ponRst,
         clk    => localClk,
         addr   => i2cBramAddr,
         wrEn   => i2cBramWr,
         wrData => i2cBramDin,
         rdEn   => i2cBramRd,
         rdData => i2cBramDout,
         i2ci   => i2cIn,
         i2co   => i2cOut
      );

   U_I2cScl : IOBUF port map ( IO => i2cScl,
                               I  => i2cOut.scl,
                               O  => i2cIn.scl,
                               T  => i2cOut.scloen);

   U_I2cSda : IOBUF port map ( IO => i2cSda,
                               I  => i2cOut.sda,
                               O  => i2cIn.sda,
                               T  => i2cOut.sdaoen);

   --------------------------------------------------------------------------------------------------
   -- iicSysClk Logic - Glue between i2cRegSlave and block RAM.
   -- Assert cpuReset upon startup and hold until address 0x8000 is written to over i2c.
   -- A write to 0x8000 causes cpuReset to be held high for 8 cycles and then dropped.
   -- A write over i2c to 0b1xxxxxxxxxxxxxxx (where x != 0) causes an interrupt.
   -- sysR.interrupt is held for 4 cycles so that it can be picked up an synchronized to the apuClk.
   --
   -- On an i2c write, in addition to the data be written at the specified address, the lower byte
   -- of the address is written to address 0x07F8 and 0xFF is written to address 0x7FC.
   --------------------------------------------------------------------------------------------------
   iicSysClkComb : process (sysR, i2cBramDin, i2cBramWr, i2cBramAddr) is
      variable v : SysRegType;
   begin
      v := sysR;

      -- Interrupt and cpuReset
      v.interrupt := '0' & sysR.interrupt(3 downto 1);
      v.cpuReset  := sysR.startup & sysR.cpuReset(7 downto 1);
      if (i2cBramWr = '1' and i2cBramAddr(15) = '1') then
         if (i2cBramAddr(14 downto 0) = "000000000000000") then
            v.cpuReset := (others => '1');
            v.startup  := '0';
         else
            v.interrupt := (others => '1');
         end if;
      end if;
  
      -- Control writes to bram
      v.wrData := i2cBramDin;
      v.wrEn   := '0';
      v.addr   := i2cBramAddr;
      case sysR.state is
         when WAIT_WR_S =>
            -- Upon I2C Write, first put wrData into bram at i2cBramAddr
            if (i2cBramWr = '1') then
               v.wrData := i2cBramDin;
               v.wrEn   := '1';
               v.addr   := i2cBramAddr;
               v.state  := WR_ADDR_L;
            end if;
         when WR_ADDR_L =>
            -- Then write lower byte of address into bram at 0x07F8
            v.wrData := i2cBramAddr(7 downto 0);
            v.wrEn   := '1';
            v.addr   := X"07F8";
            v.state  := WR_ADDR_H;
         when WR_ADDR_H =>
            -- Then write upper byte of address into bram at 0x07F9
            v.wrData := i2cBramAddr(15 downto 8);
            v.wrEn   := '1';
            v.addr   := X"07F9";
            v.state  := WR_FF_S;
         when WR_FF_S =>
            -- Then write 0xFF to bram at 0x07FC
            v.wrData := X"FF";
            v.wrEn   := '1';
            v.addr   := X"07FC";
            v.state  := WAIT_WR_S;
         when others => null;
      end case;

      sysRin <= v;

   end process iicSysClkComb;

   iicSysClkSeq : process (localClk, localClkRst) is
   begin
      if (localClkRst = '1') then
         sysR.startup   <= '1'             after TPD_G;
         sysR.interrupt <= (others => '0') after TPD_G;
         sysR.cpuReset  <= (others => '1') after TPD_G;
         sysR.wrEn      <= '0'             after TPD_G;
      -- Other bram signals don't need reset
      elsif (rising_edge(localClk)) then
         sysR <= sysRin after TPD_G;
      end if;
   end process;

   -------------------------
   -- Dual port ram
   -------------------------
   bram_0 : RAMB16_S9_S36  
      port map ( 
         DOB   => cpuBramDout,
         DOPB  => open,
         ADDRB => cpuBramAddr,
         CLKB  => localClk,
         DIB   => cpuBramDin,
         DIPB  => x"0",
         ENB   => '1',
         SSRB  => '0',
         WEB   => cpuBramWr,
         DOA   => i2cBramDout,
         DOPA  => open,
         ADDRA => sysR.addr(10 downto 0),
         CLKA  => localClk,
         DIA   => sysR.wrData,
         DIPA  => "0",
         ENA   => '1',
         SSRA  => '0',
         WEA   => sysR.wrEn 
      );

   -------------------------
   -- CPU Interface
   -------------------------
   cpuBramWr              <= localBusMaster.writeEnable;
   cpuBramAddr            <= localBusMaster.addr(10 downto 2);
   cpuBramDin             <= localBusMaster.writeData;
   localBusSlave.readData <= cpuBramDout;
   i2cIrq                 <= sysR.interrupt(0);

   -- One clock delay for read data valid
   process ( localCLk, localClkRst ) begin
      if localClkRst = '1' then
         localBusSlave.readValid <= '0' after TPD_G;
      elsif rising_edge(localClk) then
         localBusSlave.readValid <= localBusMaster.readEnable after TPD_G;
      end if;
   end process;

end;

