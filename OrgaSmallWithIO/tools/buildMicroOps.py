#!/usr/bin/python
# MIT License
# Copyright (c) 2018 David Alejandro Gonzalez Marquez
# ----------------------------------------------------------------------------
# -- OrgaSmallSystem ---------------------------------------------------------
# ----------------------------------------------------------------------------

from __future__ import print_function

import sys
from common import *

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: buildMicroOps.py file.ops")
        exit(1)

    filename = sys.argv[1]
    if filename[-4:] == ".ops":
        outputM=filename[:-4] + ".mem"
        outputV=filename[:-4] + "Verilog.mem"
    else:
        outputM=filename + ".mem"
        outputV=filename + "Verilog.mem"

    try:
        tokens = tokenizator(filename)
        microCode = parseOpcodes(tokens)
        code = codeValues(microCode)
        printMicroCode(outputM,code)
        printMicroCodeVerilog(outputV,code)

    except ValueError as e:
        print(e)
        

















