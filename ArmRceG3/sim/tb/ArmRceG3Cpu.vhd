library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;

entity ArmRceG3Cpu is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clocks
      fclkClk3                 : out    sl;
      fclkClk2                 : out    sl;
      fclkClk1                 : out    sl;
      fclkClk0                 : out    sl;
      fclkRst3                 : out    sl;
      fclkRst2                 : out    sl;
      fclkRst1                 : out    sl;
      fclkRst0                 : out    sl;

      -- Common AXI Clock
      axiClk                   : in     sl;

      -- Interrupts
      armInt                   : in     slv(15 downto 0);

      -- AXI GP Master
      axiGpMasterReset         : out    slv(1 downto 0);
      axiGpMasterWriteFromArm  : out    AxiWriteMasterVector(1 downto 0);
      axiGpMasterWriteToArm    : in     AxiWriteSlaveVector(1 downto 0);
      axiGpMasterReadFromArm   : out    AxiReadMasterVector(1 downto 0);
      axiGpMasterReadToArm     : in     AxiReadSlaveVector(1 downto 0);

      -- AXI GP Slave
      axiGpSlaveReset          : out    slv(1 downto 0);
      axiGpSlaveWriteFromArm   : out    AxiWriteSlaveVector(1 downto 0);
      axiGpSlaveWriteToArm     : in     AxiWriteMasterVector(1 downto 0);
      axiGpSlaveReadFromArm    : out    AxiReadSlaveVector(1 downto 0);
      axiGpSlaveReadToArm      : in     AxiReadMasterVector(1 downto 0);

      -- AXI ACP Slave
      axiAcpSlaveReset         : out    sl;
      axiAcpSlaveWriteFromArm  : out    AxiWriteSlaveType;
      axiAcpSlaveWriteToArm    : in     AxiWriteMasterType;
      axiAcpSlaveReadFromArm   : out    AxiReadSlaveType;
      axiAcpSlaveReadToArm     : in     AxiReadMasterType;

      -- AXI HP Slave
      axiHpSlaveReset          : out    slv(3 downto 0);
      axiHpSlaveWriteFromArm   : out    AxiWriteSlaveVector(3 downto 0);
      axiHpSlaveWriteToArm     : in     AxiWriteMasterVector(3 downto 0);
      axiHpSlaveReadFromArm    : out    AxiReadSlaveVector(3 downto 0);
      axiHpSlaveReadToArm      : in     AxiReadMasterVector(3 downto 0);

      -- Ethernet
      ethFromArm               : out    EthFromArmVector(1 downto 0);
      ethToArm                 : in     EthToArmVector(1 downto 0);

      -- External Inputs
      psSrstB                  : in     sl;
      psClk                    : in     sl;
      psPorB                   : in     sl

   );
end ArmRceG3Cpu;

