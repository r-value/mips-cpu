`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/08 15:04:43
// Design Name: 
// Module Name: GPReg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import defs::*;

module CtrlUnit(
    input[5:0] opcode,
    input[5:0] funct,
    input i16,             // For the f**king BLTZ/BGEZ
    output IDSignal ID,
    output EXSignal EX,
    output MEMSignal MEM,
    output WBSignal WB
    );

    assign Ri   = opcode == 6'o00;
    assign Bx   = opcode == 6'o01;

    assign j    = opcode == 6'o02;
    assign jal  = opcode == 6'o03;

    assign beq  = opcode == 6'o04;
    assign bne  = opcode == 6'o05;
    assign blez = opcode == 6'o06;
    assign bgtz = opcode == 6'o07;

    assign bltz_= Bx & (~i16);
    assign bgez_= Bx & i16;

    assign addi = opcode == 6'o10;
    assign addiu= opcode == 6'o11;
    assign slti = opcode == 6'o12;
    assign sltiu= opcode == 6'o13;
    assign andi = opcode == 6'o14;
    assign ori  = opcode == 6'o15;
    assign xori = opcode == 6'o16;
    assign lui  = opcode == 6'o17;


    assign jr   = Ri && (funct == 6'o10);
    assign jalr = Ri && (funct == 6'o11);

    assign mfhi = Ri & (funct == 6'o20);
    assign mthi = Ri & (funct == 6'o21);
    assign mflo = Ri & (funct == 6'o22);
    assign mtlo = Ri & (funct == 6'o23);

    assign mult = Ri & (funct == 6'o30);
    assign multu= Ri & (funct == 6'o31);
    assign div  = Ri & (funct == 6'o32);
    assign divu = Ri & (funct == 6'o33);

    localparam add_  = 6'o40;
    localparam addu_ = 6'o41;
    localparam sub_  = 6'o42;
    localparam subu_ = 6'o43;
    localparam and_  = 6'o44;
    localparam or_   = 6'o45;
    localparam xor_  = 6'o46;
    localparam nor_  = 6'o47;

    localparam slt_  = 6'o52;
    localparam sltu_ = 6'o53;

    assign load = opcode[5:3] == 3'o4;
    assign save = opcode[5:3] == 3'o5;

    assign mem = load | save;

    localparam syscall = 6'o14;

    assign WB.halt = Ri && (funct == syscall);

    always @ (opcode, funct)
    begin
        if(opcode == Ri && funct == syscall) // syscall
        begin
            $finish;
        end
    end

    assign ID.immSign   = Bx
                        | beq
                        | bne
                        | blez
                        | bgtz
                        | mem
                        | addi
                        | addiu
                        | sltiu
                        | slti;
    
    assign ID.regLink   = jal;
    
    assign ID.regDst    = Ri;
    
    assign ID.bcuEnable = Bx
                        | j
                        | jal
                        | beq
                        | bne
                        | blez
                        | bgtz
                        | jr
                        | jalr;
    
    assign ID.bcuAlways = j
                        | jal
                        | jr
                        | jalr;
    
    assign ID.bcuComp   = Bx
                        | bgtz
                        | blez;
    
    assign ID.bcuReg    = jr
                        | jalr;
    
    assign ID.bcuEq     = beq;

    always_comb 
    begin
        case (opcode)
            6'o06: ID.bcuCond = LEZ;
            6'o07: ID.bcuCond = GTZ;
            6'o01: ID.bcuCond = i16 ? GEZ : LTZ;
            default: ID.bcuCond = ILL;
        endcase
    end
    
    assign ID.bcuReg    = (opcode == Ri);

    assign ID.rsReq = ID.bcuEnable & ((~ID.bcuAlways) | ID.bcuReg);
    assign ID.rtReq = ID.bcuEnable & (~ID.bcuAlways) & (~ID.bcuComp);


    assign EX.aluOp = ({6{Ri }} & funct)
                    | ({6{mem  }} & add_)
                    | ({6{addi }} & add_)
                    | ({6{addiu}} & addu_)
                    | ({6{slti }} & slt_)
                    | ({6{sltiu}} & sltu_)
                    | ({6{andi }} & and_)
                    | ({6{ori  }} & or_)
                    | ({6{xori }} & xor_);
    
    assign EX.mduOp = ({3{mfhi}} & 3'o0)
                    | ({3{mflo}} & 3'o1)
                    | ({3{mthi}} & 3'o2)
                    | ({3{mtlo}} & 3'o3)
                    | ({3{mult}} & 3'o4)
                    | ({3{multu}}& 3'o5)
                    | ({3{div}}  & 3'o6)
                    | ({3{divu}} & 3'o7);
    
    assign EX.mduStart = Ri & ( funct[5:3] == 3'o3 );

    assign EX.mduEnable = Ri & ( (funct[5:3] == 3'o3) | (funct[5:3] == 3'o2) );

    assign EX.exResult  = ( mfhi | mflo );

    assign EX.aluSrc    = Bx
                        | mem
                        | (opcode[5:3] == 3'o1); // imm
    
    assign EX.rsReq = ~(ID.bcuEnable | mfhi | mflo);
    assign EX.rtReq = (~ID.bcuEnable) & (~EX.aluSrc) & (~(mfhi | mflo | mthi | mtlo));
    
    assign MEM.memRead  = load;
    assign MEM.memWrite = save;
    assign MEM.memWidth = opcode[1:0];
    assign MEM.memSign  = ~(opcode[5:1] == 5'b10010); // lbu/lhu

    assign WB.dataSrc   = ({2{load}} & 2'd1)
                        | ({2{jal | jalr}} & 2'd2)
                        | ({2{lui}} & 2'd3);
    
    assign WB.regWrite  = jal
                        | opcode[5:3] == 3'o1 // xxxi
                        | jalr
                        | load
                        | mfhi
                        | mflo
                        | (Ri &
                        ( funct[5:4] == 2'b10  // add/sub/slt
                        | funct[5:3] == 3'b000 // sll/sra
                        ));
endmodule
