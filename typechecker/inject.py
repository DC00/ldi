# Daniel Coo (djc4ku)
# Raymond Zhao (rfz9nt)

import sys
import random

lines = [ l.rstrip() for l in tuple(open(sys.argv[1], 'r')) ]

interesting_positions = []
for i in range(len(lines)):
    line = lines[i]
    if line in ['type', 'identifier']:
        interesting_positions = [i+1] + interesting_positions

for j in range(80):
    pos1 = random.choice(interesting_positions)
    pos2 = random.choice(interesting_positions)
    val1 = lines[pos1]
    val2 = lines[pos2]
    print "swapping " , val1, "at", pos1, "with", val2, "at", pos2
    handle = open(str(j) + "-" + sys.argv[1], 'w')

    for i in range(len(lines)):
        line = lines[i]
        if i == pos1:
            line = val2
        elif i == pos2:
            line = val1
        handle.write(line + "\n")

    handle.close()

# print interesting_positions


