
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

entity RegTest is
   generic (
      TPD_G              : time := 1 ns
   );
   port (

      -- Clocks & Reset
      axiClk          : in  sl;
      axiClkRst       : in  sl;
      ppiClk          : in  sl;
      ppiClkRst       : in  sl;

      -- PPI
      ppiOnline        : in  sl;
      ppiWriteToFifo   : out PpiWriteToFifoType;
      ppiWriteFromFifo : in  PpiWriteFromFifoType;
      ppiReadToFifo    : out PpiReadToFifoType;
      ppiReadFromFifo  : in  PpiReadFromFifoType
   );
end RegTest;

architecture structure of RegTest is

   -- Local signals
   signal axiReadMaster     : AxiLiteReadMasterType;
   signal axiReadSlave      : AxiLiteReadSlaveType;
   signal axiWriteMaster    : AxiLiteWriteMasterType;
   signal axiWriteSlave     : AxiLiteWriteSlaveType;
   signal dnaValue          : slv(63 downto 0);
   signal dnaValid          : sl;
   signal intWriteToFifo    : PpiWriteToFifoType;
   signal intWriteFromFifo  : PpiWriteFromFifoType;
   signal intReadToFifo     : PpiReadToFifoType;
   signal intReadFromFifo   : PpiReadFromFifoType;

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

   -- Mask is constant
   constant CROSSBAR_CONN_C : slv(15 downto 0) := x"FFFF";

   -- Channel 5 = 0x80000000 - 0x8000FFFF : Top level module registers
   constant TOP_SPACE_INDEX_C     : natural          := 5;
   constant TOP_SPACE_BASE_ADDR_C : slv(31 downto 0) := x"80000000";
   constant TOP_SPACE_NUM_BITS_C  : natural          := 16;

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(0 downto 0) := (
      TOP_SPACE_INDEX_C => (
         baseAddr     => TOP_SPACE_BASE_ADDR_C,
         addrBits     => TOP_SPACE_NUM_BITS_C,
         connectivity => CROSSBAR_CONN_C));

begin

   U_Route: entity work.PpiRouter 
      generic map (
         TPD_G             => 1 ns,
         NUM_WRITE_SLOTS_G => 1
      ) port map (
         ppiClk              => ppiClk,
         ppiClkRst           => ppiClkRst,
         ppiOnline           => ppiOnline,
         ppiReadToFifo       => ppiReadToFifo,
         ppiReadFromFifo     => ppiReadFromFifo,
         ppiWriteToFifo(0)   => intWriteToFifo,
         ppiWriteFromFifo(0) => intWriteFromFifo
      );

   U_Mux : entity work.PpiMux 
      generic map (
         TPD_G            => 1 ns,
         NUM_READ_SLOTS_G => 1
      ) port map (
         ppiClk             => ppiClk,
         ppiClkRst          => ppiClkRst,
         ppiOnline          => ppiOnline,
         ppiWriteToFifo     => ppiWriteToFifo,
         ppiWriteFromFifo   => ppiWriteFromFifo,
         ppiReadToFifo(0)   => intReadToFifo,
         ppiReadFromFifo(0) => intReadFromFifo
      );

   U_PpiToAxi : entity work.PpiToAxi
      generic map (
         TPD_G                  => TPD_G,
         NUM_AXI_MASTER_SLOTS_G => 1,
         AXI_MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C
      ) port map (
         ppiClk             => ppiClk,
         ppiClkRst          => ppiClkRst,
         ppiOnline          => ppiOnline,
         ppiWriteToFifo     => intWriteToFifo,
         ppiWriteFromFifo   => intWriteFromFifo,
         ppiReadToFifo      => intReadToFifo,
         ppiReadFromFifo    => intReadFromFifo,
         axiClk             => axiClk,
         axiClkRst          => axiClkRst,
         axiWriteMasters(0) => axiWriteMaster,
         axiWriteSlaves(0)  => axiWriteSlave,
         axiReadMasters(0)  => axiReadMaster,
         axiReadSlaves(0)   => axiReadSlave
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
