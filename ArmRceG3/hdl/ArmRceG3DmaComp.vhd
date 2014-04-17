-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Completion FIFOs
-- File          : ArmRceG3DmaComp.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 09/03/2013
-------------------------------------------------------------------------------
-- Description:
-- Completion Data Mover and completion FIFOs
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

entity ArmRceG3DmaComp is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock
      axiClk                  : in  sl;
      axiClkRst               : in  sl;

      -- Completion FIFOs
      compFromFifo            : in  CompFromFifoArray(7 downto 0);
      compToFifo              : out CompToFifoArray(7 downto 0);

      -- FIFO Read 
      localAxiReadMaster      : in  AxiLiteReadMasterType;
      localAxiReadSlave       : out AxiLiteReadSlaveType;
      localAxiWriteMaster     : in  AxiLiteWriteMasterType;
      localAxiWriteSlave      : out AxiLiteWriteSlaveType;

      -- FIFO Interrupts
      compInt                 : out slv(10 downto 0)

   );
end ArmRceG3DmaComp;

architecture structure of ArmRceG3DmaComp is

   -- Local Signals
   signal fifoCount     : slv(2 downto 0);
   signal fifoRead      : slv(7 downto 0);
   signal compHold      : CompFromFifoArray(7 downto 0);
   signal compWrite     : Slv16Array(7 downto 0);
   signal compDest      : Slv4Array(7 downto 0);
   signal compValid     : slv(7 downto 0);
   signal compFifoDout  : Slv36Array(15 downto 0);
   signal compFifoDin   : slv(35 downto 0);
   signal compFifoWrEn  : slv(10 downto 0);
   signal compFifoPFull : slv(10 downto 0);
   signal compFifoValid : slv(15 downto 0);
   signal compFifoRdEn  : slv(15 downto 0);
   signal axiClkRstInt  : sl := '1';

   type RegType is record
      compFifoRdEn       : slv(15 downto 0);
      compInt            : slv(10 downto 0);
      freeFifoWr         : sl;
      freeFifoDin        : slv(35 downto 0);
      localAxiReadSlave  : AxiLiteReadSlaveType;
      localAxiWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      compFifoRdEn       => (others => '0'),
      compInt            => (others => '0'),
      freeFifoWr         => '0',
      freeFifoDin        => (others => '0'),
      localAxiReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      localAxiWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
   );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute mark_debug : string;
   attribute mark_debug of axiClkRstInt : signal  is "true";
   attribute mark_debug of compFifoRdEn : signal  is "true";
   attribute mark_debug of compFifoDout : signal  is "true";

   attribute INIT : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- Holding location for FIFO outputs
   -- 8 Clocks are available for update
   U_HoldGen: for i in 0 to 7 generate
      process ( axiClk ) begin
         if rising_edge(axiClk) then
            if axiClkRstInt = '1' then
               compHold(i)  <= COMP_FROM_FIFO_INIT_C after TPD_G;
               compValid(i) <= '0'              after TPD_G;
               compWrite(i) <= (others=>'0')    after TPD_G;
            else

               -- Copy of FIFO data
               compHold(i) <= compFromFifo(i) after TPD_G;

               -- Determine if source and destination is ready, set valid bit
               compValid(i) <= compFromFifo(i).valid and 
                               (not compFifoPFull(conv_integer(compDest(i)))) after TPD_G;

               -- Generate write vector
               compWrite(i)                            <= (others=>'0') after TPD_G;
               compWrite(i)(conv_integer(compDest(i))) <= '1'           after TPD_G;

            end if;
         end if;
      end process;

      -- Filter destination
      compDest(i) <= compFromFifo(i).index when compFromFifo(i).index < 12 else "0000";

      -- Ready output
      compToFifo(i).read <= fifoRead(i);

   end generate;


   -- Sync logic
   process ( axiClk ) begin
      if rising_edge(axiClk) then
         if axiClkRstInt = '1' then
            compFifoDin  <= (others=>'0') after TPD_G;
            compFifoWrEn <= (others=>'0') after TPD_G;
            fifoRead     <= (others=>'0') after TPD_G;
            fifoCount    <= (others=>'0') after TPD_G;
         else
            compFifoDin(31 downto 0) <= compHold(conv_integer(fifoCount)).id  after TPD_G;

            -- Move data to output register
            for i in 0 to 10 loop
               compFifoWrEn(i) <= compValid(conv_integer(fifoCount)) and 
                                  compWrite(conv_integer(fifoCount))(i) after TPD_G;
            end loop;

            -- Read from source fifo
            fifoRead                          <= (others=>'0')                      after TPD_G; 
            fifoRead(conv_integer(fifoCount)) <= compValid(conv_integer(fifoCount)) after TPD_G;

            -- Fifo counter
            fifoCount <= fifoCount + 1 after TPD_G;

         end if;
      end if;
   end process;

   -----------------------------------------
   -- FIFOs
   -----------------------------------------
   U_FifoGen: for i in 0 to 10 generate
      U_CompFifo : entity work.Fifo
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
            DATA_WIDTH_G    => 36,
            ADDR_WIDTH_G    => 9,
            INIT_G          => "0",
            FULL_THRES_G    => 479,
            EMPTY_THRES_G   => 1
         ) port map (
            rst               => axiClkRstInt,
            wr_clk            => axiClk,
            wr_en             => compFifoWrEn(i),
            din               => compFifoDin,
            wr_data_count     => open,
            wr_ack            => open,
            overflow          => open,
            prog_full         => compFifoPFull(i),
            almost_full       => open,
            full              => open,
            not_full          => open,
            rd_clk            => axiClk,
            rd_en             => compFifoRdEn(i),
            dout              => compFifoDout(i),
            rd_data_count     => open,
            valid             => compFifoValid(i),
            underflow         => open,
            prog_empty        => open,
            almost_empty      => open,
            empty             => open
         );
   end generate;

   U_FreeFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => true,
         BRAM_EN_G       => false, -- Use Dist Ram
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         USE_BUILT_IN_G  => false,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 36,
         ADDR_WIDTH_G    => 4,
         INIT_G          => "0",
         FULL_THRES_G    => 15,
         EMPTY_THRES_G   => 1
      ) port map (
         rst               => axiClkRstInt,
         wr_clk            => axiClk,
         wr_en             => r.freeFifoWr,
         din               => r.freeFifoDin,
         wr_data_count     => open,
         wr_ack            => open,
         overflow          => open,
         prog_full         => open,
         almost_full       => open,
         full              => open,
         not_full          => open,
         rd_clk            => axiClk,
         rd_en             => compFifoRdEn(15),
         dout              => compFifoDout(15),
         rd_data_count     => open,
         valid             => compFifoValid(15),
         underflow         => open,
         prog_empty        => open,
         almost_empty      => open,
         empty             => open
      );

   compFifoDout(14 downto 11)  <= (others=>(others=>'0'));
   compFifoValid(14 downto 11) <= (others=>'0');


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
   process (axiClkRstInt, localAxiReadMaster, localAxiWriteMaster, compFifoDout, compFifoValid, r ) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      v.compFifoRdEn             := (others=>'0');
      v.compInt                  := compFifoValid(10 downto 0);
      v.freeFifoWr               := '0';
      v.freeFifoDin(31 downto 0) := localAxiWriteMaster.wdata;

      axiSlaveWaitTxn(localAxiWriteMaster, localAxiReadMaster, v.localAxiWriteSlave, v.localAxiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         if localAxiWriteMaster.awaddr(5 downto 2) = 15 then
            v.freeFifoWr := '1';
         end if;

         axiSlaveWriteResponse(v.localAxiWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then

         v.localAxiReadSlave.rdata := 
            compFifoDout(conv_integer(localAxiReadMaster.araddr(5 downto 2)))(31 downto 1) &
            (not compFifoValid(conv_integer(localAxiReadMaster.araddr(5 downto 2)))); -- Not valid is LSB

         v.compFifoRdEn(conv_integer(localAxiReadMaster.araddr(5 downto 2))) := '1';

         -- Send Axi Response
         axiSlaveReadResponse(v.localAxiReadSlave);
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
      compInt            <= r.compInt;
      compFifoRdEn       <= v.compFifoRdEn;
      
   end process;

end architecture structure;

