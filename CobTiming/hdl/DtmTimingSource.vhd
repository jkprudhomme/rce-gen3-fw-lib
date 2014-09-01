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
use work.AxiLitePkg.all;

entity DtmTimingSource is
   generic (
      TPD_G           : time   := 1 ns;
      IODELAY_GROUP_G : string := "DtmTimingGrp"
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

      -- Distributed Clock and reset
      distClk                  : in  sl;
      distClkRst               : in  sl;
      
      -- Opcode information
      timingCode               : in  slv(7 downto 0);
      timingCodeEn             : in  sl;
      timingCodeReady          : out sl;

      -- Feedback information
      fbCode                   : out Slv8Array(7 downto 0);
      fbCodeEn                 : out slv(7 downto 0);

      -- COB Timing bus
      dpmClkP                  : out slv(2  downto 0);
      dpmClkM                  : out slv(2  downto 0);
      dpmFbP                   : in  slv(7  downto 0);
      dpmFbM                   : in  slv(7  downto 0);

      -- Optional LED Debug
      led                      : out slv(1 downto 0)
   );
end DtmTimingSource;

architecture STRUCTURE of DtmTimingSource is

   -- Local Signals
   signal ifbCode             : Slv8Array(7 downto 0);
   signal ifbCodeEn           : slv(7 downto 0);
   signal fbStatusIdleCnt     : Slv16Array(7 downto 0);
   signal fbStatusErrorCnt    : Slv16Array(7 downto 0);
   signal regCode             : slv(7 downto 0);
   signal regCodeEn           : sl;
   signal intCode             : slv(7 downto 0);
   signal intCodeEn           : sl;
   signal ocFifoWr            : sl;
   signal ocFifoValid         : sl;
   signal ocFifoData          : slv(7 downto 0);
   signal fbFifoWr            : slv(7 downto 0);
   signal fbFifoValid         : slv(7 downto 0);
   signal fbFifoData          : Slv8Array(7 downto 0);
   signal ledCountA           : slv(31 downto 0);
   signal ledCountB           : slv(15 downto 0);
   signal dpmClk              : slv(2 downto 0);
   signal dpmFb               : slv(7 downto 0);
   signal fbFifoRd            : slv(7 downto 0);
   signal ocFifoRd            : sl;

   type RegType is record
      fbCfgSet          : slv(7 downto 0);
      fbCfgDelay        : Slv5Array(7 downto 0);
      cmdCode           : slv(7 downto 0);
      cmdCodeEn         : sl;
      ocFifoRd          : sl;
      fbFifoRd          : slv(7 downto 0);
      fbFifoWrEn        : slv(7 downto 0);
      ocFifoWrEn        : sl;
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      fbCfgSet          => (others=>'0'),
      fbCfgDelay        => (others=>(others=>'0')),
      cmdCode           => (others=>'0'),
      cmdCodeEn         => '0',
      ocFifoRd          => '0',
      fbFifoRd          => (others=>'0'),
      fbFifoWrEn        => (others=>'0'),
      ocFifoWrEn        => '0',
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute IODELAY_GROUP               : string;
   attribute IODELAY_GROUP of U_DlyCntrl : label is IODELAY_GROUP_G;   

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
   
   -- Clock outputs
   U_ClkOut : for i in 0 to 1 generate

      U_ClkGen: ODDR
         generic map(
            DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
            INIT         => '0',             -- Initial value for Q port ('1' or '0')
            SRTYPE       => "SYNC"           -- Reset Type ("ASYNC" or "SYNC")
         ) port map (
            Q  => dpmClk(i),  -- 1-bit DDR output
            C  => distClk,    -- 1-bit clock input
            CE => '1',        -- 1-bit clock enable input
            D1 => '1',        -- 1-bit data input (positive edge)
            D2 => '0',        -- 1-bit data input (negative edge)
            R  => distClkRst, -- 1-bit reset input
            S  => '0'         -- 1-bit set input
         );

      U_DpmClkOut : OBUFDS
         port map(
            O      => dpmClkP(i),
            OB     => dpmClkM(i),
            I      => dpmClk(i)
         );

   end generate;


   ----------------------------------------
   -- OpCode Output
   ----------------------------------------

   -- Select source
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            intCodeEn <= '0'           after TPD_G;
            intCode   <= (others=>'0') after TPD_G;

         elsif timingCodeEn = '1' then
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
   U_OpCodeSource : entity work.CobOpCodeSource8Bit 
      generic map (
         TPD_G => TPD_G
      ) port map (
         distClk         => distClk,
         distClkRst      => distClkRst,
         timingCode      => intCode,
         timingCodeEn    => intCodeEn,
         timingCodeReady => timingCodeReady,
         serialCode      => dpmClk(2)
      );

   U_OpCodeClkBuf : OBUFDS
      port map(
         O      => dpmClkP(2),
         OB     => dpmClkM(2),
         I      => dpmClk(2)
      );


   -- OpCode FIFO
   U_OcFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => false, -- Async
         BRAM_EN_G       => false, -- Use dist ram
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         USE_BUILT_IN_G  => false,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 8,
         ADDR_WIDTH_G    => 6,
         INIT_G          => "0",
         FULL_THRES_G    => 63,
         EMPTY_THRES_G   => 1
      ) port map (
         rst                => axiClkRst,
         wr_clk             => distClk,
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
   -- Feedback Inputs
   ----------------------------------------
   U_FbGen : for i in 0 to 7 generate

      -- IO Pin
      U_DpmFbBuf : IBUFDS
         port map(
            I      => dpmFbP(i),
            IB     => dpmFbM(i),
            O      => dpmFb(i)
         );

      -- Input processor
      U_OpCodeSink : entity work.CobOpCodeSink8Bit
         generic map (
            TPD_G           => TPD_G,
            IODELAY_GROUP_G => IODELAY_GROUP_G
         ) port map (
            serialCode      => dpmFb(i),
            distClk         => distClk,
            distClkRst      => distClkRst,
            timingCode      => ifbCode(i),
            timingCodeEn    => ifbCodeEn(i),
            configClk       => axiClk,
            configClkRst    => axiClkRst,
            configSet       => r.fbCfgSet(i),
            configDelay     => r.fbCfgDelay(i),
            statusIdleCnt   => fbStatusIdleCnt(i),
            statusErrorCnt  => fbStatusErrorCnt(i)
         );

      -- Input FIFO
      U_FbFifo : entity work.Fifo
         generic map (
            TPD_G           => TPD_G,
            RST_POLARITY_G  => '1',
            RST_ASYNC_G     => false,
            GEN_SYNC_FIFO_G => false, -- Async
            BRAM_EN_G       => false, -- Use Dist Ram
            FWFT_EN_G       => true,
            USE_DSP48_G     => "no",
            USE_BUILT_IN_G  => false,
            XIL_DEVICE_G    => "7SERIES",
            SYNC_STAGES_G   => 3,
            DATA_WIDTH_G    => 8,
            ADDR_WIDTH_G    => 6,
            INIT_G          => "0",
            FULL_THRES_G    => 63,
            EMPTY_THRES_G   => 1
         ) port map (
            rst                => axiClkRst,
            wr_clk             => distClk,
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
      fbFifoWr(i) <= r.fbFifoWrEn(i) and ifbCodeEn(i);

   end generate;

   -- Outputs
   fbCode   <= ifbCode;
   fbCodeEn <= ifbCodeEn;


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
   process (axiClkRst, axiReadMaster, axiWriteMaster, r, fbStatusErrorCnt, fbStatusIdleCnt, 
            fbFifoValid, fbFifoData, ocFifoValid, ocFifoData, ledCountA) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.fbCfgSet   := (others=>'0');
      v.cmdCodeEn  := '0';
      v.ocFifoRd   := '0';
      v.fbFifoRd   := (others=>'0');

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- FB Fifo Write Enable, one per FIFO
         if axiWriteMaster.awaddr(11 downto 0)  = x"000" then
            v.fbFifoWrEn := axiWriteMaster.wdata(7 downto 0);

         -- FB Delay configuration, one per FIFO
         elsif axiWriteMaster.awaddr(11 downto 8)  = x"1" then
            v.fbCfgSet(conv_integer(axiWriteMaster.awaddr(5 downto 2)))   := '1';
            v.fbCfgDelay(conv_integer(axiWriteMaster.awaddr(5 downto 2))) := axiWriteMaster.wdata(4 downto 0);

         -- OC Opcode Generation
         elsif axiWriteMaster.awaddr(11 downto 0)  = x"400" then
            v.cmdCodeEn := '1';
            v.cmdCode   := axiWriteMaster.wdata(7 downto 0);

         -- OC Fifo Enable
         elsif axiWriteMaster.awaddr(11 downto 0)  = x"408" then
            v.ocFifoWrEn := axiWriteMaster.wdata(0);
         end if;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- FB Fifo Write Enable, one per FIFO
         if axiReadMaster.araddr(11 downto 0)  = x"000" then
            v.axiReadSlave.rdata(7 downto 0) := r.fbFifoWrEn;

         -- FB Delay configuration, one per FIFO
         elsif axiReadMaster.araddr(11 downto 8)  = x"1" then
            v.axiReadSlave.rdata(4 downto 0) := r.fbCfgDelay(conv_integer(axiReadMaster.araddr(5 downto 2)));

         -- Feedback FIFO read
         elsif axiReadMaster.araddr(11 downto 8)  = x"2" then
            v.axiReadSlave.rdata(31 downto 16) := fbStatusErrorCnt(conv_integer(axiReadMaster.araddr(5 downto 2)));
            v.axiReadSlave.rdata(15 downto  0) := fbStatusIdleCnt(conv_integer(axiReadMaster.araddr(5 downto 2)));

         -- FB FIFO read, one per FIFO
         elsif axiReadMaster.araddr(11 downto 8)  = x"3" then
            v.fbFifoRd(conv_integer(axiReadMaster.araddr(5 downto 2))) := fbFifoValid(conv_integer(axiReadMaster.araddr(5 downto 2)));

            v.axiReadSlave.rdata(8)           := fbFifoValid(conv_integer(axiReadMaster.araddr(5 downto 2)));
            v.axiReadSlave.rdata(7 downto  0) := fbFifoData(conv_integer(axiReadMaster.araddr(5 downto 2)));

         -- OC FIFO read
         elsif axiReadMaster.araddr(11 downto 0)  = x"404" then
            v.ocFifoRd                        := ocFifoValid;
            v.axiReadSlave.rdata(8)           := ocFifoValid;
            v.axiReadSlave.rdata(7 downto  0) := ocFifoData;

         -- OC Fifo Enable
         elsif axiReadMaster.araddr(11 downto 0)  = x"408" then
            v.axiReadSlave.rdata(0) := r.ocFifoWrEn;

         -- Debug counter
         elsif axiReadMaster.araddr(11 downto 0)  = x"40C" then
            v.axiReadSlave.rdata := ledCountA;
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
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
      fbFifoRd      <= r.fbFifoRd;
      ocFifoRd      <= r.ocFifoRd;
      
   end process;

   -- Command code synchronizer
   U_CmdDataSync : entity work.SynchronizerVector 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2, 
         WIDTH_G        => 8,
         INIT_G         => "0"
      ) port map (
         clk     => distClk,
         rst     => distClkRst,
         dataIn  => r.cmdCode,
         dataOut => regCode
      );

   U_CmdSync : entity work.SynchronizerEdge 
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 3,
         INIT_G         => "0"
      ) port map (
         clk         => distClk,
         rst         => distClkRst,
         dataIn      => r.cmdCodeEn,
         dataOut     => open,
         risingEdge  => regCodeEn,
         fallingEdge => open
      );


   ----------------------------------
   -- LED Blinking
   ----------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            ledCountA <= (others=>'0') after TPD_G;
            ledCountB <= (others=>'0') after TPD_G;
         else
            ledCountA <= ledCountA + 1 after TPD_G;

            if intCodeEn = '1' then
               ledCountB <= ledCountB + 1 after TPD_G;
            end if;
         end if;
      end if;
   end process;

   led(0) <= ledCountA(26);
   led(1) <= ledCountB(15);

end architecture STRUCTURE;

