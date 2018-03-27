transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultitapShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultitapShiftRegisterTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  MultitapShiftRegisterTestbench

add wave -position end  sim:/MultitapShiftRegisterTestbench/clk
add wave -position end  sim:/MultitapShiftRegisterTestbench/reset
add wave -position end  sim:/MultitapShiftRegisterTestbench/in_valid
add wave -position end -radix unsigned sim:/MultitapShiftRegisterTestbench/in
add wave -position end -radix unsigned sim:/MultitapShiftRegisterTestbench/out
add wave -position end -radix unsigned sim:/MultitapShiftRegisterTestbench/cursor
add wave -position end -radix unsigned sim:/MultitapShiftRegisterTestbench/num_errors

add wave -position end -radix unsigned sim:/MultitapShiftRegisterTestbench/mtsr/tap_spacing


view structure
view signals
run 1500ns
