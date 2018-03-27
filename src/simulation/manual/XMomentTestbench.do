transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/XMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/XMomentTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  XMomentTestbench

add wave -position end  sim:/XMomentTestbench/clk
add wave -position end  sim:/XMomentTestbench/in_valid
add wave -position end  sim:/XMomentTestbench/in_reset
add wave -position end -radix unsigned sim:/XMomentTestbench/in_col
add wave -position end -radix unsigned sim:/XMomentTestbench/read_head
add wave -position end -radix decimal sim:/XMomentTestbench/out_xmoment
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/fifo_valid_ctr
add wave -position end  sim:/XMomentTestbench/out_valid
add wave -position end -radix hex sim:/XMomentTestbench/xmoment_mod/column_sum_shiftreg/shift_chain
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/incoming_column_sum_0
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/outgoing_column_sum_0
add wave -position end -radix signed sim:/XMomentTestbench/xmoment_mod/patch_diff_1
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/a_1
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/b_1
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/ab_2
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/patch_sum_2
add wave -position end -radix unsigned sim:/XMomentTestbench/xmoment_mod/patch_sum_3
add wave -position end -radix signed sim:/XMomentTestbench/xmoment_mod/xmoment_diff_4
add wave -position end -radix signed sim:/XMomentTestbench/xmoment_mod/xmoment_5


view structure
view signals
run 350ns
