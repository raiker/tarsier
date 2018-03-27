transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/RecBinaryMux.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/FIFO.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RecBinaryMuxTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  RecBinaryMuxTestbench

add wave -position end -radix unsigned sim:/RecBinaryMuxTestbench/cursor
add wave -position end  sim:/RecBinaryMuxTestbench/clk
add wave -position end  sim:/RecBinaryMuxTestbench/reset
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/in_data
add wave -position end  sim:/RecBinaryMuxTestbench/in_valid
add wave -position end  sim:/RecBinaryMuxTestbench/in_ready
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/out_data
add wave -position end  sim:/RecBinaryMuxTestbench/out_valid
add wave -position end  sim:/RecBinaryMuxTestbench/out_ready

add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[0]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[1]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[2]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[3]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[4]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[5]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[6]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[7]/data}
add wave -position end -radix hex {sim:/RecBinaryMuxTestbench/genblk1[8]/data}

add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/out_data
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/out_data
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_a/out_data
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_b/out_data
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/out_data
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_a/out_data
add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/out_data

#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_a/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_a/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_b/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_a/genblk1/subtree_b/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_a/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_a/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_a/out_data
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/out_data
#
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/in_data
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/in_valid
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/in_ready
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/out_data
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/out_valid
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/out_ready
#
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/accept_input
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/data_a
#add wave -position end -radix hex sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/data_b
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/valid_a
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/valid_b
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/ready_a
#add wave -position end  sim:/RecBinaryMuxTestbench/tree/genblk1/subtree_b/genblk1/subtree_b/genblk1/subtree_b/genblk1/ready_b


view structure
view signals
run 1000ns
