#!/usr/bin/python
# MIT License
# Copyright (c) 2018 David Alejandro Gonzalez Marquez

from __future__ import print_function

import sys
from common import *

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: assembler.py file.asm")
        exit(1)

    filename = sys.argv[1]
    if filename[-4:] == ".asm":
        outputM=filename[:-4] + ".mem"
        outputH=filename[:-4] + ".txt"
    else:
        outputM=filename + ".mem"
        outputH=filename + ".txt"

    try:
        tokens = tokenizator(filename)
        instructions,labels = removeLabels(tokens)
        parseBytes, parseHuman = parseInstructions(instructions,labels)
        if parseBytes != None:
            printCode(outputM,parseBytes)
        if parseHuman != None:
            printHuman(outputH,parseHuman,labels,filename)

    except ValueError as e:
        print(e)