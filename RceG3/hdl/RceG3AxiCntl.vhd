-------------------------------------------------------------------------------
-- Title         : Local AXI Bus Bridge and Registers
-- File          : RceG3AxiCntl.vhd
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

entity RceG3AxiCntl is
   generic (
      TPD_G            : time                   := 1 ns;
      DMA_AXIL_COUNT_G : integer range 1 to 256 := 4
   );
   port (

      -- GP AXI Masters, 0=axiDmaClk, 1=axiClk
      mGpReadMaster        : in     AxiReadMasterArray(1 downto 0);
      mGpReadSlave         : out    AxiReadSlaveArray(1 downto 0);
      mGpWriteMaster       : in     AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave        : out    AxiWriteSlaveArray(1 downto 0);

      -- Fast AXI Busses
      axiDmaClk            : in     sl;
      axiDmaRst            : in     sl;

      -- Interrupt Control AXI Lite Bus
      icAxilReadMaster     : out    AxiLiteReadMasterType;
      icAxilReadSlave      : in     AxiLiteReadSlaveType;
      icAxilWriteMaster    : out    AxiLiteWriteMasterType;
      icAxilWriteSlave     : in     AxiLiteWriteSlaveType;

      -- DMA AXI Lite Busses, dmaAxiClk
      dmaAxilReadMaster    : out    AxiLiteReadMasterArray(DMA_AXIL_COUNT_G-1 downto 0);
      dmaAxilReadSlave     : in     AxiLiteReadSlaveArray(DMA_AXIL_COUNT_G-1 downto 0);
      dmaAxilWriteMaster   : out    AxiLiteWriteMasterArray(DMA_AXIL_COUNT_G-1 downto 0);
      dmaAxilWriteSlave    : in     AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_G-1 downto 0);

      -- Slow AXI Busses
      axiClk               : in     sl;
      axiRst               : in     sl;

      -- BSI AXI Lite
      bsiAxilReadMaster    : out    AxiLiteReadMasterArray(1 downto 0);
      bsiAxilReadSlave     : in     AxiLiteReadSlaveArray(1 downto 0);
      bsiAxilWriteMaster   : out    AxiLiteWriteMasterArray(1 downto 0);
      bsiAxilWriteSlave    : in     AxiLiteWriteSlaveArray(1 downto 0);

      -- External AXI Lite (top level, outside DpmCore, DtmCore)
      extAxilReadMaster    : out    AxiLiteReadMasterType;
      extAxilReadSlave     : in     AxiLiteReadSlaveType;
      extAxilWriteMaster   : out    AxiLiteWriteMasterType;
      extAxilWriteSlave    : in     AxiLiteWriteSlaveType;

      -- Core AXI Lite (outside RCE, insidde DpmCore, DtmCore)
      coreAxilReadMaster   : out    AxiLiteReadMasterType;
      coreAxilReadSlave    : in     AxiLiteReadSlaveType;
      coreAxilWriteMaster  : out    AxiLiteWriteMasterType;
      coreAxilWriteSlave   : in     AxiLiteWriteSlaveType;

      -- Clock Select Lines
      clkSelA              : out    slv(1 downto 0);
      clkSelB              : out    slv(1 downto 0)
   );
end RceG3AxiCntl;

