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
      obPendSlave     : in  AxiStreamSlaveType;

      -- Debug Vectors
      obHeaderDebug   : out Slv32Array(3 downto 0)
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
      obHeaderDebug : Slv32Array(3 downto 0);
      sizeMax       : slv(7 downto 0);
      sizeMin       : slv(7 downto 0);      
      dmaReq        : AxiReadDmaReqType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      state         => IDLE_S,
      obFreeWrite   => '0',
      obFreeDin     => (others=>'0'),
      obWorkRead    => '0',
      obError       => '0',
      obHeaderDebug => (others=>(others=>'0')),
      sizeMax       => (others=>'0'),
      sizeMin       => (others=>'1'),         
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

   attribute dont_touch : string;

   attribute dont_touch of r             : signal is "true";
   attribute dont_touch of dmaReq        : signal is "true";
   attribute dont_touch of dmaAck        : signal is "true";
   attribute dont_touch of intAxisMaster : signal is "true";
   attribute dont_touch of intAxisSlave  : signal is "true";
   attribute dont_touch of intAxisCtrl   : signal is "true";
   attribute dont_touch of intReadMaster : signal is "true";
   attribute dont_touch of intReadSlave  : signal is "true";

begin

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (r, axiRst, dmaAck, obFreeAFull, obWorkValid, obWorkDout, intAxisCtrl ) is
      variable v : RegType;
   begin
      v := r;

      v.obFreeWrite := '0';
      v.obWorkRead  := '0';
      v.obError     := '0';

      v.obHeaderDebug(0)(2 downto 0) := conv_std_logic_vector(StateType'pos(r.state), 3);
      v.obHeaderDebug(0)(4)          := r.dmaReq.request;
      v.obHeaderDebug(0)(5)          := dmaAck.done;
      v.obHeaderDebug(0)(6)          := intAxisCtrl.pause;

      case r.state is

         when IDLE_S =>
            v.dmaReq.lastUser(1 downto 0)  := obWorkDout(31 downto 30); -- OpCode
            v.dmaReq.dest(3 downto 0)      := obWorkDout(29 downto 26);
            v.dmaReq.size(10 downto 3)     := obWorkDout(25 downto 18) + 2; -- Size is in units of 8 bytes
            v.dmaReq.address(17 downto  4) := obWorkDout(17 downto  4);

            -- Update the Max. Size
            if (obWorkDout(25 downto 18) + 2) > r.sizeMax then
               v.sizeMax := (obWorkDout(25 downto 18) + 2);
            end if;
            -- Update the Min. Size
            if (obWorkDout(25 downto 18) + 2) < r.sizeMin then
               v.sizeMin := (obWorkDout(25 downto 18) + 2);
            end if;             
            
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
            v.obHeaderDebug(3)(7 downto 0)   := r.sizeMin;
            v.obHeaderDebug(2)(7 downto 0)   := r.sizeMax;
            v.obHeaderDebug(1)               := r.dmaReq.address;
            v.obHeaderDebug(0)(31 downto 16) := r.dmaReq.size(15 downto 0);
            v.obHeaderDebug(0)(15 downto 14) := r.dmaReq.lastUser(1 downto 0); -- Opcode

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
      dmaReq        <= r.dmaReq;
      obFreeWrite   <= r.obFreeWrite;
      obFreeDin     <= r.obFreeDin;
      obWorkRead    <= r.obWorkRead;
      obAxiError    <= r.obError;
      obHeaderDebug <= r.obHeaderDebug;

   end process;


   -- DMA Engine
   U_ObDma : entity work.AxiStreamDmaRead 
      generic map (
         TPD_G            => TPD_G,
         AXIS_READY_EN_G  => false,
         AXIS_CONFIG_G    => PPI_AXIS_HEADER_INIT_C,
         AXI_CONFIG_G     => AXI_CONFIG_G,
         AXI_BURST_G      => PPI_AXI_BURST_C,
         AXI_CACHE_G      => PPI_AXI_ACP_CACHE_C,
         MAX_PEND_G       => 1600
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
         INT_PIPE_STAGES_G   => 1,
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
         FIFO_PAUSE_THRESH_G => 300,
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

