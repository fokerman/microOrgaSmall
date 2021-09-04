 MIT License
 Copyright (c) 2018 David Alejandro Gonzalez Marquez
 
 ----------------------------------------------------------------------------
 -- OrgaSmallSystem ---------------------------------------------------------
 ----------------------------------------------------------------------------

 This is an system-on-chip implementation for a very small processor (8 bits).
 It was design for educational purposes. Using this tool, you could explain
 the instruction cycle, how works a data path or even how to design a new
 instruction.

- Von Neumann Architecture, instructions and data in the same memory.
- 8 general purpose registers.
- One special register por program counter.
- Word size and bus 8 bits. Instructions 16 bits.
- Microprogramed design.

  Only version with interrupt:
- Support for 3 in-out ports, two ports for input, and one port for output.
- One interrupt for detect changes in one input port.

 For more information, read the documentation (for now is only in spansh,
 I will try traslate it).

 - Folders -

 There are two folders, one with the full implementation with IO, and a
 simplified version. These folders have the same content.

 micro:    System on chip description file for LogiSim and in Verilog
 doc:      documentation about microprocessor, tools and usage (in spanish)
 examples: Code example
 tools:    Compiler tool and micro-ops generation tool


