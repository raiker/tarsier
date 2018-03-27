transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTreePipelinedTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  UnsignedAdderTreePipelinedTestbench

add wave -position end  sim:/UnsignedAdderTreePipelinedTestbench/clk
add wave -position end  sim:/UnsignedAdderTreePipelinedTestbench/reset
add wave -position end  sim:/UnsignedAdderTreePipelinedTestbench/advance
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/inputs
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/cursor

add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/sum_a
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/sum_b
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_a/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_a/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_a/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_a/genblk1/genblk1/subtree_b/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_a/out_sum
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/in_addends
add wave -position end -radix unsigned sim:/UnsignedAdderTreePipelinedTestbench/test_mod/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/genblk1/genblk1/subtree_b/out_sum


view structure
view signals
run 150ns
