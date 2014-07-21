-------------------------------------------------------------------------------
-- Title      : PPI Inbound Payload Engine
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiIbPayload.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Inbound payload engine for protocol plug in.
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

entity PpiIbPayload is
   generic (
      TPD_G            : time          := 1 ns;
      AXI_RD_CONFIG_G  : AxiConfigType := AXI_CONFIG_INIT_C;
      AXI_WR_CONFIG_G  : AxiConfigType := AXI_CONFIG_INIT_C;
      CHAN_ID_G        : integer       := 0
   );
   port (

      -- Clock/Reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- Enable and error pulse
      ibAxiError      : out sl;

      -- AXI Interface
      axiReadMaster   : out AxiReadMasterType;
      axiReadSlave    : in  AxiReadSlaveType;
      axiWriteMaster  : out AxiWriteMasterType;
      axiWriteSlave   : in  AxiWriteSlaveType;

      -- Work list (external FIFO)
      ibWorkValid     : in  sl;
      ibWorkDout      : in  slv(35 downto 0);
      ibWorkRead      : out sl;

      -- Free list (external FIFO)
      ibFreeWrite     : out sl;
      ibFreeDin       : out slv(17 downto 4);
      ibFreeAFull     : in  sl;

      -- Completion FIFO
      ibCompValid     : out sl;
      ibCompSel       : out slv(31 downto 0);
      ibCompDin       : out slv(31 downto 1);
      ibCompRead      : in  sl;

      -- External interface
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      payIbMaster     : in  AxiStreamMasterType;
      payIbSlave      : out AxiStreamSlaveType;

      -- Debug Vectors
      ibPayloadDebug  : out Slv32Array(2 downto 0)
   );
end PpiIbPayload;

