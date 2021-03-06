-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, BSI Controller
-- File          : RceG3Bsi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/08/2014
-------------------------------------------------------------------------------
-- Description:
-- I2C Slave block for IPMI operations:
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 05/08/2014: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.i2cPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;

entity RceG3Bsi is
   generic (
      TPD_G  : time := 1 ns
   );
   port (

      -- Clock and reset
      axiClk          : in  sl;
      axiClkRst       : in  sl;
      axiDmaClk       : in  sl;
      axiDmaRst       : in  sl;

      -- AXI Lite Busses
      -- Channel 0 = 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
      -- Channel 1 = 0x88000000 - 0x88000FFF : DMA Control Registers
      axilReadMaster  : in  AxiLiteReadMasterArray(1 downto 0);
      axilReadSlave   : out AxiLiteReadSlaveArray(1 downto 0);
      axilWriteMaster : in  AxiLiteWriteMasterArray(1 downto 0);
      axilWriteSlave  : out AxiLiteWriteSlaveArray(1 downto 0);

      -- AXI Interface For FIFO Push
      acpWriteMaster  : out AxiWriteMasterType;
      acpWriteSlave   : in  AxiWriteSlaveType;

      -- Interrupt
      bsiInterrupt    : out sl;
      armEthMode      : in  slv(31 downto 0);
      eFuseValue      : in  slv(31 downto 0);
      deviceDna       : in  slv(63 downto 0);

      -- IIC Interface
      i2cSda          : inout sl;
      i2cScl          : inout sl
   );
end RceG3Bsi;

