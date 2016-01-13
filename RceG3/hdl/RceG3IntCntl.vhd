-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, Interrupt Controller
-- File          : RceG3IntCntl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Interrupt control for RCE core.
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
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity RceG3IntCntl is
   generic (
      TPD_G           : time           := 1 ns;
      RCE_DMA_MODE_G  : RceDmaModeType := RCE_DMA_PPI_C
   );
   port (

      -- AXI BUS Clock
      axiDmaClk           : in  sl;
      axiDmaRst           : in  sl;

      -- Local AXI Lite Bus
      icAxilReadMaster    : in  AxiLiteReadMasterType;
      icAxilReadSlave     : out AxiLiteReadSlaveType;
      icAxilWriteMaster   : in  AxiLiteWriteMasterType;
      icAxilWriteSlave    : out AxiLiteWriteSlaveType;

      -- Interrupt Inputs
      dmaInterrupt        : in  slv(DMA_INT_COUNT_C-1 downto 0);
      bsiInterrupt        : in  sl;
      userInterrupt       : in  slv(USER_INT_COUNT_C-1 downto 0);

      -- Interrupt Outputs
      armInterrupt        : out slv(15 downto 0)
   );
end RceG3IntCntl;

architecture structure of RceG3IntCntl is

   constant GROUP_SIZE_C       : integer range 1 to 32 := 32;
   constant GROUP_COUNT_C      : integer range 1 to 16 := 8;

   constant DEST_COUNT_C       : integer := GROUP_SIZE_C * GROUP_COUNT_C;
   constant DEST_COUNT_BITS_C  : integer := bitSize(DEST_COUNT_C-1);
   constant GROUP_SIZE_BITS_C  : integer := bitSize(GROUP_SIZE_C-1);
   constant GROUP_COUNT_BITS_C : integer := bitSize(GROUP_COUNT_C-1);

   constant SRC_COUNT_C        : integer := DMA_INT_COUNT_C + USER_INT_COUNT_C + 1;
   constant SRC_COUNT_BITS_C   : integer := bitSize(SRC_COUNT_C-1);

   signal locSources : slv(SRC_COUNT_C-1 downto 0);

   type RegType is record
      intEnable        : SlVectorArray(GROUP_COUNT_C-1 downto 0, GROUP_SIZE_C-1 downto 0);
      intStatus        : SlVectorArray(GROUP_COUNT_C-1 downto 0, GROUP_SIZE_C-1 downto 0);
      intSourceSel     : SlVectorArray(DEST_COUNT_C-1  downto 0, SRC_COUNT_BITS_C-1 downto 0);
      intSourceEn      : slv(DEST_COUNT_C-1  downto 0);
      intOutput        : slv(GROUP_COUNT_C-1 downto 0);
      icAxilReadSlave  : AxiLiteReadSlaveType;
      icAxilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      intEnable        => (others=>(others=>'0')),
      intStatus        => (others=>(others=>'0')),
      intSourceSel     => (others=>(others=>'0')),
      intSourceEn      => (others=>'0'),
      intOutput        => (others=>'0'),
      icAxilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      icAxilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   --------------------------------------
   -- Interrupt Registration
   --------------------------------------
   process ( axiDmaClk ) is
   begin
      if (rising_edge(axiDmaClk)) then
         if axiDmaRst = '1' then
            locSources <= (others=>'0') after TPD_G;
         else

            if RCE_DMA_MODE_G = RCE_DMA_PPI_C then
               locSources(DMA_INT_COUNT_C-1 downto 0)          <= dmaInterrupt  after TPD_G;
            end if;
            locSources(DMA_INT_COUNT_C)                        <= bsiInterrupt  after TPD_G;
            locSources(SRC_COUNT_C-1 downto DMA_INT_COUNT_C+1) <= userInterrupt after TPD_G;
         end if;
      end if;
   end process;


   --------------------------------------
   -- Interrupt Handling
   --------------------------------------

   -- Sync
   process (axiDmaClk) is
   begin
      if (rising_edge(axiDmaClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiDmaRst, dmaInterrupt, icAxilReadMaster, icAxilWriteMaster, locSources, r) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      -- Connect and drive interrupts
      for g in 0 to GROUP_COUNT_C-1 loop
         for i in 0 to GROUP_SIZE_C-1 loop
            if r.intEnable(g,i) = '1' and r.intSourceEn((g*GROUP_SIZE_C)+i) = '1' then
               v.intStatus(g,i) := locSources(conv_integer(muxSlVectorArray(r.intSourceSel,(g*GROUP_SIZE_C)+i)));
            else
               v.intStatus(g,i) := '0';
            end if;
         end loop;

         v.intOutput(g) := uOr(muxSlVectorArray(r.intStatus,g));
      end loop;

      axiSlaveWaitTxn(icAxilWriteMaster, icAxilReadMaster, v.icAxilWriteSlave, v.icAxilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Source Registers 0x0xxx
         if icAxilWriteMaster.awaddr(15) = '0' then
            for i in 0 to SRC_COUNT_BITS_C-1 loop
               v.intSourceSel(conv_integer(icAxilWriteMaster.awaddr(DEST_COUNT_BITS_C+1 downto 2)),i) := icAxilWriteMaster.wdata(i);
            end loop;
            v.intSourceEn(conv_integer(icAxilWriteMaster.awaddr(DEST_COUNT_BITS_C+1 downto 2)))  := icAxiLWriteMaster.wdata(31);

         -- Enable Registers, 0x8xx0
         elsif icAxilWriteMaster.awaddr(3 downto 2) = "00" then
            for i in 0 to GROUP_SIZE_C-1 loop
               if icAxilWriteMaster.wdata(i) = '1' then
                  v.intEnable(conv_integer(icAxilWriteMaster.awaddr(GROUP_COUNT_BITS_C+3 downto 4)),i) := '1';
               end if;
            end loop;

         -- Status/Disable Registers, 0x8xx8
         elsif icAxilWriteMaster.awaddr(3 downto 2) = "10" then
            for i in 0 to GROUP_SIZE_C-1 loop
               if icAxilWriteMaster.wdata(i) = '1' then
                  v.intEnable(conv_integer(icAxilWriteMaster.awaddr(GROUP_COUNT_BITS_C+3 downto 4)),i) := '0';
               end if;
            end loop;
         end if;

         -- Send Axi Response
         axiSlaveWriteResponse(v.icAxilWriteSlave);

      end if;
            
      -- Read
      if (axiStatus.readEnable = '1') then
         v.icAxilReadSlave.rdata := (others=>'0');

         -- Enable/source Registers 0x0xxx
         if icAxilReadMaster.araddr(15) = '0' then
            for i in 0 to SRC_COUNT_BITS_C-1 loop
               v.icAxilReadSlave.rdata(i) := r.intSourceSel(conv_integer(icAxilReadMaster.araddr(DEST_COUNT_BITS_C+1 downto 2)),i);
            end loop;
            v.icAxilReadSlave.rdata(31) := r.intSourceEn(conv_integer(icAxilReadMaster.araddr(DEST_COUNT_BITS_C+1 downto 2)));

         -- Enable Registers, 0x8xx0
         elsif icAxilReadMaster.araddr(3 downto 2) = "00" then
            for i in 0 to GROUP_SIZE_C-1 loop
               v.icAxilReadSlave.rdata(i) := r.intEnable(conv_integer(icAxilReadMaster.araddr(GROUP_COUNT_BITS_C+3 downto 4)),i);
            end loop;

         -- Status/Disable Registers, 0x8xx8
         elsif icAxilReadMaster.araddr(3 downto 2) = "10" then
            for i in 0 to GROUP_SIZE_C-1 loop

               -- Return active bits
               v.icAxilReadSlave.rdata(i) := r.intStatus(conv_integer(icAxilReadMaster.araddr(GROUP_COUNT_BITS_C+3 downto 4)),i);

               -- Disable any bits that are active
               if r.intStatus(conv_integer(icAxilReadMaster.araddr(GROUP_COUNT_BITS_C+3 downto 4)),i) = '1' then
                  v.intEnable(conv_integer(icAxilReadMaster.araddr(GROUP_COUNT_BITS_C+3 downto 4)),i) := '0';
               end if;
            end loop;
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.icAxilReadSlave);

      end if;

      -- Reset
      if axiDmaRst = '1' or RCE_DMA_MODE_G /= RCE_DMA_PPI_C then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      icAxilReadSlave  <= r.icAxilReadSlave;
      icAxilWriteSlave <= r.icAxilWriteSlave;
      armInterrupt     <= (others=>'0');

      armInterrupt(GROUP_COUNT_C-1 downto 0) <= r.intOutput;

      if RCE_DMA_MODE_G = RCE_DMA_AXIS_C then
         armInterrupt(15 downto 12) <= dmaInterrupt(3 downto 0) after TPD_G;
      end if;
      
   end process;

end architecture structure;

