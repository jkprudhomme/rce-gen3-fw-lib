-------------------------------------------------------------------------------
-- Title      : PPI Outbound Header Engine
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiObHeader.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2014-05-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Outbound header engine for protocol plug in.
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

entity PpiObHeader is
   generic (
      TPD_G        : time          := 1 ns;
      AXI_CONFIG_G : AxiConfigType := AXI_CONFIG_INIT_C
   );
   port (

      -- Clock/Reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- Enable and error pulse
      obAxiError      : out sl;

      -- AXI Interface
      axiReadMaster   : out AxiReadMasterType;
      axiReadSlave    : in  AxiReadSlaveType;

      -- Free list (external FIFO)
      obFreeWrite     : out sl;
      obFreeDin       : out slv(31 downto 0);
      obFreeAFull     : in  sl;

      -- Work list (external FIFO)
      obWorkValid     : in  sl;
      obWorkDout      : in  slv(35 downto 0);
      obWorkRead      : out sl;

      -- Outbound pending (internal FIFO)
      obPendMaster    : out AxiStreamMasterType;
      obPendSlave     : in  AxiStreamSlaveType
   );
end PpiObHeader;

architecture structure of PpiObHeader is

   type StateType is (IDLE_S, WAIT_S, FREE_S);

   type RegType is record
      state         : StateType;
      obFreeWrite   : sl;
      obFreeDin     : slv(31 downto 0);
      obWorkRead    : sl;
      obError       : sl;
      dmaReq        : AxiReadDmaReqType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state         => IDLE_S,
      obFreeWrite   => '0',
      obFreeDin     => (others=>'0'),
      obWorkRead    => '0',
      obError       => '0',
      dmaReq        => AXI_READ_DMA_REQ_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal dmaReq        : AxiReadDmaReqType;
   signal dmaAck        : AxiReadDmaAckType;
   signal intAxisMaster : AxiStreamMasterType;
   signal intAxisSlave  : AxiStreamSlaveType;
   signal intAxisCtrl   : AxiStreamCtrlType;
   signal intReadMaster : AxiReadMasterType;
   signal intReadSlave  : AxiReadSlaveType;

begin

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, axiRst, dmaAck, obFreeAFull, obWorkValid, obWorkDout ) is
      variable v : RegType;
   begin
      v := r;

      v.obFreeWrite := '0';
      v.obWorkRead  := '0';
      v.obError     := '0';

      case r.state is

         when IDLE_S =>
            v.dmaReq.lastUser(1 downto 0)  := obWorkDout(31 downto 30); -- OpCode
            v.dmaReq.dest(3 downto 0)      := obWorkDout(29 downto 26);
            v.dmaReq.size(10 downto 3)     := obWorkDout(25 downto 18) + 2; -- Size is in units of 8 bytes
            v.dmaReq.address(17 downto  4) := obWorkDout(17 downto  4);

            if obWorkValid = '1' and obFreeAFull = '0' then
               v.obWorkRead := '1';

               -- Return to free list
               if obWorkDout(31 downto 30) = 0 then
                  v.state := FREE_S;
               else
                  v.dmaReq.request := '1';
                  v.state          := WAIT_S;
               end if;
            end if;

         when WAIT_S =>
            if dmaAck.done = '1' then 
               v.dmaReq.request := '0';
               v.obError        := dmaAck.readError;
               v.state          := FREE_S;
            end if;

         when FREE_S =>
            v.obFreeDin(17 downto 0) := r.dmaReq.address(17 downto 0);
            v.obFreeWrite            := '1';
            v.state                  := IDLE_S;

      end case;

      if axiRst = '1' then
         v := REG_INIT_C;
      end if;

      -- Some Address bits are constant
      v.dmaReq.address(3  downto  0) := (others=>'0');
      v.dmaReq.address(31 downto 18) := PPI_OCM_BASE_ADDR_C(31 downto 18);

      -- Next register assignment
      rin <= v;

      -- Outputs
      dmaReq      <= r.dmaReq;
      obFreeWrite <= r.obFreeWrite;
      obFreeDin   <= r.obFreeDin;
      obWorkRead  <= r.obWorkRead;
      obAxiError  <= r.obError;

   end process;


   -- DMA Engine
   U_ObDma : entity work.AxiStreamDmaRead 
      generic map (
         TPD_G            => TPD_G,
         AXIS_READY_EN_G  => false,
         AXIS_CONFIG_G    => PPI_AXIS_HEADER_INIT_C,
         AXI_CONFIG_G     => AXI_CONFIG_G,
         AXI_BURST_G      => PPI_AXI_BURST_C,
         AXI_CACHE_G      => PPI_AXI_CACHE_C
      ) port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         dmaReq          => dmaReq,
         dmaAck          => dmaAck,
         axisMaster      => intAxisMaster,
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
         GEN_SYNC_FIFO_G     => true,
         ALTERA_SYN_G        => false,
         ALTERA_RAM_G        => "M9K",
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 9,
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 475,
         SLAVE_AXI_CONFIG_G  => PPI_AXIS_HEADER_INIT_C,
         MASTER_AXI_CONFIG_G => PPI_AXIS_HEADER_INIT_C
      ) port map (
         sAxisClk        => axiClk,
         sAxisRst        => axiRst,
         sAxisMaster     => intAxisMaster,
         sAxisSlave      => intAxisSlave,
         sAxisCtrl       => intAxisCtrl,
         mAxisClk        => axiClk,
         mAxisRst        => axiRst,
         mAxisMaster     => obPendMaster,
         mAxisSlave      => obPendSlave
      );

end structure;

