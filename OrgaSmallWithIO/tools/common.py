#!/usr/bin/python
# MIT License
# Copyright (c) 2018 David Alejandro Gonzalez Marquez
# ----------------------------------------------------------------------------
# -- OrgaSmallSystem ---------------------------------------------------------
# ----------------------------------------------------------------------------

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# 00 - Fech Reserved  - 00000 - -----------
# 01 - ADD Rx, Ry     - 00001 - XXXYYY-----
# 02 - ADC Rx, Ry     - 00010 - XXXYYY-----
# 03 - SUB Rx, Ry     - 00011 - XXXYYY-----
# 04 - AND Rx, Ry     - 00100 - XXXYYY-----
# 05 - OR  Rx, Ry     - 00101 - XXXYYY-----
# 06 - XOR Rx, Ry     - 00110 - XXXYYY-----
# 07 - CMP Rx, Ry     - 00111 - XXXYYY-----
# 08 - MOV Rx, Ry     - 01000 - XXXYYY-----
# 09 - PUSH |Rx|, Ry  - 01001 - XXXYYY-----
# 10 - POP  |Rx|, Ry  - 01010 - XXXYYY-----
# 11 - CALL |Rx|, Ry  - 01011 - XXXYYY-----
# 12 - CALL |Rx|, M   - 01100 - XXXMMMMMMMM
# 13 - RET  |Rx|      - 01101 - XXX--------
# 14 - RETI |Rx|      - 01110 - XXX--------
# 15 - Free           - 11111 - -----------
# 16 - STR  [M],  Rx  - 10000 - XXXMMMMMMMM
# 17 - LOAD  Rx, [M]  - 10001 - XXXMMMMMMMM
# 18 - STR  [Rx], Ry  - 10010 - XXXYYY-----
# 19 - LOAD  Rx, [Ry] - 10011 - XXXYYY-----
# 20 - JMP M          - 10100 - ---MMMMMMMM
# 21 - JC  M          - 10101 - ---MMMMMMMM
# 22 - JZ  M          - 10110 - ---MMMMMMMM
# 23 - JN  M          - 10111 - ---MMMMMMMM
# 24 - JO  M          - 11000 - ---MMMMMMMM
# 25 - SHRA  Rx, t    - 11001 - XXXYYY-----
# 26 - SHR   Rx, t    - 11010 - XXXYYY-----
# 27 - SHL   Rx, t    - 11011 - XXXYYY-----
# 28 - READF Rx       - 11100 - XXX--------
# 29 - LOADF Rx       - 11101 - XXX--------
# 30 - SET Rx, M      - 11111 - XXXMMMMMMMM
# 31 - Int Reserved   - 11110 - -----------

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

import sys
import os

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Tokenize function

def tokenizator(filename):
    tokens=[]
    newline=['\n']
    comment=[';']
    blank=[' ','\t']+newline+comment
    reserve=['[',']',',',':','|']

    with open(filename) as f:
        line=[]
        word=""
        isComment=False
        while True:
            c = f.read(1)
            if not c:
                break
            
            if not isComment:
                
                if c in blank:
                    if len(word)>0:
                        line=line+[word]
                    word=""
                    if c in newline or c in comment:
                        if len(line)>0:
                            tokens=tokens+[line]
                        line=[]
                    if c in comment:
                        isComment=True
                        
                elif c in reserve:
                    if len(word)>0:
                        line=line+[word]
                    word=""
                    line=line+[c]
                    
                else:
                    word=word+c
                    
            else: # isComment
                if c in newline:
                    isComment=False
    return tokens

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Assembly code constants

type_RR = ["ADD","ADC","SUB","AND","OR" ,"XOR","CMP","MOV"]
type_SR = ["PUSH", "POP", "CALL"]
type_S  = ["RET", "RETI"]
type_RM = ["STR","LOAD"]
type_M  = ["JMP","JC","JZ","JN","JO"]
type_RF = ["READF","LOADF"]
type_RS = ["SHRA","SHR","SHL"]
type_RI = ["SET"]
def_DB  = ["DB"]

