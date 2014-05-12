-------------------------------------------------------------------------------
-- Title         : Local AXI Bus Bridge and Registers
-- File          : RceG3LocalAxi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/06/2014
-------------------------------------------------------------------------------
-- Description:
-- Wrapper for AXI bus converter, crossbar and core registers
------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/06/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.Version.all;
use work.RceG3Version.all;

entity RceG3LocalAxi is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks & Reset
      axiClk              : in     sl;
      axiRst              : in     sl;
      axiDmaClk           : in     sl;
      axiDmaRst           : in     sl;

      -- GP AXI Masters
      -- GP0 = 0x40000000 - 0x7FFFFFFF
      -- GP1 = 0x80000000 - 0xBFFFFFFF
      mGpReadMaster       : in     AxiReadMasterArray(1 downto 0);
      mGpReadSlave        : out    AxiReadSlaveArray(1 downto 0);
      mGpWriteMaster      : in     AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave       : out    AxiWriteSlaveArray(1 downto 0);

      -- DMA AXI Lite
      dmaAxilReadMaster   : out    AxiLiteReadMasterType;
      dmaAxilReadSlave    : in     AxiLiteReadSlaveType;
      dmaAxilWriteMaster  : out    AxiLiteWriteMasterType;
      dmaAxilWriteSlave   : in     AxiLiteWriteSlaveType;

      -- BSI AXI Lite
      bsiAxilReadMaster   : out    AxiLiteReadMasterArray(1 downto 0);
      bsiAxilReadSlave    : in     AxiLiteReadSlaveArray(1 downto 0);
      bsiAxilWriteMaster  : out    AxiLiteWriteMasterArray(1 downto 0);
      bsiAxilWriteSlave   : in     AxiLiteWriteSlaveArray(1 downto 0);

      -- External AXI Lite
      extAxilReadMaster   : out    AxiLiteReadMasterType;
      extAxilReadSlave    : in     AxiLiteReadSlaveType;
      extAxilWriteMaster  : out    AxiLiteWriteMasterType;
      extAxilWriteSlave   : in     AxiLiteWriteSlaveType;

      -- Clock Select Lines
      clkSelA             : out    slv(1 downto 0);
      clkSelB             : out    slv(1 downto 0)
   );
end RceG3LocalAxi;

architecture structure of RceG3LocalAxi is

   -- Local signals
   signal midReadMaster     : AxiLiteReadMasterType;
   signal midReadSlave      : AxiLiteReadSlaveType;
   signal midWriteMaster    : AxiLiteWriteMasterType;
   signal midWriteSlave     : AxiLiteWriteSlaveType;
   signal axiReadMaster     : AxiLiteReadMasterType;
   signal axiReadSlave      : AxiLiteReadSlaveType;
   signal axiWriteMaster    : AxiLiteWriteMasterType;
   signal axiWriteSlave     : AxiLiteWriteSlaveType;
   signal dnaValue          : slv(63 downto 0);
   signal dnaValid          : sl;

   type RegType is record
      scratchPad    : slv(31 downto 0);
      clkSelA       : slv(1 downto 0);
      clkSelB       : slv(1 downto 0);
      axiReadSlave  : AxiLiteReadSlaveType;
      axiWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      scratchPad    => (others => '0'),
      clkSelA       => (others => '0'),
      clkSelB       => (others => '1'),
      axiReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -- Mask is constant
   constant CROSSBAR_CONN_C : slv(15 downto 0) := x"FFFF";

   -- Channel 0 = 0x80000000 - 0x8000FFFF : Top level module registers
   constant TOP_SPACE_INDEX_C     : natural          := 5;
   constant TOP_SPACE_BASE_ADDR_C : slv(31 downto 0) := x"80000000";
   constant TOP_SPACE_NUM_BITS_C  : natural          := 16;

   -- Channel 1 = 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
   constant BSI0_I2C_INDEX_C      : natural          := 0;
   constant BSI0_I2C_BASE_ADDR_C  : slv(31 downto 0) := x"84000000";
   constant BSI0_I2C_NUM_BITS_C   : natural          := 12;

   -- Channel 2 = 0x88000000 - 0x88000FFF : BSI I2C Slave Registers
   constant BSI1_I2C_INDEX_C      : natural          := 0;
   constant BSI1_I2C_BASE_ADDR_C  : slv(31 downto 0) := x"88000000";
   constant BSI1_I2C_NUM_BITS_C   : natural          := 12;

   -- Channel 3 = 0xA0000000 - 0xBFFFFFFF : External Address Space
   constant EXT_SPACE_INDEX_C     : natural          := 4;
   constant EXT_SPACE_BASE_ADDR_C : slv(31 downto 0) := x"90000000";
   constant EXT_SPACE_NUM_BITS_C  : natural          := 29;

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(3 downto 0) := (
      TOP_SPACE_INDEX_C => (
         baseAddr     => TOP_SPACE_BASE_ADDR_C,
         addrBits     => TOP_SPACE_NUM_BITS_C,
         connectivity => CROSSBAR_CONN_C),
      BSI0_I2C_INDEX_C => (
         baseAddr     => BSI0_I2C_BASE_ADDR_C,
         addrBits     => BSI0_I2C_NUM_BITS_C,
         connectivity => CROSSBAR_CONN_C),
      BSI1_I2C_INDEX_C => (
         baseAddr     => BSI1_I2C_BASE_ADDR_C,
         addrBits     => BSI1_I2C_NUM_BITS_C,
         connectivity => CROSSBAR_CONN_C),
      EXT_SPACE_INDEX_C => (
         baseAddr     => EXT_SPACE_BASE_ADDR_C,
         addrBits     => EXT_SPACE_NUM_BITS_C,
         connectivity => CROSSBAR_CONN_C));

