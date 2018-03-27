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
vlog -sv -work work +incdir+../../../extractor {../../../extractor/CornersAndDescriptors.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/BufferedCornersAndDescriptors.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORB2.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RecBinaryMux.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBArbitrator.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SectorSel.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/VectorRotate.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/XMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/YMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultilevelBarrier.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBMultiscale.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/Scale_1_2_Bilinear.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/Scale_4_5_Bilinear.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/DimensionCalculator_4_5.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlowDividerUnsigned.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/CoordinateTransformer.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBMultiscaleTestbench.sv}
vlog -sv -work work +incdir+../../../tarsier_pcie {../../../tarsier_pcie/orb_window_row_ram.v}

vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  ORBMultiscaleTestbench

add wave -position end  sim:/ORBMultiscaleTestbench/clk
add wave -position end  sim:/ORBMultiscaleTestbench/cursor
add wave -position end  sim:/ORBMultiscaleTestbench/error_count
add wave -position end  sim:/ORBMultiscaleTestbench/out_valid
add wave -position end -radix hex sim:/ORBMultiscaleTestbench/out_descriptor
add wave -position end -radix unsigned sim:/ORBMultiscaleTestbench/out_feature_x
add wave -position end -radix unsigned sim:/ORBMultiscaleTestbench/out_feature_y
add wave -position end -radix unsigned sim:/ORBMultiscaleTestbench/out_level
add wave -position end -radix hex sim:/ORBMultiscaleTestbench/in_pixel
add wave -position end -radix unsigned sim:/ORBMultiscaleTestbench/in_x
add wave -position end -radix unsigned sim:/ORBMultiscaleTestbench/in_y
add wave -position end  sim:/ORBMultiscaleTestbench/in_valid

add wave -position end  sim:/ORBMultiscaleTestbench/in_reset
add wave -position end  sim:/ORBMultiscaleTestbench/begin_frame_reset
add wave -position end  sim:/ORBMultiscaleTestbench/end_frame_reset

add wave -divider

add wave -position end  sim:/ORBMultiscaleTestbench/test_mod/r_width
add wave -position end  sim:/ORBMultiscaleTestbench/test_mod/r_height

view structure
view signals

run 110us
