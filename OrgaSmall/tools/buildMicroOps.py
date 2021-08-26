#!/usr/bin/python
# MIT License
# Copyright (c) 2018 David Alejandro Gonzalez Marquez

from __future__ import print_function

import sys
from common import *

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: buildMicroOps.py file.ops")
        exit(1)

    filename = sys.argv[1]
    if filename[-4:] == ".ops":
        output=filename[:-4] + ".mem"
    else:
        output=filename + ".mem"

    try:
        tokens = tokenizator(filename)
        microCode = parseOpcodes(tokens)
        code = codeValues(microCode)
        printMicroCode(output,code)

    except ValueError as e:
        print(e)















