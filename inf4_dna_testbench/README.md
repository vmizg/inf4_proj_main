# inf4_dna_testbench

Reference implementation of the Smith-Waterman dynamic programming
algorithm in C++, with an application to DNA alignment.
The code is going to be used to write Verilog constructs
and implement the algorithm in a suitably parallel way on a
Xilinx Zynq-7010 FPGA.

# Optimizations and parallelism
The reference code is serialized. Parallelism will be achieved
by:
* Calculating the alignment of characters in parallel (**O(m+n)** runtime)
* Passing the outputs of processing elements into a pipeline, reducing space overhead
