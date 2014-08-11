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

entity tb is end tb;

-- Define architecture
architecture tb of tb is

   constant RCE_DMA_MODE_C        : RceDmaModeType      := RCE_DMA_AXIS_C;
   --constant RCE_DMA_MODE_C        : RceDmaModeType      := RCE_DMA_PPI_C;

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
   signal armEthTx                 : ArmEthTxArray(1 downto 0);
   signal armEthRx                 : ArmEthRxArray(1 downto 0);
   signal clkSelA                  : slv(1 downto 0);
   signal clkSelB                  : slv(1 downto 0);
   signal ethRxP                   : slv(3 downto 0);
   signal ethRxM                   : slv(3 downto 0);
   signal ethRefClkP               : sl;
   signal ethRefClkM               : sl;

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
         clkSelA                   => clkSelA,
         clkSelB                   => clkSelB
      );

   i2cSda <= '1';
   i2cScl <= '1';

   dmaClk    <= (others=>sysClk200);
   dmaClkRst <= (others=>sysClk200Rst);

   dmaIbMaster(3 downto 1) <= dmaObMaster(3 downto 1);
   dmaObSlave(3 downto 1)  <= dmaIbSlave(3 downto 1);

   coreAxilReadSlave   <= AXI_LITE_READ_SLAVE_INIT_C;
   coreAxilWriteSlave  <= AXI_LITE_WRITE_SLAVE_INIT_C;


   process begin
      ethRefClkP  <= '0';
      ethRefClkM  <= '1';
      wait for 3.2 ns;
      ethRefClkP  <= '1';
      ethRefClkM  <= '0';
      wait for 3.2 ns;
   end process;

   U_XMac : entity work.XMac
      generic map (
         TPD_G            => 1 ns,
         IB_ADDR_WIDTH_G  => 9,
         OB_ADDR_WIDTH_G  => 9,
         PAUSE_THOLD_G    => 255,
         VALID_THOLD_G    => 0,
         EOH_BIT_G        => 0,
         ERR_BIT_G        => 0,
         HEADER_SIZE_G    => 16,
         AXIS_CONFIG_G    => AXI_STREAM_CONFIG_INIT_C
      ) port map (
         xmacRst          => '0',
         dmaClk           => sysClk200,
         dmaClkRst        => sysClk200Rst,
         dmaIbMaster      => dmaIbMaster(0),
         dmaIbSlave       => dmaIbSlave(0),
         dmaObMaster      => dmaObMaster(0),
         dmaObSlave       => dmaObSlave(0),
         axilClk          => axiClk,
         axilClkRst       => axiClkRst,
         axilWriteMaster  => extAxilWriteMaster,
         axilWriteSlave   => extAxilWriteSlave,
         axilReadMaster   => extAxilReadMaster,
         axilReadSlave    => extAxilReadSlave,
         statusWord       => open,
         statusSend       => open,
         ethRefClkP       => ethRefClkP,
         ethRefClkM       => ethRefClkM,
         ethRxP           => ethRxP,
         ethRxM           => ethRxM,
         ethTxP           => ethRxP,
         ethTxM           => ethRxM
      );

end tb;

