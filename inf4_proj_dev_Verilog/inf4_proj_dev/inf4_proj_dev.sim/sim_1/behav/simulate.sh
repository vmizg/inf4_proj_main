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
ExecStep $xv_path/bin/xsim tb_sw_proc_behav -key {Behavioral:sim_1:Functional:tb_sw_proc} -tclbatch tb_sw_proc.tcl -log simulate.log
