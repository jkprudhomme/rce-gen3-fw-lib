vlib work
vmap work work



echo "Compiling Core Simulation Models"
vcom -work work ../../../zynq_gige.vhd

echo "Compiling Example Design"
vcom -2008 -work work \
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
vcom -work work -novopt ../stimulus_tb.vhd ../demo_tb.vhd

echo "Starting simulation"
vsim -voptargs="+acc" -t ps work.demo_tb
do wave_mti.do
run -all
