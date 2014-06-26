TOP=tb

# Set Default Output
SIM_DIR=$(PWD)/out

all: env syn_setup rtl_src vhpi_src sim_gen

EN64=-full64

# RTL Files
rtl_src:
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/tb/glbl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/StdRtlPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/Synchronizer.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerEdge.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerVector.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/RstSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/ram/rtl/SimpleDualPortRam.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoOutputPipeline.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoAsyncBuiltIn.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoSyncBuiltIn.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoAsync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/Fifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoCascade.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerOneShot.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerOneShotCnt.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerOneShotCntVector.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SyncStatusVector.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/ArbiterPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/Arbiter.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/PrbsPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiWritePathFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiWritePathMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiReadPathFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiReadPathMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLitePkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiToAxiLite.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteCrossbar.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteEmpty.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteFifoPush.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteFifoPushPop.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteFifoPop.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/SsiPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamPipeline.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamShift.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiDmaPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamDmaWrite.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamDmaRead.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamDma.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiStreamDeMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/SsiAxiLiteMaster.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/SsiCmdMasterPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/SsiCmdMaster.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiStreamSimIb.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiStreamSimOb.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiStreamSim.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiSimMaster.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiSimMasterWrap.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiSimSlave.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/simlink/rtl/AxiSimSlaveWrap.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/xilinx7/rtl/DeviceDna.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/CrcPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/Crc32.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/stdlib.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cSlave.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cRegSlave.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/i2c_master_bit_ctrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/i2c_master_byte_ctrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cMaster.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cRegMaster.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cRegMasterMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cRegMasterAxiBridge.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../tb/Version.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Pkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiObHeader.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiObPayload.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiIbHeader.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiIbPayload.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiIbRoute.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiSocket.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiSocket.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiCompCtrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiToAxiLite.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiStateSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiStatus.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiInterconnect.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Version.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Bsi.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Clocks.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Cpu.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3DmaAxis.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3DmaPpi.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Dma.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3AxiCntl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3IntCntl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/hdl/RceG3Top.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../RceG3/simlink/rtl/RceG3CpuSim.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/XMacImport.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/XMacExport.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/XMac.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ZynqEthernet10G.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../tb/tb.vhd

# VHPI Library
vhpi_src:
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/../../StdLib/general/simlink/src/VhpiGeneric.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/../../StdLib/axi/simlink/src/AxiStreamSimOb.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/../../StdLib/axi/simlink/src/AxiStreamSimIb.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/../../StdLib/axi/simlink/src/AxiSimMaster.c
	@cd $(SIM_DIR); gcc -Wall -c -fPIC -O -I$(VCS_HOME)/include/ $(PWD)/../../StdLib/axi/simlink/src/AxiSimSlave.c
	@cd $(SIM_DIR); gcc -Wall -shared -o libAxiSim.so VhpiGeneric.o AxiStreamSimOb.o AxiStreamSimIb.o AxiSimMaster.o AxiSimSlave.o

sim_gen:
	cd $(SIM_DIR); vcs $(EN64) $(TOP) -cpp g++ -cc g++ -debug -lrt -timescale=1ns/1ps -sim_res=1ps

clean: 
	rm -rf $(SIM_DIR)/*
	rm -rf $(SIM_DIR)/.synopsys_vss.setup

# Create Synopsis Setup File
syn_setup:
	rm -f $(SIM_DIR)/.synopsys_vss.setup
	echo "UNISIM:$(XIL_SIMLIB)/unisim"                >  $(SIM_DIR)/.synopsys_vss.setup
	echo "UNIMACRO:$(XIL_SIMLIB)/unimacro"            >> $(SIM_DIR)/.synopsys_vss.setup
	echo "XILINXCORELIB:$(XIL_SIMLIB)/xilinxcorelib"  >> $(SIM_DIR)/.synopsys_vss.setup
	echo "SIMPRIM:$(XIL_SIMLIB)/simprim"              >> $(SIM_DIR)/.synopsys_vss.setup

# Create setup env script
env:
	@rm -f $(SIM_DIR)/setup_env.csh
	@echo "limit stacksize 60000"                                 >> $(SIM_DIR)/setup_env.csh
	@echo "setenv LD_LIBRARY_PATH $(SIM_DIR):${LD_LIBRARY_PATH}"  >> $(SIM_DIR)/setup_env.csh

