JMP seguir ; |00|
DB 0       ; |02|
numero:
DB 0       ; |03|
DB 0       ; |04|
otro:
DB 0       ; |05|

seguir:
SET R0, 0xFF
SET R1, 0x11
SET R2, 0x12
SET R3, 0xF0

ADD R0, R1 ; R0=0x10 c=1
ADC R0, R0 ; R0=0x21 c=0
SUB R2, R1 ; R2=0x01
AND R1, R0 ; R1=0x01
OR  R3, R1 ; R3=0xF1
XOR R3, R1 ; R3=0xF0
CMP R1, R0 ; 0x01-0x21 N=1 C=1
MOV R1, R3 ; R1=0xF0

STR [numero], R0  ; [0x03] = 0x21
LOAD R1, [numero] ; R1 = 0x21

SET R4, otro  ; R4=0x05 (otro)
STR [R4], R0  ; [0x05] = 0x21
LOAD R3, [R4] ; R3 = 0x21

JC siguiente
DB 0xFF  ; nose ejecuta
DB 0xFF  ; nose ejecuta
siguiente:

JZ  nosalta

JN  otrosiguiente
DB 0xFF  ; nose ejecuta
DB 0xFF  ; nose ejecuta
otrosiguiente:

INC R1   ; R1=0x22
DEC R3   ; R3=0x20
SHR R1,1 ; R1=0x11
SHL R3,2 ; R3=0x80

nosalta:

halt:
JMP halt
















;
;SET R0,  4 
;SET R1,  2 
;ADD R1, R0 
;        
;SET R0,  3 
;SET R1,  8 
;SUB R1, R0 
;        
;SET R0,  2 
;SET R1,  6 
;CMP R1, R0 
;        
;
;JMP comenzar
;
;numero:
;DB 0
;DB 0
;DB 0
;DB 0
;DB 0
;DB 0
;DB 0
;DB 0
;DB 0
;DB 0
;
;comenzar:
;SET R0, 0xAA
;STR [numero], R0
;
;
;
;reinicio:
;
;SET R7, 0x0F
;
;MOV R7,R4
;
;INC R7
;INC R7
;
;DEC R7
;DEC R7
;
;SET R2, 0xFF
;SET R4, 0x11
;ADD R2, R4
;
;SET R1, 0x23
;SET R5, 0x11
;SUB R1, R5
;
;SET R1, 0xFF
;SET R6, 0x11
;XOR R1, R6
;
;CMP R1, R2
;JZ seguir
;
;colgado:
;JMP colgado
;joder:
;seguir:
;
;SHR R1, 3
;SHL R2, 3
;
;SET R1, 0xAA
;SET R2, 0xBB
;
;STR [0xF1], R1
;STR [0xF2], R2
;LOAD R1, [0xF2]
;LOAD R2, [0xF1]
;
;JMP reinicio
;