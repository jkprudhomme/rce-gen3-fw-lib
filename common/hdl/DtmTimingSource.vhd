-------------------------------------------------------------------------------
-- Title         : Clock/Trigger Source Module For DTM
-- File          : DtmTimingSource.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 12/10/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock & Trigger source module for DTM
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

entity DtmTimingSource is
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

      -- Clock and reset
      sysClk                   : in  sl;
      sysClkRst                : in  sl;
      
      -- Opcode information
      timingCode               : in  slv(7 downto 0);
      timingCodeEn             : in  sl;

      -- Feedback information
      fbCode                   : out Slv8Array(7 downto 0);
      fbCodeEn                 : out slv(7 downto 0);

      -- Timing bus
      dpmClk                   : out slv(2 downto 0);
      dpmFb                    : in  slv(7 downto 0);

      -- Debug
      led                      : out slv(1 downto 0)
   );
end DtmTimingSource;

architecture STRUCTURE of DtmTimingSource is

   -- Local Signals
   signal ifbCode             : Slv8Array(7 downto 0);
   signal ifbCodeEn           : slv(7 downto 0);
   signal fbCfgSet            : slv(7 downto 0);
   signal fbCfgDelay          : slv(4 downto 0);
   signal fbStatusIdleCnt     : Slv16Array(7 downto 0);
   signal fbStatusErrorCnt    : Slv16Array(7 downto 0);
   signal cmdCode             : slv(7 downto 0);
   signal cmdCodeEn           : sl;
   signal cmdCodeEnDly        : sl;
   signal regCode             : slv(7 downto 0);
   signal regCodeEn           : sl;
   signal intCode             : slv(7 downto 0);
   signal intCodeEn           : sl;
   signal ocFifoWr            : sl;
   signal ocFifoWrEn          : sl;
   signal ocFifoRd            : sl;
   signal ocFifoValid         : sl;
   signal ocFifoData          : slv(7 downto 0);
   signal fbFifoWr            : slv(7 downto 0);
   signal fbFifoWrEn          : slv(7 downto 0);
   signal fbFifoRd            : slv(7 downto 0);
   signal fbFifoValid         : slv(7 downto 0);
   signal fbFifoData          : Slv8Array(7 downto 0);
   signal ledCountA           : slv(15 downto 0);
   signal ledCountB           : slv(15 downto 0);

