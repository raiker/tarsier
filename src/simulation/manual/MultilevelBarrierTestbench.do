transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultilevelBarrier.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultilevelBarrierTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  MultilevelBarrierTestbench

add wave *
add wave -radix unsigned sim:/MultilevelBarrierTestbench/barrier/counters
add wave sim:/MultilevelBarrierTestbench/barrier/hit_barrier

view structure
view signals

run 1us