architecture structure of PpiIbPayload is

   constant CHAN_BITS_C : integer := bitSize(PPI_COMP_CNT_C-1);
   constant COMP_BITS_C : integer := CHAN_BITS_C + 31;

   type StateType is (IDLE_S, CODE_S, READ_A_S, READ_B_S, READ_C_S, WAIT_S, FREE_S, DUMP_S, COMP_S, ERR_S);

   type RegType is record
      state          : StateType;
      opCode         : slv(2 downto 0);
      keep           : sl;
      compWrite      : sl;
      compChan       : slv(CHAN_BITS_C-1 downto 0);
      compData       : slv(31 downto 1);
      rdError        : sl;
      wrError        : sl;
      frameError     : sl;
      overFlow       : sl;
      ibAxiError     : sl;
      ibFreeWrite    : sl;
      ibFreeDin      : slv(17 downto 4);
      ibWorkRead     : sl;
      rdReq          : AxiReadDmaReqType;
      wrReq          : AxiWriteDmaReqType;
      ibPayloadDebug : Slv32Array(2 downto 0);
   end record RegType;

   constant REG_INIT_C : RegType := (
      state          => IDLE_S,
      opCode         => (others=>'0'),
      keep           => '0',
      compWrite      => '0',
      compChan       => (others=>'0'),
      compData       => (others=>'0'),
      rdError        => '0',
      wrError        => '0',
      frameError     => '0',
      overFlow       => '0',
      ibAxiError     => '0',
      ibFreeWrite    => '0',
      ibFreeDin      => (others=>'0'),
      ibWorkRead     => '0',
      rdReq          => AXI_READ_DMA_REQ_INIT_C,
      wrReq          => AXI_WRITE_DMA_REQ_INIT_C,
      ibPayloadDebug => (others=>(others=>'0'))
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal rdReq           : AxiReadDmaReqType;
   signal rdAck           : AxiReadDmaAckType;
   signal wrReq           : AxiWriteDmaReqType;
   signal wrAck           : AxiWriteDmaAckType;
   signal wrAxisMaster    : AxiStreamMasterType;
   signal wrAxisSlave     : AxiStreamSlaveType;
   signal rdAxisMaster    : AxiStreamMasterType;
   signal rdAxisSlave     : AxiStreamSlaveType;
   signal compWrite       : sl;
   signal compDin         : slv(COMP_BITS_C-1 downto 0);
   signal compDout        : slv(COMP_BITS_C-1 downto 0);
   signal compAFull       : sl;
   signal intWriteMaster  : AxiWriteMasterType;
   signal intWriteSlave   : AxiWriteSlaveType;
   signal intWriteCtrl    : AxiCtrlType;
   signal intReadMaster   : AxiReadMasterType;
   signal intReadSlave    : AxiReadSlaveType;

begin

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;


   -- Async
   process (r, axiRst, rdAck, wrAck, ibWorkValid, ibWorkDout, ibFreeAFull, rdAxisMaster, compAFull ) is
      variable v : RegType;
   begin
      v := r;

      v.ibFreeWrite := '0';
      v.ibWorkRead  := '0';
      v.ibAxiError  := '0';
      v.compWrite   := '0';

      v.ibPayloadDebug(0)(3 downto 0) := conv_std_logic_vector(StateType'pos(r.state), 4);

      case r.state is

         when IDLE_S =>
            v.rdReq.address(17 downto 4) := ibWorkDout(17 downto  4);
            v.opCode                     := ibWorkDout(30 downto 28);
            v.keep                       := ibWorkDout(31);
            v.rdError                    := '0';
            v.wrError                    := '0';
            v.overFlow                   := '0';
            v.frameError                 := '0';

            if ibWorkValid = '1' and ibFreeAFull = '0' then
               v.ibWorkRead := '1';
               v.state      := CODE_S;
            end if;

         when CODE_S =>

            -- Dump frame
            if r.opCode = 1 then
               v.wrReq.address := (others=>'0');
               v.wrReq.maxSize := (others=>'0');
               v.wrReq.drop    := '1';
               v.wrReq.request := '1';
               v.state         := DUMP_S;

            -- Return to free list, conditionally
            elsif r.opCode = 0 or r.opCode = 3 or r.opCode = 5 or r.opCode = 7 then
               v.state := FREE_S;

            -- Read descriptor
            else
               v.rdReq.request := '1';
               v.state         := READ_A_S;
            end if;

         when READ_A_S =>
            v.wrReq.address := rdAxisMaster.tData(31 downto  0);
            v.wrReq.maxSize := rdAxisMaster.tData(63 downto 32);

            if rdAxisMaster.tValid = '1' then
               v.state := READ_B_S;
            end if;

         when READ_B_S =>
            v.compData := rdAxisMaster.tData(63 downto 34) & "0";
            v.compChan := rdAxisMaster.tData(CHAN_BITS_C-1 downto 0);

            if rdAxisMaster.tValid = '1' then
               v.state := READ_C_S;
            end if;

         when READ_C_S =>
            if rdAck.done = '1' then 
               v.rdReq.request := '0';
               v.rdError       := rdAck.readError;
               v.ibAxiError    := rdAck.readError;

               if rdAck.readError = '1' then 
                  v.ibPayloadDebug(0)(8) := '1';
               end if;

               -- Return completion
               if r.opCode = 4 then
                  v.state := COMP_S;

               -- Write payload
               else
                  v.wrReq.drop    := '0';
                  v.wrReq.request := '1';
                  v.state         := WAIT_S;
               end if;
            end if;

            v.ibPayloadDebug(2) := r.rdReq.address;

         when WAIT_S =>

            v.ibPayloadDebug(1) := r.wrReq.address;

            if wrAck.done = '1' then 
               v.wrReq.request := '0';
               v.wrError       := wrAck.writeError;
               v.ibAxiError    := wrAck.writeError;
               v.frameError    := wrAck.lastUser(PPI_ERR_C);
               v.overFlow      := wrAck.overflow;

               if wrAck.writeError = '1' then 
                  v.ibPayloadDebug(0)(7) := '1';
                  v.ibPayloadDebug(0)(31 downto 30) := wrAck.errorValue;
               end if;

               -- Do we populate completion
               if r.opCode = 6 then
                  v.state := COMP_S;
               elsif r.rdError = '1' or v.wrError = '1' or v.frameError = '1' or v.overFlow = '1' then
                  v.state := ERR_S;
               else
                  v.state := FREE_S;
               end if;
            end if;

         -- Dumping frame
         when DUMP_S =>
            if wrAck.done = '1' then 
               v.wrReq.request := '0';
               v.state         := FREE_S;
            end if;

         -- Completion
         when COMP_S =>
            if compAFull = '0' then
               v.compWrite := '1';

               if r.rdError = '1' or r.wrError = '1' or r.frameError = '1' or r.overFlow = '1' then
                  v.compData(1) := '1';
                  v.state       := ERR_S;
               else
                  v.state := FREE_S;
               end if;
            end if;

         -- Completion Error
         when ERR_S =>
            v.compData                       := (others=>'0');
            v.compData(PPI_COMP_RD_ERR_C)    := r.rdError;
            v.compData(PPI_COMP_WR_ERR_C)    := r.wrError;
            v.compData(PPI_COMP_FRAME_ERR_C) := r.frameError;
            v.compData(PPI_COMP_OFLOW_ERR_C) := r.overFlow;
            v.compData(3 downto 2)           := toSlv(CHAN_ID_G,2);
            v.compData(1)                    := '0'; -- Inbound
            v.compChan                       := toSlv(PPI_COMP_CNT_C-1,CHAN_BITS_C);

            if compAFull = '0' then
               v.compWrite := '1';
               v.state     := FREE_S;
            end if;

         -- Conditionally return to free list
         when FREE_S =>
            v.ibFreeDin(17 downto 4) := r.rdReq.address(17 downto 4);
            v.ibFreeWrite            := not r.keep;
            v.state                  := IDLE_S;

      end case;

      if axiRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Upper read address bits and size are constant
      v.rdReq.address(3  downto  0) := (others=>'0');
      v.rdReq.address(31 downto 18) := PPI_OCM_BASE_ADDR_C(31 downto 18);
      v.rdReq.size                  := toSlv(16,32);

      -- Next register assignment
      rin <= v;

      -- Outputs
      wrReq       <= r.wrReq;
      rdReq       <= r.rdReq;
      ibFreeWrite <= r.ibFreeWrite;
      ibFreeDin   <= r.ibFreeDin;
      ibWorkRead  <= r.ibWorkRead;
      ibAxiError  <= r.ibAxiError;
      compWrite   <= r.compWrite;

      ibPayloadDebug <= r.ibPayloadDebug;

      compDin(COMP_BITS_C-1 downto 31) <= r.compChan;
      compDin(30 downto  0)            <= r.compData;

   end process;


   -- DMA Engine
   U_RdDma : entity work.AxiStreamDmaRead 
      generic map (
         TPD_G            => TPD_G,
         AXIS_READY_EN_G  => false,
         AXIS_CONFIG_G    => PPI_AXIS_CONFIG_INIT_C,
         AXI_CONFIG_G     => AXI_RD_CONFIG_G,
         AXI_BURST_G      => PPI_AXI_BURST_C,
         AXI_CACHE_G      => PPI_AXI_CACHE_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaReq          => rdReq,
         dmaAck          => rdAck,
         axisMaster      => rdAxisMaster,
         axisSlave       => rdAxisSlave,
         axisCtrl        => AXI_STREAM_CTRL_UNUSED_C,
         axiReadMaster   => intReadMaster,
         axiReadSlave    => intReadSlave
      );

   rdAxisSlave.tReady <= '1';


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
         AXI_CONFIG_G             => AXI_RD_CONFIG_G
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


   -- Inbound FIFO
   U_IbFifo : entity work.AxiStreamFifo 
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
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
         sAxisClk        => dmaClk,
         sAxisRst        => dmaClkRst,
         sAxisMaster     => payIbMaster,
         sAxisSlave      => payIbSlave,
         mAxisClk        => axiClk,
         mAxisRst        => axiRst,
         mAxisMaster     => wrAxisMaster,
         mAxisSlave      => wrAxisSlave
      );


   -- Write DMA Engine
   U_WrDma : entity work.AxiStreamDmaWrite
      generic map (
         TPD_G            => TPD_G,
         AXI_READY_EN_G   => false,
         AXIS_CONFIG_G    => PPI_AXIS_CONFIG_INIT_C,
         AXI_CONFIG_G     => AXI_WR_CONFIG_G,
         AXI_BURST_G      => PPI_AXI_BURST_C,
         AXI_CACHE_G      => PPI_AXI_CACHE_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaReq          => wrReq,
         dmaAck          => wrAck,
         axisMaster      => wrAxisMaster,
         axisSlave       => wrAxisSlave,
         axiWriteMaster  => intWriteMaster,
         axiWriteSlave   => intWriteSlave,
         axiWriteCtrl    => intWriteCtrl
      );


   -- Write Path AXI FIFO
   U_AxiWritePathFifo : entity work.AxiWritePathFifo
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
         ADDR_BRAM_EN_G           => true, 
         ADDR_CASCADE_SIZE_G      => 1,
         ADDR_FIFO_ADDR_WIDTH_G   => 9,
         DATA_BRAM_EN_G           => true,
         DATA_CASCADE_SIZE_G      => 1,
         DATA_FIFO_ADDR_WIDTH_G   => 9,
         DATA_FIFO_PAUSE_THRESH_G => 456,
         RESP_BRAM_EN_G           => false,
         RESP_CASCADE_SIZE_G      => 1,
         RESP_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_WR_CONFIG_G
      ) port map (
         sAxiClk         => axiClk,
         sAxiRst         => axiRst,
         sAxiWriteMaster => intWriteMaster,
         sAxiWriteSlave  => intWriteSlave,
         sAxiCtrl        => intWriteCtrl,
         mAxiClk         => axiClk,
         mAxiRst         => axiRst,
         mAxiWriteMaster => axiWriteMaster,
         mAxiWriteSlave  => axiWriteSlave
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
         rd_en         => ibCompRead,
         dout          => compDout,
         valid         => ibCompValid
   );

   process (compDout) begin
      ibCompSel <= (others=>'0');
      ibCompDin <= compDout(30 downto 0);

      ibCompSel(CHAN_BITS_C-1 downto 0) <= compDout(COMP_BITS_C-1 downto 31);
   end process;

end structure;

