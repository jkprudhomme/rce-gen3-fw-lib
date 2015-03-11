-------------------------------------------------------------------------------
-- Title      : PPI Outbound Payload Engine
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiObPayload.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Outbound payload engine for protocol plug in.
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
use work.AxiPkg.all;
use work.AxiDmaPkg.all;
use work.PpiPkg.all;

entity PpiObPayload is
   generic (
      TPD_G        : time          := 1 ns;
      AXI_CONFIG_G : AxiConfigType := AXI_CONFIG_INIT_C;
      CHAN_ID_G    : integer       := 0
   );
   port (

      -- Clock/Reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- Enable and error pulses
      obAxiError      : out sl;
      reqError        : out sl;

      -- AXI Interface
      axiReadMaster   : out AxiReadMasterType;
      axiReadSlave    : in  AxiReadSlaveType;

      -- Completion FIFO
      obCompValid     : out sl;
      obCompSel       : out slv(31 downto 0);
      obCompDin       : out slv(31 downto 1);
      obCompRead      : in  sl;

      -- Pend PPI Stream
      obPendMaster    : in  AxiStreamMasterType;
      obPendSlave     : out AxiStreamSlaveType;

      -- Outbound PPI Stream
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      dmaObMaster     : out AxiStreamMasterType;
      dmaObSlave      : in  AxiStreamSlaveType;

      -- Debug Vectors
      obPayloadDebug  : out Slv32Array(3 downto 0)
   );
end PpiObPayload;

