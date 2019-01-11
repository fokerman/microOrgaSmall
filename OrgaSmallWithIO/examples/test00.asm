; MIT License
; Copyright (c) 2018 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test00.asm: Count and show output

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
SET  R1, 0x01
SET  R4, 0x00

halt:
    ADD R4, R1
    STR [0xFC], R4
    
    ; time lost loop
    SET  R5, 0x00
    loop:
        SET  R6, 0x00
        loopBis:
            ADD R6, R1
            CMP R6, R0
            JZ continue
        JMP loopBis
        continue:
        ADD R5, R1
        CMP R5, R0
        JZ halt
    JMP loop
    
JMP halt

