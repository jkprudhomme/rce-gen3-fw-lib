-------------------------------------------------------------------------------
-- Title      : PPI Inbound Payload Router
-- Project    : RCE Gen 3
-------------------------------------------------------------------------------
-- File       : PpiIbRoute.vhd
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

entity PpiIbRoute is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock and reset
      dmaClk          : in  sl;
      dmaClkRst       : in  sl;

      -- Incoming data
      dmaIbMaster     : in  AxiStreamMasterType;
      dmaIbSlave      : out AxiStreamSlaveType;

      -- Header data
      headIbMaster    : out AxiStreamMasterType;
      headIbSlave     : in  AxiStreamSlaveType;

      -- Payload data
      payIbMaster     : out AxiStreamMasterType;
      payIbSlave      : in  AxiStreamSlaveType
   );
end PpiIbRoute;

architecture structure of PpiIbRoute is

   signal intIbMaster : AxiStreamMasterType;
   signal intIbSlave  : AxiStreamSlaveType;
   signal payloadEn   : sl;

begin

   -- Sync incoming stream for timing
   U_StreamSync : entity work.AxiStreamPipeline 
      generic map (
         TPD_G         => TPD_G,
         PIPE_STAGES_G => 2
      ) port map (
         axisClk     => dmaClk,
         axisRst     => dmaClkRst,
         sAxisMaster => dmaIbMaster,
         sAxisSlave  => dmaIbSlave,
         mAxisMaster => intIbMaster,
         mAxisSlave  => intIbSlave
      );


   -- Destination MUX
   process ( payloadEn, headIbSlave, payIbSlave, intIbMaster ) is
      variable headMaster : AxiStreamMasterType;
      variable payMaster  : AxiStreamMasterType;
      variable intSlave   : AxiStreamSlaveType;
   begin
      headMaster := AXI_STREAM_MASTER_INIT_C;
      payMaster  := AXI_STREAM_MASTER_INIT_C;
      intSlave   := AXI_STREAM_SLAVE_INIT_C;

      -- Select destination
      if payloadEn = '0' then
         headMaster := intIbMaster;
         intSlave   := headIbSlave;

         -- Set tLast equal to EOH or frame last
         headMaster.tLast := intIbMaster.tLast or 
                             axiStreamGetUserBit(PPI_AXIS_CONFIG_INIT_C,intIbMaster,PPI_EOH_C);

         -- Set EOH to equal tLast for header frame
         axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, headMaster, PPI_EOH_C,intIbMaster.tLast);

      else
         payMaster := intIbMaster;
         intSlave  := payIbSlave;
      end if;

      -- Outputs
      headIbMaster <= headMaster;
      payIbMaster  <= payMaster;
      intIbSlave   <= intSlave;

   end process;


   -- Destination Select
   process ( dmaClk ) begin
      if rising_edge(dmaClk) then
         if dmaClkRst = '1' then
            payloadEn <= '0' after TPD_G;
         elsif intIbMaster.tValid = '1' and intIbSlave.tReady = '1' then

            -- Go to header mode on EOF
            if intIbMaster.tLast = '1' then
               payloadEn <= '0' after TPD_G;

            -- Go to payload mode on EOH (and not EOF)
            elsif axiStreamGetUserBit(PPI_AXIS_CONFIG_INIT_C,intIbMaster,PPI_EOH_C) = '1' then
               payloadEn <= '1' after TPD_G;
            end if;
         end if;
      end if;
   end process;

end structure;