architecture structure of PpiObPayload is

   constant CHAN_BITS_C : integer := bitSize(PPI_COMP_CNT_C-1);
   constant COMP_BITS_C : integer := CHAN_BITS_C + 31;

   type StateType is (DESCA_S, DESCB_S, HEAD_S, PAUSE_S, WAIT_S, COMP_S, ERR_S);

   type RegType is record
      state          : StateType;
      compWrite      : sl;
      compChan       : slv(CHAN_BITS_C-1 downto 0);
      compData       : slv(31 downto 1);
      compEnable     : sl;
      rdError        : sl;
      headOnly       : sl;
      noHeader       : sl;
      reqError       : sl;
      fAxisMaster    : AxiStreamMasterType;
      hAxisSlave     : AxiStreamSlaveType;
      dmaReq         : AxiReadDmaReqType;
      sizeMax        : slv(31 downto 0);
      sizeMin        : slv(31 downto 0);
      obPayloadDebug : Slv32Array(3 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => DESCA_S,
      compWrite      => '0',
      compChan       => (others=>'0'),
      compData       => (others=>'0'),
      compEnable     => '0',
      rdError        => '0',
      headOnly       => '0',
      reqError       => '0',
      noHeader       => '0',
      fAxisMaster    => AXI_STREAM_MASTER_INIT_C,
      hAxisSlave     => AXI_STREAM_SLAVE_INIT_C,
      dmaReq         => AXI_READ_DMA_REQ_INIT_C,
      sizeMax        => (others=>'0'),
      sizeMin        => (others=>'1'),     
      obPayloadDebug => (others=>(others=>'0'))
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal dmaReq        : AxiReadDmaReqType;
   signal dmaAck        : AxiReadDmaAckType;
   signal intAxisMaster : AxiStreamMasterType;
   signal intAxisSlave  : AxiStreamSlaveType;
   signal intAxisCtrl   : AxiStreamCtrlType;
   signal dmaAxisMaster : AxiStreamMasterType;
   signal compWrite     : sl;
   signal compDin       : slv(COMP_BITS_C-1 downto 0);
   signal compDout      : slv(COMP_BITS_C-1 downto 0);
   signal compAFull     : sl;
   signal intReadMaster : AxiReadMasterType;
   signal intReadSlave  : AxiReadSlaveType;

   -- Attribute for XST
   attribute use_dsp48      : string;
   attribute use_dsp48 of r : signal is "yes";     
   
begin

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, axiRst, dmaAck, obPendMaster, dmaAxisMaster, intAxisCtrl, compAFull ) is
      variable v : RegType;
   begin
      v := r;

      v.rdError            := '0';
      v.hAxisSlave.tReady  := '0';
      v.fAxisMaster.tValid := '0';
      v.compWrite          := '0';
      v.reqError           := '0';

      v.obPayloadDebug(0)(2 downto 0) := conv_std_logic_vector(StateType'pos(r.state), 3);
      v.obPayloadDebug(0)(4)          := r.noHeader;
      v.obPayloadDebug(0)(5)          := r.compEnable;
      v.obPayloadDebug(0)(6)          := r.headOnly;

      -- Determine completion enable
      if obPendMaster.tLast = '1' then
         if axiStreamGetUserField(PPI_AXIS_CONFIG_INIT_C, obPendMaster)(1 downto 0) = 3 then
            v.compEnable := '1';
         else
            v.compEnable := '0';
         end if;
      end if;

      -- Header only
      if obPendMaster.tLast = '1' then
         if axiStreamGetUserField(PPI_AXIS_CONFIG_INIT_C, obPendMaster)(1 downto 0) = 1 then
            v.headOnly := '1';
         else
            v.headOnly := '0';
         end if;
      end if;

      case r.state is

         -- get payload descriptor portion of header
         when DESCA_S =>
            v.dmaReq.address          := obPendMaster.tData(31 downto 0);
            v.dmaReq.size             := obPendMaster.tData(63 downto 32);
            v.dmaReq.dest(3 downto 0) := obPendMaster.tDest(3 downto 0);
            v.hAxisSlave.tReady       := '1';
            v.noHeader                := '0';
            -- Update the Max. Size
            if obPendMaster.tData(63 downto 32) > r.sizeMax then
               v.sizeMax := obPendMaster.tData(63 downto 32);
            end if;
            -- Update the Min. Size
            if obPendMaster.tData(63 downto 32) < r.sizeMin then
               v.sizeMin := obPendMaster.tData(63 downto 32);
            end if;                        

            if obPendMaster.tValid = '1' then
               v.state := DESCB_S;
            end if;

         -- get completion descriptor portion of header
         when DESCB_S =>
            v.compData          := obPendMaster.tData(63 downto 34) & "0";
            v.compChan          := obPendMaster.tData(CHAN_BITS_C-1 downto 0);
            v.hAxisSlave.tReady := '1';

            -- Data is valid
            if obPendMaster.tValid = '1' then

               -- Zero header frame
               if obPendMaster.tLast = '1' then
                  v.noHeader          := '1';
                  v.fAxisMaster.tLast := '0'; -- not end of frame yet

                  -- Oops. Zero header and zero payload. Just drop it!
                  if v.headOnly = '1' or r.dmaReq.size = 0 then
                     v.dmaReq.request := '0';
                     v.state          := DESCA_S;
                     v.reqError       := '1';

                  -- No header. EOH not asserted
                  else
                     v.dmaReq.request := '1';
                     v.state          := WAIT_S;
                  end if;

               -- Pass along header data
               else
                  v.state := HEAD_S;
               end if;
            end if;

            v.obPayloadDebug(3)               := r.sizeMin;
            v.obPayloadDebug(2)               := r.sizeMax;
            v.obPayloadDebug(1)               := r.dmaReq.address;
            v.obPayloadDebug(0)(31 downto 16) := r.dmaReq.size(15 downto 0);

         -- Header data, send out
         when HEAD_S =>
            v.hAxisSlave.tReady  := '1';
            v.fAxisMaster        := obPendMaster;
            v.fAxisMaster.tUser  := (others=>'0'); -- Clear user field

            -- End of frame
            if obPendMaster.tValid = '1' and obPendMaster.tLast = '1' then

               -- Set end of header
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.fAxisMaster, PPI_EOH_C,'1');

               -- Header only, we are done
               if v.headOnly = '1' then
                  v.state    := DESCA_S;

               -- Zero payload, skip request
               elsif r.dmaREq.size = 0 then
                  v.state    := WAIT_S;

               -- Payload Enable, start DMA
               else
                  v.state             := WAIT_S;
                  v.fAxisMaster.tLast := '0'; -- not end of frame yet
                  v.dmaReq.request    := '1';
               end if;

            -- Pause asserted
            elsif intAxisCtrl.pause = '1' then
               v.state := PAUSE_S;
            end if;

         -- Pause is asserted while moving header data
         when PAUSE_S => 
            if intAxisCtrl.pause = '0' then
               v.state := HEAD_S;
            end if;

         -- Wait for DMA to complete
         when WAIT_S =>

            if dmaReq.request = '1' then
               v.fAxisMaster := dmaAxisMaster;
            end if;

            -- DMA is done or zero payload (no request)
            if dmaAck.done = '1' or r.dmaReq.request = '0' then
               v.dmaReq.request := '0';
               v.compData(1)    := dmaAck.readError;
               v.rdError        := dmaAck.readError;

               -- Do we populate completion
               if r.compEnable = '1' then
                  v.state := COMP_S;
               elsif dmaAck.readError = '1' then
                  v.state := ERR_S;
               else
                  v.state := DESCA_S;
               end if;
            end if;

         -- Completion
         when COMP_S =>
            if compAFull = '0' then
               v.compWrite := '1';

               if r.compData(1) = '1' then
                  v.state := ERR_S;
               else
                  v.state := DESCA_S;
               end if;
            end if;

         -- Completion Error
         when ERR_S =>
            v.compData                    := (others=>'0');
            v.compData(PPI_COMP_RD_ERR_C) := '1';
            v.compData(3 downto 2)        := toSlv(CHAN_ID_G,2);
            v.compData(1)                 := '1'; -- Outbound
            v.compChan                    := toSlv(PPI_COMP_CNT_C-1,CHAN_BITS_C);

            if compAFull = '0' then
               v.compWrite := '1';
               v.state     := DESCA_S;
            end if;

      end case;

      -- Reset
      if axiRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      dmaReq         <= r.dmaReq;
      obAxiError     <= r.rdError;
      obPendSlave    <= v.hAxisSlave;
      intAxisMaster  <= r.fAxisMaster;
      compWrite      <= r.compWrite;
      obPayloadDebug <= r.obPayloadDebug;
      reqError       <= r.reqError;

      compDin(COMP_BITS_C-1 downto 31) <= r.compChan;
      compDin(30 downto  0)            <= r.compData;

   end process;


   -- DMA Engine
   U_ObDma : entity work.AxiStreamDmaRead 
      generic map (
         TPD_G            => TPD_G,
         AXIS_READY_EN_G  => false,
         AXIS_CONFIG_G    => PPI_AXIS_CONFIG_INIT_C,
         AXI_CONFIG_G     => AXI_CONFIG_G,
         AXI_BURST_G      => PPI_AXI_BURST_C,
         AXI_CACHE_G      => PPI_AXI_CACHE_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaReq          => dmaReq,
         dmaAck          => dmaAck,
         axisMaster      => dmaAxisMaster,
         axisSlave       => intAxisSlave,
         axisCtrl        => intAxisCtrl,
         axiReadMaster   => intReadMaster,
         axiReadSlave    => intReadSlave
      );


   -- Read Path AXI FIFO
   U_AxiReadPathFifo : entity work.AxiReadPathFifo 
      generic map (
         TPD_G                    => TPD_G,
         XIL_DEVICE_G             => "7SERIES",
         USE_BUILT_IN_G           => false,
         GEN_SYNC_FIFO_G          => true,
         ALTERA_SYN_G             => false,
         ALTERA_RAM_G             => "M9K",
         ADDR_LSB_G               => 3,
         ID_FIXED_EN_G            => true,
         SIZE_FIXED_EN_G          => true,
         BURST_FIXED_EN_G         => true,
         LEN_FIXED_EN_G           => false,
         LOCK_FIXED_EN_G          => true,
         PROT_FIXED_EN_G          => true,
         CACHE_FIXED_EN_G         => true,
         ADDR_BRAM_EN_G           => false, 
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 4,
         DATA_BRAM_EN_G           => false,
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_CONFIG_G
      ) port map (
         sAxiClk        => axiClk,
         sAxiRst        => axiRst,
         sAxiReadMaster => intReadMaster,
         sAxiReadSlave  => intReadSlave,
         mAxiClk        => axiClk,
         mAxiRst        => axiRst,
         mAxiReadMaster => axiReadMaster,
         mAxiReadSlave  => axiReadSlave
      );


   -- Outbound Pend FIFO
   U_PendFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         BRAM_EN_G           => true,
         XIL_DEVICE_G        => "7SERIES",
         USE_BUILT_IN_G      => false,
         GEN_SYNC_FIFO_G     => false,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 475,
         SLAVE_AXI_CONFIG_G  => PPI_AXIS_CONFIG_INIT_C,
         MASTER_AXI_CONFIG_G => PPI_AXIS_CONFIG_INIT_C
      ) port map (
         sAxisClk        => axiClk,
         sAxisRst        => axiRst,
         sAxisMaster     => intAxisMaster,
         sAxisSlave      => intAxisSlave,
         sAxisCtrl       => intAxisCtrl,
         mAxisClk        => dmaClk,
         mAxisRst        => dmaClkRst,
         mAxisMaster     => dmaObMaster,
         mAxisSlave      => dmaObSlave
      );


   -- Completion FIFO
   U_CompFifo : entity work.Fifo 
      generic map (
         TPD_G              => TPD_G,
         RST_POLARITY_G     => '1',
         RST_ASYNC_G        => true,
         GEN_SYNC_FIFO_G    => true,
         BRAM_EN_G          => true,
         FWFT_EN_G          => true,
         USE_DSP48_G        => "no",
         USE_BUILT_IN_G     => false,
         XIL_DEVICE_G       => "7SERIES",
         SYNC_STAGES_G      => 3,
         DATA_WIDTH_G       => COMP_BITS_C,
         ADDR_WIDTH_G       => 9,
         INIT_G             => "0",
         FULL_THRES_G       => 1,
         EMPTY_THRES_G      => 1
      ) port map (
         rst           => axiRst,
         wr_clk        => axiClk,
         wr_en         => compWrite,
         din           => compDin,
         almost_full   => compAFull,
         rd_clk        => axiClk,
         rd_en         => obCompRead,
         dout          => compDout,
         valid         => obCompValid
   );


   process (compDout) begin
      obCompSel <= (others=>'0');
      obCompDin <= compDout(30 downto 0);

      obCompSel(CHAN_BITS_C-1 downto 0) <= compDout(COMP_BITS_C-1 downto 31);
   end process;

end structure;

