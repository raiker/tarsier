transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/NonmaxSuppression.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/NonmaxSuppressionTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  NonmaxSuppressionTestbench

add wave -position end  sim:/NonmaxSuppressionTestbench/clk
add wave -position end  sim:/NonmaxSuppressionTestbench/cursor
add wave -position end  sim:/NonmaxSuppressionTestbench/error_count
add wave -position end  sim:/NonmaxSuppressionTestbench/is_error
add wave -position end  sim:/NonmaxSuppressionTestbench/is_local_max
add wave -position end  sim:/NonmaxSuppressionTestbench/input_window

view structure
view signals

run 100ns
