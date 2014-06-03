-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : PpiPkg.vhd
-- Author     : Ryan Herbst  <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2014-05-27
-- Last update: 2014-05-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

package PpiPkg is

   constant PPI_EOH_C  : integer := 0;
   constant PPI_ERR_C  : integer := 1;

   constant PPI_TDATA_BYTES_C : integer       := 8;
   constant PPI_TUSER_BITS_C  : integer       := 2;
   constant PPI_TDEST_BITS_C  : integer       := 4;
   constant PPI_TID_BITS_C    : integer       := 0;
   constant PPI_TSTRB_EN_C    : boolean       := false;
   constant PPI_TKEEP_MODE_C  : TKeepModeType := TKEEP_COMP_C;
   constant PPI_TUSER_MODE_C  : TUserModeType := TUSER_LAST_C;

   constant PPI_MAX_HEADER_C     : slv(31 downto 0) := x"00000100";
   constant PPI_OCM_BASE_ADDR_C  : slv(31 downto 0) := x"FFFC0000";
   constant PPI_AXI_BURST_C      : slv(1 downto 0)  := "01";
   constant PPI_AXI_CACHE_C      : slv(3 downto 0)  := "1111";

   constant PPI_COMP_CNT_C       : integer := 32;
   constant PPI_COMP_RD_ERR_C    : integer := 6;
   constant PPI_COMP_WR_ERR_C    : integer := 7;
   constant PPI_COMP_FRAME_ERR_C : integer := 8;
   constant PPI_COMP_OFLOW_ERR_C : integer := 9;

   -------------------------------------------------------------------------------------------------
   -- Build an PPI configuration
   -------------------------------------------------------------------------------------------------
   function ppiAxiStreamConfig (
      dataBytes : natural := PPI_TDATA_BYTES_C)
      return AxiStreamConfigType;

   -- A default PPI config is useful to have
   constant PPI_AXIS_CONFIG_INIT_C : AxiStreamConfigType := ppiAxiStreamConfig(PPI_TDATA_BYTES_C);

   -------------------------------------------------------------------------------------------------
   -- PPI Records and AXI-Stream conversion functions
   -------------------------------------------------------------------------------------------------
   type PpiMasterType is record
      data   : slv((PPI_TDATA_BYTES_C*8)-1 downto 0);        -- Data
      size   : slv(bitSize(PPI_TDATA_BYTES_C-1)-1 downto 0); -- Number of valid bytes
      eof    : sl;                                           -- End of frame indication
      eoh    : sl;                                           -- End of header, inbound PPI only
      err    : sl;                                           -- Frame has error, inbound PPI only
      ftype  : slv(PPI_TDEST_BITS_C-1 downto 0);             -- Frame type
      valid  : sl;                                           -- Frame data is valid
   end record PpiMasterType;

   type PpiSlaveType is record
      ready    : sl;
      pause    : sl;
      overflow : sl;
   end record PpiSlaveType;

   function ppi2AxisMaster (
      axisConfig : AxiStreamConfigType;
      ppiMaster  : PpiMasterType)
      return AxiStreamMasterType;

   function ppi2AxisSlave (
      ppiSlave : PpiSlaveType)
      return AxiStreamSlaveType;

   function ppi2AxisCtrl (
      ppiSlave : PpiSlaveType)
      return AxiStreamCtrlType;

   function axis2PpiMaster (
      axisConfig : AxiStreamConfigType;
      axisMaster : AxiStreamMasterType)
      return PpiMasterType;

   function axis2PpiSlave (
      axisConfig : AxiStreamConfigType;
      axisSlave  : AxiStreamSlaveType := AXI_STREAM_SLAVE_INIT_C;
      axisCtrl   : AxiStreamCtrlType  := AXI_STREAM_CTRL_UNUSED_C)
      return PpiSlaveType;

   function ppiMasterInit (
      axisConfig : AxiStreamConfigType)
      return PpiMasterType;

   function ppiSlaveInit (
      axisConfig : AxiStreamConfigType)
      return PpiSlaveType;

   -------------------------------------------------------------------------------------------------
   -- Functions to interpret TUSER bits
   -------------------------------------------------------------------------------------------------
   function ppiGetUserErr (
      axisConfig : AxiStreamConfigType;
      axisMaster : AxiStreamMasterType) 
      return sl;
   
   procedure ppiSetUserErr (
      axisConfig : in    AxiStreamConfigType;
      axisMaster : inout AxiStreamMasterType;
      err        : in    sl);

   function ppiGetUserEoh (
      axisConfig : AxiStreamConfigType;
      axisMaster : AxiStreamMasterType) 
      return sl;
   
   procedure ppiSetUserEoh (
      axisConfig : in    AxiStreamConfigType;
      axisMaster : inout AxiStreamMasterType;
      eoh        : in    sl); 

   procedure ppiResetFlags (
      axisMaster : inout AxiStreamMasterType);       

end package PpiPkg;

