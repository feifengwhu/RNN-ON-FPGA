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

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7z020clg484-1
  set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir /home/josefonseca/Documents/thesis/verilog/weight_ram/Synth_weight_ram/Synth_weight_ram.cache/wt [current_project]
  set_property parent.project_path /home/josefonseca/Documents/thesis/verilog/weight_ram/Synth_weight_ram/Synth_weight_ram.xpr [current_project]
  set_property ip_repo_paths /home/josefonseca/Documents/thesis/verilog/weight_ram/Synth_weight_ram/Synth_weight_ram.cache/ip [current_project]
  set_property ip_output_repo /home/josefonseca/Documents/thesis/verilog/weight_ram/Synth_weight_ram/Synth_weight_ram.cache/ip [current_project]
  add_files -quiet /home/josefonseca/Documents/thesis/verilog/weight_ram/Synth_weight_ram/Synth_weight_ram.runs/synth_2/weightRAM.dcp
  read_xdc /home/josefonseca/Documents/thesis/verilog/weight_ram/Synth_weight_ram/Synth_weight_ram.srcs/constrs_1/new/weightRAM_timing.xdc
  link_design -top weightRAM -part xc7z020clg484-1
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
  opt_design -directive Explore
  write_checkpoint -force weightRAM_opt.dcp
  report_drc -file weightRAM_drc_opted.rpt
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
  catch {write_hwdef -file weightRAM.hwdef}
  place_design -directive Explore
  write_checkpoint -force weightRAM_placed.dcp
  report_io -file weightRAM_io_placed.rpt
  report_utilization -file weightRAM_utilization_placed.rpt -pb weightRAM_utilization_placed.pb
  report_control_sets -verbose -file weightRAM_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step phys_opt_design
set rc [catch {
  create_msg_db phys_opt_design.pb
  phys_opt_design -directive Explore
  write_checkpoint -force weightRAM_physopt.dcp
  close_msg_db -file phys_opt_design.pb
} RESULT]
if {$rc} {
  step_failed phys_opt_design
  return -code error $RESULT
} else {
  end_step phys_opt_design
}

  set_msg_config -source 4 -id {Route 35-39} -severity "critical warning" -new_severity warning
start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design -directive Explore -tns_cleanup
  write_checkpoint -force weightRAM_routed.dcp
  report_drc -file weightRAM_drc_routed.rpt -pb weightRAM_drc_routed.pb
  report_timing_summary -max_paths 10 -file weightRAM_timing_summary_routed.rpt -rpx weightRAM_timing_summary_routed.rpx
  report_power -file weightRAM_power_routed.rpt -pb weightRAM_power_summary_routed.pb
  report_route_status -file weightRAM_route_status.rpt -pb weightRAM_route_status.pb
  report_clock_utilization -file weightRAM_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step post_route_phys_opt_design
set rc [catch {
  create_msg_db post_route_phys_opt_design.pb
  phys_opt_design -directive Explore
  write_checkpoint -force weightRAM_postroute_physopt.dcp
  report_timing_summary -warn_on_violation -max_paths 10 -file weightRAM_timing_summary_postroute_physopted.rpt -rpx weightRAM_timing_summary_postroute_physopted.rpx
  close_msg_db -file post_route_phys_opt_design.pb
} RESULT]
if {$rc} {
  step_failed post_route_phys_opt_design
  return -code error $RESULT
} else {
  end_step post_route_phys_opt_design
}

