#!/usr/bin/python2

import sys
import re

def main():
    if len(sys.argv) != 3:
        print "Usage:", sys.argv[0], "<input file name> <output file name>"
        return
    input_file = open(sys.argv[1], 'r')
    output_file= open(sys.argv[2], 'w')
    match_hex32b = re.compile('[0-9a-fA-F]{8}')
    START_ADDR = 0
    now_addr = START_ADDR

    linenum = 0
    for eachline in input_file:
        line = eachline.strip(' \n\r')
        if not eachline:
            continue
        result = match_hex32b.match(eachline)
        if not result:
            print "Error parsing line %d\"%s\": Invalid." % (linenum, line)
            continue
        target_line = "14'h%04x:    data = 32'h%s;\n" % (now_addr, line)
        output_file.write(target_line)

        now_addr = now_addr + 1
        linenum = linenum + 1

    input_file.close()
    output_file.close()


if __name__ == '__main__':
    main()
