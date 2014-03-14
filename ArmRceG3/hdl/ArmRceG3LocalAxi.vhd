-------------------------------------------------------------------------------
-- Title         : AXI Bus To Local Bus Bridge
-- File          : ArmRceG3LocalAxi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/06/2014
-------------------------------------------------------------------------------
-- Description:
-- Wrapper for AXI bus converter and crossbar.
-- Channel 0 = 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
-- Channel 1 = 0x88000000 - 0x88000FFF : DMA Control Registers
-- Channel 2 = 0x88001000 - 0x880010FF : DMA Control Completion FIFOs
-- Channel 3 = 0x88001100 - 0x880011FF : DMA Control Free List FIFOs
-- Channel 4 = 0xA0000000 - 0xBFFFFFFF : External Address Space
-- Channel 5 = 0x80000000 - 0x8000FFFF : Top level module registers
-------------------------------------------------------------------------------
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

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.Version.all;
use work.ArmRceG3Version.all;

entity ArmRceG3LocalAxi is
   generic (
      TPD_G              : time := 1 ns;
      NUM_MASTER_SLOTS_G : natural range 1 to 16 := 6
   );
   port (

      -- Clocks & Reset
      axiClk                  : in     sl;
      axiClkRst               : in     sl;

      -- AXI Master
      axiGpMasterReadFromArm  : in     AxiReadMasterType;
      axiGpMasterReadToArm    : out    AxiReadSlaveType;
      axiGpMasterWriteFromArm : in     AxiWriteMasterType;
      axiGpMasterWriteToArm   : out    AxiWriteSlaveType;

      -- Local AXI Lite Busses
      localAxiReadMaster      : out    AxiLiteReadMasterArray(NUM_MASTER_SLOTS_G-2 downto 0);
      localAxiReadSlave       : in     AxiLiteReadSlaveArray(NUM_MASTER_SLOTS_G-2 downto 0);
      localAxiWriteMaster     : out    AxiLiteWriteMasterArray(NUM_MASTER_SLOTS_G-2 downto 0);
      localAxiWriteSlave      : in     AxiLiteWriteSlaveArray(NUM_MASTER_SLOTS_G-2 downto 0);

      -- Clock Select Lines
      clkSelA                 : out    slv(1 downto 0);
      clkSelB                 : out    slv(1 downto 0)

   );
end ArmRceG3LocalAxi;

