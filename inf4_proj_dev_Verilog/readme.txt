INF4 Honours Project Submission by S1451552
Hardware DNA alignment accelerator architecture files

* The backup_sources folder just contains sources from previous iteration
during development

* inf4_proj_dev along with init_xillybus are the main project folders.
To open the Verilog project, use Vivado and source the project from inside
inf4_proj_dev folder. The init_xillybus has dependencies related to
FPGA to host communication. Most of the files are a customized Xillybus IP core
that exposes 2 input and 1 output FIFO; Verilog source files for the custom
design are located in inf4_proj_dev/inf4_proj_dev.srcs/sources_1/new

* dnabin_testfiles contains some of the binary DNA sequences for
Verilog simulation testbench, used in previous iterations, such as preloading
longer sequence for simulation of processing element array

* sd_boot contains the boot files for microSD card with xillydemo.bit bitstream file containing the bytecode logic of hardware accelerator (name left from a template xillybus demo project; change requires changing and recompiling kernel device tree, therefore I have left it as it is). To upload and run the architecture on ZYBO, refer to Xillybus Zynq-7010 guide (online) and use the Xillinux operating system along with these boot files.
