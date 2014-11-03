-------------------------------------------------------------------------------
-- Title      : PPI Socket
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiSocket.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Socket wrapper for protocol plug in.
--
-- Base + 0x00000 :
--    Bit 0 : PPI Online Bit
--    Bit 1 : PPI User   Bit
-- Base + 0x0000C :
--    Bit 0 : Count reset (auto clear)
-- Base + 0x00010 :
--    Bit 7:0 : Outbound header AXI error count
-- Base + 0x00014 :
--    Bit 7:0 : Outbound payload AXI error count
-- Base + 0x00018 :
--    Bit 7:0 : Inbound header AXI error count
-- Base + 0x0001C :
--    Bit 7:0 : Inbound payload AXI error count
-- Base + 0x10000 :
--    Bit 31:0 : Outbound free list read
-- Base + 0x10004 :
--    Bit 31:0 : Inbound pending list read
-- Base + 0x10200 :
--    Bit 31:0 : Outbound work list write
-- Base + 0x10240 :
--    Bit 31:0 : Inbound work list write
--
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/27/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.RceG3Pkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiDmaPkg.all;
use work.PpiPkg.all;

entity PpiSocket is
   generic (
      TPD_G     : time    := 1 ns;
      CHAN_ID_G : integer := 0
   );
   port (

      -- Clock/Reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- Local AXI Lite Bus
      axilReadMaster  : in  AxiLiteReadMasterArray(1 downto 0);
      axilReadSlave   : out AxiLiteReadSlaveArray(1 downto 0);
      axilWriteMaster : in  AxiLiteWriteMasterArray(1 downto 0);
      axilWriteSlave  : out AxiLiteWriteSlaveArray(1 downto 0);

      -- AXI ACP Slave
      acpReadMaster   : out AxiReadMasterArray(1 downto 0);
      acpReadSlave    : in  AxiReadSlaveArray(1 downto 0);
      acpWriteMaster  : out AxiWriteMasterType;
      acpWriteSlave   : in  AxiWriteSlaveType;

      -- AXI HP Slave
      hpReadMaster    : out AxiReadMasterType;
      hpReadSlave     : in  AxiReadSlaveType;
      hpWriteMaster   : out AxiWriteMasterType;
      hpWriteSlave    : in  AxiWriteSlaveType;

      -- Completion
      compValid       : out slv(1 downto 0);
      compSel         : out SlV32Array(1 downto 0);
      compDin         : out Slv31Array(1 downto 0);
      compRead        : in  slv(1 downto 0);

      -- Interrupts
      ibPendValid     : out sl;
      ibWorkAFull     : out sl;
      obFreeAEmpty    : out sl;
      obWorkAFull     : out sl;

      -- External interface
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      dmaState        : out RceDmaStateType;
      dmaIbMaster     : in  AxiStreamMasterType;
      dmaIbSlave      : out AxiStreamSlaveType;
      dmaObMaster     : out AxiStreamMasterType;
      dmaObSlave      : in  AxiStreamSlaveType
   );
end PpiSocket;

