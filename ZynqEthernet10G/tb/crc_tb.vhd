LIBRARY ieee;
USE work.ALL;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
Library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiStreamPkg.all;

entity crc_tb is end crc_tb;

-- Define architecture
architecture crc_tb of crc_tb is

   signal phyClk         : sl;
   signal phyClkRst      : sl;
   signal txCount        : slv(15 downto 0);
   signal phyTxd         : slv(63 downto 0);
   signal phyTxc         : slv(7  downto 0);
   signal phyReady       : sl;
   signal rxPauseReq     : sl;
   signal rxPauseSet     : sl;
   signal rxPauseValue   : slv(15 downto 0);
   signal interFrameGap  : slv(3  downto 0);
   signal pauseTime      : slv(15 downto 0);
   signal macAddress     : slv(47 downto 0);
   signal byteSwap       : sl;
   signal txCountEn      : sl;
   signal txUnderRun     : sl;
   signal txLinkNotReady : sl;
   signal dmaObMaster    : AxiStreamMasterType;
   signal dmaIbMaster    : AxiStreamMasterType;
   signal phyRxd         : slv(63 downto 0);
   signal phyRxc         : slv(7  downto 0);
   signal rxCountEn      : sl;
   signal rxOverFlow     : sl;
   signal rxCrcError     : sl;

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
               when x"0100" =>
                  dmaObMaster.tValid             <= '1';
                  dmaObMaster.tLast              <= '0';
                  dmaObMaster.tKeep              <= (others=>'1');
                  dmaObMaster.tData(63 downto 0) <= x"2222222211111111";  -- 8
               when x"0101" =>
                  dmaObMaster.tValid             <= '1';
                  dmaObMaster.tData(63 downto 0) <= x"4444444433333333";  -- 16
                  dmaObMaster.tLast              <= '1';
                  dmaObMaster.tKeep              <= (others=>'1');
     --          when x"0102" =>
     --             dmaObMaster.tValid             <= '1';
     --             dmaObMaster.tData(63 downto 0) <= x"6666666655555555";  -- 24
     --             dmaObMaster.tLast              <= '0';
     --             dmaObMaster.tKeep              <= (others=>'1');
     --          when x"0103" =>
     --             dmaObMaster.tValid             <= '1';
     --             dmaObMaster.tData(63 downto 0) <= x"8888888877777777"; -- 32
     --             dmaObMaster.tLast              <= '0';
     --             dmaObMaster.tKeep              <= (others=>'1');
     --          when x"0104" =>
     --             dmaObMaster.tValid             <= '1';
     --             dmaObMaster.tData(63 downto 0) <= x"AAAAAAAA99999999"; -- 40
     --             dmaObMaster.tLast              <= '0';
     --             dmaObMaster.tKeep              <= (others=>'1');
     --          when x"0105" =>
     --             dmaObMaster.tValid             <= '1';
     --             dmaObMaster.tData(63 downto 0) <= x"CCCCCCCCBBBBBBBB"; -- 48
     --             dmaObMaster.tLast              <= '0';
     --             dmaObMaster.tKeep              <= (others=>'1');
     --          when x"0106" =>
     --             dmaObMaster.tValid             <= '1';
     --             dmaObMaster.tData(63 downto 0) <= x"EEEEEEEEDDDDDDDD"; -- 56
     --             dmaObMaster.tLast              <= '0';
     --             dmaObMaster.tKeep              <= (others=>'1');
     --          when x"0107" =>
     --             dmaObMaster.tValid             <= '1';
     --             dmaObMaster.tData(63 downto 0) <= x"1111111100000000"; -- 64
     --             dmaObMaster.tLast              <= '1';
     --             --dmaObMaster.tKeep(7 downto 0)  <= "11111111";
     --             dmaObMaster.tKeep(7 downto 0)  <= "01111111";
     --             --dmaObMaster.tKeep(7 downto 0)  <= "00111111";
     --             --dmaObMaster.tKeep(7 downto 0)  <= "00011111";
     --             --dmaObMaster.tKeep(7 downto 0)  <= "00001111";
     --             --dmaObMaster.tKeep(7 downto 0)  <= "00000111";
     --             --dmaObMaster.tKeep(7 downto 0)  <= "00000011";
     --             --dmaObMaster.tKeep(7 downto 0)  <= "00000001";
               when others =>
                  dmaObMaster.tValid             <= '0';
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

   phyReady      <= '1';
   interFrameGap <= "0011";
   pauseTime     <= (others=>'1');
   macAddress    <= (others=>'0');
   byteSwap      <= '0';

   U_Export : entity work.XMacExport 
      generic map (
         TPD_G         => 1 ns,
         ADDR_WIDTH_G  => 9,
         VALID_THOLD_G => 255,
         AXIS_CONFIG_G => AXI_STREAM_CONFIG_INIT_C
      ) port map (
         dmaClk           => phyClk,
         dmaClkRst        => phyClkRst,
         dmaObMaster      => dmaObMaster,
         dmaObSlave       => open,
         phyClk           => phyClk,
         phyRst           => phyClkRst,
         phyTxd           => phyTxd,
         phyTxc           => phyTxc,
         phyReady         => phyReady,
         rxPauseReq       => rxPauseReq,
         rxPauseSet       => rxPauseSet,
         rxPauseValue     => rxPauseValue,
         interFrameGap    => interFrameGap,
         pauseTime        => pauseTime,
         macAddress       => macAddress,
         byteSwap         => byteSwap,
         txCountEn        => txCountEn,
         txUnderRun       => txUnderRun,
         txLinkNotReady   => txLinkNotReady
      );

   phyRxc <= phyTxc;
   phyRxd <= phyTxd;

   U_Import : entity work.XMacImport
      generic map (
         TPD_G         => 1 ns,
         PAUSE_THOLD_G => 255,
         ADDR_WIDTH_G  => 9,
         EOH_BIT_G     => 0,
         ERR_BIT_G     => 0,
         HEADER_SIZE_G => 16,
         AXIS_CONFIG_G => AXI_STREAM_CONFIG_INIT_C
      ) port map ( 
         dmaClk           => phyClk,
         dmaClkRst        => phyClkRst,
         dmaIbMaster      => dmaIbMaster,
         dmaIbSlave       => AXI_STREAM_SLAVE_FORCE_C,
         phyClk           => phyClk,
         phyRst           => phyClkRst,
         phyRxd           => phyRxd,
         phyRxc           => phyRxc,
         phyReady         => phyReady,
         macAddress       => macAddress,
         byteSwap         => byteSwap,
         rxPauseReq       => rxPauseReq,
         rxPauseSet       => rxPauseSet,
         rxPauseValue     => rxPauseValue,
         rxCountEn        => rxCountEn,
         rxOverFlow       => rxOverFlow,
         rxCrcError       => rxCrcError
      );

end crc_tb;

