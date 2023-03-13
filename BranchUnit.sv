`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/09 00:43:19
// Design Name: 
// Module Name: BranchUnit
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

module BranchCtrlUnit(
    input bcuEnable,   // 1 if any change to pc
    input bcuAlways,   // 1 if j*, 0 if b*
    input bcuComp,     // 0: beq/bne  1: compare to 0
    input bcuReg,      // j(al)r
    input bcuEq,       // 1 if beq
    input[2:0] bcuCond,// [0]: eq [1] gr [2] lt
    input Word rs,
    input Word rt,
    input Word pc4,
    input Instr instr,
    output pcWrite,
    output Word pcValue
    );

    assign pcValue = bcuAlways ? (bcuReg ? rs : {pc4[31:28], instr.J.addr, 2'b00}) : pc4 + 32'(signed'({instr.I.imm, 2'b00}));

    assign bne = (rs != rt);
    assign eqz = (rs == 32'b0);
    assign grz = (~rs[31]) & (~eqz);
    assign ltz = rs[31];

    assign pcWrite = bcuEnable & (bcuAlways | (bcuComp ? ((bcuCond[0] & eqz) | (bcuCond[1] & grz) | (bcuCond[2] & ltz)) : (bcuEq ^ bne)));
endmodule