opcodes = {"ADD"  : 1,  "ADC"  : 2, "SUB"   : 3,
           "AND"  : 4,  "OR"   : 5, "XOR"   : 6,
           "CMP"  : 7,   "MOV" : 8,
           "PUSH" : 9,  "POP"  : 10,
           "CALL" : 11, "CALLm": 12, "RET"  : 13, "RETI" : 14,
           "STR"  : 16, "LOAD" : 17, "STRr" : 18, "LOADr": 19,
           "JMP"  : 20, "JC"   : 21, "JZ"   : 22, "JN"   : 23, "JO"  :24,
           "SHRA" : 25, "SHR"  : 26, "SHL"  : 27,
           "READF": 28, "LOADF": 29, "SET"  : 30}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Assembly code functions

def removeLabels(tokens):
    instCount=0
    reserveLabel=':'
    instructions=[]
    labels={}
    for t in tokens:
        if len(t)<2:
            raise ValueError("Error: Can not convert \"" + t[0] + "\"")
            return None, None
        if t[1]==reserveLabel:
            labels[t[0]]=instCount
            if len(t)>2:
                instructions=instructions+[t[2:]]
                if t[2] in def_DB:
                    instCount=instCount+1
                else:
                    instCount=instCount+2
        else:
            instructions=instructions+[t[0:]]
            if t[0] in def_DB:
                instCount=instCount+1
            else:
                instCount=instCount+2
    return instructions,labels

def reg2num(reg):
    if reg[0]=="R":
        try:
            val = int(reg[1:])
        except ValueError:
            print("Error: Can not convert \"" + reg + "\"")
            return None
        if 0 <= val and val <= 7:
            return val
        print("Error: \"" + reg + "\" out of range (0-7)" )
        raise ValueError()
    else:
        print("Error: \"" + reg + "\" is not a valid register" )
        raise ValueError()

def mem2num(mem,labels):
    if mem in labels.keys():
        return labels[mem]
    else:
        try:
            if mem[0:2] == "0x" or mem[0:2] == "0X":
                val = int(mem[2:],16)
            elif mem[-1:] == "b":
                val = int(mem[:-1],2)
            else:
                val = int(mem,10)        
        except ValueError:
            print("Error: Can not convert \"" + mem + "\"")
            return None
        if 0 <= val and val <= 255:
            return val
        print("Error: \"" + mem + "\" out of range (0-255)" )
        raise ValueError()

def shf2num(num):
    val = mem2num(num,{})
    if 0 <= val and val <= 7:
        return val
    print("Error: \"" + num + "\" out of range (0-7)" )
    raise ValueError()
    
def buidInst(d):
    n = 0
    if "O" in d:
        n = n + (d["O"] << 11)
    if "X" in d:
        n = n + (d["X"] << 8)
    if "Y" in d:
        n = n + (d["Y"] << 5)
    if "M" in d:
        n = n + (d["M"])
    if "I" in d:
        n = n + (d["M"])
    return n

def appendParse(parseBytes,parseHuman,i,n):
    addr=len(parseBytes)
    parseBytes.append(n >> 8)
    parseBytes.append(n & 0xFF)
    parseHuman.append([addr,i])
    
