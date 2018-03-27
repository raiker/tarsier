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
vlog -sv -work work +incdir+../../../extractor {../../../extractor/Scale_4_5_BilinearTestbench.sv}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  Scale_4_5_BilinearTestbench

add wave -position end  sim:/Scale_4_5_BilinearTestbench/clk
add wave -position end -radix unsigned sim:/Scale_4_5_BilinearTestbench/in_x
add wave -position end -radix unsigned sim:/Scale_4_5_BilinearTestbench/in_y
add wave -position end -radix unsigned sim:/Scale_4_5_BilinearTestbench/out_x
add wave -position end -radix unsigned sim:/Scale_4_5_BilinearTestbench/out_y
add wave -position end -radix hex sim:/Scale_4_5_BilinearTestbench/in_pixel
add wave -position end -radix hex sim:/Scale_4_5_BilinearTestbench/out_pixel
add wave -position end  sim:/Scale_4_5_BilinearTestbench/in_valid
add wave -position end  sim:/Scale_4_5_BilinearTestbench/out_valid
add wave -position end  sim:/Scale_4_5_BilinearTestbench/is_error

view structure
view signals
run 48000ns
