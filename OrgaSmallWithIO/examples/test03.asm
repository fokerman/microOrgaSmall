; MIT License
; Copyright (c) 2018 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test03.asm: IO Pooling, copy outputs with delay

; Memory
; 0x00 = entry point
; ...
; 0xFB = stack base
; 0xFC = port Output
; 0xFD = port Input
; 0xFE = port Interrupt
; 0xFF = Interrupt rutine pointer

; set STACK
SET R7, 0xFB

; main
SET  R0, 0x00
SET  R5, 1
SET  R6, 0xFF

halt:
    ; load input port
    LOAD R1, [0xFD]
    AND R1, R5
    CMP R1, R5
    ; if the first bit is set
    JZ seguir
    
    ; set output port with 0xFF
    STR [0xFC], R6
    
    seguir:
    ; else,
    ; decrement the value of the output port
    ; until reach 0x00.
    LOAD R1, [0xFC]
    CMP R1, R0
    JZ halt
    SUB R1, R5
    STR [0xFC], R1

JMP halt
