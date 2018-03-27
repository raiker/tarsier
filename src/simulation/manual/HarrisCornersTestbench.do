transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/NonmaxSuppression.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultitapShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisMatrixPipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/Functions.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/FIFO.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlidingWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisCornersPipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisCornersPipelinedTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  HarrisCornersPipelinedTestbench

add wave -position end  sim:/HarrisCornersPipelinedTestbench/clk
add wave -position end  sim:/HarrisCornersPipelinedTestbench/sw_wr_en
add wave -position end  sim:/HarrisCornersPipelinedTestbench/hc_wr_en
add wave -position end -radix hex sim:/HarrisCornersPipelinedTestbench/in
add wave -position end -radix hex sim:/HarrisCornersPipelinedTestbench/window
add wave -position end  sim:/HarrisCornersPipelinedTestbench/score
add wave -position end  sim:/HarrisCornersPipelinedTestbench/score_cmp
add wave -position end  sim:/HarrisCornersPipelinedTestbench/error_count
add wave -position end  sim:/HarrisCornersPipelinedTestbench/cursor
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/out_score
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/feed_matrix
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/weighted_matrices
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/combined_matrix
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/combined_matrix_ff2
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/det
add wave -position end  sim:/HarrisCornersPipelinedTestbench/test_mod/trace

view structure
view signals

run 50us