architecture structure of ArmRceG3Cpu is

   component AxiMasterModel is 
      port (
         masterId       : in  slv(7  downto 0);
         axiClk         : in  sl;
         axiClkRst      : out sl;
         arvalid        : out sl;
         arready        : in  sl;
         araddr         : out slv(31 downto 0);
         arid           : out slv(11 downto 0);
         arlen          : out slv(3  downto 0);
         arsize         : out slv(2  downto 0);
         arburst        : out slv(1  downto 0);
         arlock         : out slv(1  downto 0);
         arprot         : out slv(2  downto 0);
         arcache        : out slv(3  downto 0);
         arqos          : out slv(3  downto 0);
         aruser         : out slv(4  downto 0);
         rready         : out sl;
         rdataH         : in  slv(31 downto 0);
         rdataL         : in  slv(31 downto 0);
         rlast          : in  sl;
         rvalid         : in  sl;
         rid            : in  slv(11 downto 0);
         rresp          : in  slv(1  downto 0);
         rdissuecap1_en : out sl;
         racount        : in  slv(2  downto 0);
         rcount         : in  slv(7  downto 0);
         awvalid        : out sl;
         awready        : in  sl;
         awaddr         : out slv(31 downto 0);
         awid           : out slv(11 downto 0);
         awlen          : out slv(3  downto 0);
         awsize         : out slv(2  downto 0);
         awburst        : out slv(1  downto 0);
         awlock         : out slv(1  downto 0);
         awcache        : out slv(3  downto 0);
         awprot         : out slv(2  downto 0);
         awqos          : out slv(3  downto 0);
         awuser         : out slv(4  downto 0);
         wready         : in  sl;
         wdataH         : out slv(31 downto 0);
         wdataL         : out slv(31 downto 0);
         wlast          : out sl;
         wvalid         : out sl;
         wid            : out slv(11 downto 0);
         wstrb          : out slv(7  downto 0);
         bready         : out sl;
         bresp          : in  slv(1  downto 0);
         bvalid         : in  sl;
         bid            : in  slv(11 downto 0);
         wrissuecap1_en : out sl;
         wacount        : in  slv(5  downto 0);
         wcount         : in  slv(7  downto 0)
      );
   end component;

   component AxiSlaveModel is 
      port (
         masterId       : in  slv(7  downto 0);
         axiClk         : in  sl;
         axiClkRst      : out sl;
         arvalid        : in  sl;
         arready        : out sl;
         araddr         : in  slv(31 downto 0);
         arid           : in  slv(11 downto 0);
         arlen          : in  slv(3  downto 0);
         arsize         : in  slv(2  downto 0);
         arburst        : in  slv(1  downto 0);
         arlock         : in  slv(1  downto 0);
         arprot         : in  slv(2  downto 0);
         arcache        : in  slv(3  downto 0);
         arqos          : in  slv(3  downto 0);
         aruser         : in  slv(4  downto 0);
         rready         : in  sl;
         rdataH         : out slv(31 downto 0);
         rdataL         : out slv(31 downto 0);
         rlast          : out sl;
         rvalid         : out sl;
         rid            : out slv(11 downto 0);
         rresp          : out slv(1  downto 0);
         rdissuecap1_en : in  sl;
         racount        : out slv(2  downto 0);
         rcount         : out slv(7  downto 0);
         awvalid        : in  sl;
         awready        : out sl;
         awaddr         : in  slv(31 downto 0);
         awid           : in  slv(11 downto 0);
         awlen          : in  slv(3  downto 0);
         awsize         : in  slv(2  downto 0);
         awburst        : in  slv(1  downto 0);
         awlock         : in  slv(1  downto 0);
         awcache        : in  slv(3  downto 0);
         awprot         : in  slv(2  downto 0);
         awqos          : in  slv(3  downto 0);
         awuser         : in  slv(4  downto 0);
         wready         : out sl;
         wdataH         : in  slv(31 downto 0);
         wdataL         : in  slv(31 downto 0);
         wlast          : in  sl;
         wvalid         : in  sl;
         wid            : in  slv(11 downto 0);
         wstrb          : in  slv(7  downto 0);
         bready         : in  sl;
         bresp          : out slv(1  downto 0);
         bvalid         : out sl;
         bid            : out slv(11 downto 0);
         wrissuecap1_en : in  sl;
         wacount        : out slv(5  downto 0);
         wcount         : out slv(7  downto 0)
      );
   end component;

   -- Local signals
   signal masterId : Slv8Array(1 downto 0);
   signal slaveId  : Slv8Array(6 downto 0);

