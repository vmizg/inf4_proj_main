Test sequences...
To get results for the actual sequence,
the sequences needs to be reversed first. The results will
be for non-reversed alignment.

Base:
Normal: ACTTCCGTCCACGATT
"\x00\x01\x03\x03\x01\x01\x02\x03\x01\x01\x00\x01\x02\x00\x03\x03"
struct.pack("<I", int("00011111010110110101000110001111", base=2))
Reversed: TTAGCACCTGCCTTCA

Stream:
Normal: GTTAGTTGCAGATAAC
"\x02\x03\x03\x00\x02\x03\x03\x02\x01\x00\x02\x00\x03\x00\x00\x01"
struct.pack("<I", int("10111100101111100100100011000001", base=2))
Reversed: CAATAGACGTTGATTG


