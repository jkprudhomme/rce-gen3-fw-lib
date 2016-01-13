-------------------------------------------------------------------------------
-- Title      : PPI Inbound Header Engine
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiIbHeader.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Inbound header engine for protocol plug in.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PPI Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PPI Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
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

entity PpiIbHeader is
   generic (
      TPD_G          : time          := 1 ns;
      AXI_CONFIG_G   : AxiConfigType := AXI_CONFIG_INIT_C
   );
   port (

      -- Clock/Reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- Enable and error pulse
      ibAxiError      : out sl;

      -- AXI Interface
      axiWriteMaster  : out AxiWriteMasterType;
      axiWriteSlave   : in  AxiWriteSlaveType;

      -- Pending list (external FIFO)
      ibPendWrite     : out sl;
      ibPendDin       : out slv(31 downto 0);
      ibPendAFull     : in  sl;

      -- Free list (internal FIFO)
      ibFreeWrite     : in  sl;
      ibFreeDin       : in  slv(17 downto 4);
      ibFreeAFull     : out sl;

      -- External interface
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;
      headIbMaster    : in  AxiStreamMasterType;
      headIbSlave     : out AxiStreamSlaveType;

      -- Debug Vectors
      ibHeaderDebug   : out Slv32Array(1 downto 0)
   );
end PpiIbHeader;

architecture structure of PpiIbHeader is

   type StateType is (IDLE_S, WAIT_S);

   type RegType is record
      state         : StateType;
      baseAddr      : slv(17 downto 4);
      ibPendWrite   : sl;
      ibPendDin     : slv(31 downto 0);
      ibFreeRead    : sl;
      ibError       : sl;
      ibHeaderDebug : Slv32Array(1 downto 0);
      dmaReq        : AxiWriteDmaReqType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state         => IDLE_S,
      baseAddr      => (others=>'0'),
      ibPendWrite   => '0',
      ibPendDin     => (others=>'0'),
      ibFreeRead    => '0',
      ibError       => '0',
      ibHeaderDebug => (others=>(others=>'0')),
      dmaReq        => AXI_WRITE_DMA_REQ_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal dmaReq          : AxiWriteDmaReqType;
   signal dmaAck          : AxiWriteDmaAckType;
   signal intAxisMaster   : AxiStreamMasterType;
   signal intAxisSlave    : AxiStreamSlaveType;
   signal ibFreeValid     : sl;
   signal ibFreeDout      : slv(17 downto 4);
   signal ibFreeRead      : sl;
   signal intWriteMaster  : AxiWriteMasterType;
   signal intWriteSlave   : AxiWriteSlaveType;
   signal intWriteCtrl    : AxiCtrlType;

begin

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, axiRst, dmaAck, ibPendAFull, ibFreeDout, ibFreeValid, intAxisMaster, intAxisSlave ) is
      variable v : RegType;
   begin
      v := r;

      v.ibPendWrite := '0';
      v.ibFreeRead  := '0';
      v.ibError     := '0';

      v.ibHeaderDebug(0)(3 downto 0) := conv_std_logic_vector(StateType'pos(r.state), 4);
      v.ibHeaderDebug(0)(4)          := r.dmaReq.request;
      v.ibHeaderDebug(0)(5)          := dmaAck.done;
      v.ibHeaderDebug(0)(8)          := intAxisMaster.tValid;
      v.ibHeaderDebug(0)(9)          := intAxisSlave.tReady;

      v.ibHeaderDebug(0)(31 downto 16) := dmaAck.size(15 downto 0);

      case r.state is

         when IDLE_S =>
            v.dmaReq.address(17 downto 4) := ibFreeDout + 1;
            v.baseAddr                    := ibFreeDout;

            if ibFreeValid = '1' and ibPendAFull = '0' then
               v.dmaReq.request := '1';
               v.ibFreeRead     := '1';
               v.state          := WAIT_S;
            end if;

         when WAIT_S =>
            if dmaAck.done = '1' then 
               v.dmaReq.request          := '0';
               v.ibError                 := dmaAck.writeError;
               v.ibPendDin(31)           := not dmaAck.lastUser(PPI_EOH_C); -- EOH = EOF here
               v.ibPendDin(29 downto 26) := dmaAck.dest(3 downto 0);
               v.ibPendDin(17 downto  4) := r.baseAddr;
               v.ibPendWrite             := '1';
               v.state                   := IDLE_S;

               -- Errors
               if dmaAck.overflow = '1' or dmaAck.lastUser(PPI_ERR_C) = '1' then
                  v.ibPendDin(30) := '1';
               else
                  v.ibPendDin(30) := '0';
               end if;
            end if;

            v.ibHeaderDebug(1) := r.dmaReq.address;
      end case;

      if axiRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Upper address bits are constant
      v.dmaReq.address(3  downto  0) := (others=>'0');
      v.dmaReq.address(31 downto 18) := PPI_OCM_BASE_ADDR_C(31 downto 18);
      v.dmaReq.maxSize               := PPI_MAX_HEADER_C;

      -- Next register assignment
      rin <= v;

      -- Outputs
      dmaReq        <= r.dmaReq;
      ibPendWrite   <= r.ibPendWrite;
      ibPendDin     <= r.ibPendDin;
      ibFreeRead    <= r.ibFreeRead;
      ibAxiError    <= r.ibError;
      ibHeaderDebug <= r.ibHeaderDebug;

   end process;


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
         SLAVE_AXI_CONFIG_G  => PPI_AXIS_HEADER_INIT_C,
         MASTER_AXI_CONFIG_G => PPI_AXIS_HEADER_INIT_C
      ) port map (
         sAxisClk        => dmaClk,
         sAxisRst        => dmaClkRst,
         sAxisMaster     => headIbMaster,
         sAxisSlave      => headIbSlave,
         mAxisClk        => axiClk,
         mAxisRst        => axiRst,
         mAxisMaster     => intAxisMaster,
         mAxisSlave      => intAxisSlave
      );


   -- DMA Engine
   U_IbDma : entity work.AxiStreamDmaWrite
      generic map (
         TPD_G            => TPD_G,
         AXI_READY_EN_G   => false,
         AXIS_CONFIG_G    => PPI_AXIS_HEADER_INIT_C,
         AXI_CONFIG_G     => AXI_CONFIG_G,
         AXI_BURST_G      => PPI_AXI_BURST_C,
         AXI_CACHE_G      => PPI_AXI_ACP_CACHE_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaReq          => dmaReq,
         dmaAck          => dmaAck,
         axisMaster      => intAxisMaster,
         axisSlave       => intAxisSlave,
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
         AXI_CONFIG_G             => AXI_CONFIG_G
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


   -- Free List FIFO
   U_FreeFifo : entity work.Fifo 
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
         DATA_WIDTH_G       => 14,
         ADDR_WIDTH_G       => 9,
         INIT_G             => "0",
         FULL_THRES_G       => 1,
         EMPTY_THRES_G      => 1
      ) port map (
         rst           => axiRst,
         wr_clk        => axiClk,
         wr_en         => ibFreeWrite,
         din           => ibFreeDin,
         almost_full   => ibFreeAFull,
         rd_clk        => axiClk,
         rd_en         => ibFreeRead,
         dout          => ibFreeDout,
         valid         => ibFreeValid
   );

end structure;

