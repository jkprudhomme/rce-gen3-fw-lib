#!/bin/sh
mkdir work

# Needed for LMC Smartmodel simulation - setenv LMC_TIMEUNIT -12

ncvlog -work work -define NCV \
      $XILINX/verilog/src/glbl.v \
      -incdir ../ -incdir ../../source \
      -file ../source_rtl.f 

ncvlog -work work -define NCV \
       -incdir ../ -incdir ../../simulation \
       -incdir ../ -incdir ../tests -incdir ../dsport \
       -f rport_rtl.f
      
ncvhdl -v93 -work work \
   -f board_rtl.f

ncelab -access +rwc -VHdl_time_precision 1ps \
work.board work.glbl

ncsim work.board 
