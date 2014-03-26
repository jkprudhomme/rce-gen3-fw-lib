-------------------------------------------------------------------------------
-- Title         : General Purpopse EOF Counter For ASYNC FIFOs
-- File          : FifoEofAsync.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/21/2014
-------------------------------------------------------------------------------
-- Description:
-- PPI block to track the number of EOFs contained in an async FIFO.
-- Copies code from FifoAsync.vhd located in the StdLib.
-------------------------------------------------------------------------------
-- Copyright (c) 2014 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/21/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;

entity FifoEofAsync is
   generic (
      TPD_G         : time                  := 1 ns;
      USE_DSP48_G   : string                := "no";
      SYNC_STAGES_G : integer range 3 to (2**24) := 3;
      ADDR_WIDTH_G  : integer range 2 to 48 := 4
   );
   port (

      -- Asynchronous Reset
      rst           : in  sl;
      --Write Ports (wr_clk domain)
      wr_clk        : in  sl;
      wr_en         : in  sl;
      wr_eof        : in  sl;
      --Read Ports (rd_clk domain)
      rd_clk        : in  sl;
      rd_en         : in  sl;
      rd_eof        : in  sl;
      empty         : out sl
   );
end FifoEofAsync;

architecture structure of FifoEofAsync is

   constant RAM_DEPTH_C : integer := 2**ADDR_WIDTH_G;

   type RegType is record
      waddr   : slv(ADDR_WIDTH_G-1 downto 0);
      raddr   : slv(ADDR_WIDTH_G-1 downto 0);
      advance : slv(ADDR_WIDTH_G-1 downto 0);
      cnt     : slv(ADDR_WIDTH_G-1 downto 0);
      rdy     : sl;
      done    : sl;
   end record;
   
   constant READ_INIT_C : RegType := (
      (others => '0'),
      (others => '0'),
      conv_std_logic_vector(1, ADDR_WIDTH_G),
      (others => '0'),                  --empty during reset
      '0',
      '0');       

   constant WRITE_INIT_C : RegType := (
      (others => '0'),
      (others => '0'),
      conv_std_logic_vector(1, ADDR_WIDTH_G),
      (others => '1'),                  --full during reset
      '0',
      '0');       

   signal rdReg : RegType := READ_INIT_C;
   signal wrReg : RegType := WRITE_INIT_C;

   signal fullStatus : sl;
   signal readEnable : sl;

   signal readRst  : sl;
   signal writeRst : sl;

   signal rdReg_rdy : sl;
   signal wrReg_rdy : sl;

   constant SYNC_INIT_C  : slv(SYNC_STAGES_G-1 downto 0) := (others => '0');
   constant GRAY_INIT_C  : slv(ADDR_WIDTH_G-1 downto 0)  := (others => '0');
   signal   rdReg_rdGray : slv(ADDR_WIDTH_G-1 downto 0)  := GRAY_INIT_C;
   signal   rdReg_wrGray : slv(ADDR_WIDTH_G-1 downto 0)  := GRAY_INIT_C;
   signal   wrReg_rdGray : slv(ADDR_WIDTH_G-1 downto 0)  := GRAY_INIT_C;
   signal   wrReg_wrGray : slv(ADDR_WIDTH_G-1 downto 0)  := GRAY_INIT_C;

   type ReadStatusType is
   record
      count        : slv(ADDR_WIDTH_G-1 downto 0);
      prog_empty   : sl;
      almost_empty : sl;
      empty        : sl;
   end record;
   constant READ_STATUS_INIT_C : ReadStatusType := (
      (others => '0'),
      '1',
      '1',
      '1');   
   signal fifoStatus, fwftStatus : ReadStatusType := READ_STATUS_INIT_C;

   -- Attribute for XST
   attribute use_dsp48          : string;
   attribute use_dsp48 of rdReg : signal is USE_DSP48_G;
   attribute use_dsp48 of wrReg : signal is USE_DSP48_G;
   