begin

   -------------------------------------
   -- GP0 AXI-4 to AXI Lite Conversion
   -------------------------------------
   U_Gp0AxiLite : entity work.AxiToAxiLite
      generic map (
         TPD_G  => TPD_G
      ) port map (
         axiClk              => axiDmaClk,
         axiClkRst           => axiDmaRst,
         axiReadMaster       => mGpReadMaster(0),
         axiReadSlave        => mGpReadSlave(0),
         axiWriteMaster      => mGpWriteMaster(0),
         axiWriteSlave       => mGpWriteSlave(0),
         axilReadMaster      => dmaAxilReadMaster,
         axilReadSlave       => dmaAxilReadSlave,
         axilWriteMaster     => dmaAxilWriteMaster,
         axilWriteSlave      => dmaAxilWriteSlave,
      );


   -------------------------------------
   -- GP1 AXI-4 to AXI Lite Conversion
   -------------------------------------
   U_Gp1AxiLite : entity work.AxiToAxiLite
      generic map (
         TPD_G  => TPD_G
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiRst,
         axiReadMaster       => mGpReadMaster(1),
         axiReadSlave        => mGpReadSlave(1),
         axiWriteMaster      => mGpWriteMaster(1),
         axiWriteSlave       => mGpWriteSlave(1),
         axilReadMaster      => midReadMaster,
         axilReadSlave       => midReadSlave,
         axilWriteMaster     => midWriteMaster,
         axilWriteSlave      => midWriteSlave,
      );


   -------------------------------------
   -- AXI Lite Crossbar
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_SLOTS_G        => 4,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C 
      ) port map (
         axiClk                       => axiClk,
         axiClkRst                    => axiRst,
         sAxiWriteMasters(0)          => midWriteMaster,
         sAxiWriteSlaves(0)           => midWriteSlave,
         sAxiReadMasters(0)           => midReadMaster,
         sAxiReadSlaves(0)            => midReadSlave,
         mAxiWriteMasters(0)          => axiWriteMaster,
         mAxiWriteSlaves(0)           => axiWriteSlave,
         mAxiReadMasters(0)           => axiReadMaster,
         mAxiReadSlaves(0)            => axiReadSlave,
         mAxiWriteMasters(2 downto 1) => bsiAxilWriteMaster,
         mAxiWriteSlaves(2 downto 1)  => bsiAxilWriteSlave,
         mAxiReadMasters(2 downto 1)  => bsiAxilReadMaster,
         mAxiReadSlaves(2 downto 1)   => bsiAxilReadSlave,
         mAxiWriteMasters(3)          => extAxilWriteMaster,
         mAxiWriteSlaves(3)           => extAxilWriteSlave,
         mAxiReadMasters(3)           => extAxilReadMaster,
         mAxiReadSlaves(3)            => extAxilReadSlave
      );


   -------------------------------------
   -- Local Registers
   -------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiRst, axiReadMaster, axiWriteMaster, dnaValid, dnaValue, r ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (axiWriteMaster.awaddr(15 downto 0)) is
            when X"0004" =>
               v.scratchPad := axiWriteMaster.wdata;
            when X"0010" =>
               v.clkSelA(0) := axiWriteMaster.wdata(0);
               v.clkSelB(0) := axiWriteMaster.wdata(1);
            when X"0014" =>
               v.clkSelA(1) := axiWriteMaster.wdata(0);
               v.clkSelB(1) := axiWriteMaster.wdata(1);
            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave );
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         if axiReadMaster.araddr(15 downto 12) = 0 then

            -- Decode address and assign read data
            case axiReadMaster.araddr(15 downto 0) is
               when X"0000" =>
                  v.axiReadSlave.rdata := FPGA_VERSION_C;
               when X"0004" =>
                  v.axiReadSlave.rdata := r.scratchPad;
               when X"0008" =>
                  v.axiReadSlave.rdata := RCE_G3_VERSION_C;
               when X"0010" =>
                  v.axiReadSlave.rdata(0) := r.clkSelA(0);
                  v.axiReadSlave.rdata(1) := r.clkSelB(0);
               when X"0014" =>
                  v.axiReadSlave.rdata(0) := r.clkSelA(1);
                  v.axiReadSlave.rdata(1) := r.clkSelB(1);
               when X"0020" =>
                  v.axiReadSlave.rdata(31)          := dnaValid;
                  v.axiReadSlave.rdata(24 downto 0) := dnaValue(56 downto 32);
               when X"0024" =>
                  v.axiReadSlave.rdata := dnaValue(31 downto 0);
               when others => null;
            end case;
         else
            for x in 0 to 3 loop
               if (conv_integer(axiReadMaster.araddr(7 downto 0))+x+1) <= BUILD_STAMP_C'length then
                  c := BUILD_STAMP_C(conv_integer(axiReadMaster.araddr(7 downto 0))+x+1);
                  v.axiReadSlave.rdata(x*8+7 downto x*8) := conv_std_logic_vector(character'pos(c),8);
               end if;
            end loop;
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
      end if;

      -- Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      clkSelA       <= r.clkSelA;
      clkSelB       <= r.clkSelB;
      
   end process;


   -------------------------------------
   -- Device DNA
   -------------------------------------
   U_DeviceDna : entity work.DeviceDna
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         SIM_DNA_VALUE_G => X"000000000000000"
      ) port map (
         clk      => axiClk,
         rst      => axiRst,
         dnaValue => dnaValue,
         dnaValid => dnaValid
      );

end architecture structure;
