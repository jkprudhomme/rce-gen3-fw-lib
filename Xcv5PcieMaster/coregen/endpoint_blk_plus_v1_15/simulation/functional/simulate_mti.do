vlib work
vmap work
vlog -work work +incdir+../.+../../source \
      -f ../source_rtl.f \
      $env(XILINX)/verilog/src/glbl.v 

vlog -work work +incdir+../.+../../simulation \
      +incdir+../+../tests+../dsport \
      -f rport_rtl.f

vcom -93 -work work \
      -f board_rtl.f

vsim +notimingchecks -t 1ps +TESTNAME=sample_smoke_test0 \
          -L work -L secureip -L unisims_ver work.board glbl

run -all
