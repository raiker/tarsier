transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTreePipelinedTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  AdderTreePipelinedTestbench

add wave *
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/out_sum
add wave -position end  sim:/AdderTreePipelinedTestbench/tree_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/out_sum

view structure
view signals
run 60ns
