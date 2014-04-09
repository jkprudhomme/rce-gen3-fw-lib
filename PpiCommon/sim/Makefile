TOP=tb

# Set Default Output
SIM_DIR=$(PWD)/out

all: syn_setup rtl_src sim_gen

EN64=-full64 -xlrm

# RTL Files
rtl_src:
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/tb/glbl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/StdRtlPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/Synchronizer.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerEdge.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerVector.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/RstSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerOneShot.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/ram/rtl/SimpleDualPortRam.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoAsyncBuiltIn.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoSyncBuiltIn.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoAsync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/Fifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/ArbiterPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/Arbiter.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/PrbsPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLitePkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/xilinx7/rtl/DeviceDna.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteCrossbar.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteAsync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64Pkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64Mux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64Sync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64Fifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64FifoMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64PrbsRx.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../Vc64Lib/rtl/Vc64PrbsTx.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../pgp2b/core/rtl/Pgp2bPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../ArmRceG3/hdl/ArmRceG3Pkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiFifoAsync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiFifoSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiMux.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiRouter.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiToAxi.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiStatus.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiCrossbar.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiVcIb.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../PpiCommon/hdl/PpiVcOb.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/tb/tb.vhd

sim_gen:
	cd $(SIM_DIR); vcs $(EN64) $(TOP) -cpp g++ -cc gcc -debug -lrt -timescale=1ns/1ps 

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
