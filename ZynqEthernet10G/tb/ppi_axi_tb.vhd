LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.PpiPkg.all;
use work.RceG3Pkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;

entity ppi_axi_tb is end ppi_axi_tb;

-- Define architecture
architecture ppi_axi_tb of ppi_axi_tb is

   signal phyClk         : sl;
   signal phyClkRst      : sl;
   signal txCount        : slv(11 downto 0);
   signal dmaObMaster    : AxiStreamMasterType;
   signal dmaIbMaster    : AxiStreamMasterType;
   signal dmaObSlave     : AxiStreamSlaveType;
   signal dmaIbSlave     : AxiStreamSlaveType;
   signal dmaState       : RceDmaStateType;

   signal intObMaster    : AxiStreamMasterType;
   signal intObSlave     : AxiStreamSlaveType;

   signal ppiReadMaster  : AxiLiteReadMasterArray(0 to 0);
   signal ppiReadSlave   : AxiLiteReadSlaveArray(0 to 0);
   signal ppiWriteMaster : AxiLiteWriteMasterArray(0 to 0);
   signal ppiWriteSlave  : AxiLiteWriteSlaveArray(0 to 0);

   constant NUM_AXI_MASTERS_C : natural := 4;
   constant AXIL_BASEADDR_G   : slv(31 downto 0) := x"A0000000";

   constant TRIG_AXI_INDEX_C : natural := 0;
   constant SCA_AXI_INDEX_C  : natural := 1;
   constant ROL_AXI_INDEX_C  : natural := 3;
   constant FEX_AXI_INDEX_C  : natural := 2;

   constant TRIG_BASE_ADDR_C : slv(31 downto 0) := (AXIL_BASEADDR_G + X"00000000");
   constant SCA_BASE_ADDR_C  : slv(31 downto 0) := (AXIL_BASEADDR_G + X"00001000");
   constant ROL_BASE_ADDR_C  : slv(31 downto 0) := (AXIL_BASEADDR_G + X"00002000");
   constant FEX_BASE_ADDR_C  : slv(31 downto 0) := (AXIL_BASEADDR_G + X"00004000");

   constant AXI_CROSSBAR_MASTERS_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := (
      TRIG_AXI_INDEX_C => (
         baseAddr      => TRIG_BASE_ADDR_C,
         addrBits      => 12,
         connectivity  => X"0003"),
      SCA_AXI_INDEX_C  => (
         baseAddr      => SCA_BASE_ADDR_C,
         addrBits      => 12,
         connectivity  => X"0003"),
      ROL_AXI_INDEX_C  => (
         baseAddr      => ROL_BASE_ADDR_C,
         addrBits      => 12,
         connectivity  => X"0003"),
      FEX_AXI_INDEX_C  => (
         baseAddr      => FEX_BASE_ADDR_C,
         addrBits      => 14,
         connectivity  => X"0003"));

   signal mAxiWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxiWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxiReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal mAxiReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);


