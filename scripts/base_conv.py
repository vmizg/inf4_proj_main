#!/usr/bin/python

import sys
import struct

outfile = open('dnabinary', 'w+')

print "{",
for line in sys.stdin:
    line = line.strip()
    for dnabase in line:
        dnabase = str(dnabase)
        if dnabase.lower() == "a":
            outfile.write(struct.pack("c", chr(0)))
            print "{2'd0},",
        elif dnabase.lower() == "c":
            outfile.write(struct.pack("c", chr(1)))
            print "{2'd1},",
        elif dnabase.lower() == "g":
            outfile.write(struct.pack("c", chr(2)))
            print "{2'd2},",
        elif dnabase.lower() == "t":
            outfile.write(struct.pack("c", chr(3)))
            print "{2'd3},",
print "};"

outfile.close()

