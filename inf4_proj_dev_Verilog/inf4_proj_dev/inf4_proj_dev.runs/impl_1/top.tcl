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
set_msg_config  -ruleid {1}  -id {BD 41-968}  -string {{xillybus_S_AXI}}  -new_severity {INFO} 
set_msg_config  -ruleid {2}  -id {BD 41-967}  -string {{xillybus_ip_0/xillybus_M_AXI}}  -new_severity {INFO} 
set_msg_config  -ruleid {3}  -id {BD 41-967}  -string {{xillybus_ip_0/xillybus_S_AXI}}  -new_severity {INFO} 
set_msg_config  -ruleid {4}  -id {BD 41-678}  -string {{xillybus_S_AXI/Reg}}  -new_severity {INFO} 
set_msg_config  -ruleid {5}  -id {BD 41-1356}  -string {{xillybus_S_AXI/Reg}}  -new_severity {INFO} 
set_msg_config  -ruleid {7}  -id {BD 41-759}  -string {{xlconcat_0/In}}  -new_severity {INFO} 
set_msg_config  -ruleid {8}  -id {Netlist 29-160}  -string {{vivado_system_processing_system7}}  -new_severity {INFO} 

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/inf4_proj_dev/inf4_proj_dev.cache/wt [current_project]
  set_property parent.project_path /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/inf4_proj_dev/inf4_proj_dev.xpr [current_project]
  set_property ip_repo_paths {
  /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/inf4_proj_dev/inf4_proj_dev.cache/ip
  /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado-ip
} [current_project]
  set_property ip_output_repo /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/inf4_proj_dev/inf4_proj_dev.cache/ip [current_project]
  add_files -quiet /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/inf4_proj_dev/inf4_proj_dev.runs/synth_1/top.dcp
  set_property edif_extra_search_paths /home/vytas/INF4/Verilog/init_xillybus/cores [current_fileset]
  read_edif /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/system/pcores/xillybus_lite_v1_00_a/netlist/xillybus_lite.ngc
  add_files -quiet /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vga_fifo/vga_fifo.dcp
  set_property netlist_only true [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vga_fifo/vga_fifo.dcp]
  add_files -quiet /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/fifo_32x512/fifo_32x512.dcp
  set_property netlist_only true [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/fifo_32x512/fifo_32x512.dcp]
  read_xdc -ref vga_fifo -cells U0 /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vga_fifo/vga_fifo/vga_fifo.xdc
  set_property processing_order EARLY [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vga_fifo/vga_fifo/vga_fifo.xdc]
  read_xdc -ref fifo_32x512 -cells U0 /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/fifo_32x512/fifo_32x512/fifo_32x512.xdc
  set_property processing_order EARLY [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/fifo_32x512/fifo_32x512/fifo_32x512.xdc]
  read_xdc -ref vivado_system_processing_system7_0_0 -cells inst /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/ip/vivado_system_processing_system7_0_0/vivado_system_processing_system7_0_0.xdc
  set_property processing_order EARLY [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/ip/vivado_system_processing_system7_0_0/vivado_system_processing_system7_0_0.xdc]
  read_xdc -prop_thru_buffers -ref vivado_system_rst_processing_system7_0_100M_0 /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/ip/vivado_system_rst_processing_system7_0_100M_0/vivado_system_rst_processing_system7_0_100M_0_board.xdc
  set_property processing_order EARLY [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/ip/vivado_system_rst_processing_system7_0_100M_0/vivado_system_rst_processing_system7_0_100M_0_board.xdc]
  read_xdc -ref vivado_system_rst_processing_system7_0_100M_0 /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/ip/vivado_system_rst_processing_system7_0_100M_0/vivado_system_rst_processing_system7_0_100M_0.xdc
  set_property processing_order EARLY [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vivado_system/ip/vivado_system_rst_processing_system7_0_100M_0/vivado_system_rst_processing_system7_0_100M_0.xdc]
  read_xdc /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/xillydemo.xdc
  read_xdc -ref vga_fifo -cells U0 /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vga_fifo/vga_fifo/vga_fifo_clocks.xdc
  set_property processing_order LATE [get_files /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/vga_fifo/vga_fifo/vga_fifo_clocks.xdc]
  link_design -top top -part xc7z010clg400-1
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
  write_checkpoint -force top_opt.dcp
  report_drc -file top_drc_opted.rpt
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
  catch {write_hwdef -file top.hwdef}
  place_design 
  write_checkpoint -force top_placed.dcp
  report_io -file top_io_placed.rpt
  report_utilization -file top_utilization_placed.rpt -pb top_utilization_placed.pb
  report_control_sets -verbose -file top_control_sets_placed.rpt
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
  set src_rc [catch { 
    puts "source /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/showstopper.tcl"
    source /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/showstopper.tcl
  } _RESULT] 
  if {$src_rc} { 
    send_msg_id runtcl-1 error "$_RESULT"
    send_msg_id runtcl-2 error "sourcing script /home/vytas/INF4/inf4_proj_main/inf4_proj_dev_Verilog/init_xillybus/vivado-essentials/showstopper.tcl failed"
    return -code error
  }
  write_checkpoint -force top_routed.dcp
  report_drc -file top_drc_routed.rpt -pb top_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file top_timing_summary_routed.rpt -rpx top_timing_summary_routed.rpx
  report_power -file top_power_routed.rpt -pb top_power_summary_routed.pb
  report_route_status -file top_route_status.rpt -pb top_route_status.pb
  report_clock_utilization -file top_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

