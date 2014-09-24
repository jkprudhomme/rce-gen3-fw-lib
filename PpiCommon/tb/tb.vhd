LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.PpiPkg.all;

entity tb is end tb;

-- Define architecture
architecture tb of tb is

   --constant RCE_DMA_MODE_C        : RceDmaModeType      := RCE_DMA_AXIS_C;
   constant RCE_DMA_MODE_C        : RceDmaModeType      := RCE_DMA_PPI_C;

   signal i2cSda                   : sl;
   signal i2cScl                   : sl;
   signal sysClk125                : sl;
   signal sysClk125Rst             : sl;
   signal sysClk200                : sl;
   signal sysClk200Rst             : sl;
   signal axiClk                   : sl;
   signal axiClkRst                : sl;
   signal extAxilReadMaster        : AxiLiteReadMasterType;
   signal extAxilReadSlave         : AxiLiteReadSlaveType;
   signal extAxilWriteMaster       : AxiLiteWriteMasterType;
   signal extAxilWriteSlave        : AxiLiteWriteSlaveType;
   signal coreAxilReadMaster       : AxiLiteReadMasterType;
   signal coreAxilReadSlave        : AxiLiteReadSlaveType;
   signal coreAxilWriteMaster      : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave       : AxiLiteWriteSlaveType;
   signal dmaClk                   : slv(3 downto 0);
   signal dmaClkRst                : slv(3 downto 0);
   signal dmaState                 : RceDmaStateArray(3 downto 0);
   signal dmaObMaster              : AxiStreamMasterArray(3 downto 0);
   signal dmaObSlave               : AxiStreamSlaveArray(3 downto 0);
   signal dmaIbMaster              : AxiStreamMasterArray(3 downto 0);
   signal dmaIbSlave               : AxiStreamSlaveArray(3 downto 0);
   signal locIbMaster              : AxiStreamMasterArray(0 downto 0);
   signal locIbSlave               : AxiStreamSlaveArray(0 downto 0);
   signal armEthTx                 : ArmEthTxArray(1 downto 0);
   signal armEthRx                 : ArmEthRxArray(1 downto 0);
   signal clkSelA                  : slv(1 downto 0);
   signal clkSelB                  : slv(1 downto 0);