def parseInstructions(instructions,labels):
    parseBytes=[]
    parseHuman=[]
    for i in instructions:
        
        try:
            
            # AAA Rx,Ry || Rx <= Rx AAA Ry
            if i[0] in type_RR:
                if i[2] == ",":
                    n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[1]), "Y":reg2num(i[3])})
                    appendParse(parseBytes,parseHuman,i,n)
                else:
                    raise ValueError("Error: Invalid instruction \"" + i[0] + "\"")
                    break
                
            # STR || LOAD
            elif i[0] in type_RM:
                if i[0]=="STR" and i[1]=="[" and i[3]=="]" and i[4]==",":
                    if i[2][0]=="R":
                        # STR [Rx],RY  || [Rx] <= Ry
                        n = buidInst({"O":opcodes[i[0]+'r'], "X":reg2num(i[2]), "Y":reg2num(i[5])})
                    else:
                        # STR [M],Rx  || [M] <= Rx
                        n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[5]), "M":mem2num(i[2],labels)})
                    appendParse(parseBytes,parseHuman,i,n)
                elif i[0]=="LOAD" and i[2]=="," and i[3]=="[" and i[5]=="]":
                    if i[4][0]=="R":
                        # LOAD Rx,[Ry] || Rx <= [Ry]
                        n = buidInst({"O":opcodes[i[0]+'r'], "X":reg2num(i[1]), "Y":reg2num(i[4])})
                    else:
                        # LOAD Rx,[M] || Rx <= [M]
                        n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[1]), "M":mem2num(i[4],labels)})
                    appendParse(parseBytes,parseHuman,i,n)
                else:
                    raise ValueError("Error: Invalid instruction \"" + i[0] + "\"")
                    break
                
            # Jxx M
            elif i[0] in type_M:
                n = buidInst({"O":opcodes[i[0]], "M":mem2num(i[1],labels)})
                appendParse(parseBytes,parseHuman,i,n)
                
            # PUSH |Rx|, Ry || POP |Rx|, Ry || CALL |Rx|, Ry || CALL |Rx|, M
            elif i[0] in type_SR:
                # ERROR FALTA INDICAR EL REGISTRO PILA
                if i[5][0]=="R":
                    # PUSH |Rx|, Ry || POP |Rx|, Ry || CALL |Rx|, Ry
                    n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[2]), "Y":reg2num(i[5])})
                else:
                    # CALL |Rx|, M
                    n = buidInst({"O":opcodes[i[0]+'m'], "X":reg2num(i[2]), "M":mem2num(i[5],labels)})
                appendParse(parseBytes,parseHuman,i,n)  
                
            # RET |Rx| || RETI |Rx|
            elif i[0] in type_S:
                n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[2])})
                appendParse(parseBytes,parseHuman,i,n)
                
            # AAA Rx
            elif i[0] in type_RF:
                n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[1])})
                appendParse(parseBytes,parseHuman,i,n)
                
            # SSS Rx,7
            elif i[0] in type_RS:
                if i[2] == ",":
                    n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[1]), "Y":shf2num(i[3])})
                    appendParse(parseBytes,parseHuman,i,n)
                else:
                    raise ValueError("Error: Invalid instruction \"" + i[0] + "\"")
                    break
                
            # SET Rx, M
            elif i[0] in type_RI:
                if i[2]==",":
                    n = buidInst({"O":opcodes[i[0]], "X":reg2num(i[1]), "M":mem2num(i[3],labels)})
                    appendParse(parseBytes,parseHuman,i,n)
                else:
                    raise ValueError("Error: Invalid instruction \"" + i[0] + "\"")
                    break
                
            # DB M
            elif i[0] in def_DB:
                parseHuman.append( [len(parseBytes),i] )
                parseBytes.append( mem2num(i[1],labels) )
                
            ##
            else:
                raise ValueError("Error: Unknown instruction \"" + i[0] + "\"")
                sys.exit(1)
                
        except ValueError as err:
            if len(err.args)>0:
                print(err.args[0])
            print("Error: Instruction: " +  " ".join(i))
            sys.exit(1)
            
    return parseBytes,parseHuman

def printCode(output,parse):
    f = open(output,"w")
    f.write("v2.0 raw\n")
    for i in parse:
        f.write('%02x ' % i )
        f.write("\n")
    f.close()
    
def printCodeVerilog(output,parse):
    f = open(output,"w")    
    for i in range(len(parse)):
        f.write("%02x\n" % (parse[i]))
    f.close()

def printHuman(outputH,parseHuman,labels,filename):
    f = open(outputH,"w")
    
    inverseLabels = {}
    for name, addr in labels.items():
        if addr in inverseLabels:
            inverseLabels[addr].append(name)
        else:
            inverseLabels[addr] = [name]
            
    allNames = list(map(lambda x: ", ".join(x),  inverseLabels.values() ))
    if len(allNames)==0:
        maxName = 0
    else:
        maxName = max(map(len,allNames))
    
    for p in parseHuman:
        if p[0] in inverseLabels:
            f.write( (", ".join(inverseLabels[p[0]])).rjust(maxName) )
        else:
            f.write(" "*maxName)
        f.write(' |%02x| ' % p[0] )
        f.write(" ".join(p[1]) )
        f.write("\n")
    f.close()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Build micro operations constants

