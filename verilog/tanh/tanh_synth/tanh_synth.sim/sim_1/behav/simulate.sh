#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2015.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim tb_tanh_behav -key {Behavioral:sim_1:Functional:tb_tanh} -tclbatch tb_tanh.tcl -view /home/jfonseca/thesis/verilog/tanh/tanh_synth/tb_tanh_behav.wcfg -log simulate.log
