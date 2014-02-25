-------------------------------------------------------------------------------
-- Title         : Clock/Trigger Sink Module For DPM
-- File          : DpmTimingSink.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/10/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock & Trigger sink module for COB
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 12/10/2013: created.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;
use work.ArmRceG3Pkg.all;

entity DpmTimingSink is
   generic (
      TPD_G        : time    := 1 ns
   );
   port (

      -- Local Bus
      axiClk                   : in  sl;
      axiClkRst                : in  sl;
      localBusMaster           : in  LocalBusMasterType;
      localBusSlave            : out LocalBusSlaveType;

      -- Reference Clock
      sysClk200                : in  sl;
      sysClk200Rst             : in  sl;

      -- Timing bus
      dpmClk                   : in  slv(2 downto 1);
      dpmFb                    : out sl;

      -- Clock output   
      sysClk                   : out sl;
      sysClkRst                : out sl;
      
      -- Opcode information, synchronous to sysClk
      timingCode               : out slv(7 downto 0);
      timingCodeEn             : out sl;

      -- Feedback information, synchronous to sysClk
      fbCode                   : in  slv(7 downto 0);
      fbCodeEn                 : in  sl;

      -- Debug
      led                      : out slv(1 downto 0)
   );
end DpmTimingSink;

architecture STRUCTURE of DpmTimingSink is

   -- Local Signals
   signal intClk              : sl;
   signal intClkRst           : sl;
   signal intReset            : sl;
   signal intCode             : slv(7 downto 0);
   signal intCodeEn           : sl;
   signal cfgReset            : sl;
   signal cfgSet              : sl;
   signal cfgDelay            : slv(4 downto 0);
   signal statusIdleCnt       : Slv(15 downto 0);
   signal statusErrorCnt      : Slv(15 downto 0);
   signal ocFifoWr            : sl;
   signal ocFifoWrEn          : sl;
   signal ocFifoRd            : sl;
   signal ocFifoValid         : sl;
   signal ocFifoData          : slv(7 downto 0);
   signal ledCountA           : slv(31 downto 0);
   signal ledCountB           : slv(31 downto 0);

