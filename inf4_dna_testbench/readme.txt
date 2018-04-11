Reference implementation of the Smith-Waterman dynamic programming
algorithm in C++, with an application to DNA alignment.

-- Optimizations and parallelism
 The reference code is serialized. Parallelism will be achieved by:
 * Calculating the alignment of characters in parallel (**O(m+n)** runtime)
 * Passing the outputs of processing elements into a pipeline, reducing space overhead

-- Usage:
  $ g++ main.cpp -o main
  $ ./main baseseq.txt streamseq.txt