begin

   ---------------------------------------
   -- Unused signals
   ---------------------------------------
   -- armInt    : in slv(15 downto 0);
   -- ethToArm  : in EthToArmType
   ethFromArm <= (others=>EthFromArmInit);

   ---------------------------------------
   -- Clock and reset generation
   ---------------------------------------

   -- Reset
   process begin
      fclkRst0  <= '0';
      fclkRst1  <= '0';
      fclkRst2  <= '0';
      fclkRst3  <= '0';
      wait for (10.0 ns);
      fclkRst0 <= '1';
      fclkRst1 <= '1';
      fclkRst2 <= '1';
      fclkRst3 <= '1';
      wait for (10.0 ns * 20);
      fclkRst0 <= '0';
      fclkRst1 <= '0';
      fclkRst2 <= '0';
      fclkRst3 <= '0';
      wait;
   end process;

   -- 100Mhz
   process begin
      fclkClk0 <= '0';
      fclkClk1 <= '0';
      fclkClk2 <= '0';
      fclkClk3 <= '0';
      wait for (10.0 ns / 2);
      fclkClk0 <= '1';
      fclkClk1 <= '1';
      fclkClk2 <= '1';
      fclkClk3 <= '1';
      wait for (10.0 ns / 2);
   end process;

   ---------------------------------------
   -- Master GP
   ---------------------------------------
   U_MasterGpGen : for i in 0 to 1 generate

      U_MasterGp : AxiMasterModel 
         port map (
            masterId        => masterId(i),
            axiClk          => axiClk,
            axiClkRst       => axiGpMasterReset(i),
            arvalid         => axiGpMasterReadFromArm(i).arvalid,
            arready         => axiGpMasterReadToArm(i).arready,
            araddr          => axiGpMasterReadFromArm(i).araddr,
            arid            => axiGpMasterReadFromArm(i).arid,
            arlen           => axiGpMasterReadFromArm(i).arlen,
            arsize          => axiGpMasterReadFromArm(i).arsize,
            arburst         => axiGpMasterReadFromArm(i).arburst,
            arlock          => axiGpMasterReadFromArm(i).arlock,
            arprot          => axiGpMasterReadFromArm(i).arprot,
            arcache         => axiGpMasterReadFromArm(i).arcache,
            arqos           => axiGpMasterReadFromArm(i).arqos,
            aruser          => axiGpMasterReadFromArm(i).aruser,
            rready          => axiGpMasterReadFromArm(i).rready,
            rdataH          => axiGpMasterReadToArm(i).rdata(63 downto 32),
            rdataL          => axiGpMasterReadToArm(i).rdata(31 downto  0),
            rlast           => axiGpMasterReadToArm(i).rlast,
            rvalid          => axiGpMasterReadToArm(i).rvalid,
            rid             => axiGpMasterReadToArm(i).rid,
            rresp           => axiGpMasterReadToArm(i).rresp,
            rdissuecap1_en  => axiGpMasterReadFromArm(i).rdissuecap1_en,
            racount         => axiGpMasterReadToArm(i).racount,
            rcount          => axiGpMasterReadToArm(i).rcount,
            awvalid         => axiGpMasterWriteFromArm(i).awvalid,
            awready         => axiGpMasterWriteToArm(i).awready,
            awaddr          => axiGpMasterWriteFromArm(i).awaddr,
            awid            => axiGpMasterWriteFromArm(i).awid,
            awlen           => axiGpMasterWriteFromArm(i).awlen,
            awsize          => axiGpMasterWriteFromArm(i).awsize,
            awburst         => axiGpMasterWriteFromArm(i).awburst,
            awlock          => axiGpMasterWriteFromArm(i).awlock,
            awcache         => axiGpMasterWriteFromArm(i).awcache,
            awprot          => axiGpMasterWriteFromArm(i).awprot,
            awqos           => axiGpMasterWriteFromArm(i).awqos,
            awuser          => axiGpMasterWriteFromArm(i).awuser,
            wready          => axiGpMasterWriteToArm(i).wready,
            wdataH          => axiGpMasterWriteFromArm(i).wdata(63 downto 32),
            wdataL          => axiGpMasterWriteFromArm(i).wdata(31 downto 0),
            wlast           => axiGpMasterWriteFromArm(i).wlast,
            wvalid          => axiGpMasterWriteFromArm(i).wvalid,
            wid             => axiGpMasterWriteFromArm(i).wid,
            wstrb           => axiGpMasterWriteFromArm(i).wstrb,
            bready          => axiGpMasterWriteFromArm(i).bready,
            bresp           => axiGpMasterWriteToArm(i).bresp,
            bvalid          => axiGpMasterWriteToArm(i).bvalid,
            bid             => axiGpMasterWriteToArm(i).bid,
            wrissuecap1_en  => axiGpMasterWriteFromArm(i).wrissuecap1_en,
            wacount         => axiGpMasterWriteToArm(i).wacount,
            wcount          => axiGpMasterWriteToArm(i).wcount
         );

      masterId(i) <= conv_std_logic_vector(i,8);

   end generate;

   ---------------------------------------
   -- Slave GP
   ---------------------------------------
   U_SlaveGpGen : for i in 0 to 1 generate

      U_SlaveGp : AxiSlaveModel 
         port map (
            masterId        => slaveId(i),
            axiClk          => axiClk,
            axiClkRst       => axiGpSlaveReset(i),
            arvalid         => axiGpSlaveReadToArm(i).arvalid,
            arready         => axiGpSlaveReadFromArm(i).arready,
            araddr          => axiGpSlaveReadToArm(i).araddr,
            arid            => axiGpSlaveReadToArm(i).arid,
            arlen           => axiGpSlaveReadToArm(i).arlen,
            arsize          => axiGpSlaveReadToArm(i).arsize,
            arburst         => axiGpSlaveReadToArm(i).arburst,
            arlock          => axiGpSlaveReadToArm(i).arlock,
            arprot          => axiGpSlaveReadToArm(i).arprot,
            arcache         => axiGpSlaveReadToArm(i).arcache,
            arqos           => axiGpSlaveReadToArm(i).arqos,
            aruser          => axiGpSlaveReadToArm(i).aruser,
            rready          => axiGpSlaveReadToArm(i).rready,
            rdataH          => axiGpSlaveReadFromArm(i).rdata(63 downto 32),
            rdataL          => axiGpSlaveReadFromArm(i).rdata(31 downto  0),
            rlast           => axiGpSlaveReadFromArm(i).rlast,
            rvalid          => axiGpSlaveReadFromArm(i).rvalid,
            rid             => axiGpSlaveReadFromArm(i).rid,
            rresp           => axiGpSlaveReadFromArm(i).rresp,
            rdissuecap1_en  => axiGpSlaveReadToArm(i).rdissuecap1_en,
            racount         => axiGpSlaveReadFromArm(i).racount,
            rcount          => axiGpSlaveReadFromArm(i).rcount,
            awvalid         => axiGpSlaveWriteToArm(i).awvalid,
            awready         => axiGpSlaveWriteFromArm(i).awready,
            awaddr          => axiGpSlaveWriteToArm(i).awaddr,
            awid            => axiGpSlaveWriteToArm(i).awid,
            awlen           => axiGpSlaveWriteToArm(i).awlen,
            awsize          => axiGpSlaveWriteToArm(i).awsize,
            awburst         => axiGpSlaveWriteToArm(i).awburst,
            awlock          => axiGpSlaveWriteToArm(i).awlock,
            awcache         => axiGpSlaveWriteToArm(i).awcache,
            awprot          => axiGpSlaveWriteToArm(i).awprot,
            awqos           => axiGpSlaveWriteToArm(i).awqos,
            awuser          => axiGpSlaveWriteToArm(i).awuser,
            wready          => axiGpSlaveWriteFromArm(i).wready,
            wdataH          => axiGpSlaveWriteToArm(i).wdata(63 downto 32),
            wdataL          => axiGpSlaveWriteToArm(i).wdata(31 downto 0),
            wlast           => axiGpSlaveWriteToArm(i).wlast,
            wvalid          => axiGpSlaveWriteToArm(i).wvalid,
            wid             => axiGpSlaveWriteToArm(i).wid,
            wstrb           => axiGpSlaveWriteToArm(i).wstrb,
            bready          => axiGpSlaveWriteToArm(i).bready,
            bresp           => axiGpSlaveWriteFromArm(i).bresp,
            bvalid          => axiGpSlaveWriteFromArm(i).bvalid,
            bid             => axiGpSlaveWriteFromArm(i).bid,
            wrissuecap1_en  => axiGpSlaveWriteToArm(i).wrissuecap1_en,
            wacount         => axiGpSlaveWriteFromArm(i).wacount,
            wcount          => axiGpSlaveWriteFromArm(i).wcount
         );

      slaveId(i) <= conv_std_logic_vector(i,8);

   end generate;

   ---------------------------------------
   -- Slave ACP
   ---------------------------------------

   U_SlaveAcp : AxiSlaveModel 
      port map (
         masterId        => slaveId(2),
         axiClk          => axiClk,
         axiClkRst       => axiAcpSlaveReset,
         arvalid         => axiAcpSlaveReadToArm.arvalid,
         arready         => axiAcpSlaveReadFromArm.arready,
         araddr          => axiAcpSlaveReadToArm.araddr,
         arid            => axiAcpSlaveReadToArm.arid,
         arlen           => axiAcpSlaveReadToArm.arlen,
         arsize          => axiAcpSlaveReadToArm.arsize,
         arburst         => axiAcpSlaveReadToArm.arburst,
         arlock          => axiAcpSlaveReadToArm.arlock,
         arprot          => axiAcpSlaveReadToArm.arprot,
         arcache         => axiAcpSlaveReadToArm.arcache,
         arqos           => axiAcpSlaveReadToArm.arqos,
         aruser          => axiAcpSlaveReadToArm.aruser,
         rready          => axiAcpSlaveReadToArm.rready,
         rdataH          => axiAcpSlaveReadFromArm.rdata(63 downto 32),
         rdataL          => axiAcpSlaveReadFromArm.rdata(31 downto  0),
         rlast           => axiAcpSlaveReadFromArm.rlast,
         rvalid          => axiAcpSlaveReadFromArm.rvalid,
         rid             => axiAcpSlaveReadFromArm.rid,
         rresp           => axiAcpSlaveReadFromArm.rresp,
         rdissuecap1_en  => axiAcpSlaveReadToArm.rdissuecap1_en,
         racount         => axiAcpSlaveReadFromArm.racount,
         rcount          => axiAcpSlaveReadFromArm.rcount,
         awvalid         => axiAcpSlaveWriteToArm.awvalid,
         awready         => axiAcpSlaveWriteFromArm.awready,
         awaddr          => axiAcpSlaveWriteToArm.awaddr,
         awid            => axiAcpSlaveWriteToArm.awid,
         awlen           => axiAcpSlaveWriteToArm.awlen,
         awsize          => axiAcpSlaveWriteToArm.awsize,
         awburst         => axiAcpSlaveWriteToArm.awburst,
         awlock          => axiAcpSlaveWriteToArm.awlock,
         awcache         => axiAcpSlaveWriteToArm.awcache,
         awprot          => axiAcpSlaveWriteToArm.awprot,
         awqos           => axiAcpSlaveWriteToArm.awqos,
         awuser          => axiAcpSlaveWriteToArm.awuser,
         wready          => axiAcpSlaveWriteFromArm.wready,
         wdataH          => axiAcpSlaveWriteToArm.wdata(63 downto 32),
         wdataL          => axiAcpSlaveWriteToArm.wdata(31 downto 0),
         wlast           => axiAcpSlaveWriteToArm.wlast,
         wvalid          => axiAcpSlaveWriteToArm.wvalid,
         wid             => axiAcpSlaveWriteToArm.wid,
         wstrb           => axiAcpSlaveWriteToArm.wstrb,
         bready          => axiAcpSlaveWriteToArm.bready,
         bresp           => axiAcpSlaveWriteFromArm.bresp,
         bvalid          => axiAcpSlaveWriteFromArm.bvalid,
         bid             => axiAcpSlaveWriteFromArm.bid,
         wrissuecap1_en  => axiAcpSlaveWriteToArm.wrissuecap1_en,
         wacount         => axiAcpSlaveWriteFromArm.wacount,
         wcount          => axiAcpSlaveWriteFromArm.wcount
      );

   slaveId(2) <= conv_std_logic_vector(2,8);

   ---------------------------------------
   -- Slave HP
   ---------------------------------------
   U_SlaveHpGen : for i in 0 to 3 generate

      U_SlaveHp : AxiSlaveModel 
         port map (
            masterId        => slaveId(i+3),
            axiClk          => axiClk,
            axiClkRst       => axiHpSlaveReset(i),
            arvalid         => axiHpSlaveReadToArm(i).arvalid,
            arready         => axiHpSlaveReadFromArm(i).arready,
            araddr          => axiHpSlaveReadToArm(i).araddr,
            arid            => axiHpSlaveReadToArm(i).arid,
            arlen           => axiHpSlaveReadToArm(i).arlen,
            arsize          => axiHpSlaveReadToArm(i).arsize,
            arburst         => axiHpSlaveReadToArm(i).arburst,
            arlock          => axiHpSlaveReadToArm(i).arlock,
            arprot          => axiHpSlaveReadToArm(i).arprot,
            arcache         => axiHpSlaveReadToArm(i).arcache,
            arqos           => axiHpSlaveReadToArm(i).arqos,
            aruser          => axiHpSlaveReadToArm(i).aruser,
            rready          => axiHpSlaveReadToArm(i).rready,
            rdataH          => axiHpSlaveReadFromArm(i).rdata(63 downto 32),
            rdataL          => axiHpSlaveReadFromArm(i).rdata(31 downto  0),
            rlast           => axiHpSlaveReadFromArm(i).rlast,
            rvalid          => axiHpSlaveReadFromArm(i).rvalid,
            rid             => axiHpSlaveReadFromArm(i).rid,
            rresp           => axiHpSlaveReadFromArm(i).rresp,
            rdissuecap1_en  => axiHpSlaveReadToArm(i).rdissuecap1_en,
            racount         => axiHpSlaveReadFromArm(i).racount,
            rcount          => axiHpSlaveReadFromArm(i).rcount,
            awvalid         => axiHpSlaveWriteToArm(i).awvalid,
            awready         => axiHpSlaveWriteFromArm(i).awready,
            awaddr          => axiHpSlaveWriteToArm(i).awaddr,
            awid            => axiHpSlaveWriteToArm(i).awid,
            awlen           => axiHpSlaveWriteToArm(i).awlen,
            awsize          => axiHpSlaveWriteToArm(i).awsize,
            awburst         => axiHpSlaveWriteToArm(i).awburst,
            awlock          => axiHpSlaveWriteToArm(i).awlock,
            awcache         => axiHpSlaveWriteToArm(i).awcache,
            awprot          => axiHpSlaveWriteToArm(i).awprot,
            awqos           => axiHpSlaveWriteToArm(i).awqos,
            awuser          => axiHpSlaveWriteToArm(i).awuser,
            wready          => axiHpSlaveWriteFromArm(i).wready,
            wdataH          => axiHpSlaveWriteToArm(i).wdata(63 downto 32),
            wdataL          => axiHpSlaveWriteToArm(i).wdata(31 downto 0),
            wlast           => axiHpSlaveWriteToArm(i).wlast,
            wvalid          => axiHpSlaveWriteToArm(i).wvalid,
            wid             => axiHpSlaveWriteToArm(i).wid,
            wstrb           => axiHpSlaveWriteToArm(i).wstrb,
            bready          => axiHpSlaveWriteToArm(i).bready,
            bresp           => axiHpSlaveWriteFromArm(i).bresp,
            bvalid          => axiHpSlaveWriteFromArm(i).bvalid,
            bid             => axiHpSlaveWriteFromArm(i).bid,
            wrissuecap1_en  => axiHpSlaveWriteToArm(i).wrissuecap1_en,
            wacount         => axiHpSlaveWriteFromArm(i).wacount,
            wcount          => axiHpSlaveWriteFromArm(i).wcount
         );

      slaveId(i+3) <= conv_std_logic_vector(i+3,8);

   end generate;

end architecture structure;