begin

   -------------------------------
   -- rd_clk domain
   -------------------------------
   READ_RstSync : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         RELEASE_DELAY_G => SYNC_STAGES_G)   
      port map (
         clk      => rd_clk,
         asyncRst => rst,
         syncRst  => readRst); 

   fifoStatus.empty  <= '1' when (rdReg.cnt = 0) else readRst;

   -- Always first word fall through
   readEnable    <= ((rd_en and rd_eof) or fwftStatus.empty) and not(fifoStatus.empty);
   empty         <= fwftStatus.empty;
   process (rd_clk, readRst) is
   begin
      --asychronous reset
      if readRst = '1' then
         fwftStatus <= READ_STATUS_INIT_C after TPD_G;
      elsif rising_edge(rd_clk) then
         fwftStatus.prog_empty   <= fifoStatus.prog_empty                                         after TPD_G;
         fwftStatus.almost_empty <= fifoStatus.almost_empty                                       after TPD_G;
         fwftStatus.empty        <= ((rd_en and rd_eof) or fwftStatus.empty) and fifoStatus.empty after TPD_G;
         fwftStatus.count        <= fifoStatus.count                                              after TPD_G;
      end if;
   end process;

   SynchronizerVector_0 : entity work.SynchronizerVector
      generic map (
         TPD_G       => TPD_G,
         RST_ASYNC_G => true,
         STAGES_G    => SYNC_STAGES_G,
         WIDTH_G     => ADDR_WIDTH_G,
         INIT_G      => GRAY_INIT_C)
      port map (
         rst     => readRst,
         clk     => rd_clk,
         dataIn  => wrReg_wrGray,
         dataOut => rdReg_wrGray);

   Synchronizer_0 : entity work.Synchronizer
      generic map (
         TPD_G       => TPD_G,
         RST_ASYNC_G => true,
         STAGES_G    => SYNC_STAGES_G,
         INIT_G      => SYNC_INIT_C)
      port map (
         clk     => rd_clk,
         rst     => readRst,
         dataIn  => wrReg.done,
         dataOut => rdReg_rdy);         

   READ_SEQUENCE : process (rd_clk, readRst) is
   begin
      if readRst = '1' then
         rdReg        <= READ_INIT_C after TPD_G;
         rdReg_rdGray <= GRAY_INIT_C after TPD_G;
      elsif rising_edge(rd_clk) then
         rdReg.done <= '1' after TPD_G;
         if rdReg_rdy = '1' then

            --Decode the Gray code pointer
            rdReg.waddr <= grayDecode(rdReg_wrGray) after TPD_G;

            --check for read operation
            if readEnable = '1' then
               if fifoStatus.empty = '0' then
                  --increment the read address pointer
                  rdReg.raddr   <= rdReg.raddr + 1             after TPD_G;
                  rdReg.advance <= rdReg.advance + 1           after TPD_G;
                  --Calculate the count
                  rdReg.cnt     <= rdReg.waddr - rdReg.advance after TPD_G;
               else
                  --Calculate the count
                  rdReg.cnt   <= rdReg.waddr - rdReg.raddr after TPD_G;
               end if;
            else
               --Calculate the count
               rdReg.cnt <= rdReg.waddr - rdReg.raddr after TPD_G;
            end if;

            --Encode the Gray code pointer
            rdReg_rdGray <= grayEncode(rdReg.raddr) after TPD_G;
            
         end if;
      end if;
   end process READ_SEQUENCE;

   -------------------------------
   -- wr_clk domain
   -------------------------------   
   WRITE_RstSync : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         RELEASE_DELAY_G => SYNC_STAGES_G)   
      port map (
         clk      => wr_clk,
         asyncRst => rst,
         syncRst  => writeRst); 

   process (wr_clk, writeRst) is
   begin
      if writeRst = '1' then
         fullStatus  <= '1' after TPD_G;
      elsif rising_edge(wr_clk) then
         --fullStatus
         if (wrReg.cnt = (RAM_DEPTH_C-1)) or (wrReg.cnt = (RAM_DEPTH_C-2)) then
            fullStatus <= '1' after TPD_G;
         else
            fullStatus <= '0' after TPD_G;
         end if;
      end if;
   end process;

   SynchronizerVector_1 : entity work.SynchronizerVector
      generic map (
         TPD_G       => TPD_G,
         RST_ASYNC_G => true,
         STAGES_G    => SYNC_STAGES_G,
         WIDTH_G     => ADDR_WIDTH_G,
         INIT_G      => GRAY_INIT_C)
      port map (
         rst     => writeRst,
         clk     => wr_clk,
         dataIn  => rdReg_rdGray,
         dataOut => wrReg_rdGray);

   Synchronizer_1 : entity work.Synchronizer
      generic map (
         TPD_G       => TPD_G,
         RST_ASYNC_G => true,
         STAGES_G    => SYNC_STAGES_G,
         INIT_G      => SYNC_INIT_C)
      port map (
         clk     => wr_clk,
         rst     => writeRst,
         dataIn  => rdReg.done,
         dataOut => wrReg_rdy);           

   WRITE_SEQUENCE : process (wr_clk, writeRst) is
   begin
      if writeRst = '1' then
         wrReg        <= WRITE_INIT_C after TPD_G;
         wrReg_wrGray <= GRAY_INIT_C  after TPD_G;
      elsif rising_edge(wr_clk) then
         wrReg.done <= '1' after TPD_G;
         if wrReg_rdy = '1' then
            if wrReg.rdy = '0' then
               wrReg.rdy <= '1';
               wrReg.cnt <= (others => '0');
            else

               --Decode the Gray code pointer
               wrReg.raddr <= grayDecode(wrReg_rdGray) after TPD_G;

               --check for write operation
               if wr_en = '1' and wr_eof = '1' then
                  if fullStatus = '0' then
                     --increment the read address pointer
                     wrReg.waddr   <= wrReg.waddr + 1             after TPD_G;
                     wrReg.advance <= wrReg.advance + 1           after TPD_G;
                     --Calculate the count
                     wrReg.cnt     <= wrReg.advance - wrReg.raddr after TPD_G;
                  else
                     --Calculate the count
                     wrReg.cnt   <= wrReg.waddr - wrReg.raddr after TPD_G;
                  end if;
               else
                  --Calculate the count
                  wrReg.cnt <= wrReg.waddr - wrReg.raddr after TPD_G;
               end if;

               --Encode the Gray code pointer
               wrReg_wrGray <= grayEncode(wrReg.waddr) after TPD_G;
               
            end if;
         end if;
      end if;
   end process WRITE_SEQUENCE;

end architecture structure;

