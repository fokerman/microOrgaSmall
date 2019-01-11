`timescale 1ns / 1ps
// MIT License
// Copyright (c) 2018 David Alejandro Gonzalez Marquez
// ----------------------------------------------------------------------------
// -- OrgaSmallSystem ---------------------------------------------------------
// ----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
///* ArithmeticLogicUnit *//////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module ArithmeticLogicUnit(clk, reset, A, B, O, enA, enB, enOut, OP, shift, flags, opW);
    input  clk, reset;
    input  [7:0] A, B;
    output [7:0] O;
    input  enA, enB, enOut;
    input  [3:0] OP;
    input  [2:0] shift;
    output [4:0] flags;
    input  opW;
    
    reg [8:0] qA, qB, qO;
    reg fI, fO, fN, fZ, fC;
    
    initial begin
        qA <= 0;
        qB <= 0;
        qO <= 0;
        fI <= 0;
        fO <= 0;
        fN <= 0;
        fZ <= 0;
        fC <= 0;
    end
    
    always @(posedge clk) begin
        case(OP)
            4'b0000 : begin  qO <= qO;                           end
            4'b0001 : begin  qO <= qA + qB;                      end
            4'b0010 : begin  qO <= qA + qB + {8'h0, fC};         end
            4'b0011 : begin  qO <= qA - qB;                      end
            4'b0100 : begin  qO <= qA & qB;                      end
            4'b0101 : begin  qO <= qA | qB;                      end 
            4'b0110 : begin  qO <= qA ^ qB;                      end 
            4'b0111 : begin  qO <= {qA[7],qA[7:0]} >>> shift;    end
            4'b1000 : begin  qO <= qA[7:0] >> shift;             end 
            4'b1001 : begin  qO <= qA[7:0] << shift;             end 
            4'b1010 : begin  qO <= {3'b000, fI, fO, fN, fZ, fC}; end
            4'b1100 : begin  qO <= 9'h000; end // cte 00
            4'b1101 : begin  qO <= 9'h001; end // cte 01
            4'b1110 : begin  qO <= 9'h002; end // cte 02
            4'b1111 : begin  qO <= 9'h0FF; end // cte ff
             default: begin  qO <= 9'h000; end
        endcase
    end
    
    always @(negedge clk) begin
        if(enA) qA <= {1'h0,A};
        if(enB) qB <= {1'h0,B};
        if(reset) begin
            qA <= 0;
            qB <= 0;
        end
        if(opW) begin
            fN <= qO[7];
            fZ <= (qO[7:0] == 8'h0)? 1 : 0;
            if (OP==4'b0001 | OP==4'b0010 | OP==4'b0011)
            begin
                fC <= qO[8];
                fO <= (qO[8:7] == 2'b01 || qO[8:7] == 2'b10)? 1 : 0;
            end
                else
            begin
                fC <= 0;
                fO <= 0;
            
            end
        end
        if(OP==4'b1011) begin fI <= qA[4]; fO <= qA[3]; fN <= qA[2]; fZ <= qA[1]; fC <= qA[0]; end
    end
    
    assign flags = {fI, fO, fN, fZ, fC};
    assign O = enOut? qO[7:0] : 'bz;
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* Registers *////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module Registers(clk, reset, inData, outData, enIn, enOut, selIn, selOut, setSP);
    input  clk, reset;
    input  [7:0] inData;
    output [7:0] outData;
    input  enIn, enOut;
    input [2:0] selIn, selOut;
    input setSP;
    
    reg [7:0] q [7:0];
    
    initial begin
        q[0] <= 0; q[1] <= 0; q[2] <= 0; q[3] <= 0;
        q[4] <= 0; q[5] <= 0; q[6] <= 0; q[7] <= 0;
    end
    
    always @(negedge clk) begin
        if(enIn) begin
            if(setSP)
                q[7] <= inData;
            else
                q[selIn] <= inData;
        end
        if(reset) begin
            q[0] <= 0; q[1] <= 0; q[2] <= 0; q[3] <= 0;
            q[4] <= 0; q[5] <= 0; q[6] <= 0; q[7] <= 0;
            
        end
    end
     
    assign outData = enOut? (setSP? q[7] : q[selOut]) : 'bz;
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* ProgramCounter *///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module ProgramCounter(clk, reset, inValue, outValue, PC_load, PC_inc, PC_enOut);
    input  clk, reset;
    input  [7:0] inValue;
    output [7:0] outValue;
    input  PC_load, PC_inc, PC_enOut;
    
    reg [7:0] q;
    
    initial begin
        q <= 'b0;
    end
    
    always @(negedge clk) begin
        if(reset)   q <= 'b0;
        if(PC_inc)  q <= q + 1;
        if(PC_load) q <= inValue;
    end
    
    assign outValue = PC_enOut? q : 'bz;
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* Decode *///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module Decode(clk, reset, halfInst, loadL, loadH, opcode, indexX, indexY, valueM);
    input  clk, reset;
    input [7:0] halfInst;
    input loadL, loadH;
    output [4:0] opcode;
    output [2:0] indexX, indexY;
    output [7:0] valueM;
    
    reg [15:0] q;
    
    initial begin
        q <= 'b0;
    end
    
    always @(negedge clk) begin
        if(loadL) q[7:0]  <= halfInst;
        if(loadH) q[15:8] <= halfInst;
        if(reset) q       <= 'b0;
    end
    //[15 14 13 12 11] [10 9 8] [7 6 5] 4 3 2 1 0]
    assign opcode = q[15:11];
    assign indexX = q[10:8];
    assign indexY = q[7:5];
    assign valueM = q[7:0];
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* Memory *///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module Memory(clk, reset, inData, outData, addr, enOut, load, enAddr, outAddr);
    input  clk, reset;
    input  [7:0] inData;
    output [7:0] outData;
    input  [7:0] addr;
    input  enOut, load, enAddr;
    output [7:0] outAddr;
    
    reg [7:0] mem_addr;
    reg [7:0] mem [255:0];
    
    initial begin
        mem_addr <= 'b0;
        $readmemh("../../examples/test00Verilog.mem", mem); 
    end
    
    always @(negedge clk) begin
        if(load & (mem_addr!=8'hfc & mem_addr!=8'hfd & mem_addr!=8'hfe)) mem[mem_addr] <= inData;
        if(enAddr) mem_addr <= addr;
        if(reset)  mem_addr <= 'b0;
    end
    
    assign outData = (enOut & (mem_addr!=8'hfc & mem_addr!=8'hfd & mem_addr!=8'hfe))? mem[mem_addr] : 'bz;
    assign outAddr = mem_addr;
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* IOports *//////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module IOports(clk, reset, inData, outData, load, addr, enOut, portOutput, portInput, portInterrupt);
    input  clk, reset;
    input  [7:0] inData;
    output [7:0] outData;
    input  load;
    input  [7:0] addr;
    input  enOut;
    output [7:0] portOutput;
    input  [7:0] portInput;
    input  [7:0] portInterrupt;
    
    reg [7:0] qPortOutput;
    reg [7:0] qPortInput;
    reg [7:0] qPortInterrupt;
    
    initial begin
        qPortOutput <= 8'h00;
        qPortInput <= 8'h00;
        qPortInterrupt <= 8'h00;   
    end
    
    always @(negedge clk) begin
        if(addr==8'hfc && load)
            qPortOutput <= inData;
        qPortInput <= portInput;
        qPortInterrupt <= portInterrupt;
        if(reset) begin
            qPortOutput <= 8'hFF;
            qPortInput <= 8'hFF;
            qPortInterrupt <= 8'hFF;
        end
    end

    assign outData = (enOut & addr==8'hfc)? qPortOutput    : 'bz;
    assign outData = (enOut & addr==8'hfd)? qPortInput     : 'bz;
    assign outData = (enOut & addr==8'hfe)? qPortInterrupt : 'bz;
    assign portOutput = qPortOutput;
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* InterruptController *//////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module InterruptController(clk, reset, portInterrupt, intReq, intAck);
    input  clk, reset;
    input  [7:0] portInterrupt;
    output intReq;
    input  intAck;
    
    reg [7:0] qnew;
    reg [7:0] q;
    reg interrupt;
    
    initial begin
        q <= 8'h00;
        qnew <= 8'h00;
        interrupt <= 0;        
    end
    
    always @(negedge clk) begin
        qnew <= portInterrupt;
        if(qnew != q) begin
            q <= qnew;
            interrupt <= 1;
        end
        if(intAck) interrupt <= 0;
        if(reset) begin
            q <= 8'h00;
            qnew <= 8'h00;
            interrupt <= 0;
        end 
    end
    
    assign intReq = interrupt;
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* ControlUnit *//////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module ControlUnit(clk, reset,
    RB_enIn, RB_enOut, RB_selIndexIn, RB_selIndexOut, RB_setSP,
    MM_enOut, MM_load, MM_enAddr,
    ALU_enA, ALU_enB, ALU_enOut, ALU_opW,
    ALU_OP,
    PC_load, PC_inc, PC_enOut,
    DE_enOutImm, DE_loadL, DE_loadH,
    ALU_flags, DE_opcode,
    IC_intReq, IC_intAck);
    input  clk, reset;
    output RB_enIn, RB_enOut, RB_selIndexIn, RB_selIndexOut, RB_setSP;
    output MM_enOut, MM_load, MM_enAddr;
    output ALU_enA, ALU_enB, ALU_enOut, ALU_opW;
    output [3:0] ALU_OP;
    output PC_load, PC_inc, PC_enOut;
    output DE_enOutImm, DE_loadL, DE_loadH;
    input  [4:0] ALU_flags;
    input  [4:0] DE_opcode;
    input  IC_intReq;
    output IC_intAck;
    
    wire JC_microOp, JZ_microOp, JN_microOp, JO_microOp;
    wire load_int_microOp, load_microOp, reset_microOp;
    reg [31:0] rom [512:0];
    reg [8:0] microOp = 0;

    initial begin
        $readmemh("../microCodeVerilog.mem", rom); 
    end

    always @(negedge clk) begin
        if(load_microOp & JC_microOp & ALU_flags[0])
           microOp <= microOp + 2;
           
        else
        if(load_microOp & JZ_microOp & ALU_flags[1])
            microOp <= microOp + 2;
             
        else
        if(load_microOp & JN_microOp & ALU_flags[2])
            microOp <= microOp + 2;
            
        else
        if(load_microOp & JO_microOp & ALU_flags[3])
            microOp <= microOp + 2;
            
        else
        if(load_microOp & load_int_microOp & ALU_flags[4] & IC_intReq)
            microOp <= 9'h1f0;
            
        else
        if(load_microOp & !JC_microOp & !JZ_microOp & !JN_microOp & !JO_microOp & !load_int_microOp)
            microOp <= { DE_opcode, 4'b0000 };
             
        else
            microOp <= microOp + 1;
            
        if(reset | reset_microOp) microOp <= 0;
    end
      
    assign RB_enIn          = rom[microOp][0];
    assign RB_enOut         = rom[microOp][1];
    assign RB_selIndexIn    = rom[microOp][2];
    assign RB_selIndexOut   = rom[microOp][3];
    assign RB_setSP         = rom[microOp][4];
    
    assign MM_enOut         = rom[microOp][5];
    assign MM_load          = rom[microOp][6];
    assign MM_enAddr        = rom[microOp][7];
                      
    assign ALU_enA          = rom[microOp][8];
    assign ALU_enB          = rom[microOp][9];
    assign ALU_enOut        = rom[microOp][10];
    assign ALU_opW          = rom[microOp][11];
    
    assign ALU_OP           = { rom[microOp][15], rom[microOp][14],
                                rom[microOp][13], rom[microOp][12] };
    
    assign JC_microOp       = rom[microOp][16];
    assign JZ_microOp       = rom[microOp][17];
    assign JN_microOp       = rom[microOp][18];
    assign JO_microOp       = rom[microOp][19];
    
    assign PC_load          = rom[microOp][20];
    assign PC_inc           = rom[microOp][21];
    assign PC_enOut         = rom[microOp][22];
    // rom[microOp][23];
    
    assign DE_enOutImm      = rom[microOp][24];
    assign DE_loadL         = rom[microOp][25];
    assign DE_loadH         = rom[microOp][26];
    assign IC_intAck        = rom[microOp][27];
    // rom[microOp][28];
    
    assign load_int_microOp = rom[microOp][29];
    assign load_microOp     = rom[microOp][30];
    assign reset_microOp    = rom[microOp][31];
    
endmodule

////////////////////////////////////////////////////////////////////////////////
///* OrgaSmallSystem *//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

module OrgaSmallSystem(clk, reset, portOutput, portInput, portInterrupt);

    input clk, reset;
    
    output [7:0] portOutput;
    input  [7:0] portInput;
    input  [7:0] portInterrupt;
 
    wire [7:0] BUS;
    wire ALU_enA, ALU_enB, ALU_enOut, ALU_opW;
    wire [3:0] ALU_OP;
    wire [4:0] ALU_flags;
    wire RB_enIn, RB_enOut, RB_setSP; wire [2:0] RB_selIn, RB_selOut;
    wire PC_load, PC_inc, PC_enOut;
    wire DE_enOutImm, DE_loadL, DE_loadH;
    wire [4:0] DE_opcode;
    wire MM_enOut, MM_load, MM_enAddr;
    wire [2:0] DE_indexX, DE_indexY;
    wire [7:0] DE_valueM;
    wire [7:0] outAddr;
    wire IC_intReq, IC_intAck;
    wire RB_selIndexIn, RB_selIndexOut;

    ArithmeticLogicUnit ALU(clk, reset, BUS, BUS, BUS, ALU_enA, ALU_enB, ALU_enOut, ALU_OP, DE_indexY, ALU_flags, ALU_opW);
    
    Registers RB(clk, reset, BUS, BUS, RB_enIn, RB_enOut, RB_selIn, RB_selOut, RB_setSP);
    
    ProgramCounter PC(clk, reset, BUS, BUS, PC_load, PC_inc, PC_enOut);
    
    Decode DE(clk, reset, BUS, DE_loadL, DE_loadH, DE_opcode, DE_indexX, DE_indexY, DE_valueM);
        
    Memory MM(clk, reset, BUS, BUS, BUS, MM_enOut, MM_load, MM_enAddr, outAddr);

    IOports IO(clk, reset, BUS, BUS, MM_load, outAddr, MM_enOut, portOutput, portInput, portInterrupt);
        
    InterruptController IC(clk, reset, portInterrupt, IC_intReq, IC_intAck);

    ControlUnit CU(clk, reset,
        RB_enIn, RB_enOut, RB_selIndexIn, RB_selIndexOut, RB_setSP,
        MM_enOut, MM_load, MM_enAddr,
        ALU_enA, ALU_enB, ALU_enOut, ALU_opW,
        ALU_OP,
        PC_load, PC_inc, PC_enOut,
        DE_enOutImm, DE_loadL, DE_loadH,
        ALU_flags, DE_opcode,
        IC_intReq, IC_intAck);
    
    assign RB_selIn  = RB_selIndexIn?  DE_indexY : DE_indexX;
    assign RB_selOut = RB_selIndexOut? DE_indexY : DE_indexX;
    assign BUS       = DE_enOutImm?    DE_valueM : 'bz;
    
endmodule

