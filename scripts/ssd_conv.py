#!/usr/bin/python

import sys
num_arg = sys.argv[1]
num_bin = format(int(num_arg), 'b').zfill(6)
print(num_bin)

if (int(num_arg) > 64):
    raise TypeError("Integer out of bounds")

for i in range(0, 6):
    if (i == 0):
        print "core_en:              ",
    elif (i == 1):
        print "final_counter = SEQ:  ",
    elif (i == 2):
        print "read_open:            ",
    elif (i == 3):
        print "write_open:           ",
    elif (i == 4):
        print "final_flag:           ",
    elif (i == 5):
        print "read_EOF:             ",
    print num_bin[i]
    
