#!/bin/sh
mkdir work

echo "Compiling Core Simulation Models"
ncvhdl -v93 -work work ../../../zynq_gige.vhd

echo "Compiling Example Design"
ncvhdl -v93 -work work \
../../example_design/zynq_gige_sync_block.vhd \
../../example_design/zynq_gige_reset_sync.vhd \
../../example_design/transceiver/zynq_gige_gtwizard_gt.vhd \
../../example_design/transceiver/zynq_gige_gtwizard.vhd \
../../example_design/transceiver/zynq_gige_tx_startup_fsm.vhd \
../../example_design/transceiver/zynq_gige_rx_startup_fsm.vhd \
../../example_design/transceiver/zynq_gige_gtwizard_init.vhd \
../../example_design/transceiver/zynq_gige_transceiver.vhd \
../../example_design/zynq_gige_tx_elastic_buffer.vhd \
../../example_design/zynq_gige_block.vhd \
../../example_design/zynq_gige_example_design.vhd

echo "Compiling Test Bench"
ncvhdl -v93 -work work ../stimulus_tb.vhd ../demo_tb.vhd

echo "Elaborating design"
ncelab -access +rw work.demo_tb:behav

echo "Starting simulation"
ncsim -gui work.demo_tb:behav -input @"simvision -input wave_ncsim.sv"
