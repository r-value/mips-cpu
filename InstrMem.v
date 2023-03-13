`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/08 15:04:43
// Design Name: 
// Module Name: InstrMem
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


module InstrMem(
    input[31:0] pc,
    output[31:0] instr
    );
    reg [31:0] memory [0:1023];
    initial
    begin
        $readmemh("*.asm.txt", memory);
    end
    assign instr = memory[pc[11:2]];
endmodule
