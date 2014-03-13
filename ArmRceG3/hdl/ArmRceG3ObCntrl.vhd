-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Outbound FIFOs
-- File          : ArmRceG3ObCntrl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- FIFO controller for outbound header FIFOs
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ArmRceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity ArmRceG3ObCntrl is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  std_logic;

      -- AXI ACP Master
      axiAcpSlaveReadFromArm  : in  AxiReadSlaveType;
      axiAcpSlaveReadToArm    : out AxiReadMasterType;

      -- Transmit Descriptor write
      headerPtrWrite          : in  slv(3  downto 0);
      headerPtrData           : in  slv(35 downto 0);

      -- FIFO Read 
      localAxiReadMaster      : in  AxiLiteReadMasterType;
      localAxiReadSlave       : out AxiLiteReadSlaveType;
      localAxiWriteMaster     : in  AxiLiteWriteMasterType;
      localAxiWriteSlave      : out AxiLiteWriteSlaveType;

      -- Configuration
      memBaseAddress          : in  slv(31 downto 18);      -- Lower bits from free list FIFO
      fifoEnable              : in  slv(3  downto  0);      -- 0-3 = header
      readDmaCache            : in  slv(3  downto 0);       -- Used in AXI transactions

      -- Header FIFO Interface
      obHeaderToFifo          : in  ObHeaderToFifoVector(3 downto 0);
      obHeaderFromFifo        : out ObHeaderFromFifoVector(3 downto 0)
   );
end ArmRceG3ObCntrl;

architecture structure of ArmRceG3ObCntrl is

   -- Local signals
   signal headerDmaId        : Slv3Array(3 downto 0);
   signal axiReadToCntrl     : AxiReadToCntrlVector(3 downto 0);
   signal axiReadFromCntrl   : AxiReadFromCntrlVector(3 downto 0);
   signal freePtrWrite       : slv(3 downto 0);
   signal freePtrDin         : Slv18Array(3 downto 0);
   signal freePtrDout        : Slv18Array(3 downto 0);
   signal freePtrValid       : slv(3 downto 0);
   signal axiClkRstInt       : sl := '1';

   type RegType is record
      freePtrRead        : slv(3 downto 0);
      localAxiReadSlave  : AxiLiteReadSlaveType;
      localAxiWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      freePtrRead        => (others => '0'),
      localAxiReadSlave  => AXI_READ_SLAVE_INIT_C,
      localAxiWriteSlave => AXI_WRITE_SLAVE_INIT_C
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

   -----------------------------------------
   -- Read Controller
   -----------------------------------------
   U_ReadCntrl : entity work.AxiRceG3AxiReadCntrl 
      generic map (
         TPD_G      => TPD_G,
         CHAN_CNT_G => 4
      ) port map (
         axiClk               => axiClk,
         axiClkRst            => axiClkRstInt,
         axiSlaveReadFromArm  => axiAcpSlaveReadFromArm,
         axiSlaveReadToArm    => axiAcpSlaveReadToArm,
         readDmaCache         => readDmaCache,
         axiReadToCntrl       => axiReadToCntrl,
         axiReadFromCntrl     => axiReadFromCntrl
      );

   ------------------------------------------------------
   -- Header FIFOs
   ------------------------------------------------------
   U_HeaderFifoGen: for i in 0 to 3 generate

      U_ObHeaderFifo: entity work.ArmRceG3ObHeaderFifo 
         generic map (
            TPD_G      => TPD_G
         ) port map (
            axiClk                  => axiClk,
            axiClkRst               => axiClkRstInt,
            axiReadToCntrl          => axiReadToCntrl(i),
            axiReadFromCntrl        => axiReadFromCntrl(i),
            headerPtrWrite          => headerPtrWrite(i),
            headerPtrData           => headerPtrData,
            freePtrWrite            => freePtrWrite(i),
            freePtrData             => freePtrDin(i),
            memBaseAddress          => memBaseAddress,
            fifoEnable              => fifoEnable(i),
            headerReadDmaId         => headerDmaId(i),
            obHeaderToFifo          => obHeaderToFifo(i),
            obHeaderFromFifo        => obHeaderFromFifo(i)
         );

         -- Generate DMA IDs
         headerDmaId(i) <= "0" & conv_std_logic_vector(i,2);

   end generate;

   ------------------------------------------------------
   -- Free List FIFOs
   ------------------------------------------------------
   U_FifoGen: for i in 0 to 3 generate
      U_CompFifo : entity work.FifoSyncBuiltIn 
         generic map (
            TPD_G          => TPD_G,
            RST_POLARITY_G => '1',
            FWFT_EN_G      => true,
            USE_DSP48_G    => "no",
            XIL_DEVICE_G   => "7SERIES",
            DATA_WIDTH_G   => 18,
            ADDR_WIDTH_G   => 11,
            FULL_THRES_G   => 479,
            EMPTY_THRES_G  => 1
         ) port map (
            rst               => axiClkRstInt,
            clk               => axiClk,
            wr_en             => freePtrWrite(i),
            din               => freePtrDin(i),
            data_count        => open,
            wr_ack            => open,
            overflow          => open,
            prog_full         => open,
            almost_full       => open,
            full              => open,
            not_full          => open,
            rd_en             => rin.freePtrRead(i),
            dout              => freePtrDout(i),
            valid             => freePtrValid(i),
            underflow         => open,
            prog_empty        => open,
            almost_empty      => open,
            empty             => open
         );
   end generate;

   -----------------------------------------
   -- FIFO Read
   -----------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRstInt, localAxiReadMaster, localAxiWriteMaster, freePtrDout, freePtrValid, r ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      v.freePtrRead := (others=>'0');

      axiSlaveWaitTxn(localAxiWriteMaster, localAxiReadMaster, v.localAxiWriteSlave, v.localAxiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then
         axiSlaveWriteResponse(localAxiWriteMaster, localAxiReadMaster, v.localAxiWriteSlave, v.localAxiReadSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then

         v.localAxiReadSlave.rdata(17 downto  0) := freePtrDout(conv_integer(localAxiReadMaster.araddr(3 downto 2)));
         v.localAxiReadSlave.rdata(30 downto 18) := (others=>'0');
         v.localAxiReadSlave.rdata(31)           := freePtrValid(conv_integer(localAxiReadMaster.araddr(3 downto 2)));

         v.freePtrRead(conv_integer(localAxiReadMaster.araddr(3 downto 2))) := '1';

         -- Send Axi Response
         axiSlaveReadResponse(localAxiWriteMaster, localAxiReadMaster, v.localAxiWriteSlave, v.localAxiReadSlave);
      end if;

      -- Reset
      if (axiClkRstInt = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      localAxiReadSlave  <= r.localAxiReadSlave;
      localAxiWriteSlave <= r.localAxiWriteSlave;
      
   end process;

end architecture structure;

