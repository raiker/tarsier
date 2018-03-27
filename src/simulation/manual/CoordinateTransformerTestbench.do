transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/CoordinateTransformer.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/CoordinateTransformerTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  CoordinateTransformerTestbench

add wave *
add wave -position end -radix unsigned sim:/CoordinateTransformerTestbench/out_vals

view structure
view signals

run 200ns
