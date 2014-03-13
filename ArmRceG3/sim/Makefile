TOP=tb

# Set Default Output
SIM_DIR=$(PWD)/out

all: syn_setup rtl_src sysc_src sim_gen

EN64=-full64

# RTL Files
rtl_src:
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/tb/glbl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/tb/Version.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/StdRtlPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/Synchronizer.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerEdge.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/SynchronizerVector.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/ArbiterPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/general/rtl/Arbiter.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/sync/rtl/RstSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/ram/rtl/SimpleDualPortRam.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoAsyncBuiltIn.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoSyncBuiltIn.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoAsync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/FifoSync.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/fifo/rtl/Fifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLitePkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/xilinx7/rtl/DeviceDna.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../StdLib/axi/rtl/AxiLiteCrossbar.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cPkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/stdlib.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cSlave.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../../i2c_core/rtl/I2cRegSlave.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3Pkg.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3Version.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3Clocks.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3I2c.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3AxiWriteCntrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3IbQWordFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3IbHeaderFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3IbCntrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3AxiReadCntrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3ObHeaderFifo.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3ObCntrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3IbPpi.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3ObPpi.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3DmaComp.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3DmaCntrl.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3LocalAxi.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/tb/ArmRceG3Cpu.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/../hdl/ArmRceG3Top.vhd
	cd $(SIM_DIR); vhdlan $(EN64) $(PWD)/tb/tb.vhd

# System C Files
sysc_src:
	cd $(SIM_DIR); syscan $(EN64) -cpp g++  $(PWD)/../software/lib/AxiSharedMem.cpp
	cd $(SIM_DIR); syscan $(EN64) -cpp g++ -port $(PWD)/sysc/AxiMasterModel.map  $(PWD)/sysc/AxiMasterModel.cpp:AxiMasterModel
	cd $(SIM_DIR); syscan $(EN64) -cpp g++ -port $(PWD)/sysc/AxiSlaveModel.map  $(PWD)/sysc/AxiSlaveModel.cpp:AxiSlaveModel

sim_gen:
	cd $(SIM_DIR); vcs $(EN64) -sysc $(TOP) -cpp g++ -cc gcc -debug -lrt -timescale=1ns/1ps 

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
