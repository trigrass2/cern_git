proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -ruleid {1}  -id {Vivado 12-3645}  -suppress 

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.cache/wt [current_project]
  set_property parent.project_path D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.xpr [current_project]
  set_property ip_repo_paths d:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.cache/ip [current_project]
  set_property ip_output_repo d:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.cache/ip [current_project]
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/synth_1/fc7_gbt_example_design.dcp
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/tx_pll/vivado/xlx_k7v7_tx_pll.dcp
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_rx_dpram_synth_1/xlx_k7v7_rx_dpram.dcp
  set_property netlist_only true [get_files D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_rx_dpram_synth_1/xlx_k7v7_rx_dpram.dcp]
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_tx_dpram_synth_1/xlx_k7v7_tx_dpram.dcp
  set_property netlist_only true [get_files D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_tx_dpram_synth_1/xlx_k7v7_tx_dpram.dcp]
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_synth_1/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.dcp
  set_property netlist_only true [get_files D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_synth_1/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.dcp]
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_vio_synth_1/xlx_k7v7_vio.dcp
  set_property netlist_only true [get_files D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_vio_synth_1/xlx_k7v7_vio.dcp]
  add_files -quiet D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_vivado_debug_synth_1/xlx_k7v7_vivado_debug.dcp
  set_property netlist_only true [get_files D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.runs/xlx_k7v7_vivado_debug_synth_1/xlx_k7v7_vivado_debug.dcp]
  read_xdc -mode out_of_context -ref xlx_k7v7_rx_dpram -cells U0 d:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.srcs/sources_1/ip/xlx_k7v7_rx_dpram/xlx_k7v7_rx_dpram_ooc.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.srcs/sources_1/ip/xlx_k7v7_rx_dpram/xlx_k7v7_rx_dpram_ooc.xdc]
  read_xdc -mode out_of_context -ref xlx_k7v7_tx_dpram -cells U0 d:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.srcs/sources_1/ip/xlx_k7v7_tx_dpram/xlx_k7v7_tx_dpram_ooc.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/fc7/vivado_project/fc7_gbt_example_design.srcs/sources_1/ip/xlx_k7v7_tx_dpram/xlx_k7v7_tx_dpram_ooc.xdc]
  read_xdc -mode out_of_context -ref xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm -cells inst d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_ooc.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_ooc.xdc]
  read_xdc -prop_thru_buffers -ref xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm -cells inst d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_board.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_board.xdc]
  read_xdc -ref xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm -cells inst d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm.xdc]
  read_xdc -mode out_of_context -ref xlx_k7v7_vio d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_vio/vivado/xlx_k7v7_vio_ooc.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_vio/vivado/xlx_k7v7_vio_ooc.xdc]
  read_xdc -ref xlx_k7v7_vio d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_vio/vivado/xlx_k7v7_vio.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_vio/vivado/xlx_k7v7_vio.xdc]
  read_xdc -mode out_of_context -ref xlx_k7v7_vivado_debug d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_ila/vivado/xlx_k7v7_vivado_debug_ooc.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_ila/vivado/xlx_k7v7_vivado_debug_ooc.xdc]
  read_xdc -ref xlx_k7v7_vivado_debug d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_ila/vivado/ila_v6_0/constraints/ila.xdc
  set_property processing_order EARLY [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/chipscope_ila/vivado/ila_v6_0/constraints/ila.xdc]
  read_xdc D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/xdc/fc7_gbt_exmpldsgn_io.xdc
  read_xdc D:/gbt_fpga/example_designs/xilinx_k7v7/fc7/xdc/fc7_gbt_exmpldsgn_timingclosure.xdc
  read_xdc -ref xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm -cells inst d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_late.xdc
  set_property processing_order LATE [get_files d:/gbt_fpga/example_designs/xilinx_k7v7/core_sources/gbt_rx_frameclk_phalgnr/vivado/xlx_k7v7_gbt_rx_frameclk_phalgnr_mmcm_late.xdc]
  link_design -top fc7_gbt_example_design -part xc7k420tffg1156-2
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force fc7_gbt_example_design_opt.dcp
  report_drc -file fc7_gbt_example_design_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file fc7_gbt_example_design.hwdef}
  place_design 
  write_checkpoint -force fc7_gbt_example_design_placed.dcp
  report_io -file fc7_gbt_example_design_io_placed.rpt
  report_utilization -file fc7_gbt_example_design_utilization_placed.rpt -pb fc7_gbt_example_design_utilization_placed.pb
  report_control_sets -verbose -file fc7_gbt_example_design_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force fc7_gbt_example_design_routed.dcp
  report_drc -file fc7_gbt_example_design_drc_routed.rpt -pb fc7_gbt_example_design_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file fc7_gbt_example_design_timing_summary_routed.rpt -rpx fc7_gbt_example_design_timing_summary_routed.rpx
  report_power -file fc7_gbt_example_design_power_routed.rpt -pb fc7_gbt_example_design_power_summary_routed.pb
  report_route_status -file fc7_gbt_example_design_route_status.rpt -pb fc7_gbt_example_design_route_status.pb
  report_clock_utilization -file fc7_gbt_example_design_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force fc7_gbt_example_design.mmi }
  write_bitstream -force fc7_gbt_example_design.bit 
  catch { write_sysdef -hwdef fc7_gbt_example_design.hwdef -bitfile fc7_gbt_example_design.bit -meminfo fc7_gbt_example_design.mmi -file fc7_gbt_example_design.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

