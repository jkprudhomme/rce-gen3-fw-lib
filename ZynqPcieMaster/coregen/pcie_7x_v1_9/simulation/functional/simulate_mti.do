vlib work
vmap work
  
vlog -work work -sv +incdir+../../source \
        +define+SIMULATION \
	$env(XILINX)/verilog/src/glbl.v \
      -f board_vlog.f
      
vcom -work work -f board.f
      
vsim -voptargs="+acc" +notimingchecks -L work \
      -L unisims_ver -L unimacro_ver \
      -L unisim -L unimacro  -L secureip  -t "1ps" \
      glbl \
      work.board
            
add log -r /*
run -all