architecture structure of RceG3AxiCntl is

   constant GP0_MAST_CNT_C : integer := DMA_AXIL_COUNT_G + 1;
   constant GP1_MAST_CNT_C : integer := 5;

   -- Gp0 Signals
   signal midGp0ReadMaster     : AxiLiteReadMasterType;
   signal midGp0ReadSlave      : AxiLiteReadSlaveType;
   signal midGp0WriteMaster    : AxiLiteWriteMasterType;
   signal midGp0WriteSlave     : AxiLiteWriteSlaveType;
   signal tmpGp0ReadMasters    : AxiLiteReadMasterArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0ReadSlaves     : AxiLiteReadSlaveArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0WriteMasters   : AxiLiteWriteMasterArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0WriteSlaves    : AxiLiteWriteSlaveArray(GP0_MAST_CNT_C-1 downto 0);

   -- Gp1 Signals
   signal midGp1ReadMaster     : AxiLiteReadMasterType;
   signal midGp1ReadSlave      : AxiLiteReadSlaveType;
   signal midGp1WriteMaster    : AxiLiteWriteMasterType;
   signal midGp1WriteSlave     : AxiLiteWriteSlaveType;
   signal tmpGp1ReadMasters    : AxiLiteReadMasterArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1ReadSlaves     : AxiLiteReadSlaveArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1WriteMasters   : AxiLiteWriteMasterArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1WriteSlaves    : AxiLiteWriteSlaveArray(GP1_MAST_CNT_C-1 downto 0);

   -- Local signals
   signal intReadMaster     : AxiLiteReadMasterType;
   signal intReadSlave      : AxiLiteReadSlaveType;
   signal intWriteMaster    : AxiLiteWriteMasterType;
   signal intWriteSlave     : AxiLiteWriteSlaveType;
   signal dnaValue          : slv(63 downto 0);
   signal dnaValid          : sl;

   type RegType is record
      scratchPad    : slv(31 downto 0);
      clkSelA       : slv(1 downto 0);
      clkSelB       : slv(1 downto 0);
      intReadSlave  : AxiLiteReadSlaveType;
      intWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      scratchPad    => (others => '0'),
      clkSelA       => (others => '0'),
      clkSelB       => (others => '1'),
      intReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      intWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -- GP0 Address Map Generator
   function genGp0Config ( dmaCnt : positive ) return AxiLiteCrossbarMasterConfigArray is
      variable retConf : AxiLiteCrossbarMasterConfigArray(dmaCnt downto 0);
      variable addr    : slv(31 downto 0);
   begin

      -- Int control record is fixed
      retConf(0).baseAddr     := x"40000000";
      retConf(0).addrBits     := 16;
      retConf(0).connectivity := x"FFFF";

      -- Generate dma records
      addr := x"60000000";
      for i in 0 to dmaCnt-1 loop
         addr(23 downto 16)        := toSlv(i,8);
         retConf(i+1).baseAddr     := addr;
         retConf(i+1).addrBits     := 16;
         retConf(i+1).connectivity := x"FFFF";
      end loop;

      return retConf;
   end function;

   constant GP0_MASTERS_CONFIG_G : AxiLiteCrossbarMasterConfigArray := genGp0Config(DMA_AXIL_COUNT_G);

