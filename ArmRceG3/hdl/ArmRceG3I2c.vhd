-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, I2C Slave
-- File          : ArmRceG3I2c.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/29/2013
-------------------------------------------------------------------------------
-- Description:
-- I2C Slave block for IPMI operations:
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
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock and reset
      axiClk         : in  sl;
      axiClkRst      : in  sl;

      -- Local bus interface
      localBusMaster : in  LocalBusMasterType;
      localBusSlave  : out LocalBusSlaveType;

      -- FIFO Interface
      bsiToFifo      : out QWordToFifoType;
      bsiFromFifo    : in  QWordFromFifoType;

      -- IIC Interface
      i2cSda         : inout sl;
      i2cScl         : inout sl
   );
end ArmRceG3I2c;

architecture IMP of ArmRceG3I2c is

   signal i2cBramRd   : sl;
   signal i2cBramWr   : sl;
   signal i2cBramAddr : slv(15 downto 0);
   signal i2cBramDout : slv( 7 downto 0);
   signal locBramDout : slv( 7 downto 0);
   signal i2cBramDin  : slv( 7 downto 0);
   signal cpuBramWr   : sl;
   signal cpuBramAddr : slv(8  downto 0);
   signal cpuBramDout : slv(31 downto 0);
   signal cpuBramDin  : slv(31 downto 0);
   signal i2cIn       : i2c_in_type;
   signal i2cOut      : i2c_out_type;
   signal readEnDly   : slv(1 downto 0);
   signal aFullData   : slv(7 downto 0);

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
         aRst   => axiClkRst,
         clk    => axiClk,
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

   -------------------------
   -- Dual port ram
   -------------------------
   bram_0 : RAMB16_S9_S36  
      port map ( 
         DOB   => cpuBramDout,
         DOPB  => open,
         ADDRB => cpuBramAddr,
         CLKB  => axiClk,
         DIB   => cpuBramDin,
         DIPB  => x"0",
         ENB   => '1',
         SSRB  => '0',
         WEB   => cpuBramWr,
         DOA   => locBramDout,
         DOPA  => open,
         ADDRA => i2cBramAddr(10 downto 0),
         CLKA  => axiClk,
         DIA   => i2cBramDin,
         DIPA  => "0",
         ENA   => '1',
         SSRA  => '0',
         WEA   => i2cBramWr
      );

   -- Mux high order address, output almost full state at address 2048 (0x0800)
   i2cBramDout <= aFullData when i2cBramAddr(11) = '1' else locBramDout;

   -- Register almost full data
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         aFullData <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         aFullData(0) <= bsiFromFifo.almostFull after TPD_G;
      end if;
   end process;

   -------------------------
   -- Connect to CPU FIFO
   -------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         bsiToFifo <= QWordToFifoInit after TPD_G;
      elsif rising_edge(axiClk) then

         if i2cBramWr = '1' then
            if i2cBramAddr(1 downto 0) = 0 then
               bsiToFifo.data(7  downto  0) <= i2cBramDin after TPD_G;
               bsiToFifo.valid              <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 1 then
               bsiToFifo.data(15 downto 8)  <= i2cBramDin after TPD_G;
               bsiToFifo.valid              <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 2 then
               bsiToFifo.data(23 downto 16) <= i2cBramDin after TPD_G;
               bsiToFifo.valid              <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 3 then
               bsiToFifo.data(47 downto 32) <= i2cBramAddr after TPD_G;
               bsiToFifo.data(31 downto 24) <= i2cBramDin  after TPD_G;
               bsiToFifo.valid              <= '1'         after TPD_G;
            end if;
         else
            bsiToFifo.valid <= '0' after TPD_G;
         end if;
      end if;
   end process;

   -------------------------
   -- CPU Interface
   -------------------------
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         cpuBramWr   <= '0'           after TPD_G;
         cpuBramAddr <= (others=>'0') after TPD_G;
         cpuBramDin  <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         cpuBramWr   <= localBusMaster.writeEnable       after TPD_G;
         cpuBramAddr <= localBusMaster.addr(10 downto 2) after TPD_G;
         cpuBramDin  <= localBusMaster.writeData         after TPD_G;
      end if;
   end process;

   -- Clock delay for read data valid
   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         localBusSlave.readValid <= '0'           after TPD_G;
         localBusSlave.readData  <= (others=>'0') after TPD_G;
         readEnDly               <= (others=>'0') after TPD_G;
      elsif rising_edge(axiClk) then
         localBusSlave.readData  <= cpuBramDout               after TPD_G;
         readEnDly(1)            <= localBusMaster.readEnable after TPD_G;
         readEnDly(0)            <= readEnDly(1)              after TPD_G;
         localBusSlave.readValid <= readEnDly(0)              after TPD_G;
      end if;
   end process;

end architecture IMP;

