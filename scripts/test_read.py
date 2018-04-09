#!/usr/bin/python

import os
import struct
from d2b import d2b

f_in = os.open('/dev/xillybus_stream_score_out', os.O_RDONLY)

d = os.read(f_in, 4)

print str(struct.unpack('<L', d)[0]) + "|",
counter = 1
total = 1
printed = False
while (d != ''):
    d = os.read(f_in, 4)
    if (len(d) == 4):
    	print str(struct.unpack('<I', d)[0]) + "|",
