# MIT License
# Copyright (c) 2022 David Alejandro Gonzalez Marquez
# ----------------------------------------------------------------------------
# -- OrgaSmallSystem ---------------------------------------------------------
# ----------------------------------------------------------------------------

# Generate the memory code for the micro operations.
# It is use into the Control Unit memory.

SOURCE := microCode.ops

OUTPUT_C := microCode.mem
OUTPUT_V := microCodeVerilog.mem

all: $(OUTPUT_C)

ASM=python ../tools/buildMicroOps.py

%.mem: %.ops
	$(ASM) $<

clean:
	rm -f $(OUTPUT_C) $(OUTPUT_V)
