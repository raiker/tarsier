transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/NonmaxSuppression.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultitapShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisMatrixPipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/Functions.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/FIFO.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlidingWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTree.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisCornersPipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/HarrisCornersAndNonmax.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/CornersAndDescriptors.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/BufferedCornersAndDescriptors.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/XMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/YMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/VectorRotate.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORB2.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RecBinaryMux.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBArbitrator.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SectorSel.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTree.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/CornersAndDescriptorsTestbench.sv}
vlog -sv -work work +incdir+../../../tarsier_pcie {../../../tarsier_pcie/orb_window_row_ram.v}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  CornersAndDescriptorsTestbench

add wave -position end  sim:/CornersAndDescriptorsTestbench/clk
add wave -position end  sim:/CornersAndDescriptorsTestbench/cursor
add wave -position end -radix hex sim:/CornersAndDescriptorsTestbench/out_descriptor
add wave -position end  sim:/CornersAndDescriptorsTestbench/out_valid
add wave -position end  sim:/CornersAndDescriptorsTestbench/error_count
add wave -position end -radix hex sim:/CornersAndDescriptorsTestbench/in_pixel
add wave -position end -radix unsigned sim:/CornersAndDescriptorsTestbench/out_feature_x
add wave -position end -radix unsigned sim:/CornersAndDescriptorsTestbench/out_feature_y

add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/in_valid
add wave -position end -radix hex sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/in_pixel
add wave -position end -radix unsigned sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/in_x
add wave -position end -radix unsigned sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/in_y

add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/in_begin_frame_reset
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/out_frame_reset_complete
add wave -position end -radix decimal sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/orb_in_corner_x_1
add wave -position end -radix decimal sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/orb_in_corner_y_1
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/orb_not_in_margin_1
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/corners_is_local_max_1
#add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/nonmax_window_valid_1
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/orb_is_corner_1

add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/out_frame_end
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/q_flushing
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/in_valid
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/pixel_window_input_valid
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/corners_input_valid_0

add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/clk
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_valid
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_col
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_is_corner
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_reset
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_consume
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_x
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_y
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/in_mask
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/out_descriptor
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/out_valid
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/out_feature_x
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/out_feature_y
add wave -position end  sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/out_request_stall

add wave -position end  {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/out_accepting_input}
add wave -position end -radix unsigned {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/state}
add wave -position end  {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/windows[0]/window/mode}
add wave -position end  {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/windows[0]/window/patch_dirty}
add wave -position end -radix unsigned {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/windows[0]/window/fill_counter}
add wave -position end  {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/windows[0]/window/q_flush_start}
add wave -position end  {sim:/CornersAndDescriptorsTestbench/test_mod/cd_mod/arbitrator_mod/orb_modules[0]/orb_mod/windows[0]/window/out_patch_valid}


view structure
view signals

run 115us