begin

   -- Core
   U_RceG3Top: entity work.RceG3Top
      generic map (
         TPD_G                 => 1 ns,
         DMA_CLKDIV_G          => 4.5,
         RCE_DMA_MODE_G        => RCE_DMA_MODE_C,
         OLD_BSI_MODE_G        => false
      ) port map (
         i2cSda                    => i2cSda,
         i2cScl                    => i2cScl,
         sysClk125                 => sysClk125,
         sysClk125Rst              => sysClk125Rst,
         sysClk200                 => sysClk200,
         sysClk200Rst              => sysClk200Rst,
         axiClk                    => axiClk,
         axiClkRst                 => axiClkRst,
         extAxilReadMaster         => extAxilReadMaster,
         extAxilReadSlave          => extAxilReadSlave,
         extAxilWriteMaster        => extAxilWriteMaster,
         extAxilWriteSlave         => extAxilWriteSlave,
         coreAxilReadMaster        => coreAxilReadMaster,
         coreAxilReadSlave         => coreAxilReadSlave,
         coreAxilWriteMaster       => coreAxilWriteMaster,
         coreAxilWriteSlave        => coreAxilWriteSlave,
         dmaClk                    => dmaClk,
         dmaClkRst                 => dmaClkRst,
         dmaState                  => dmaState,
         dmaObMaster               => dmaObMaster,
         dmaObSlave                => dmaObSlave,
         dmaIbMaster               => dmaIbMaster,
         dmaIbSlave                => dmaIbSlave,
         userInterrupt             => (others=>'0'),
         armEthTx                  => armEthTx,
         armEthRx                  => armEthRx,
         armEthMode                => (others=>'0'),
         clkSelA                   => clkSelA,
         clkSelB                   => clkSelB
      );

   i2cSda <= '1';
   i2cScl <= '1';

   dmaClk    <= (others=>sysClk125);
   dmaClkRst <= (others=>sysClk125Rst);

   dmaIbMaster(2 downto 1) <= dmaObMaster(2 downto 1);
   dmaObSlave(2 downto 1)  <= dmaIbSlave(2 downto 1);

   extAxilReadSlave    <= AXI_LITE_READ_SLAVE_INIT_C;
   extAxilWriteSlave   <= AXI_LITE_WRITE_SLAVE_INIT_C;
   coreAxilReadSlave   <= AXI_LITE_READ_SLAVE_INIT_C;
   coreAxilWriteSlave  <= AXI_LITE_WRITE_SLAVE_INIT_C;

   U_PpiInterconnect : entity work.PpiInterconnect 
      generic map (
         TPD_G               => 1 ns,
         NUM_PPI_SLOTS_G     => 1,
         NUM_AXI_SLOTS_G     => 1,
         NUM_STATUS_WORDS_G  => 1,
         STATUS_SEND_WIDTH_G => 1,
         AXIL_BASEADDR_G     => X"00000000",
         AXIL_BASEBOT_G      => 32,
         AXIL_ADDRBITS_G     => 24
      ) port map (
         ppiClk            => sysClk125,
         ppiClkRst         => sysClk125Rst,
         ppiState          => dmaState(0),
         ppiIbMaster       => dmaIbMaster(0),
         ppiIbSlave        => dmaIbSlave(0),
         ppiObMaster       => dmaObMaster(0),
         ppiObSlave        => dmaObSlave(0),
         locIbMaster       => locIbMaster,
         locIbSlave        => locIbSlave,
         locObMaster       => open,
         locObSlave        => (others=>AXI_STREAM_SLAVE_INIT_C),
         axilClk           => sysClk125,
         axilClkRst        => sysClk125Rst,
         axilWriteMasters  => open,
         axilWriteSlaves   => (others=>AXI_LITE_WRITE_SLAVE_INIT_C),
         axilReadMasters   => open,
         axilReadSlaves    => (others=>AXI_LITE_READ_SLAVE_INIT_C),
         statusClk         => sysClk125,
         statusClkRst      => sysClk125Rst,
         statusWords       => (others=>(others=>'0')),
         statusSend        => (others=>'0')
      );

   U_SsiPrbsTx : entity work.SsiPrbsTx
      generic map (
         TPD_G                      => 1 ns,
         ALTERA_SYN_G               => false,
         ALTERA_RAM_G               => "M9K",
         XIL_DEVICE_G               => "7SERIES",  --Xilinx only generic parameter    
         BRAM_EN_G                  => true,
         USE_BUILT_IN_G             => false,  --if set to true, this module is only Xilinx compatible only!!!
         GEN_SYNC_FIFO_G            => false,
         CASCADE_SIZE_G             => 1,
         PRBS_SEED_SIZE_G           => 32,
         PRBS_TAPS_G                => (0 => 16),
         FIFO_ADDR_WIDTH_G          => 9,
         FIFO_PAUSE_THRESH_G        => 256,    -- Almost full at 1/2 capacity
         MASTER_AXI_STREAM_CONFIG_G => PPI_AXIS_CONFIG_INIT_C,
         MASTER_AXI_PIPE_STAGES_G   => 0
      ) port map (

         mAxisClk     => sysClk125,
         mAxisRst     => sysClk125,
         mAxisSlave   => locIbSlave(0),
         mAxisMaster  => locIbMaster(0),
         locClk       => sysClk125,
         locRst       => sysClk125Rst,
         trig         => '1',
         packetLength => x"00000100",
         busy         => open,
         tDest        => (others=>'0'),
         tId          => (others=>'0')
      );

end tb;

