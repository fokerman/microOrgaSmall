# MIT License
# Copyright (c) 2018 David Alejandro Gonzalez Marquez
# ----------------------------------------------------------------------------
# -- OrgaSmallSystem ---------------------------------------------------------
# ----------------------------------------------------------------------------

# Asemble any code for the memory processor
# It generates three files for each .asm
# .mem is for the memory procesor (code machine)
# .txt is a human redeable code as result of asemble

SOURCES_ASM := $(shell find . -name '*.asm')
SOURCES_OPS := $(shell find . -name '*.ops')

OUTPUT_C := $(SOURCES_ASM:%.asm=%.mem)
OUTPUT_T := $(SOURCES_ASM:%.asm=%.txt)
OUTPUT_O := $(SOURCES_OPS:%.ops=%.mem)

all: $(OUTPUT_C) $(OUTPUT_O)

ASM=python ../tools/assembler.py
OPS=python ../tools/buildMicroOps.py

%.mem: %.asm
	$(ASM) $<

%.mem: %.ops
	$(OPS) $<

clean:
	rm -f $(OUTPUT_C) $(OUTPUT_T) $(OUTPUT_O)
