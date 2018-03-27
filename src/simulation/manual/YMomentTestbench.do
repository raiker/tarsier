transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/YMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/YMomentTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  YMomentTestbench

add wave -position end  sim:/YMomentTestbench/clk
add wave -position end  sim:/YMomentTestbench/in_valid
add wave -position end  sim:/YMomentTestbench/in_reset
add wave -position end -radix unsigned sim:/YMomentTestbench/in_col
add wave -position end -radix unsigned sim:/YMomentTestbench/in_peek_col
add wave -position end -radix signed sim:/YMomentTestbench/read_head
add wave -position end -radix signed sim:/YMomentTestbench/peek_head
add wave -position end -radix decimal sim:/YMomentTestbench/out_ymoment
add wave -position end  sim:/YMomentTestbench/out_valid

add wave -position end -radix unsigned sim:/YMomentTestbench/ymoment_mod/row_sums
add wave -position end -radix decimal sim:/YMomentTestbench/ymoment_mod/scaled_row_sums_1
add wave -position end -radix decimal sim:/YMomentTestbench/ymoment_mod/scaled_row_sums_2
add wave -position end -radix unsigned sim:/YMomentTestbench/ymoment_mod/row_flush_ctr
add wave -position end -radix decimal sim:/YMomentTestbench/ymoment_mod/adder_tree_output


view structure
view signals
run 350ns