architecture IMP of RceG3Bsi is

   signal i2cBramRd       : sl;
   signal i2cBramWr       : sl;
   signal i2cBramAddr     : slv(15 downto 0);
   signal i2cBramDout     : slv( 7 downto 0);
   signal locBramDout     : slv( 7 downto 0);
   signal i2cBramDin      : slv( 7 downto 0);
   signal cpuBramDout     : slv(31 downto 0);
   signal i2cIn           : i2c_in_type;
   signal i2cOut          : i2c_out_type;
   signal bsiFifoWrite    : sl;
   signal bsiFifoDin      : slv(47 downto 0);
   signal bsiFifoAFull    : sl;
   signal bsiFifoDout     : slv(47 downto 0);
   signal bsiFifoValid    : sl;
   signal aFullData       : slv(7 downto 0);
   signal intWriteMaster  : AxiWriteMasterType;
   signal intWriteSlave   : AxiWriteSlaveType;

   type RegType is record
      cpuBramWr      : sl;
      cpuBramAddr    : slv(8  downto 0);
      cpuBramDin     : slv(31 downto 0);
      readEnDly      : slv(1  downto 0);
      bsiFifoRd      : sl;
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      cpuBramWr      => '0',
      cpuBramAddr    => (others=>'0'),
      cpuBramDin     => (others=>'0'),
      readEnDly      => (others=>'0'),
      bsiFifoRd      => '0',
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   type StateType is (S_IDLE_C, S_ADDR_C, S_DATA_C, S_WAIT_C);

   type BsiType is record
      bsiTest             : sl;
      fifoEnable          : slv(8  downto  0);
      memBaseAddress      : slv(31 downto 18);
      writeDmaCache       : slv(3 downto 0);
      readDmaCache        : slv(3 downto 0);
      intEnable           : slv(15  downto 0);
      ppiReadDmaCache     : slv(3 downto 0);
      ppiWriteDmaCache    : slv(3 downto 0);
      state               : StateType;
      dirty               : sl;
      bsiFifoRd           : sl;
      wMaster             : AxiWriteMasterType;
      axilReadSlave       : AxiLiteReadSlaveType;
      axilWriteSlave      : AxiLiteWriteSlaveType;
   end record BsiType;

   constant BSI_INIT_C : BsiType := (
      bsiTest             => '0',
      fifoEnable          => (others=>'0'),
      memBaseAddress      => (others=>'0'),
      writeDmaCache       => (others=>'0'),
      readDmaCache        => (others=>'0'),
      intEnable           => (others=>'0'),
      ppiReadDmaCache     => (others=>'0'),
      ppiWriteDmaCache    => (others=>'0'),
      state               => S_IDLE_C,
      dirty               => '0',
      bsiFifoRd           => '0',
      wMaster             => AXI_WRITE_MASTER_INIT_C,
      axilReadSlave       => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave      => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal b   : BsiType := BSI_INIT_C;
   signal bin : BsiType;

   signal bsiFifoRd    : sl;
   signal bsiFifoRdAxi : sl;
   signal bsiFifoRdAcp : sl;

begin


   -------------------------
   -- I2c Slave
   -------------------------
   U_i2cb: entity work.i2cRegSlave 
      generic map (
         TPD_G                => TPD_G,
         TENBIT_G             => 0,
         I2C_ADDR_G           => 73, -- "1001001";
         OUTPUT_EN_POLARITY_G => 0,
         FILTER_G             => 4,
         ADDR_SIZE_G          => 2, -- in bytes
         DATA_SIZE_G          => 1, -- in bytes
         ENDIANNESS_G         => 0  -- 0=LE, 1=BE
      ) port map (
         sRst   => '0',
         aRst   => axiClkRst,
         clk    => axiClk,
         addr   => i2cBramAddr,
         wrEn   => i2cBramWr,
         wrData => i2cBramDin,
         rdEn   => i2cBramRd,
         rdData => i2cBramDout,
         i2ci   => i2cIn,
         i2co   => i2cOut
      );

   U_I2cScl : IOBUF port map ( IO => i2cScl,
                               I  => i2cOut.scl,
                               O  => i2cIn.scl,
                               T  => i2cOut.scloen);

   U_I2cSda : IOBUF port map ( IO => i2cSda,
                               I  => i2cOut.sda,
                               O  => i2cIn.sda,
                               T  => i2cOut.sdaoen);


   -------------------------
   -- Dual port ram
   -------------------------
   bram_0 : RAMB16_S9_S36  
      port map ( 
         DOB   => cpuBramDout,
         DOPB  => open,
         ADDRB => r.cpuBramAddr,
         CLKB  => axiClk,
         DIB   => r.cpuBramDin,
         DIPB  => x"0",
         ENB   => '1',
         SSRB  => '0',
         WEB   => r.cpuBramWr,
         DOA   => locBramDout,
         DOPA  => open,
         ADDRA => i2cBramAddr(10 downto 0),
         CLKA  => axiClk,
         DIA   => i2cBramDin,
         DIPA  => "0",
         ENA   => '1',
         SSRA  => '0',
         WEA   => i2cBramWr
      );

   -- Mux I2C Output Data
   process ( i2cBramAddr, aFullData, armEthMode, eFuseValue, deviceDna, locBramDout ) begin
      case i2cBramAddr(11 downto 0) is 
         when x"800" => i2cBramDout <= aFullData; -- Bit 0 = AFULL
         when x"801" => i2cBramDout <= (others=>'0');
         when x"802" => i2cBramDout <= (others=>'0');
         when x"803" => i2cBramDout <= (others=>'0');
         when x"804" => i2cBramDout <= armEthMode(7  downto  0);
         when x"805" => i2cBramDout <= armEthMode(15 downto  8);
         when x"806" => i2cBramDout <= armEthMode(23 downto 16);
         when x"807" => i2cBramDout <= armEthMode(31 downto 24);
         when x"808" => i2cBramDout <= eFuseValue(7  downto  0);
         when x"809" => i2cBramDout <= eFuseValue(15 downto  8);
         when x"80A" => i2cBramDout <= eFuseValue(23 downto 16);
         when x"80B" => i2cBramDout <= eFuseValue(31 downto 24);
         when x"80C" => i2cBramDout <= deviceDna(7  downto  0);
         when x"80D" => i2cBramDout <= deviceDna(15 downto  8);
         when x"80E" => i2cBramDout <= deviceDna(23 downto 16);
         when x"80F" => i2cBramDout <= deviceDna(31 downto 24);
         when x"810" => i2cBramDout <= deviceDna(39 downto 32);
         when x"811" => i2cBramDout <= deviceDna(47 downto 40);
         when x"812" => i2cBramDout <= deviceDna(55 downto 48);
         when x"813" => i2cBramDout <= deviceDna(63 downto 56);
         when others => i2cBramDout <= locBramDout; -- DPRAM 0x000 - 0x7FF
      end case;
   end process;

   -- Register almost full data
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            aFullData <= (others=>'0') after TPD_G;
         else
            aFullData(0) <= bsiFifoAFull after TPD_G;
         end if;
      end if;
   end process;


   -------------------------
   -- BSI CPU Interface
   -------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRst, axilReadMaster(0), axilWriteMaster(0), cpuBramDout, r, bsiFifoValid, bsiFifoDout ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.bsiFifoRd := '0';
      v.cpuBramWr := '0';
      v.readEnDly := (others=>'0');

      axiSlaveWaitTxn(axilWriteMaster(0), axilReadMaster(0), v.axilWriteSlave, v.axilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Write only to block ram
         if axilWriteMaster(0).awaddr(11) = '0' then
            v.cpuBramWr   := '1';
            v.cpuBramAddr := axilWriteMaster(0).awaddr(10 downto 2);
            v.cpuBramDin  := axilWriteMaster(0).wdata;
         end if;
         axiSlaveWriteResponse(v.axilWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.cpuBramAddr := axilReadMaster(0).araddr(10 downto 2);

         -- Read from to block ram
         if axilReadMaster(0).araddr(11) = '0' then
            v.readEnDly(0) := '1';
            v.readEnDly(1) := r.readEnDly(0);

            -- Send Axi Response
            if ( r.readEnDly(1) = '1' ) then
               v.axilReadSlave.rdata := cpuBramDout;
               axiSlaveReadResponse(v.axilReadSlave);
            end if;
         else
            v.bsiFifoRd                        := bsiFifoValid;
            v.axilReadSlave.rdata(15 downto 0) := bsiFifoDout(47 downto 32);
            v.axilReadSlave.rdata(16)          := bsiFifoValid;
            axiSlaveReadResponse(v.axilReadSlave);
         end if;
      end if;

      -- Reset
      if (axiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axilReadSlave(0)  <= r.axilReadSlave;
      axilWriteSlave(0) <= r.axilWriteSlave;
      bsiFifoRdAxi      <= r.bsiFifoRd;
      
   end process;


   --------------------------------------------------
   -- BSI FIFO 
   --------------------------------------------------
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            bsiFifoDin   <= (others=>'0') after TPD_G;
            bsiFifoWrite <= '0'           after TPD_G;
         elsif i2cBramWr = '1' then
            if i2cBramAddr(1 downto 0) = 0 then
               bsiFifoDin(7  downto  0) <= i2cBramDin after TPD_G;
               bsiFifoWrite             <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 1 then
               bsiFifoDin(15 downto 8)  <= i2cBramDin after TPD_G;
               bsiFifoWrite             <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 2 then
               bsiFifoDin(23 downto 16) <= i2cBramDin after TPD_G;
               bsiFifoWrite             <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 3 then
               bsiFifoDin(47 downto 32) <= i2cBramAddr after TPD_G;
               bsiFifoDin(31 downto 24) <= i2cBramDin  after TPD_G;
               bsiFifoWrite             <= '1'         after TPD_G;
            end if;
         else
            bsiFifoWrite <= '0' after TPD_G;
         end if;
      end if;
   end process;


   U_BsiFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => true,
         BRAM_EN_G       => true,
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         USE_BUILT_IN_G  => true,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 48,
         ADDR_WIDTH_G    => 9,
         INIT_G          => "0",
         FULL_THRES_G    => 479,
         EMPTY_THRES_G   => 1
      ) port map (
         rst             => axiClkRst,
         wr_clk          => axiClk,
         wr_en           => bsiFifoWrite,
         din             => bsiFifoDin,
         wr_data_count   => open,
         wr_ack          => open,
         overflow        => open,
         prog_full       => bsiFifoAFull,
         almost_full     => open,
         full            => open,
         not_full        => open,
         rd_clk          => axiClk,
         rd_en           => bsiFifoRd,
         dout            => bsiFifoDout,
         rd_data_count   => open,
         valid           => bsiFifoValid,
         underflow       => open,
         prog_empty      => open,
         almost_empty    => open,
         empty           => open
      );

   bsiFifoRd <= bsiFifoRdAcp or bsiFifoRdAxi;

   --------------------------------------------------
   -- ACP Push
   --------------------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         b <= bin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRst, b, axilWriteMaster(1), axilReadMaster(1), intWriteSlave, bsiFifoValid, bsiFifoDout ) is
      variable v         : BsiType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := b;

      v.bsiTest := '0';

      ------------------------
      -- Register Space
      ------------------------

      axiSlaveWaitTxn(axilWriteMaster(1), axilReadMaster(1), v.axilWriteSlave, v.axilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Dirty flag clear, 0x88000310
         if axilWriteMaster(1).awaddr(11 downto 0) = x"310" then
            v.dirty := '0';

            -- Single entry registers, 0x880004xx
         elsif axilWriteMaster(1).awaddr(11 downto 8) = x"4" then
            case (axilWriteMaster(1).awaddr(7 downto 0)) is

               -- IntEnable, Bit 4 = BSI FIFO
               when X"04" =>
                  v.intEnable := axilWriteMaster(1).wdata(15 downto 0);

               when X"08" =>
                  v.writeDmaCache := axilWriteMaster(1).wdata(3 downto 0);

               when X"0C" =>
                  v.readDmaCache := axilWriteMaster(1).wdata(3 downto 0);

               -- FIFO Enable, Bit 4 = BSI FIFO
               when X"10" =>
                  v.fifoEnable := axilWriteMaster(1).wdata(8 downto 0);

               -- Memory base address 0x88000418
               when X"18" =>
                  v.memBaseAddress := axilWriteMaster(1).wdata(31 downto 18);

               when X"1C" =>
                  v.ppiReadDmaCache := axilWriteMaster(1).wdata(3 downto 0);

               when X"20" =>
                  v.ppiWriteDmaCache := axilWriteMaster(1).wdata(3 downto 0);

               when X"80" =>
                  v.bsiTest := axilWriteMaster(1).wdata(0);

               when others => null;
            end case;
         end if;

         axiSlaveWriteResponse(v.axilWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axilReadSlave.rdata := (others => '0');

         -- Decode address and perform write
         case (axilReadMaster(1).araddr(11 downto 0)) is

            -- Dirty/Ready status, 16 bits 0x88000400
            -- Bits 4     = BSI FIFO
            when X"400" =>
               v.axilReadSlave.rdata(4) := b.dirty;

            when X"404" =>
               v.axilReadSlave.rdata(15 downto 0) := b.intEnable;

            when X"408" =>
               v.axilReadSlave.rdata(3 downto 0) := b.writeDmaCache;

            when X"40C" =>
               v.axilReadSlave.rdata(3 downto 0) := b.readDmaCache;

            -- FIFO Enable, 20 bits - 0x88000410
            -- Bits 4     = BSI FIFO
            when X"410" =>
               v.axilReadSlave.rdata(8 downto 0) := b.fifoEnable;

            -- Memory base address 0x88000418
            when X"418" =>
               v.axilReadSlave.rdata(31 downto 18) := b.memBaseAddress;

            when X"41C" =>
               v.axilReadSlave.rdata(3 downto 0) := b.ppiReadDmaCache;

            when X"420" =>
               v.axilReadSlave.rdata(3 downto 0) := b.ppiWriteDmaCache;

            when others => null;
         end case;

         axiSlaveReadResponse(v.axilReadSlave);
      end if;


      ------------------------
      -- State Machine
      ------------------------

      -- Init
      v.wMaster.awvalid := '0';
      v.wMaster.bready  := '1';
      v.bsiFifoRd       := '0';

      case b.state is

         when S_IDLE_C =>
            if (bsiFifoValid = '1' and b.dirty = '0' and b.fifoEnable(4) = '1') or b.bsiTest = '1' then
               v.state := S_ADDR_C;
            end if;

         when S_ADDR_C =>
            v.wMaster.awaddr(31 downto 18) := b.memBaseAddress;
            v.wMaster.awaddr(17 downto  8) := (others=>'0');
            v.wMaster.awaddr(7  downto  3) := "00100";
            v.wMaster.awvalid              := '1';

            if intWriteSlave.awready = '1' and b.wMaster.awvalid = '1' then
               v.wMaster.awvalid := '0';
               v.state           := S_DATA_C;
            end if;

         when S_DATA_C =>
               v.wMaster.wvalid              := '1';
               v.wMaster.wdata(63 downto 0)  := x"0000" & bsiFifoDout;

            if intWriteSlave.wready = '1' and b.wMaster.wvalid = '1' then
               v.wMaster.wvalid := '0';
               v.state          := S_WAIT_C;
               v.bsiFifoRd      := '1';
            end if;

         when S_WAIT_C =>
            if intWriteSlave.bvalid = '1' then
               v.state := S_IDLE_C;
               v.dirty := '1';
            end if;

         when others => 
            null;

      end case;

      -- Reset
      if (axiClkRst = '1') then
         v := BSI_INIT_C;
      end if;

      -- Static Signals
      v.wMaster.awsize  := "111";
      v.wMaster.awburst := "01";
      v.wMaster.awcache := "1111";
      v.wMaster.awlen   := (others=>'0');
      v.wMaster.awlock  := "00";   -- Unused
      v.wMaster.awprot  := "000";  -- Unused
      v.wMaster.awid    := (others=>'0');
      v.wMaster.wid     := (others=>'0');
      v.wMaster.wlast   := '1';
      v.wMaster.wstrb   := (others=>'1');

      -- Next register assignment
      bin <= v;

      -- Outputs
      axilReadSlave(1)  <= b.axilReadSlave;
      axilWriteSlave(1) <= b.axilWriteSlave;
      intWriteMaster    <= b.wMaster;
      bsiFifoRdAcp      <= b.bsiFifoRd;

   end process;

   bsiInterrupt <= b.intEnable(4) and b.dirty;

   -- Write path FIFO
   U_AxiWritePathFifo : entity work.AxiWritePathFifo
      generic map (
         TPD_G                    => TPD_G,
         XIL_DEVICE_G             => "7SERIES",
         USE_BUILT_IN_G           => false,
         GEN_SYNC_FIFO_G          => false,
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
         DATA_FIFO_PAUSE_THRESH_G => 1,
         RESP_BRAM_EN_G           => false,
         RESP_CASCADE_SIZE_G      => 1,
         RESP_FIFO_ADDR_WIDTH_G   => 4,
         AXI_CONFIG_G             => AXI_ACP_INIT_C
      ) port map (
         sAxiClk         => axiClk,
         sAxiRst         => axiClkRst,
         sAxiWriteMaster => intWriteMaster,
         sAxiWriteSlave  => intWriteSlave,
         sAxiCtrl        => open,
         mAxiClk         => axiDmaClk,
         mAxiRst         => axiDmaRst,
         mAxiWriteMaster => acpWriteMaster,
         mAxiWriteSlave  => acpWriteSlave
      );

end architecture IMP;

