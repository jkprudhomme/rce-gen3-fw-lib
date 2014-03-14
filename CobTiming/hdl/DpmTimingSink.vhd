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
use work.AxiLitePkg.all;

entity DpmTimingSink is
   generic (
      TPD_G        : time    := 1 ns
   );
   port (

      -- Local Bus
      axiClk                   : in  sl;
      axiClkRst                : in  sl;
      axiReadMaster            : in  AxiLiteReadMasterType;
      axiReadSlave             : out AxiLiteReadSlaveType;
      axiWriteMaster           : in  AxiLiteWriteMasterType;
      axiWriteSlave            : out AxiLiteWriteSlaveType;

      -- Reference Clock
      sysClk200                : in  sl;
      sysClk200Rst             : in  sl;

      -- Timing bus
      dtmClkP                  : in    slv(1 downto 0);
      dtmClkM                  : in    slv(1 downto 0);
      dtmFbP                   : out   sl;
      dtmFbM                   : out   sl;

      -- Clock output   
      distClk                  : out sl;
      distClkRst               : out sl;
      
      -- Opcode information, synchronous to distClk
      timingCode               : out slv(7 downto 0);
      timingCodeEn             : out sl;

      -- Feedback information, synchronous to distClk
      fbCode                   : in  slv(7 downto 0);
      fbCodeEn                 : in  sl;

      -- Debug
      led                      : out slv(1 downto 0)
   );
end DpmTimingSink;

architecture STRUCTURE of DpmTimingSink is

   -- Local Signals
   signal dtmClk              : slv(1 downto 0);
   signal dtmFb               : sl;
   signal intClk              : sl;
   signal intClkRst           : sl;
   signal intReset            : sl;
   signal intCode             : slv(7 downto 0);
   signal intCodeEn           : sl;
   signal statusIdleCnt       : Slv(15 downto 0);
   signal statusErrorCnt      : Slv(15 downto 0);
   signal ocFifoWr            : sl;
   signal ocFifoValid         : sl;
   signal ocFifoData          : slv(7 downto 0);
   signal ledCountA           : slv(31 downto 0);
   signal ledCountB           : slv(31 downto 0);
   signal ocFifoRd            : sl;
   signal axiClkRstInt        : sl := '1';

   type RegType is record
      cfgReset          : sl;
      cfgSet            : sl;
      cfgDelay          : slv(4 downto 0);
      ocFifoRd          : sl;
      ocFifoWrEn        : sl;
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      cfgReset         => '0',
      cfgSet           => '0',
      cfgDelay         => (others=>'0'),
      ocFifoRd         => '0',
      ocFifoWrEn       => '0',
      axiReadSlave     => AXI_READ_SLAVE_INIT_C,
      axiWriteSlave    => AXI_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal is "true";

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- Clock and reset out
   distClk      <= intClk;
   distClkRst   <= intClkRst;
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

   -- DTM Clock 0
   U_DtmClk0 : IBUFDS 
      generic map ( DIFF_TERM => true ) 
      port map ( 
         I  => dtmClkP(0),
         IB => dtmClkM(0),
         O  => dtmClk(0)
      );

   U_Bufg : BUFG
      port map (
         I => dtmClk(0),
         O => intClk
      );

   intReset <= axiClkRstInt or r.cfgReset;

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

   -- DTM Clock 1
   U_DtmClk1 : IBUFDS 
      generic map ( DIFF_TERM => true ) 
      port map ( 
         I  => dtmClkP(1),
         IB => dtmClkM(1),
         O  => dtmClk(1)
      );

   -- Input processor
   U_OpCodeSink : entity work.CobOpCodeSink8Bit 
      generic map (
         TPD_G => TPD_G
      ) port map (
         serialCode      => dtmClk(1),
         distClk         => intClk,
         distClkRst      => intClkRst,
         timingCode      => intCode,
         timingCodeEn    => intCodeEn,
         configClk       => axiClk,
         configClkRst    => axiClkRstInt,
         configSet       => r.cfgSet,
         configDelay     => r.cfgDelay,
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
         rst                => axiClkRstInt,
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
   ocFifoWr <= r.ocFifoWrEn and intCodeEn;


   ----------------------------------------
   -- Feedback Output
   ----------------------------------------

   -- Module
   U_FbSource : entity work.CobOpCodeSource8Bit
      generic map (
         TPD_G => TPD_G
      ) port map (
         distClk         => intClk,
         distClkRst      => intClkRst,
         timingCode      => fbCode,
         timingCodeEn    => fbCodeEn,
         serialCode      => dtmFb
      );

   -- DTM Feedback
   U_DtmFb : OBUFDS 
      port map ( 
         O  => dtmFbP,     
         OB => dtmFbM,     
         I  => dtmFb     
      );

   ----------------------------------------
   -- Local Registers
   ----------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRst, axiReadMaster, axiWriteMaster, r, statusErrorCnt, statusIdleCnt, ocFifoValid, ocFifoData ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      v.cfgReset  := '0';
      v.cfgSet    := '0';
      v.cfgDelay  := axiWriteMaster.wdata(4 downto 0);
      v.ocFifoRd  := '0';

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Master Reset
         if axiWriteMaster.awaddr(11 downto 0) = x"000" then
            v.cfgReset := '1';

         -- OC Fifo Write Enable
         elsif axiWriteMaster.awaddr(11 downto 0) = x"004" then
            v.ocFifoWrEn := axiWriteMaster.wdata(0);

         -- OC Delay configuration
         elsif axiWriteMaster.awaddr(11 downto 0) = x"008" then
            v.cfgSet := '1';
         end if;

         -- Send Axi response
         axiSlaveWriteResponse(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- OC FIFO status
         if axiWriteMaster.awaddr(11 downto 0) = x"00C" then
            v.axiReadSlave.rdata(31 downto 16) := statusErrorCnt;
            v.axiReadSlave.rdata(15 downto 0)  := statusIdleCnt;

         -- OC FIFO read, one per FIFO
         elsif axiWriteMaster.awaddr(11 downto 0) = x"010" then
            v.ocFifoRd := '1';

            v.axiReadSlave.rdata(8)           := ocFifoValid;
            v.axiReadSlave.rdata(7 downto 0)  := ocFifoData;

         -- Clock Count
         elsif axiWriteMaster.awaddr(11 downto 0) = x"014" then
            v.axiReadSlave.rdata := ledCountA;
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
      ocFifoRd      <= v.ocFifoRd;
      
   end process;


   ----------------------------------
   -- LED Blinking
   ----------------------------------
   process ( intClk ) begin
      if rising_edge(intClk) then
         if intClkRst = '1' then
            ledCountA <= (others=>'0') after TPD_G;
         else
            ledCountA <= ledCountA + 1 after TPD_G;
         end if;
      end if;
   end process;

   led(0) <= ledCountA(26);

   process ( intClk ) begin
      if rising_edge(intClk) then
         if intClkRst = '1' then
            ledCountB <= (others=>'0') after TPD_G;
            led(1)    <= '1'           after TPD_G;
         elsif intCodeEn = '1' then
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