architecture structure of PpiSocket is

   constant POP_FIFO_COUNT_C  : integer := 2;
   constant PUSH_FIFO_COUNT_C : integer := 2;
   constant COUNT_WIDTH_C     : integer := 8;

   signal payIbMaster         : AxiStreamMasterType;
   signal payIbSlave          : AxiStreamSlaveType;
   signal headIbMaster        : AxiStreamMasterType;
   signal headIbSlave         : AxiStreamSlaveType;
   signal obHeadAxiError      : sl;
   signal obPayAxiError       : sl;
   signal ibHeadAxiError      : sl;
   signal ibPayAxiError       : sl;
   signal obPendMaster        : AxiStreamMasterType;
   signal obPendSlave         : AxiStreamSlaveType;
   signal popFifoValid        : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal popFifoAEmpty       : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal pushFifoAFull       : slv(PUSH_FIFO_COUNT_C-1 downto 0);
   signal popFifoClk          : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal popFifoRst          : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal popFifoWrite        : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal popFifoDin          : Slv32Array(POP_FIFO_COUNT_C-1 downto 0);
   signal popFifoFull         : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal popFifoAFull        : slv(POP_FIFO_COUNT_C-1 downto 0);
   signal pushFifoClk         : slv(PUSH_FIFO_COUNT_C-1 downto 0);
   signal pushFifoRst         : slv(PUSH_FIFO_COUNT_C-1 downto 0);
   signal pushFifoValid       : slv(PUSH_FIFO_COUNT_C-1 downto 0);
   signal pushFifoDout        : Slv36Array(PUSH_FIFO_COUNT_C-1 downto 0);
   signal pushFifoRead        : slv(PUSH_FIFO_COUNT_C-1 downto 0);
   signal ibFreeWrite         : sl;
   signal ibFreeDin           : slv(17 downto 4);
   signal ibFreeAFull         : sl;
   signal counters            : SlVectorArray(3 downto 0, COUNT_WIDTH_C-1 downto 0);
   signal debug               : Slv32Array(8 downto 0);

   type RegType is record
      dmaState       : RceDmaStateType;
      countReset     : sl;
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      dmaState       => RCE_DMA_STATE_INIT_C,
      countReset     => '0',
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute dont_touch : string;
   attribute dont_touch of debug : signal is "true";

   COMPONENT ppi_debug
     PORT (
       clk : IN STD_LOGIC;
       probe0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe6 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       probe8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
     );
   END COMPONENT;
   ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
   ATTRIBUTE SYN_BLACK_BOX OF ppi_debug : COMPONENT IS TRUE;
   ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
   ATTRIBUTE BLACK_BOX_PAD_PIN OF ppi_debug : COMPONENT IS "clk,probe0[31:0],probe1[31:0],probe2[31:0],probe3[31:0],probe4[31:0],probe5[31:0],probe6[31:0],probe7[31:0],probe8[31:0]";

