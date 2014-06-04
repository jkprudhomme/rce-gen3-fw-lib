-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, Interrupt Controller
-- File          : RceG3IntCntl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Interrupt control for RCE core.
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

   constant WINDOW_SIZE_C     : integer := 32;
   constant SRC_WINDOW_CNT_C  : integer := 16;
   constant GROUP_COUNT_C     : integer := 16;

   constant GROUP_BITS_C      : integer := bitSize(GROUP_COUNT_C-1);
   constant SRC_INT_COUNT_C   : integer := WINDOW_SIZE_C * SRC_WINDOW_CNT_C;
   constant WINDOW_SEL_BITS_C : integer := bitSize(SRC_WINDOW_CNT_C-1);

   signal locWindows : SlVectorArray(SRC_WINDOW_CNT_C-1 downto 0,WINDOW_SIZE_C-1 downto 0);

   type RegType is record
      intEnable        : SlVectorArray(GROUP_COUNT_C-1 downto 0,WINDOW_SIZE_C-1 downto 0);
      intStatus        : SlVectorArray(GROUP_COUNT_C-1 downto 0,WINDOW_SIZE_C-1 downto 0);
      groupSourceSel   : SlVectorArray(GROUP_COUNT_C-1 downto 0,WINDOW_SEL_BITS_C-1 downto 0);
      groupSourceMask  : SlVectorArray(GROUP_COUNT_C-1 downto 0,WINDOW_SIZE_C-1 downto 0);
      intOutput        : slv(GROUP_COUNT_C-1 downto 0);
      icAxilReadSlave  : AxiLiteReadSlaveType;
      icAxilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      intEnable        => (others=>(others=>'0')),
      intStatus        => (others=>(others=>'0')),
      groupSourceSel   => (others=>(others=>'0')),
      groupSourceMask  => (others=>(others=>'0')),
      intOutput        => (others=>'0'),
      icAxilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      icAxilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   --------------------------------------
   -- Interrupt Window Mapping
   --------------------------------------
   process ( axiDmaClk ) is
   begin
      if (rising_edge(axiDmaClk)) then
         if axiDmaRst = '1' then
            locWindows <= (others=>(others=>'0')) after TPD_G;
         else



      --dmaInterrupt        : in  slv(DMA_INT_COUNT_C-1 downto 0);
      --bsiInterrupt        : in  sl;
      --userInterrupt       : in  slv(USER_INT_COUNT_C-1 downto 0);






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
   process (r, axiDmaRst, icAxilReadMaster, icAxilWriteMaster, locWindows ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable wrGrpSel  : integer;
      variable rdGrpSel  : integer;
   begin
      v := r;

      -- Connect and drive interrupts
      for g in 0 to GROUP_COUNT_C-1 loop
         for i in 0 to WINDOW_SIZE_C-1 loop
            if r.intEnable(g,i) = '1' and r.groupSourceMask(g,i) = '1' then
               v.intStatus(g,i) := locWindows(conv_integer(muxSlVectorArray(r.groupSourceSel,g)),i);
            else
               v.intStatus(g,i) := '0';
            end if;
         end loop;

         v.intOutput(g) := uOr(muxSlVectorArray(r.intStatus,g));

      end loop;

      axiSlaveWaitTxn(icAxilWriteMaster, icAxilReadMaster, v.icAxilWriteSlave, v.icAxilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then
         wrGrpSel := conv_integer(icAxilWriteMaster.awaddr(GROUP_BITS_C+7 downto 8));

         -- Each group gets 8 bits of address space
         case icAxilWriteMaster.awaddr(7 downto 0) is

            -- Group source select
            when x"00" =>
               for i in 0 to WINDOW_SEL_BITS_C-1 loop
                  v.groupSourceSel(wrGrpSel,i) := icAxilWriteMaster.wdata(i);
               end loop;

            -- Group mask
            when x"04" =>
               for i in 0 to WINDOW_SIZE_C-1 loop
                  v.groupSourceMask(wrGrpSel,i) := icAxilWriteMaster.wdata(i);
               end loop;

            -- Int enable
            when x"08" =>
               for i in 0 to WINDOW_SIZE_C-1 loop
                  v.intEnable(wrGrpSel,i) := icAxilWriteMaster.wdata(i);
               end loop;

            when others =>
               null;
         end case;

         axiSlaveWriteResponse(v.icAxilWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         rdGrpSel := conv_integer(icAxilWriteMaster.awaddr(GROUP_BITS_C+7 downto 8));

         v.icAxilReadSlave.rdata := (others=>'0');

         -- Each group gets 8 bits of address space
         case icAxilReadMaster.araddr(7 downto 0) is

            -- Group source select
            when x"00" =>
               for i in 0 to WINDOW_SEL_BITS_C-1 loop
                  v.icAxilReadSlave.rdata(i) := r.groupSourceSel(rdGrpSel,i);
               end loop;

            -- Group mask
            when x"04" =>
               for i in 0 to WINDOW_SIZE_C-1 loop
                  v.icAxilReadSlave.rdata(i) := r.groupSourceMask(rdGrpSel,i);
               end loop;

            -- Int enable
            when x"08" =>
               for i in 0 to WINDOW_SIZE_C-1 loop
                  v.icAxilReadSlave.rdata(i) := r.intEnable(rdGrpSel,i);
               end loop;
      
            -- Int status/disable
            when x"0C" =>
               for i in 0 to WINDOW_SIZE_C-1 loop

                  -- Return active bits
                  v.icAxilReadSlave.rdata(i) := r.intStatus(rdGrpSel,i);

                  -- Disable any bits that are active
                  if r.intStatus(rdGrpSel,i) = '1' then
                     v.intEnable(rdGrpSel,i) := '0';
                  end if;
               end loop;

            when others =>
               null;
         end case;

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
      
   end process;

end architecture structure;

