; MIT License
; Copyright (c) 2018 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test02.asm: Sorting algorithm

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

; buble sort
;          R0                R1    (tmp value)
;         _|_________________|__________________
;        |___|_____________|___|->______________|
;          |                 |
; index:   R2                R4
; offset:  R3                R5

sort:
    
    SET R2, 0
    SET R3, data
    SET R4, 1
    SET R5, data
    SET R0, 1
    ADD R5, R0
    
    seguir:
    
        ; compare current values
        LOAD R0, [R3]
        LOAD R1, [R5]
        CMP R0, R1
        JN R0lowerthanR1
        
        ; exchange values
        STR [R3], R1
        STR [R5], R0
        
        R0lowerthanR1:
        ; set next element
        SET R0, 1
        ADD R4, R0
        ADD R5, R0
        
        ; check element range
        SET R0, 10
        CMP R4, R0
        JN R3lowerthanR0
        
        ; check last element
        SET R0, 8
        CMP R2, R0
        JZ halt

        ; set next first element
        SET R0, 1
        ADD R2, R0
        ADD R3, R0
        MOV R4, R2
        MOV R5, R3
        ADD R4, R0
        ADD R5, R0
        
        R3lowerthanR0:
        ; continue sorting
        JMP seguir

halt:
JMP halt

    DB 0x00
    DB 0x00
    DB 0x00
    DB 0x00
    
data:
    DB 0x35
    DB 0x64
    DB 0x33
    DB 0x75
    DB 0x12
    DB 0x02
    DB 0x03
    DB 0x22
    DB 0x08
    DB 0x1E
    
    DB 0x00
    DB 0x00
    DB 0x00
    DB 0x00