begin

   -------------------------------------
   -- GP0 AXI-4 to AXI Lite Conversion
   -- 0x40000000 - 0x7FFFFFFF, axiDmaClk
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
         axilReadMaster      => midGp0ReadMaster,
         axilReadSlave       => midGp0ReadSlave,
         axilWriteMaster     => midGp0WriteMaster,
         axilWriteSlave      => midGp0WriteSlave
      );

   -------------------------------------
   -- GP0 AXI Lite Crossbar
   -- 0x40000000 - 0x7FFFFFFF, axiDmaClk
   -------------------------------------
   U_Gp0Crossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => GP0_MAST_CNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => GP0_MASTERS_CONFIG_G
      ) port map (
         axiClk              => axiDmaClk,
         axiClkRst           => axiDmaRst,
         sAxiWriteMasters(0) => midGp0WriteMaster,
         sAxiWriteSlaves(0)  => midGp0WriteSlave,
         sAxiReadMasters(0)  => midGp0ReadMaster,
         sAxiReadSlaves(0)   => midGp0ReadSlave,
         mAxiWriteMasters    => tmpGp0WriteMasters,
         mAxiWriteSlaves     => tmpGp0WriteSlaves,
         mAxiReadMasters     => tmpGp0ReadMasters,
         mAxiReadSlaves      => tmpGp0ReadSlaves
      );

   icAxilWriteMaster    <= tmpGp0WriteMasters(0);
   tmpGp0WriteSlaves(0) <= icAxilWriteSlave;
   icAxilReadMaster     <= tmpGp0ReadMasters(0);
   tmpGp0ReadSlaves(0)  <= icAxilReadSlave;

   dmaAxilWriteMaster                           <= tmpGp0WriteMasters(DMA_AXIL_COUNT_G downto 1);
   tmpGp0WriteSlaves(DMA_AXIL_COUNT_G downto 1) <= dmaAxilWriteSlave;
   dmaAxilReadMaster                            <= tmpGp0ReadMasters(DMA_AXIL_COUNT_G downto 1);
   tmpGp0ReadSlaves(DMA_AXIL_COUNT_G downto 1)  <= dmaAxilReadSlave;


   -------------------------------------
   -- GP1 AXI-4 to AXI Lite Conversion
   -- 0x80000000 - 0xBFFFFFFF, axiClk
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
         axilReadMaster      => midGp1ReadMaster,
         axilReadSlave       => midGp1ReadSlave,
         axilWriteMaster     => midGp1WriteMaster,
         axilWriteSlave      => midGp1WriteSlave
      );


   -------------------------------------
   -- GP1 AXI Lite Crossbar
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_Gp1Crossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => GP1_MAST_CNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            -- 0x80000000 - 0x8000FFFF : Internal registers
            0 => (
              baseAddr     => x"80000000",
              addrBits     => 16,
              connectivity => x"FFFF"),

            -- 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
            1 => (
              baseAddr     => x"84000000",
              addrBits     => 12,
              connectivity => x"FFFF"),

            -- 0x88000000 - 0x88000FFF : BSI I2C Slave Registers
            2 => (
              baseAddr     => x"88000000",
              addrBits     => 12,
              connectivity => x"FFFF"),

            -- 0xA0000000 - 0xAFFFFFFF : External Register Space
            3 => (
              baseAddr     => x"A0000000",
              addrBits     => 28,
              connectivity => x"FFFF"),

            -- 0xB0000000 - 0xBFFFFFFF : Core Register Space
            4 => (
              baseAddr     => x"B0000000",
              addrBits     => 28,
              connectivity => x"FFFF"))
      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiRst,
         sAxiWriteMasters(0) => midGp1WriteMaster,
         sAxiWriteSlaves(0)  => midGp1WriteSlave,
         sAxiReadMasters(0)  => midGp1ReadMaster,
         sAxiReadSlaves(0)   => midGp1ReadSlave,
         mAxiWriteMasters    => tmpGp1WriteMasters,
         mAxiWriteSlaves     => tmpGp1WriteSlaves,
         mAxiReadMasters     => tmpGp1ReadMasters,
         mAxiReadSlaves      => tmpGp1ReadSlaves
      );

   intWriteMaster       <= tmpGp1WriteMasters(0);
   tmpGp1WriteSlaves(0) <= intWriteSlave;
   intReadMaster        <= tmpGp1ReadMasters(0);
   tmpGp1ReadSlaves(0)  <= intReadSlave;

   bsiAxilWriteMaster            <= tmpGp1WriteMasters(2 downto 1);
   tmpGp1WriteSlaves(2 downto 1) <= bsiAxilWriteSlave;
   bsiAxilReadMaster             <= tmpGp1ReadMasters(2 downto 1);
   tmpGp1ReadSlaves(2 downto 1)  <= bsiAxilReadSlave;

   extAxilWriteMaster    <= tmpGp1WriteMasters(3);
   tmpGp1WriteSlaves(3)  <= extAxilWriteSlave;
   extAxilReadMaster     <= tmpGp1ReadMasters(3);
   tmpGp1ReadSlaves(3)   <= extAxilReadSlave;

   coreAxilWriteMaster    <= tmpGp1WriteMasters(4);
   tmpGp1WriteSlaves(4)   <= coreAxilWriteSlave;
   coreAxilReadMaster     <= tmpGp1ReadMasters(4);
   tmpGp1ReadSlaves(4)    <= coreAxilReadSlave;


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
   process (axiRst, intReadMaster, intWriteMaster, dnaValid, dnaValue, r ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      axiSlaveWaitTxn(intWriteMaster, intReadMaster, v.intWriteSlave, v.intReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (intWriteMaster.awaddr(15 downto 0)) is
            when X"0004" =>
               v.scratchPad := intWriteMaster.wdata;
            when X"0010" =>
               v.clkSelA(0) := intWriteMaster.wdata(0);
               v.clkSelB(0) := intWriteMaster.wdata(1);
            when X"0014" =>
               v.clkSelA(1) := intWriteMaster.wdata(0);
               v.clkSelB(1) := intWriteMaster.wdata(1);
            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.intWriteSlave );
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.intReadSlave.rdata := (others => '0');

         if intReadMaster.araddr(15 downto 12) = 0 then

            -- Decode address and assign read data
            case intReadMaster.araddr(15 downto 0) is
               when X"0000" =>
                  v.intReadSlave.rdata := FPGA_VERSION_C;
               when X"0004" =>
                  v.intReadSlave.rdata := r.scratchPad;
               when X"0008" =>
                  v.intReadSlave.rdata := RCE_G3_VERSION_C;
               when X"0010" =>
                  v.intReadSlave.rdata(0) := r.clkSelA(0);
                  v.intReadSlave.rdata(1) := r.clkSelB(0);
               when X"0014" =>
                  v.intReadSlave.rdata(0) := r.clkSelA(1);
                  v.intReadSlave.rdata(1) := r.clkSelB(1);
               when X"0020" =>
                  v.intReadSlave.rdata(31)          := dnaValid;
                  v.intReadSlave.rdata(24 downto 0) := dnaValue(56 downto 32);
               when X"0024" =>
                  v.intReadSlave.rdata := dnaValue(31 downto 0);
               when others => null;
            end case;
         else
            for x in 0 to 3 loop
               if (conv_integer(intReadMaster.araddr(7 downto 0))+x+1) <= BUILD_STAMP_C'length then
                  c := BUILD_STAMP_C(conv_integer(intReadMaster.araddr(7 downto 0))+x+1);
                  v.intReadSlave.rdata(x*8+7 downto x*8) := conv_std_logic_vector(character'pos(c),8);
               end if;
            end loop;
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.intReadSlave);
      end if;

      -- Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      intReadSlave  <= r.intReadSlave;
      intWriteSlave <= r.intWriteSlave;
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
