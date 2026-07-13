vlib work
vlog -sv -timescale 1ns/1ps +incdir+. ../rtl/fifo.sv fifo_if.sv fifo_pkg.sv tb_top.sv
vsim work.tb_top +UVM_TESTNAME=fifo_rand_test
run -all
