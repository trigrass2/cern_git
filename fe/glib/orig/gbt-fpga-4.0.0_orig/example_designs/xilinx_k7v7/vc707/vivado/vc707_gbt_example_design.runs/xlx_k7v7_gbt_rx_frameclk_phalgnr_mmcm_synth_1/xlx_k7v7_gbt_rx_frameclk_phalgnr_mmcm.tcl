# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7vx485tffg1761-2

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.cache/wt [current_project]
set_property parent.project_path D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part xilinx.com:vc707:part0:1.2 [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_ip D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.xci
set_property used_in_implementation false [get_files -all d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.dcp]
set_property is_locked true [get_files D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.xci]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
synth_design -top xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm -part xc7vx485tffg1761-2 -mode out_of_context
rename_ref -prefix_all xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_
write_checkpoint -noxdef xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.dcp
catch { report_utilization -file xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_utilization_synth.rpt -pb xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_utilization_synth.pb }
if { [catch {
  file copy -force D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.runs/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_synth_1/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.dcp D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.dcp
} _RESULT ] } { 
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}
if { [catch {
  write_verilog -force -mode synth_stub D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode synth_stub D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_verilog -force -mode funcsim D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode funcsim D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if {[file isdir D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.ip_user_files/ip/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm]} {
  catch { 
    file copy -force D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_stub.v D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.ip_user_files/ip/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm
  }
}

if {[file isdir D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.ip_user_files/ip/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm]} {
  catch { 
    file copy -force D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_stub.vhdl D:/gbt_fpga/example_designs/xilinx_k7v7/vc707/vivado/vc707_gbt_example_design.ip_user_files/ip/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm
  }
}
