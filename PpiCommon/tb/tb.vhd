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
   signal rxCount                  : slv(7 downto 0);
   signal rxError                  : sl;
   signal outClk                   : sl;
   signal outClkRst                : sl;
   signal outCount                 : slv(7 downto 0);

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

   dmaClk    <= (others=>outClk);
   dmaClkRst <= (others=>outClkRst);

   --dmaIbMaster(2 downto 0) <= dmaObMaster(2 downto 0);
   --dmaObSlave(2 downto 0)  <= dmaIbSlave(2 downto 0);
   dmaIbMaster(2 downto 0) <= (others=>AXI_STREAM_MASTER_INIT_C);
   dmaObSlave(2 downto 0)  <= (others=>AXI_STREAM_SLAVE_FORCE_C) when outCount(7 downto 6) = 0 else 
                              (others=>AXI_STREAM_SLAVE_INIT_C);

   process ( outClk ) begin
      if rising_edge(outClk) then
         if outClkRst = '1' then
            rxCount  <= (others=>'0') after 1 ns;
            rxError  <= '0' after 1 ns;
            outCount <= (others=>'0') after 1 ns;
         else
            outCount <= outCount + 1 after 1 ns;

            if dmaObMaster(0).tValid = '1' and dmaObSlave(0).tReady = '1' then
               if dmaObMaster(0).tLast = '1' then
                  rxCount <= (others=>'0') after 1 ns;
                  if rxCount /= 9 then
                     rxError <= '1' after 1 ns;
                  end if;
               else
                  rxCount <= rxCount + 1 after 1 ns;
               end if;
            end if;
         end if;
      end if;
   end process;

   extAxilReadSlave    <= AXI_LITE_READ_SLAVE_INIT_C;
   extAxilWriteSlave   <= AXI_LITE_WRITE_SLAVE_INIT_C;
   coreAxilReadSlave   <= AXI_LITE_READ_SLAVE_INIT_C;
   coreAxilWriteSlave  <= AXI_LITE_WRITE_SLAVE_INIT_C;

   process begin
      outClk <= '0';
      wait for 8 ns;
      outClk <= '1';
      wait for 8 ns;
   end process;

   process begin
      outClkRst <= '1';
      wait for 100 ns;
      outClkRst <= '0';
      wait;
   end process;

end tb;

