#!/usr/bin/python

import sys
num_arg = sys.argv[1]
num_bin = format(int(num_arg), 'b').zfill(7)
print(num_bin)

if (int(num_arg) > 64):
    raise TypeError("Integer out of bounds")

for i in range(0, 7):
    if (i == 0):
        print "EOF:                  ",
    elif (i == 1):
        print "score_out FULL:       ",
    elif (i == 2):
        print "score_out OPEN:       ",
    elif (i == 3):
        print "proc_counter:         ",
    elif (i == 4):
        print "dna_y OPEN:           ",
    elif (i == 5):
        print "dna_X READY:          ",
    elif (i == 6):
        print "dna_X OPEN:           ",
    print num_bin[i]
    