begin

   process begin
      phyClk <= '0';
      wait for 5 ns;
      phyClk <= '1';
      wait for 5 ns;
   end process;

   process begin
      phyClkRst <= '1';
      wait for 1000 ns;
      phyClkRst <= '0';
      wait;
   end process;

   process ( phyClk ) begin
      if rising_edge(phyClk) then
         if phyClkRst = '1' then
            dmaObmaster  <= AXI_STREAM_MASTER_INIT_C;
         else
            case txCount is 
               when x"100" =>
                  dmaObMaster.tValid             <= '1';
                  dmaObMaster.tLast              <= '0';
                  dmaObMaster.tKeep              <= (others=>'1');
                  dmaObMaster.tDest              <= x"01";
                  dmaObMaster.tData(63 downto 0) <= x"0000000000000000";  -- 8
               when x"101" =>
                  dmaObMaster.tValid             <= '1';
                  dmaObMaster.tDest              <= x"01";
                  dmaObMaster.tData(63 downto 0) <= x"00000000a0004000";  -- 16
                  dmaObMaster.tLast              <= '1';
                  dmaObMaster.tKeep              <= (others=>'1');
               when others =>
                  dmaObMaster.tValid             <= '0';
                  dmaObMaster.tDest              <= x"01";
                  dmaObMaster.tData(63 downto 0) <= (others=>'0');
                  dmaObMaster.tLast              <= '0';
            end case;
         end if;
      end if;
   end process;

   process ( phyClk ) begin
      if rising_edge(phyClk) then
         if phyClkRst = '1' then
            txCount <= (others=>'0');
         else
            txCount <= txCount + 1;
         end if;
      end if;
   end process;

   dmaIbSlave      <= AXI_STREAM_SLAVE_FORCE_C;
   dmaState.enable <= '1';
   dmaState.online <= '1';




   U_InFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G                => 1 ns,
         PIPE_STAGES_G        => 0,
         SLAVE_READY_EN_G     => true,
         VALID_THOLD_G        => 1,
         BRAM_EN_G            => true,
         XIL_DEVICE_G         => "7SERIES",
         USE_BUILT_IN_G       => false,
         GEN_SYNC_FIFO_G      => false,
         CASCADE_SIZE_G       => 1,
         FIFO_ADDR_WIDTH_G    => 9,
         FIFO_FIXED_THRESH_G  => true,
         FIFO_PAUSE_THRESH_G  => 500,
         SLAVE_AXI_CONFIG_G   => PPI_AXIS_CONFIG_INIT_C,
         MASTER_AXI_CONFIG_G  => PPI_AXIS_CONFIG_INIT_C 
      ) port map (
         sAxisClk        => phyClk,
         sAxisRst        => phyClkRst,
         sAxisMaster     => dmaObMaster,
         sAxisSlave      => dmaObSlave,
         sAxisCtrl       => open,
         mAxisClk        => phyClk,
         mAxisRst        => phyClkRst,
         mAxisMaster     => intObMaster,
         mAxisSlave      => intObSlave
      );

   U_PpiInterconnect : entity work.PpiInterconnect
      generic map (
         TPD_G               => 1 ns,
         NUM_PPI_SLOTS_G     => 1,
         NUM_AXI_SLOTS_G     => 1,
         NUM_STATUS_WORDS_G  => 4,
         STATUS_SEND_WIDTH_G => 4,
         AXIL_BASEADDR_G     => x"A0000000",
         AXIL_BASEBOT_G      => 28,
         AXIL_ADDRBITS_G     => 24
      )
      port map (
         -- PPI's streaming interface
         ppiClk           => phyClk,
         ppiClkRst        => phyClkRst,
         ppiState         => dmaState,
         ppiIbMaster      => dmaIbMaster,
         ppiIbSlave       => dmaIbSlave,
         ppiObMaster      => intObMaster,
         ppiObSlave       => intObSlave,
         locIbMaster      => (others=>AXI_STREAM_MASTER_INIT_C),
         locIbSlave       => open,
         locObMaster      => open,
         locObSlave       => (others=>AXI_STREAM_SLAVE_FORCE_C),
         -- PPI's AXI-Lite interface
         axilClk          => phyClk,
         axilClkRst       => phyClkRst,
         axilWriteMasters => ppiWriteMaster,
         axilWriteSlaves  => ppiWriteSlave,
         axilReadMasters  => ppiReadMaster,
         axilReadSlaves   => ppiReadSlave,
         -- PPI's status words
         statusClk        => phyClk,
         statusClkRst     => phyClkRst,
         statusWords(0)   => (others=>'0'),
         statusWords(1)   => (others=>'0'),
         statusWords(2)   => (others=>'0'),
         statusWords(3)   => (others=>'0'),
         statusSend(0)    => '0',
         statusSend(1)    => '0',
         statusSend(2)    => '0',
         statusSend(3)    => '0'
      );

   -- AXI-Lite Crossbar
   AxiLiteCrossbar_Inst : entity work.AxiLiteCrossbar
      generic map (
         NUM_SLAVE_SLOTS_G  => 2,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         --DEC_ERROR_RESP_G   => AXI_ERROR_RESP_G,
         MASTERS_CONFIG_G   => AXI_CROSSBAR_MASTERS_CONFIG_C
      ) port map (
         axiClk              => phyClk,
         axiClkRst           => phyClkRst,
         sAxiWriteMasters(0) => AXI_LITE_WRITE_MASTER_INIT_C,
         sAxiWriteMasters(1) => ppiWriteMaster(0),
         sAxiWriteSlaves(0)  => open,
         sAxiWriteSlaves(1)  => ppiWriteSlave(0),
         sAxiReadMasters(0)  => AXI_LITE_READ_MASTER_INIT_C,
         sAxiReadMasters(1)  => ppiReadMaster(0),
         sAxiReadSlaves(0)   => open,
         sAxiReadSlaves(1)   => ppiReadSlave(0),
         mAxiWriteMasters    => mAxiWriteMasters,
         mAxiWriteSlaves     => mAxiWriteSlaves,
         mAxiReadMasters     => mAxiReadMasters,
         mAxiReadSlaves      => mAxiReadSlaves);             


   U_Gen : for i in 0 to 3 generate 

      U_Empty : entity work.AxiLiteEmpty 
         generic map (
            TPD_G           => 1 ns,
            NUM_WRITE_REG_G => 1,
            NUM_READ_REG_G  => 1
         ) port map (
            axiClk                    => phyClk,
            axiClkRst                 => phyClkRst,
            axiReadMaster             => mAxiReadMasters(i),
            axiReadSlave              => mAxiReadSlaves(i),
            axiWriteMaster            => mAxiWriteMasters(i),
            axiWriteSlave             => mAxiWriteSlaves(i)
         );
   end generate;

end ppi_axi_tb;