package body PpiPkg is

   function ppiAxiStreamConfig (
      dataBytes : natural := PPI_TDATA_BYTES_C )
      return AxiStreamConfigType is
      variable ret : AxiStreamConfigType;
   begin
      ret.TDATA_BYTES_C := dataBytes;           -- Configurable data size
      ret.TUSER_BITS_C  := PPI_TUSER_BITS_C;    -- 2 TUSER: EOH, ERR
      ret.TDEST_BITS_C  := PPI_TDEST_BITS_C;    -- 4 TDEST bits for type
      ret.TID_BITS_C    := PPI_TID_BITS_C;      -- TID not used
      ret.TKEEP_MODE_C  := PPI_TKEEP_MODE_C;    -- Compress TKEEP
      ret.TSTRB_EN_C    := PPI_TSTRB_EN_C;      -- No TSTRB support in PPI
      ret.TUSER_MODE_C  := PPI_TUSER_MODE_C;    -- User field valid on last only
      return ret;
   end function ppiAxiStreamConfig;

   -------------------------------------------------------------------------------------------------
   function ppi2AxisMaster (
      axisConfig : AxiStreamConfigType;
      ppiMaster  : PpiMasterType)
      return AxiStreamMasterType
   is
      variable ret : AxiStreamMasterType;
   begin
      ret        := AXI_STREAM_MASTER_INIT_C;
      ret.tValid := ppiMaster.valid;
      ret.tLast  := ppiMaster.eof;

      ret.tData(axisConfig.TDATA_BYTES_C-1 downto 0) := ppiMaster.data;

      ret.tDest(axisConfig.TDEST_BITS_C-1 downto 0) := ppiMaster.fType;

      ret.tKeep(axisConfig.TDATA_BYTES_C downto 0)     := (others=>'0');
      ret.tKeep(conv_integer(ppiMaster.size) downto 0) := (others=>'1');

      ppiSetUserEoh(axisConfig, ret, ppiMaster.eoh);
      ppiSetUserErr(axisConfig, ret, ppiMaster.err);
      return ret;
   end function ppi2AxisMaster;

   function ppi2AxisSlave (
      ppiSlave : PpiSlaveType)
      return AxiStreamSlaveType
   is
      variable ret : AxiStreamSlaveType;
   begin
      ret.tReady := ppiSlave.ready;
      return ret;
   end function ppi2AxisSlave;

   function ppi2AxisCtrl (
      ppiSlave : PpiSlaveType)
      return AxiStreamCtrlType
   is
      variable ret : AxiStreamCtrlType;
   begin
      ret.pause    := ppiSlave.pause;
      ret.overflow := ppiSlave.overflow;
      return ret;
   end function ppi2AxisCtrl;

   function axis2PpiMaster (
      axisConfig : AxiStreamConfigType;
      axisMaster : AxiStreamMasterType)
      return PpiMasterType
   is
      variable ret : PpiMasterType;
   begin
      ret.valid  := axisMaster.tValid;
      ret.data   := axisMaster.tData((PPI_TDATA_BYTES_C*8)-1 downto 0);
      ret.ftype  := axisMaster.tDest(axisConfig.TDEST_BITS_C-1 downto 0);

      ret.size   := onesCount(axisMaster.tKeep(axisConfig.TDATA_BYTES_C-1 downto 0));

      ret.eoh    := ppiGetUserEoh(axisConfig, axisMaster);
      ret.eof    := axisMaster.tLast;
      ret.err    := ppiGetUserErr(axisConfig, axisMaster);
      return ret;
   end function axis2PpiMaster;

   function axis2PpiSlave (
      axisConfig : AxiStreamConfigType;
      axisSlave  : AxiStreamSlaveType := AXI_STREAM_SLAVE_INIT_C;
      axisCtrl   : AxiStreamCtrlType  := AXI_STREAM_CTRL_UNUSED_C)
      return PpiSlaveType
   is
      variable ret : PpiSlaveType;
   begin
      ret.ready    := axisSlave.tReady;
      ret.pause    := axisCtrl.pause;
      ret.overflow := axisCtrl.overflow;
      return ret;
   end function axis2PpiSlave;

   function ppiMasterInit (
      axisConfig : AxiStreamConfigType)
      return PpiMasterType is
   begin
      return axis2PpiMaster(axisConfig, AXI_STREAM_MASTER_INIT_C);
   end function ppiMasterInit;

   function ppiSlaveInit (
      axisConfig : AxiStreamConfigType)
      return PpiSlaveType is
   begin
      return axis2PpiSlave(axisConfig, AXI_STREAM_SLAVE_INIT_C, AXI_STREAM_CTRL_UNUSED_C);
   end function ppiSlaveInit;

   -------------------------------------------------------------------------------------------------

   function ppiGetUserErr (
      axisConfig : AxiStreamConfigType;
      axisMaster : AxiStreamMasterType) 
      return sl is
      variable ret : sl;
   begin
      ret := axiStreamGetUserBit(axisConfig, axisMaster, PPI_ERR_C);
      return ret;
   end function;

   procedure ppiSetUserErr (
      axisConfig : in    AxiStreamConfigType;
      axisMaster : inout AxiStreamMasterType;
      err        : in    sl) is
   begin
      axiStreamSetUserBit(axisConfig, axisMaster, PPI_ERR_C, err);
   end procedure;

   function ppiGetUserEoh (
      axisConfig : AxiStreamConfigType;
      axisMaster : AxiStreamMasterType) 
      return sl is
      variable ret : sl;
   begin
      ret := axiStreamGetUserBit(axisConfig, axisMaster, PPI_EOH_C);
      return ret;
   end function;

   procedure ppiSetUserEoh (
      axisConfig : in    AxiStreamConfigType;
      axisMaster : inout AxiStreamMasterType;
      eoh        : in    sl) is
   begin
      axiStreamSetUserBit(axisConfig, axisMaster, PPI_EOH_C, eoh);
   end procedure;
   
   procedure ppiResetFlags (
      axisMaster : inout AxiStreamMasterType) is
   begin
      axisMaster.tValid := '0';
      axisMaster.tLast  := '0';
      axisMaster.tUser  := (others => '0');
   end procedure;

end package body PpiPkg;

