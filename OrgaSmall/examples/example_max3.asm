max3:
        LOAD R1, [data1]
        LOAD R2, [data2]
        LOAD R3, [data3]

        CMP R1, R2
        JN maxR2
        MOV R0, R1
        JMP nextR3
maxR2:  MOV R0, R2
nextR3: CMP R0, R3
        JN maxR3
        JMP fin
maxR3:  MOV R0, R3
fin:    STR [mayor], R0

halt:   JMP halt
    
data1:  DB 0x35
data2:  DB 0x64
data3:  DB 0x33
mayor:  DB 0x00
    
