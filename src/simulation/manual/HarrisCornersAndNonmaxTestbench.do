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
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisCornersAndNonmax.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisCornersAndNonmaxTestbench.sv}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  HarrisCornersAndNonmaxTestbench

add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/clk
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/sw_wr_en
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/hc_wr_en
add wave -position end -radix hex sim:/HarrisCornersAndNonmaxTestbench/in
add wave -position end -radix hex sim:/HarrisCornersAndNonmaxTestbench/window
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/error_count
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/output_x
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/output_y
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/out_is_corner
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/ref_is_corner
add wave -position end  sim:/HarrisCornersAndNonmaxTestbench/cursor

add wave -position end -radix decimal sim:/HarrisCornersAndNonmaxTestbench/test_mod/nonmax_input_score
add wave -position end -radix decimal sim:/HarrisCornersAndNonmaxTestbench/test_mod/harris_output_score
add wave -position end -radix decimal sim:/HarrisCornersAndNonmaxTestbench/test_mod/nonmax_window
add wave -position end -radix decimal sim:/HarrisCornersAndNonmaxTestbench/test_mod/cornersmod/feed_matrix
add wave -position end -radix hex sim:/HarrisCornersAndNonmaxTestbench/test_mod/cornersmod/hm_mod/window

view structure
view signals

run 60us