begin

   ---------------------------------------
   -- Local Registers
   ---------------------------------------
   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, axiRst, axilReadMaster, axilWriteMaster, counters, debug ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.countReset := '0';

      axiSlaveWaitTxn(axilWriteMaster(0), axilReadMaster(0), v.axilWriteSlave, v.axilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         case axilWriteMaster(0).awaddr(7 downto 0) is
            when x"00" =>
               v.dmaState.online := axilWriteMaster(0).wdata(0);
               v.dmaState.user   := axilWriteMaster(0).wdata(1);
            when x"0C" =>
               v.countReset := axilWriteMaster(0).wdata(0);
            when others =>
               null;
         end case;

         axiSlaveWriteResponse(v.axilWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axilReadSlave.rdata := (others=>'0');

         if axilReadMaster(0).araddr(7) = '1' then
            v.axilReadSlave.rdata := debug(conv_integer(axilReadMaster(0).araddr(5 downto 2)));
         else 
            case axilReadMaster(0).araddr(7 downto 0) is
               when x"00" =>
                  v.axilReadSlave.rdata(0) := r.dmaState.online;
                  v.axilReadSlave.rdata(1) := r.dmaState.user;
               when x"10" =>
                  v.axilReadSlave.rdata(COUNT_WIDTH_C-1 downto 0) := muxSlVectorArray (counters, 0); -- obHeadAxiError
               when x"14" =>
                  v.axilReadSlave.rdata(COUNT_WIDTH_C-1 downto 0) := muxSlVectorArray (counters, 1); -- obPayAxiError
               when x"18" =>
                  v.axilReadSlave.rdata(COUNT_WIDTH_C-1 downto 0) := muxSlVectorArray (counters, 2); -- ibHeadAxiError
               when x"1C" =>
                  v.axilReadSlave.rdata(COUNT_WIDTH_C-1 downto 0) := muxSlVectorArray (counters, 3); -- ibPayAxiError
               when others =>
                  null;
            end case;
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.axilReadSlave);

      end if;

      -- Reset
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axilReadSlave(0)  <= r.axilReadSlave;
      axilWriteSlave(0) <= r.axilWriteSlave;
      dmaState          <= r.dmaState;
      
   end process;


   ---------------------------------------
   -- Counters
   ---------------------------------------
   U_Counters : entity work.SynchronizerOneShotCntVector
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         COMMON_CLK_G    => true,
         RELEASE_DELAY_G => 3,
         IN_POLARITY_G   => "1",
         OUT_POLARITY_G  => "1",
         USE_DSP48_G     => "no",
         SYNTH_CNT_G     => "1",
         CNT_RST_EDGE_G  => true,
         CNT_WIDTH_G     => COUNT_WIDTH_C,
         WIDTH_G         => 4
      ) port map (
         dataIn(0)  => obHeadAxiError,
         dataIn(1)  => obPayAxiError,
         dataIn(2)  => ibHeadAxiError,
         dataIn(3)  => ibPayAxiError,
         rollOverEn => "0000",
         cntRst     => r.countReset,
         dataOut    => open,
         cntOut     => counters,
         wrClk      => axiClk,
         wrRst      => axiRst,
         rdClk      => axiClk,
         rdRst      => axiRst
      );           


   ---------------------------------------
   -- FIFOs
   ---------------------------------------
   U_Fifos : entity work.AxiLiteFifoPushPop
      generic map (
         TPD_G              => TPD_G,
         POP_FIFO_COUNT_G   => POP_FIFO_COUNT_C,
         POP_SYNC_FIFO_G    => true,
         POP_BRAM_EN_G      => true,
         POP_ADDR_WIDTH_G   => 9,
         LOOP_FIFO_EN_G     => false,
         LOOP_FIFO_COUNT_G  => 1,
         LOOP_BRAM_EN_G     => true,
         LOOP_ADDR_WIDTH_G  => 4,
         PUSH_FIFO_COUNT_G  => PUSH_FIFO_COUNT_C,
         PUSH_SYNC_FIFO_G   => true,
         PUSH_BRAM_EN_G     => true,
         PUSH_ADDR_WIDTH_G  => 9,
         RANGE_LSB_G        => 8,
         VALID_POSITION_G   => 0,
         VALID_POLARITY_G   => '0',
         USE_BUILT_IN_G     => false,
         XIL_DEVICE_G       => "7SERIES"
      ) port map (
         axiClk             => axiClk,
         axiClkRst          => axiRst,
         axiReadMaster      => axilReadMaster(1),
         axiReadSlave       => axilReadSlave(1),
         axiWriteMaster     => axilWriteMaster(1),
         axiWriteSlave      => axilWriteSlave(1),
         popFifoValid       => popFifoValid,
         popFifoAEmpty      => popFifoAEmpty,
         pushFifoAFull      => pushFifoAFull,
         popFifoClk         => popFifoClk,
         popFifoRst         => popFifoRst,
         popFifoWrite       => popFifoWrite,
         popFifoDin         => popFifoDin,
         popFifoFull        => popFifoFull,
         popFifoAFull       => popFifoAFull,
         pushFifoClk        => pushFifoClk,
         pushFifoRst        => pushFifoRst,
         pushFifoValid      => pushFifoValid,
         pushFifoDout       => pushFifoDout,
         pushFifoRead       => pushFifoRead
      );

   popFifoClk   <= (others=>axiClk);
   popFifoRst   <= (others=>axiRst);
   pushFifoClk  <= (others=>axiClk);
   pushFifoRst  <= (others=>axiRst);

   obFreeAEmpty <= popFifoAEmpty(0);
   obWorkAFull  <= pushFifoAFull(0);
   ibPendValid  <= popFifoValid(1);
   ibWorkAFull  <= pushFifoAFull(1);


   ---------------------------------------
   -- Outbound
   ---------------------------------------

   U_ObHeader : entity work.PpiObHeader 
      generic map (
         TPD_G        => TPD_G,
         AXI_CONFIG_G => AXI_ACP_INIT_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         obAxiError      => obHeadAxiError,
         axiReadMaster   => acpReadMaster(0),
         axiReadSlave    => acpReadSlave(0),
         obFreeWrite     => popFifoWrite(0),
         obFreeDin       => popFifoDin(0),
         obFreeAFull     => popFifoAFull(0),
         obWorkValid     => pushFifoValid(0),
         obWorkDout      => pushFifoDout(0),
         obWorkRead      => pushFifoRead(0),
         obPendMaster    => obPendMaster,
         obPendSlave     => obPendSlave,
         obHeaderDebug   => debug(1 downto 0)
      );


   U_ObPayload : entity work.PpiObPayload
      generic map (
         TPD_G        => TPD_G,
         AXI_CONFIG_G => AXI_HP_INIT_C,
         CHAN_ID_G    => CHAN_ID_G
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         obAxiError      => obPayAxiError,
         axiReadMaster   => hpReadMaster,
         axiReadSlave    => hpReadSlave,
         obCompValid     => compValid(0),
         obCompSel       => CompSel(0),
         obCompDin       => compDin(0),
         obCompRead      => compRead(0),
         obPendMaster    => obPendMaster,
         obPendSlave     => obPendSlave,
         dmaClk          => dmaClk,
         dmaClkRst       => dmaClkRst,
         dmaObMaster     => dmaObMaster,
         dmaObSlave      => dmaObSlave,
         obPayloadDebug  => debug(3 downto 2)
      );


   ---------------------------------------
   -- Inbound
   ---------------------------------------

   U_IbRoute : entity work.PpiIbRoute 
      generic map (
         TPD_G => TPD_G
      ) port map (
         dmaClk          => dmaClk,
         dmaClkRst       => dmaClkRst,
         dmaIbMaster     => dmaIbMaster,
         dmaIbSlave      => dmaIbSlave,
         headIbMaster    => headIbMaster,
         headIbSlave     => headIbSlave,
         payIbMaster     => payIbMaster,
         payIbSlave      => payIbSlave
      );


   U_IbHeader : entity work.PpiIbHeader
      generic map (
         TPD_G          => TPD_G,
         AXI_CONFIG_G   => AXI_ACP_INIT_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         ibAxiError      => ibHeadAxiError,
         axiWriteMaster  => acpWriteMaster,
         axiWriteSlave   => acpWriteSlave,
         ibPendWrite     => popFifoWrite(1),
         ibPendDin       => popFifoDin(1),
         ibPendAFull     => popFifoAFull(1),
         ibFreeWrite     => ibFreeWrite,
         ibFreeDin       => ibFreeDin,
         ibFreeAFull     => ibFreeAFull,
         dmaClk          => dmaClk,
         dmaClkRst       => dmaClkRst,
         headIbMaster    => headIbMaster,
         headIbSlave     => headIbSlave,
         ibHeaderDebug   => debug(5 downto 4)
      );


   U_IbPayload : entity work.PpiIbPayload
      generic map (
         TPD_G            => TPD_G,
         AXI_RD_CONFIG_G  => AXI_ACP_INIT_C,
         AXI_WR_CONFIG_G  => AXI_HP_INIT_C,
         CHAN_ID_G        => CHAN_ID_G
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         ibAxiError      => ibPayAxiError,
         axiReadMaster   => acpReadMaster(1),
         axiReadSlave    => acpReadSlave(1),
         axiWriteMaster  => hpWriteMaster,
         axiWriteSlave   => hpWriteSlave,
         ibWorkValid     => pushFifoValid(1),
         ibWorkDout      => pushFifoDout(1),
         ibWorkRead      => pushFifoRead(1),
         ibFreeWrite     => ibFreeWrite,
         ibFreeDin       => ibFreeDin,
         ibFreeAFull     => ibFreeAFull,
         ibCompValid     => compValid(1),
         ibCompSel       => compSel(1),
         ibCompDin       => compDin(1),
         ibCompRead      => compRead(1),
         dmaClk          => dmaClk,
         dmaClkRst       => dmaClkRst,
         payIbMaster     => payIbMaster,
         payIbSlave      => payIbSlave,
         ibPayloadDebug  => debug(8 downto 6)
      );

   U_PpiDebug : ppi_debug
     PORT MAP (
       clk    => axiClk,
       probe0 => debug(0),
       probe1 => debug(1),
       probe2 => debug(2),
       probe3 => debug(3),
       probe4 => debug(4),
       probe5 => debug(5),
       probe6 => debug(6),
       probe7 => debug(7),
       probe8 => debug(8)
     );

end structure;

