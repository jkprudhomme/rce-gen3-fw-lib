#!/bin/sh

# Clean up the results directory
rm -rf results
mkdir results

#Synthesize the Wrapper Files
echo 'Synthesizing example design with XST';
xst -ifn xilinx_pcie_2_1_rport_7x.xst -ofn xilinx_pcie_2_1_rport_7x.log

cp xilinx_pcie_2_1_rport_7x.ngc ./results/

cp xilinx_pcie_2_1_rport_7x.log xst.srp

rm -rf *.mgo xlnx_auto_0_xdb xlnx_auto_0.ise netlist.lst smart

cd results

echo 'Running ngdbuild'
ngdbuild -verbose -uc ../../example_design/xilinx_pcie_2_1_rport_7x_01_lane_gen1_xc7z045-ffg900-2-PCIE_X0Y0.ucf xilinx_pcie_2_1_rport_7x.ngc -sd .


echo 'Running map'
map -w \
  -o mapped.ncd \
  xilinx_pcie_2_1_rport_7x.ngd \
  mapped.pcf

echo 'Running par'
par \
  -w mapped.ncd \
  routed.ncd \
  mapped.pcf

echo 'Running trce'
trce -u -e 100 \
  routed.ncd \
  mapped.pcf

echo 'Running design through netgen'
netgen -sim -ofmt vhdl -w -tm xilinx_pcie_2_1_rport_7x routed.ncd

# Uncomment to enable Bitgen.  To generate a bitfile, all I/O must be LOC'd to pin.
# Refer to AR 41615 for more information
#echo 'Running design through bitgen'
#bitgen -w routed.ncd

 