begin

   -- Clock and reset out
   sysClk       <= intClk;
   sysClkRst    <= intClkRst;
   timingCode   <= intCode;
   timingCodeEn <= intCodeEn;

   ----------------------------------------
   -- Delay Control
   ----------------------------------------
   U_DlyCntrl : IDELAYCTRL
      port map (
         RDY    => open,        -- 1-bit output: Ready output
         REFCLK => sysClk200,   -- 1-bit input: Reference clock input
         RST    => sysClk200Rst -- 1-bit input: Active high reset input
      );


   ----------------------------------------
   -- Incoming global clock
   ----------------------------------------
   U_Bufg : BUFG
      port map (
         I => dpmClk(1),
         O => intClk
      );

   intReset <= axiClkRst or cfgReset;

   -- Reset gen
   U_RstGen : entity work.RstSync
      generic map (
         TPD_G            => TPD_G,
         IN_POLARITY_G    => '1',
         OUT_POLARITY_G   => '1',
         RELEASE_DELAY_G  => 16
      )
      port map (
        clk      => intClk,
        asyncRst => intReset,
        syncRst  => intClkRst
      );


   ----------------------------------------
   -- Incoming Sync Stream
   ----------------------------------------

   -- Input processor
   U_OpCodeSink : entity work.CobOpCodeSink8Bit 
      generic map (
         TPD_G => TPD_G
      ) port map (
         dpmClk          => dpmClk(2),
         sysClk          => intClk,
         sysClkRst       => intClkRst,
         timingCode      => intCode,
         timingCodeEn    => intCodeEn,
         configClk       => axiClk,
         configClkRst    => axiClkRst,
         configSet       => cfgSet,
         configDelay     => cfgDelay,
         statusIdleCnt   => statusIdleCnt,
         statusErrorCnt  => statusErrorCnt
      );

   -- Input FIFO
   U_OcFifo : entity work.FifoASync
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => false,  -- Use Dist Ram
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => 3,
         DATA_WIDTH_G   => 8,
         ADDR_WIDTH_G   => 6,
         INIT_G         => "0",
         FULL_THRES_G   => 63,
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => axiClkRst,
         wr_clk             => intClk,
         wr_en              => ocFifoWr,
         din                => intCode,
         wr_data_count      => open,
         wr_ack             => open,
         overflow           => open,
         prog_full          => open,
         almost_full        => open,
         full               => open,
         not_full           => open,
         rd_clk             => axiClk,
         rd_en              => ocFifoRd,
         dout               => ocFifoData,
         rd_data_count      => open,
         valid              => ocFifoValid,
         underflow          => open,
         prog_empty         => open,
         almost_empty       => open,
         empty              => open
      );

   -- Control writes
   ocFifoWr <= ocFifoWrEn and intCodeEn;


   ----------------------------------------
   -- Feedback Output
   ----------------------------------------

   -- Module
   U_FbSource : entity work.CobOpCodeSource8Bit
      generic map (
         TPD_G => TPD_G
      ) port map (
         sysClk          => intClk,
         sysClkRst       => intClkRst,
         timingCode      => fbCode,
         timingCodeEn    => fbCodeEn,
         dpmClk          => dpmFb
      );


   ----------------------------------------
   -- Local Registers
   ----------------------------------------

   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         localBusSlave    <= LocalBusSlaveInit after TPD_G;
         cfgReset         <= '0'               after TPD_G;
         cfgSet           <= '0'               after TPD_G;
         cfgDelay         <= (others=>'0')     after TPD_G;
         ocFifoRd         <= '0'               after TPD_G;
         ocFifoWrEn       <= '0'               after TPD_G;
      elsif rising_edge(axiClk) then

         -- Init
         localBusSlave.readValid <= localBusMaster.readEnable            after TPD_G;
         localBusSlave.readData  <= (others=>'0')                        after TPD_G;
         cfgReset                <= '0'                                  after TPD_G;
         cfgSet                  <= '0'                                  after TPD_G;
         cfgDelay                <= localBusMaster.writeData(4 downto 0) after TPD_G;
         ocFifoRd                <= '0'                                  after TPD_G;

         -- Master Reset
         if localBusMaster.addr(23 downto 0) = x"000000" then
            cfgReset <= localBusMaster.writeEnable after TPD_G;

         -- OC Fifo Write Enable
         elsif localBusMaster.addr(23 downto 0) = x"000004" then
            if localBusMaster.writeEnable = '1' then
               ocFifoWrEn <= localBusMaster.writeData(0) after TPD_G;
            end if;

         -- OC Delay configuration
         elsif localBusMaster.addr(23 downto 0) = x"000008" then
            cfgSet <= localBusMaster.writeEnable after TPD_G;

         -- OC FIFO status, one per FIFO
         elsif localBusMaster.addr(23 downto 0) = x"00000C" then
            localBusSlave.readData(31 downto 16) <= statusErrorCnt after TPD_G;
            localBusSlave.readData(15 downto  0) <= statusIdleCnt  after TPD_G;

         -- OC FIFO read, one per FIFO
         elsif localBusMaster.addr(23 downto 0) = x"000010" then
            ocFifoRd <= localBusMaster.readEnable after TPD_G;

            localBusSlave.readValid             <= ocFifoRd    after TPD_G;
            localBusSlave.readData(8)           <= ocFifoValid after TPD_G;
            localBusSlave.readData(7 downto  0) <= ocFifoData  after TPD_G;

         -- Clock Count
         elsif localBusMaster.addr(23 downto 0) = x"000014" then
            localBusSlave.readData <= ledCountA  after TPD_G;

         end if;

      end if;
   end process;



   ----------------------------------
   -- LED Blinking
   ----------------------------------
   process ( intClk, intClkRst ) begin
      if intClkRst = '1' then
         ledCountA <= (others=>'0') after TPD_G;
      elsif rising_edge(intClk) then
         ledCountA <= ledCountA + 1 after TPD_G;
      end if;
   end process;

   led(0) <= ledCountA(26);

   process ( intClk, intClkRst ) begin
      if intClkRst = '1' then
         ledCountB <= (others=>'0') after TPD_G;
         led(1)    <= '0'           after TPD_G;
      elsif rising_edge(intClk) then

         if intCodeEn = '1' then
            ledCountB <= (others=>'1') after TPD_G;
            led(1)    <= '0'           after TPD_G;
         elsif ledCountB /= 0 then
            ledCountB <= ledCountB - 1 after TPD_G;
            led(1)    <= '0'           after TPD_G;
         else
            led(1)    <= '1'           after TPD_G;
         end if;
      end if;
   end process;

end architecture STRUCTURE;

