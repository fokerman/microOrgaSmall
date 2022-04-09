; MIT License
; Copyright (c) 2022 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test05.asm: Interruption rutine, pulse signal controller

; Memory
; 0x00 = entry point
; ...
; 0xFB = stack base
; 0xFC = port Output
; 0xFD = port Input
; 0xFE = port Interrupt
; 0xFF = Interrupt rutine pointer

; ---------------------------------------------------------
; main
SET R0, 0x0
SET R1, 0x1

; set STACK
SET R7, 0xFB

; Set Interrupt Rutine
SET R0, interrupt_handler
STR  [0xFF], R0

; Set Interrupt Flag
SET R0, 0x10
LOADF R0

; loop
whileTrue:
    STR [0xFC], R0
    CALL |R7|, sleep
    STR [0xFC], R1
    CALL |R7|, sleep
JMP whileTrue

sleep:
    SET R3, 0x8
    LOAD R2, [data]
    ciclo:
        SUB R2, R1
        CMP R2, R0
        JZ end_sleep
        ; start SLEEP COUNTER
            LOAD R4, [0xFC]
            ADD R4, R3
            STR [0xFC], R4
        ; end SLEEP COUNTER
        JMP ciclo
    end_sleep:
    RET  |R7|

; ---------------------------------------------------------
data:
    DB 0x0F

; ---------------------------------------------------------
interrupt_handler:
    ; save registers
    PUSH |R7|, R0
    PUSH |R7|, R1
    PUSH |R7|, R2
    PUSH |R7|, R3
    PUSH |R7|, R4
    SET R0, 0x1
    SET R1, 0x2
    LOAD R3, [0xFE]
    CMP R3, R0
    JZ inc
    CMP R3, R1
    JZ dec
    end_interrupt:
    POP  |R7|, R4
    POP  |R7|, R3
    POP  |R7|, R2
    POP  |R7|, R1
    POP  |R7|, R0
    RETI |R7|
    
    inc:
    	SET R0, 1
        LOAD R3, [data]
        ADD R3, R0
        STR [data], R3
        JMP end_interrupt
    
    dec:
    	SET R0, 1
        LOAD R3, [data]
        SUB R3, R0
        STR [data], R3
        JMP end_interrupt

