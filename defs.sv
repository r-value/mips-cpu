
package defs;

typedef logic[31:0] Word;
typedef logic[4:0] RegAddr;

typedef union packed {
    logic[31:0] bits;
    struct packed {
        logic[5:0] opcode;
        logic[4:0] rs;
        logic[4:0] rt;
        logic[4:0] rd;
        logic[4:0] shamt;
        logic[5:0] funct;
    } R;
    struct packed {
        logic[5:0] opcode;
        logic[25:0] addr;
    } J;
    struct packed {
        logic[5:0] opcode;
        logic[4:0] rs;
        logic[4:0] rd;
        logic[15:0] imm;
    } I;
} Instr;

typedef struct packed {
    Word imm;
    logic[4:0] shamt;
    RegAddr rdAddr;
    RegAddr rsAddr;
    RegAddr rtAddr;
    Word rsData;
    Word rtData;
    Word pc8;
} IDResult;

typedef struct packed {
    Instr instr;
    Word pc4;
} IFResult;

typedef struct packed {
    Word evalResult;
    Word pc8;
    RegAddr rdAddr;
    RegAddr rtAddr;
    Word rtData;
    Word imm;
} EXResult;

typedef struct packed {
    Word evalResult;
    Word pc8;
    RegAddr rdAddr;
    Word imm;
    Word mem;
} MEMResult;

typedef struct packed {
    logic immSign;     // 0:zero 1:sign
    logic regLink;     // 1 if mask regDst to 31
    logic regDst;       // 1 if use [15:11] else [20:16]
    logic bcuEnable;   // 1 if any change to pc
    logic bcuAlways;   // 1 if j*, 0 if b*
    logic bcuComp;     // 0: beq/bne  1: compare to 0
    logic bcuReg;      // j(al)r
    logic bcuEq;       // 1 if beq
    logic rsReq;
    logic rtReq;
    enum logic[2:0] {  // [0]: eq [1] gr [2] lt
        ILL = 3'b000,
        GTZ = 3'b010,
        GEZ = 3'b011,
        LTZ = 3'b100,
        LEZ = 3'b101
    } bcuCond;
} IDSignal;

typedef struct packed {
    logic[5:0] aluOp;
    logic[2:0] mduOp;
    logic exResult;     // 0:ALU 1:MDU
    logic mduStart;
    logic mduEnable;
    logic aluSrc;       // 0:rd1 1:imm
    logic rsReq;
    logic rtReq;
} EXSignal;

typedef struct packed {
    logic memRead;
    logic memWrite;
    logic memSign;
    logic[1:0] memWidth;// 00:byte 01:half 11:word
} MEMSignal;

typedef struct packed {
    logic[1:0] dataSrc; // 0:aluOut 1:mem 2:pc+8 3:imm<<16
    logic regWrite;     // 1 if enables write to reg
    logic halt;
} WBSignal;

typedef struct packed {
    logic write;
    logic eval;
    RegAddr addr;
    Word value;
} ForwardPort;

typedef struct packed {
    logic hazard;
    logic resolved;
    Word value;
} ForwardResult;

endpackage