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
vlog -sv -work work +incdir+../../../extractor {../../../extractor/DualPortSSRAM.sv}
vlog -sv -work work +incdir+../../../extractor {../../../extractor/ORBWindowTestbench.sv}
vlog -sv -work work +incdir+../../../tarsier_pcie {../../../tarsier_pcie/orb_window_row_ram.v}


vsim -t 1ns -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriav_ver -L rtl_work -L work -voptargs="+acc"  ORBWindowTestbench

add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/clk
add wave -position end -radix decimal sim:/ORBWindowTestbench/state
add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/in_valid
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/in_col
add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/in_coord1
add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/in_coord2
add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/in_flush
add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/in_mode
add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/out_patch_valid
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/out_pix1
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/out_pix2
add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/out_xmoment
add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/out_ymoment
add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/ymoment_early
add wave -position end sim:/ORBWindowTestbench/orb_window_mod/ymoment_valid_early
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/in_column
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/in_peek_column
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/row_sums
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/row_flush_ctr
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/valid_ctr

#add wave -position end -radix unsigned {sim:/ORBWindowTestbench/orb_window_mod/rows[0]/ram/altsyncram_component/m_default/altsyncram_inst/mem_data}
#add wave -position end -radix unsigned {sim:/ORBWindowTestbench/orb_window_mod/rows[1]/ram/altsyncram_component/m_default/altsyncram_inst/mem_data}
#add wave -position end -radix unsigned {sim:/ORBWindowTestbench/orb_window_mod/rows[2]/ram/altsyncram_component/m_default/altsyncram_inst/mem_data}
#add wave -position end -radix unsigned {sim:/ORBWindowTestbench/orb_window_mod/rows[3]/ram/altsyncram_component/m_default/altsyncram_inst/mem_data}
#add wave -position end -radix unsigned {sim:/ORBWindowTestbench/orb_window_mod/rows[4]/ram/altsyncram_component/m_default/altsyncram_inst/mem_data}

add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/q_write_col
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/fill_counter
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/mem_valid_counter
add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/xmoment_valid
add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/ymoment_valid
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/write_col_addr
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/read_col_addr
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/x_centre
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/write_col
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/read_col

#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/in_valid
#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/row_sums
#add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/row_products
#add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/adder_tree_output
#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/ymoment_mod/row_flush_ctr

#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/incoming_column_sum
#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/outgoing_column_sum
#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/shiftreg_input
#add wave -position end  sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/shiftreg_wr_en
#add wave -position end -radix signed sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/patch_sum
#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/reset_ctr
#add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/xmoment_mod/fifo_valid_ctr

add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/x_addresses
add wave -position end -radix unsigned sim:/ORBWindowTestbench/orb_window_mod/rowdata_out

view structure
view signals
run 500ns
