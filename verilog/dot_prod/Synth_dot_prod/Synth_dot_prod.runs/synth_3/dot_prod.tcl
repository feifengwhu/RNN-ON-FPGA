# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z020clg484-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /home/josefonseca/Documents/thesis/verilog/dot_prod/Synth_dot_prod/Synth_dot_prod.cache/wt [current_project]
set_property parent.project_path /home/josefonseca/Documents/thesis/verilog/dot_prod/Synth_dot_prod/Synth_dot_prod.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_verilog -library xil_defaultlib /home/josefonseca/Documents/thesis/verilog/dot_prod/dot_prod.v
read_xdc /home/josefonseca/Documents/thesis/verilog/dot_prod/Synth_dot_prod/Synth_dot_prod.srcs/constrs_1/new/dot_prod_timing.xdc
set_property used_in_implementation false [get_files /home/josefonseca/Documents/thesis/verilog/dot_prod/Synth_dot_prod/Synth_dot_prod.srcs/constrs_1/new/dot_prod_timing.xdc]

synth_design -top dot_prod -part xc7z020clg484-1 -fanout_limit 400 -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5
write_checkpoint -noxdef dot_prod.dcp
catch { report_utilization -file dot_prod_utilization_synth.rpt -pb dot_prod_utilization_synth.pb }
