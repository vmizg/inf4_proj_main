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
ExecStep $xv_path/bin/xelab -wto e4740ae897dd4904b9588b83af9c0453 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L fifo_generator_v13_0_1 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_8 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_7 -L axi_data_fifo_v2_1_6 -L axi_crossbar_v2_1_8 -L axi_protocol_converter_v2_1_7 -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_sw_proc_behav xil_defaultlib.tb_sw_proc xil_defaultlib.glbl -log elaborate.log