architecture structure of ArmRceG3LocalAxi is

   -- Local signals
   signal midReadMaster     : AxiLiteReadMasterType;
   signal midReadSlave      : AxiLiteReadSlaveType;
   signal midWriteMaster    : AxiLiteWriteMasterType;
   signal midWriteSlave     : AxiLiteWriteSlaveType;
   signal intAxiReadMaster  : AxiLiteReadMasterArray(NUM_MASTER_SLOTS_G-1 downto 0);
   signal intAxiReadSlave   : AxiLiteReadSlaveArray(NUM_MASTER_SLOTS_G-1 downto 0);
   signal intAxiWriteMaster : AxiLiteWriteMasterArray(NUM_MASTER_SLOTS_G-1 downto 0);
   signal intAxiWriteSlave  : AxiLiteWriteSlaveArray(NUM_MASTER_SLOTS_G-1 downto 0);
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
      clkSelA       => (others => '1'),
      clkSelB       => (others => '1'),
      axiReadSlave  => AXI_READ_SLAVE_INIT_C,
      axiWriteSlave => AXI_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   -------------------------------------
   -- AXI-4 to AXI Lite Conversion
   -------------------------------------

   midWriteMaster.awaddr  <= axiGpMasterWriteFromArm.awaddr;
   midWriteMaster.awprot  <= axiGpMasterWriteFromArm.awprot;
   midWriteMaster.awvalid <= axiGpMasterWriteFromArm.awvalid;
   midWriteMaster.wdata   <= axiGpMasterWriteFromArm.wdata(31 downto 0);
   midWriteMaster.wstrb   <= axiGpMasterWriteFromArm.wstrb(3 downto 0);
   midWriteMaster.wvalid  <= axiGpMasterWriteFromArm.wvalid;
   midWriteMaster.bready  <= axiGpMasterWriteFromArm.bready;

   axiGpMasterWriteToArm.awready <= midWriteSlave.awready;
   axiGpMasterWriteToArm.bresp   <= midWriteSlave.bresp;
   axiGpMasterWriteToArm.bvalid  <= midWriteSlave.bvalid;
   axiGpMasterWriteToArm.wready  <= midWriteSlave.wready;
   axiGpMasterWriteToArm.wacount <= (others=>'0');
   axiGpMasterWriteToArm.wcount  <= (others=>'0');

   midReadMaster.araddr  <= axiGpMasterReadFromArm.araddr;
   midReadMaster.arprot  <= axiGpMasterReadFromArm.arprot;
   midReadMaster.arvalid <= axiGpMasterReadFromArm.arvalid;
   midReadMaster.rready  <= axiGpMasterReadFromArm.rready;

   axiGpMasterReadToArm.arready             <= midReadSlave.arready;
   axiGpMasterReadToArm.rdata(63 downto 32) <= (others=>'0');
   axiGpMasterReadToArm.rdata(31 downto  0) <= midReadSlave.rdata;
   axiGpMasterReadToArm.rresp               <= midReadSlave.rresp;
   axiGpMasterReadToArm.rlast               <= '1';
   axiGpMasterReadToArm.rvalid              <= midReadSlave.rvalid;
   axiGpMasterReadToArm.racount             <= (others=>'0');
   axiGpMasterReadToArm.rcount              <= (others=>'0');

   -- ID Tracking
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            axiGpMasterReadToArm.rid  <= (others=>'0') after TPD_G;
            axiGpMasterWriteToArm.bid <= (others=>'0') after TPD_G;
         else

            if axiGpMasterReadFromArm.arvalid = '1' then
               axiGpMasterReadToArm.rid <= axiGpMasterReadFromArm.arid after TPD_G;
            end if;

            if axiGpMasterWriteFromArm.awvalid = '1' then
               axiGpMasterWriteToArm.bid <= axiGpMasterWriteFromArm.awid after TPD_G;
            end if;
         end if;
      end if;
   end process;


   -------------------------------------
   -- AXI Lite Crossbar
   -------------------------------------
   U_AxiCrossbar : entity work.AxiLiteCrossbar 
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_MASTER_SLOTS_G,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => (

            -- Channel 0 = 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
            0 => ( baseAddr     => x"84000000",
                   addrBits     => 12,
                   connectivity => x"FFFF"),

            -- Channel 1 = 0x88000000 - 0x88000FFF : DMA Control Registers
            1 => ( baseAddr     => x"88000000",
                   addrBits     => 12,
                   connectivity => x"FFFF"),

            -- Channel 2 = 0x88001000 - 0x880010FF : DMA Control Completion FIFOs
            2 => ( baseAddr     => x"88001000",
                   addrBits     => 8,
                   connectivity => x"FFFF"),

            -- Channel 3 = 0x88001100 - 0x880011FF : DMA Control Free List FIFOs
            3 => ( baseAddr     => x"88001100",
                   addrBits     => 8,
                   connectivity => x"FFFF"),

            -- Channel 4 = 0xA0000000 - 0xBFFFFFFF : External Address Space
            4 => ( baseAddr     => x"A0000000",
                   addrBits     => 29,
                   connectivity => x"FFFF"),

            -- Channel 5 = 0x80000000 - 0x8000FFFF : Top level module registers
            5 => ( baseAddr     => x"80000000",
                   addrBits     => 16,
                   connectivity => x"FFFF"))

      ) port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sAxiWriteMasters(0) => midWriteMaster,
         sAxiWriteSlaves(0)  => midWriteSlave,
         sAxiReadMasters(0)  => midReadMaster,
         sAxiReadSlaves(0)   => midReadSlave,
         mAxiWriteMasters    => intAxiWriteMaster,
         mAxiWriteSlaves     => intAxiWriteSlave,
         mAxiReadMasters     => intAxiReadMaster,
         mAxiReadSlaves      => intAxiReadSlave
      );

   -- External Connections
   localAxiReadMaster                              <= intAxiReadMaster(NUM_MASTER_SLOTS_G-2 downto 0);
   intAxiReadSlave(NUM_MASTER_SLOTS_G-2 downto 0)  <= localAxiReadSlave;
   localAxiWriteMaster                             <= intAxiWriteMaster(NUM_MASTER_SLOTS_G-2 downto 0);
   intAxiWriteSlave(NUM_MASTER_SLOTS_G-2 downto 0) <= localAxiWriteSlave;

   -- Local Registers
   axiReadMaster       <= intAxiReadMaster(5);
   intAxiReadSlave(5)  <= axiReadSlave;
   axiWriteMaster      <= intAxiWriteMaster(5);
   intAxiWriteSlave(5) <= axiWriteSlave;


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
   process (axiClkRst, axiReadMaster, axiWriteMaster, dnaValid, dnaValue, r ) is
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
         axiSlaveWriteResponse(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave);
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
                  v.axiReadSlave.rdata := ArmRceG3Version;
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
         axiSlaveReadResponse(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave);
      end if;

      -- Reset
      if (axiClkRst = '1') then
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
         rst      => axiClkRst,
         dnaValue => dnaValue,
         dnaValid => dnaValid
      );

end architecture structure;
