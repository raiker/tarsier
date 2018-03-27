transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/Scale_4_5_Bilinear.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlidingWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultitapShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ScalerRateTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  ScalerRateTestbench

add wave -position end  sim:/ScalerRateTestbench/clk
add wave -position end -radix unsigned sim:/ScalerRateTestbench/in_x
add wave -position end -radix unsigned sim:/ScalerRateTestbench/in_y
add wave -position end -radix unsigned sim:/ScalerRateTestbench/out_x
add wave -position end -radix unsigned sim:/ScalerRateTestbench/out_y
add wave -position end -radix unsigned sim:/ScalerRateTestbench/predicted_x
add wave -position end -radix unsigned sim:/ScalerRateTestbench/predicted_y
add wave -position end -radix hex sim:/ScalerRateTestbench/in_pixel
add wave -position end -radix hex sim:/ScalerRateTestbench/out_pixel
add wave -position end  sim:/ScalerRateTestbench/in_valid
add wave -position end  sim:/ScalerRateTestbench/out_valid

add wave -position end -radix unsigned sim:/ScalerRateTestbench/scaler/x_mod_1
add wave -position end -radix unsigned sim:/ScalerRateTestbench/scaler/y_mod_1
add wave -position end -radix unsigned sim:/ScalerRateTestbench/scaler/x_1
add wave -position end -radix unsigned sim:/ScalerRateTestbench/scaler/y_1
add wave -position end  sim:/ScalerRateTestbench/scaler/output_pixel
add wave -position end  sim:/ScalerRateTestbench/scaler/valid_1
add wave -position end  sim:/ScalerRateTestbench/scaler/valid_2

view structure
view signals
run 4620us
