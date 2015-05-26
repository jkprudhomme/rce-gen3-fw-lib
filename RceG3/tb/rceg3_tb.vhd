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

entity rceg3_tb is end rceg3_tb;

-- Define architecture
architecture rceg3_tb of rceg3_tb is

   constant RCE_DMA_MODE_C        : RceDmaModeType      := RCE_DMA_AXIS_C;

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
   signal dmaOnline                : slv(3 downto 0);
   signal dmaEnable                : slv(3 downto 0);
   signal dmaObMaster              : AxiStreamMasterArray(3 downto 0);
   signal dmaObSlave               : AxiStreamSlaveArray(3 downto 0);
   signal dmaIbMaster              : AxiStreamMasterArray(3 downto 0);
   signal dmaIbSlave               : AxiStreamSlaveArray(3 downto 0);
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
         RCE_DMA_MODE_G        => RCE_DMA_MODE_C
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
         dmaOnline                 => dmaOnline,
         dmaEnable                 => dmaEnable,
         dmaObMaster               => dmaObMaster,
         dmaObSlave                => dmaObSlave,
         dmaIbMaster               => dmaIbMaster,
         dmaIbSlave                => dmaIbSlave,
         armEthTx                  => armEthTx,
         armEthRx                  => armEthRx,
         clkSelA                   => clkSelA,
         clkSelB                   => clkSelB
      );

   i2cSda <= '1';
   i2cScl <= '1';

   dmaClk    <= (others=>sysClk125);
   dmaClkRst <= (others=>sysClk125Rst);

   dmaIbMaster <= dmaObMaster;
   dmaObSlave  <= dmaIbSlave;

   extAxilReadSlave    <= AXI_LITE_READ_SLAVE_INIT_C;
   extAxilWriteSlave   <= AXI_LITE_WRITE_SLAVE_INIT_C;
   coreAxilReadSlave   <= AXI_LITE_READ_SLAVE_INIT_C;
   coreAxilWriteSlave  <= AXI_LITE_WRITE_SLAVE_INIT_C;


end tb;

