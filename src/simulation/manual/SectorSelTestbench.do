transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/SectorSel.sv}

vlog -sv -work work +incdir+../../../extractor {../../../extractor/SectorSelTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  SectorSelTestbench

add wave *
add wave -position end  sim:/SectorSelTestbench/ss_mod/nan_1
add wave -position end -radix unsigned sim:/SectorSelTestbench/ss_mod/quad_1
add wave -position end -radix signed sim:/SectorSelTestbench/ss_mod/x_1
add wave -position end -radix signed sim:/SectorSelTestbench/ss_mod/y_1

add wave -position end  sim:/SectorSelTestbench/ss_mod/nan_2
add wave -position end -radix unsigned sim:/SectorSelTestbench/ss_mod/quad_2
add wave -position end -radix signed sim:/SectorSelTestbench/ss_mod/y_2
add wave -position end -radix signed sim:/SectorSelTestbench/ss_mod/yvals_2

add wave -position end  sim:/SectorSelTestbench/ss_mod/nan_3
add wave -position end -radix unsigned sim:/SectorSelTestbench/ss_mod/quad_3
add wave -position end -radix signed sim:/SectorSelTestbench/ss_mod/y_3
add wave -position end -radix signed sim:/SectorSelTestbench/ss_mod/yvals_3

add wave -position end  sim:/SectorSelTestbench/ss_mod/nan_4
add wave -position end -radix unsigned sim:/SectorSelTestbench/ss_mod/quad_4
add wave -position end -radix unsigned sim:/SectorSelTestbench/ss_mod/cmp_4

view structure
view signals
run 1us
