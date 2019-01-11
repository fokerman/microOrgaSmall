; MIT License
; Copyright (c) 2018 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test04.asm: Interruption rutine test, interrupt counter

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

; Set Interrupt Rutine
SET R0, interrupt_handler
STR  [0xFF], R0

; Set Interrupt Flag
SET R0, 0x10
LOADF R0

; main
halt:
    ; set output port with interrupts count
    LOAD R6, [data]
    STR [0xFC], R6
JMP halt

data:
    DB 0x0

interrupt_handler:
    ; save registers
    PUSH |R7|, R0
    PUSH |R7|, R1
    ; increment interrupt count
    SET R1, 1
    LOAD R0, [data]
    ADD  R0, R1
    STR  [data], R0
    ; load registers
    POP  |R7|, R1
    POP  |R7|, R0
    RETI |R7|





