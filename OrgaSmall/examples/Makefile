# MIT License
# Copyright (c) 2018 David Alejandro Gonzalez Marquez
# ----------------------------------------------------------------------------
# -- OrgaSmallSystem ---------------------------------------------------------
# ----------------------------------------------------------------------------

# Asemble any code for the memory processor
# It generates three files for each .asm
# .mem is for the memory procesor (code machine)
# .txt is a human redeable code as result of asemble
# Verilog.mem is the same as .mem for verilog code

SOURCES := $(shell find . -name '*.asm')

OUTPUT_C := $(SOURCES:%.asm=%.mem)
OUTPUT_T := $(SOURCES:%.asm=%.txt)

all: $(OUTPUT_C)

ASM=python ../tools/assembler.py

%.mem: %.asm
	$(ASM) $<

clean:
	rm -f $(OUTPUT_C) $(OUTPUT_T)
