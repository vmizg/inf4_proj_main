#!/usr/bin/python

import sys
import struct

def d2b(dna = None):
    if dna is None:
       dna = "TCTCCACCACATCCAT"
    res = ""
    for base in dna:
       if base.lower() == "a":
          res = res + "00"
       elif base.lower() == "c":
          res = res + "01"
       elif base.lower() == "g":
          res = res + "10"
       elif base.lower() == "t":
          res = res + "11"
    res_bin = struct.pack(">I", int(res, base=2))
    return res_bin

def d2b_file():
    outfile = open('dnabin', 'w+')
    print "{",
    for line in sys.stdin:
        line = line.strip()
        for base in line:
            base = str(base)
            if base.lower() == "a":
                outfile.write(struct.pack("c", chr(0)))
                print "{2'd0},",
            elif base.lower() == "c":
                outfile.write(struct.pack("c", chr(1)))
                print "{2'd1},",
            elif base.lower() == "g":
                outfile.write(struct.pack("c", chr(2)))
                print "{2'd2},",
            elif base.lower() == "t":
                outfile.write(struct.pack("c", chr(3)))
                print "{2'd3},",
    print "};"
    outfile.close()