signals={ "RB_enIn"           :  0,
          "RB_enOut"          :  1,
          "RB_selectIndexIn"  :  2,
          "RB_selectIndexOut" :  3,
          "RB_selectSP"       :  4,
          "MM_enOut"          :  5,
          "MM_load"           :  6,
          "MM_enAddr"         :  7,
          "ALU_enA"           :  8,
          "ALU_enB"           :  9,
          "ALU_enOut"         : 10,
          "ALU_opW"           : 11,
          "ALU_OP"            : 12,
          "RESERVED_ALU_OP_1" : 13,
          "RESERVED_ALU_OP_2" : 14,
          "RESERVED_ALU_OP_3" : 15,
          "JC_microOp"        : 16,
          "JZ_microOp"        : 17,
          "JN_microOp"        : 18,
          "JO_microOp"        : 19,
          "PC_load"           : 20,
          "PC_inc"            : 21,
          "PC_enOut"          : 22,
          "RESERVED23"        : 23,
          "DE_enOutImm"       : 24,
          "DE_loadL"          : 25,
          "DE_loadH"          : 26,
          "IC_intAck"         : 27,
          "RESERVED28"        : 28,
          "load_Int_microOp"  : 29,
          "load_microOp"      : 30,
          "reset_microOp"     : 31 }

ALUops={ "RESERVED0"  : 0, 
         "ADD"        : 1, 
         "ADC"        : 2, 
         "SUB"        : 3, 
         "AND"        : 4, 
         "OR"         : 5, 
         "XOR"        : 6, 
         "SHRA"       : 7, 
         "SHR"        : 8, 
         "SHL"        : 9, 
         "READ_FLAGS" : 10, 
         "LOAD_FLAGS" : 11,
         "cte0x00"    : 12,
         "cte0x01"    : 13,
         "cte0x02"    : 14,
         "cte0xFF"    : 15 }

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Build micro operations functions

def val2num(val):
    if val in ALUops.keys():
        return ALUops[val]
    else:
        return int(val)

def str2signal(signal):
    sig=signal.split("=")
    if sig[0] in signals.keys():
        index=signals[sig[0]]
        if len(sig)>1:
            num=val2num(sig[1])
        else:
            num=1
        return [index,num]
    else:
        print("Error: Signal \"" + signal + "\" unknown")
        sys.exit(1)
    
def parseOpcodes(tokens):
    microCode=[]
    label=""
    microInst=[]
    for t in tokens:
        if len(t)>1 and t[1]==":":
            if not (len(microInst)==0):
                microCode.append([label,microInst])
                microInst=[]
            label=t[0]
        else:
            microInst.append(filter(lambda x: x!=None, map(str2signal,t)))
    if not (len(microInst)==0):
        microCode.append([label,microInst])
        microInst=[]
    return microCode

def codeValues(microCode):
    code={}
    for m in microCode:
        addr=int(m[0],2)
        micro=[]
        for step in m[1]:
            s=0
            for sign in step:
                s=s+(sign[1] << sign[0])
            micro.append(s)
        code[addr]=micro
    return code
            
def printMicroCode(output,code):
    f = open(output,"w")
    f.write("v2.0 raw\n")
    for i in range(32):
        if i in code.keys():
            for m in code[i]:
                f.write('%08x' % m)
                f.write(" ")
            f.write(str(16-len(code[i]))+"*0\n") 
        else:
            f.write("80000000 15*0\n")
    f.close()

def printMicroCodeVerilog(output,code):
    f = open(output,"w")
    for i in range(32):
        #print(i)
        for j in range(len(code[i])):
            f.write("%08x "%(code[i][j]))
        for j in range(16-len(code[i])):
            f.write("%08x "%(0))
        f.write("\n")
    f.close()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

