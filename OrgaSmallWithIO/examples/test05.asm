; MIT License
; Copyright (c) 2018 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test05.asm: Interruption rutine test, counter with restart

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
SET R0, 0x0
SET R1, 0x1
halt:
    ; set output port with interrupts count
    CALL |R7|, delay
    LOAD R6, [data]
    STR [0xFC], R6
    CMP R6, R0
    JZ halt
    SUB R6, R1
    STR [data], R6
JMP halt

data:
    DB 0x0F

interrupt_handler:
    ; save registers
    PUSH |R7|, R0
    ; set max value
    SET R0, 0x0F
    STR  [data], R0
    ; load registers
    POP  |R7|, R0
    RETI |R7|

delay:
    PUSH |R7|, R0
    PUSH |R7|, R1
    PUSH |R7|, R2
    PUSH |R7|, R3
    PUSH |R7|, R4
    ; test data is zero to delay
    SET R0, 0
    LOAD R2, [data]
    CMP R2, R0
    JZ end
    ; delay counter
        SET R1, 1
        SET R2, 0x0F
        SET R3, 0xFF
        SET R4, 0xFF
        loop0:
            SUB R2, R1
            CMP R2, R0
            JZ end
            SET R3, 0xFF
            loop1:
                SUB R3, R1
                CMP R3, R0
                JZ loop0
                SET R4, 0xFF
                loop2:
                    SUB R4, R1
                    CMP R4, R0
                    JZ loop1
                JMP loop2
    end:
    POP  |R7|, R4
    POP  |R7|, R3
    POP  |R7|, R2
    POP  |R7|, R1
    POP  |R7|, R0
    RET  |R7|
    
    
    
    	
    


