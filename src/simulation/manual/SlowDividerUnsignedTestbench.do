transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlowDividerUnsigned.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlowDividerUnsignedTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  SlowDividerUnsignedTestbench

add wave -position end -radix decimal sim:/SlowDividerUnsignedTestbench/read_head
add wave -position end -radix decimal sim:/SlowDividerUnsignedTestbench/num_errors
add wave -position end  sim:/SlowDividerUnsignedTestbench/clk
add wave -position end  sim:/SlowDividerUnsignedTestbench/q_valid
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/quotient
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/remainder
add wave -position end  sim:/SlowDividerUnsignedTestbench/error
add wave -position end  sim:/SlowDividerUnsignedTestbench/output_valid
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/in_dividend
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/in_divisor
add wave -position end  sim:/SlowDividerUnsignedTestbench/divider_mod/in_valid
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/out_quotient
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/out_remainder
add wave -position end  sim:/SlowDividerUnsignedTestbench/divider_mod/out_error
add wave -position end  sim:/SlowDividerUnsignedTestbench/divider_mod/out_valid
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/counter
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/current_remainder
add wave -position end -radix unsigned sim:/SlowDividerUnsignedTestbench/divider_mod/current_subtrahend

view structure
view signals
run 1500ns
