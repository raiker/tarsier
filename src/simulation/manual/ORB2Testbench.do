transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+../../../extractor {../../../extractor/AdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/UnsignedAdderTreePipelined.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ShiftRegister.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/RAMBlock.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/XMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/YMoment.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBWindow.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/SectorSel.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORB2.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/VectorRotate.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/DualPortSSRAM.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORB2Testbench.sv}
vlog -sv -work work +incdir+../../../tarsier_pcie {../../../tarsier_pcie/orb_window_row_ram.v}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L rtl_work -L work -voptargs="+acc"  ORB2Testbench

add wave *
add wave -position end  sim:/ORB2Testbench/orb_mod/q_mode
add wave -position end -radix hex sim:/ORB2Testbench/orb_mod/in_col
add wave -position end  {sim:/ORB2Testbench/orb_mod/windows[0]/window/out_patch_valid}
add wave -position end -radix signed {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment}
add wave -position end -radix signed {sim:/ORB2Testbench/orb_mod/windows[0]/window/ymoment}

#add wave -position end  {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_valid}
#add wave -position end  {sim:/ORB2Testbench/orb_mod/windows[0]/window/ymoment_valid}

#add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/incoming_column_sum}
#add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/outgoing_column_sum}
#add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/shiftreg_input}
#add wave -position end  {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/shiftreg_wr_en}
#add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/patch_sum}
#add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/reset_ctr}
#add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/xmoment_mod/fifo_valid_ctr}

add wave -position end  sim:/ORB2Testbench/orb_mod/sectorsel_mod/in_valid

add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sector
add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sector_latched
#add wave -position end  sim:/ORB2Testbench/orb_mod/sectorsel_mod/nan_1
#add wave -position end  sim:/ORB2Testbench/orb_mod/sectorsel_mod/nan_2
#add wave -position end  sim:/ORB2Testbench/orb_mod/sectorsel_mod/nan_3
#add wave -position end  sim:/ORB2Testbench/orb_mod/sectorsel_mod/nan_4
#add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sectorsel_mod/quad_1
#add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sectorsel_mod/quad_2
#add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sectorsel_mod/quad_3
#add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sectorsel_mod/quad_4
#add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sectorsel_mod/x_1
#add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sectorsel_mod/y_1
#add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sectorsel_mod/y_2
#add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sectorsel_mod/y_3
#add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sectorsel_mod/yvals_2
#add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sectorsel_mod/yvals_3
#add wave -position end  sim:/ORB2Testbench/orb_mod/sectorsel_mod/cmp_4

add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/x_addresses}
add wave -position end -radix unsigned {sim:/ORB2Testbench/orb_mod/windows[0]/window/x_centre}
add wave -position end -radix hex {sim:/ORB2Testbench/orb_mod/windows[0]/window/rowdata_out}

add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/state
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/cos_angle
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/sin_angle
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/x1
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/y1
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/x2
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/y2
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/rx1
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/ry1
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/rx2
add wave -position end -radix signed sim:/ORB2Testbench/orb_mod/ry2
add wave -position end -radix hex sim:/ORB2Testbench/orb_mod/pix1
add wave -position end -radix hex sim:/ORB2Testbench/orb_mod/pix2
add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/sample_bit_index
add wave -position end -radix unsigned sim:/ORB2Testbench/orb_mod/output_bit_index

view structure
view signals
run 4us
