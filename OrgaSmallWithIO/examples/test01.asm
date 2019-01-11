; MIT License
; Copyright (c) 2018 David Alejandro Gonzalez Marquez
; ----------------------------------------------------------------------------
; -- OrgaSmallSystem ---------------------------------------------------------
; ----------------------------------------------------------------------------

; EXAMPLE OrgaSmall
; test01.asm: Instruction test

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

main:
    SET R0, 0xF1
    SET R1, 0xF2
    SET R2, 0xF3
    SET R3, 0xF4
    SET R4, 0x10
    SET R5, 0x20
    SET R6, 0x0F
    
    SUB R2, R3  ; R2 <- F3 - F4 = FF
    ADD R0, R1  ; R0 <- F1 + F2 = E3 (c=1)
    ADC R4, R5  ; R4 <- 10 + 20 + 1 = 31
    AND R3, R4  ; R3 <- F4 & 31 = 30
    OR  R3, R6  ; R3 <- 30 | 0F = 3F
    XOR R3, R2  ; R3 <- 3F | FF = C0
    CMP R0, R0  ; Z = 1
    MOV R0, R6  ; R0 <- 0F

    PUSH |R7|, R0 ; [FB] <- 0F ; R7 <- FA
    PUSH |R7|, R1 ; [FA] <- F2 ; R7 <- F9
    POP  |R7|, R0 ;  R0  <- F2 ; R7 <- F9
    POP  |R7|, R1 ;  R1  <- 0F ; R7 <- FA

    SHR  R0, 3 ; R0 <- 1E
    SHL  R0, 3 ; R0 <- F0
    SHRA R0, 1 ; R0 <- F8
    
    CALL |R7|, funcion
    
    READF R0       ; R0   <- 04
    SET   R1, 0x0C
    OR    R0, R1   ; R0   <- 0C
    LOADF R0       ; FLAG <- 0C
    
    
    SET R0, 0x7F
    ADD R0, R0
    JO continue    ; its true, so Jump!
    impossibleToReach:
    SET R0, 0x00
    SET R1, 0x11
    SET R2, 0x22
    SET R3, 0x33
    SET R4, 0x44
    SET R5, 0x55
    SET R6, 0x66
    SET R6, 0x77
    continue:
    ADD R0, R0
    JZ impossibleToReach ; its false, it's not negative
    JMP halt
    
    funcion:
        SET R0, 0x1
        SET R1, 0x2
        SET R2, 0x3
        SET R3, 0x4
        RET |R7|
halt:
JMP halt
    
data:
    DB 0x35
    DB 0x64
    DB 0x33
    DB 0x75
    DB 0x92
    DB 0xf2
    DB 0x03
    DB 0x62
    DB 0x88
    DB 0xEE