begin

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
   -- Clock Outputs
   ----------------------------------------

   -- Clock output
   U_Clk0: ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',             -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC"           -- Reset Type ("ASYNC" or "SYNC")
      ) port map (
         Q  => dpmClk(0),  -- 1-bit DDR output
         C  => sysClk,     -- 1-bit clock input
         CE => '1',        -- 1-bit clock enable input
         D1 => '1',        -- 1-bit data input (positive edge)
         D2 => '0',        -- 1-bit data input (negative edge)
         R  => sysClkRst,  -- 1-bit reset input
         S  => '0'         -- 1-bit set input
      );

   -- Clock output
   U_Clk1: ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',             -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC"           -- Reset Type ("ASYNC" or "SYNC")
      ) port map (
         Q  => dpmClk(1),  -- 1-bit DDR output
         C  => sysClk,     -- 1-bit clock input
         CE => '1',        -- 1-bit clock enable input
         D1 => '1',        -- 1-bit data input (positive edge)
         D2 => '0',        -- 1-bit data input (negative edge)
         R  => sysClkRst,  -- 1-bit reset input
         S  => '0'         -- 1-bit set input
      );


   ----------------------------------------
   -- OpCode Output
   ----------------------------------------

   -- Select source
   process ( sysClk, sysClkRst ) begin
      if sysClkRst = '1' then
         intCodeEn <= '0'           after TPD_G;
         intCode   <= (others=>'0') after TPD_G;
      elsif rising_edge(sysClk) then

         if timingCodeEn = '1' then
            intCodeEn <= '1'        after TPD_G;
            intCode   <= timingCode after TPD_G;

         elsif regCodeEn = '1' then
            intCodeEn <= '1'     after TPD_G;
            intCode   <= regCode after TPD_G;

         else
            intCodeEn <= '0'           after TPD_G;
            intCode   <= (others=>'0') after TPD_G;
         end if;
      end if;
   end process;

   -- Module
   U_OpCodeSource : entity work.CobOpCodeSource 
      generic map (
         TPD_G => TPD_G
      ) port map (
         sysClk          => sysClk,
         sysClkRst       => sysClkRst,
         timingCode      => intCode,
         timingCodeEn    => intCodeEn,
         dpmClk          => dpmClk(2)
      );

   -- OpCode FIFO
   U_OcFifo : entity work.FifoASync
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         BRAM_EN_G      => false,  -- Use Dist Ram
         FWFT_EN_G      => true,
         USE_DSP48_G    => "no",
         ALTERA_SYN_G   => false,
         ALTERA_RAM_G   => "M9K",
         SYNC_STAGES_G  => 2,
         DATA_WIDTH_G   => 8,
         ADDR_WIDTH_G   => 6,
         INIT_G         => "0",
         FULL_THRES_G   => 63,
         EMPTY_THRES_G  => 1
      ) port map (
         rst                => axiClkRst,
         wr_clk             => sysClk,
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
   -- Feedback Inputs
   ----------------------------------------
   U_FbGen : for i in 0 to 7 generate

      -- Input processor
      U_OpCodeSink : entity work.CobOpCodeSink
         generic map (
            TPD_G => TPD_G
         ) port map (
            dpmClk          => dpmFb(i),
            sysClk          => sysClk,
            sysClkRst       => sysClkRst,
            timingCode      => ifbCode(i),
            timingCodeEn    => ifbCodeEn(i),
            configClk       => axiClk,
            configClkRst    => axiClkRst,
            configSet       => fbCfgSet(i),
            configDelay     => fbCfgDelay,
            statusIdleCnt   => fbStatusIdleCnt(i),
            statusErrorCnt  => fbStatusErrorCnt(i)
         );

      -- Input FIFO
      U_FbFifo : entity work.FifoASync
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            BRAM_EN_G      => false,  -- Use Dist Ram
            FWFT_EN_G      => true,
            USE_DSP48_G    => "no",
            ALTERA_SYN_G   => false,
            ALTERA_RAM_G   => "M9K",
            SYNC_STAGES_G  => 2,
            DATA_WIDTH_G   => 8,
            ADDR_WIDTH_G   => 6,
            INIT_G         => "0",
            FULL_THRES_G   => 63,
            EMPTY_THRES_G  => 1
         ) port map (
            rst                => axiClkRst,
            wr_clk             => sysClk,
            wr_en              => fbFifoWr(i),
            din                => ifbCode(i),
            wr_data_count      => open,
            wr_ack             => open,
            overflow           => open,
            prog_full          => open,
            almost_full        => open,
            full               => open,
            not_full           => open,
            rd_clk             => axiClk,
            rd_en              => fbFifoRd(i),
            dout               => fbFifoData(i),
            rd_data_count      => open,
            valid              => fbFifoValid(i),
            underflow          => open,
            prog_empty         => open,
            almost_empty       => open,
            empty              => open
         );

      -- Control writes
      fbFifoWr(i) <= fbFifoWrEn(i) and ifbCodeEn(i);

   end generate;

   -- Outputs
   fbCode   <= ifbCode;
   fbCodeEn <= ifbCodeEn;


   ----------------------------------------
   -- Local Registers
   ----------------------------------------

   process ( axiClk, axiClkRst ) begin
      if axiClkRst = '1' then
         localBusSlave    <= LocalBusSlaveInit after TPD_G;
         fbCfgSet         <= (others=>'0')     after TPD_G;
         fbCfgDelay       <= (others=>'0')     after TPD_G;
         cmdCode          <= (others=>'0')     after TPD_G;
         cmdCodeEn        <= '0'               after TPD_G;
         cmdCodeEnDly     <= '0'               after TPD_G;
         ocFifoRd         <= '0'               after TPD_G;
         fbFifoRd         <= (others=>'0')     after TPD_G;
         fbFifoWrEn       <= (others=>'0')     after TPD_G;
         ocFifoWrEn       <= '0'               after TPD_G;
      elsif rising_edge(axiClk) then

         -- Init
         localBusSlave.readValid <= localBusMaster.readEnable            after TPD_G;
         localBusSlave.readData  <= (others=>'0')                        after TPD_G;
         fbCfgSet                <= (others=>'0')                        after TPD_G;
         fbCfgDelay              <= localBusMaster.writeData(4 downto 0) after TPD_G;
         cmdCodeEn               <= '0'                                  after TPD_G;
         ocFifoRd                <= '0'                                  after TPD_G;
         fbFifoRd                <= (others=>'0')                        after TPD_G;

         -- FB Fifo Write Enable, one per FIFO
         if localBusMaster.addr(23 downto 0) = x"000000" then
            if localBusMaster.writeEnable = '1' then
               fbFifoWrEn <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;

         -- FB Delay configuration, one per FIFO
         elsif localBusMaster.addr(23 downto 8) = x"0001" then
            fbCfgSet(conv_integer(localBusMaster.addr(5 downto 2))) <= localBusMaster.writeEnable after TPD_G;

         -- FB FIFO status, one per FIFO
         elsif localBusMaster.addr(23 downto 8) = x"0002" then
            localBusSlave.readData(31 downto 16) <= fbStatusErrorCnt(conv_integer(localBusMaster.addr(5 downto 2))) after TPD_G;
            localBusSlave.readData(15 downto  0) <= fbStatusIdleCnt(conv_integer(localBusMaster.addr(5 downto 2)))  after TPD_G;

         -- FB FIFO read, one per FIFO
         elsif localBusMaster.addr(23 downto 8) = x"0003" then
            fbFifoRd(conv_integer(localBusMaster.addr(5 downto 2))) <= localBusMaster.readEnable after TPD_G;

            localBusSlave.readValid             <= fbFifoRd(conv_integer(localBusMaster.addr(5 downto 2)))    after TPD_G;
            localBusSlave.readData(8)           <= fbFifoValid(conv_integer(localBusMaster.addr(5 downto 2))) after TPD_G;
            localBusSlave.readData(7 downto  0) <= fbFifoData(conv_integer(localBusMaster.addr(5 downto 2)))  after TPD_G;

         -- OC Opcode Generation
         elsif localBusMaster.addr(23 downto 8) = x"0004" then
            cmdCodeEn <= localBusMaster.writeEnable after TPD_G;

            if localBusMaster.writeEnable = '1' then
               cmdCode <= localBusMaster.writeData(7 downto 0) after TPD_G;
            end if;

         -- OC FIFO read
         elsif localBusMaster.addr(23 downto 0) = x"000404" then
            ocFifoRd                            <= localBusMaster.readEnable after TPD_G;
            localBusSlave.readValid             <= ocFifoRd                  after TPD_G;
            localBusSlave.readData(8)           <= ocFifoValid               after TPD_G;
            localBusSlave.readData(7 downto  0) <= ocFifoData                after TPD_G;

         -- OC Fifo Enable
         elsif localBusMaster.addr(23 downto 0) = x"000408" then
            localBusSlave.readData(0) <= ocFifoWrEn after TPD_G;

            if localBusMaster.writeEnable = '1' then
               ocFifoWrEn <= localBusMaster.writeData(0) after TPD_G;
            end if;

         end if;

         -- Command code delay
         cmdCodeEnDly <= cmdCodeEn after TPD_G;
      end if;
   end process;

   -- Command code synchronizer
   U_CmdSync : entity work.SynchronizerVector 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2, 
         WIDTH_G        => 9,
         INIT_G         => "0"
      ) port map (
         clk                 => sysClk,
         rst                 => sysClkRst,
         dataIn(8)           => cmdCodeEnDly,
         dataIn(7 downto 0)  => cmdCode,
         dataOut(8)          => regCodeEn,
         dataOut(7 downto 0) => regCode
      );


    ----------------------------------
    -- LED Blinking
    ----------------------------------
   process ( sysClk, sysClkRst ) begin
      if axiClkRst = '1' then
         ledCountA <= (others=>'0') after TPD_G;
      elsif rising_edge(sysClk) then
         ledCountA <= ledCountA + 1 after TPD_G;
      end if;
   end process;

   led(0) <= ledCountA(15);

   process ( sysClk, sysClkRst ) begin
      if axiClkRst = '1' then
         ledCountB <= (others=>'0') after TPD_G;
         led(1)    <= '0'           after TPD_G;
      elsif rising_edge(sysClk) then

         if intCodeEn = '1' then
            ledCountB <= (others=>'0') after TPD_G;
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

