transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/Scale_1_2_Bilinear.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SlidingWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/MultitapShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/Scale_1_2_BilinearTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  Scale_1_2_BilinearTestbench

add wave -position end  sim:/Scale_1_2_BilinearTestbench/clk
add wave -position end -radix unsigned sim:/Scale_1_2_BilinearTestbench/in_x
add wave -position end -radix unsigned sim:/Scale_1_2_BilinearTestbench/in_y
add wave -position end -radix unsigned sim:/Scale_1_2_BilinearTestbench/out_x
add wave -position end -radix unsigned sim:/Scale_1_2_BilinearTestbench/out_y
add wave -position end -radix hex sim:/Scale_1_2_BilinearTestbench/in_pixel
add wave -position end -radix hex sim:/Scale_1_2_BilinearTestbench/out_pixel
add wave -position end  sim:/Scale_1_2_BilinearTestbench/in_valid
add wave -position end  sim:/Scale_1_2_BilinearTestbench/out_valid
add wave -position end  sim:/Scale_1_2_BilinearTestbench/is_error

view structure
view signals
run 600ns
