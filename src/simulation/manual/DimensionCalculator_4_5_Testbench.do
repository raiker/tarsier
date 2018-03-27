transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlowDividerUnsigned.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/DimensionCalculator_4_5.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/DimensionCalculator_4_5_Testbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  DimensionCalculator_4_5_Testbench

add wave sim:/DimensionCalculator_4_5_Testbench/clk
add wave sim:/DimensionCalculator_4_5_Testbench/in_progress
add wave sim:/DimensionCalculator_4_5_Testbench/in_valid
add wave sim:/DimensionCalculator_4_5_Testbench/out_valid
add wave -radix unsigned sim:/DimensionCalculator_4_5_Testbench/cursor
add wave -radix unsigned sim:/DimensionCalculator_4_5_Testbench/out
add wave -radix unsigned sim:/DimensionCalculator_4_5_Testbench/calc/divider/counter


view structure
view signals
run 1ms
