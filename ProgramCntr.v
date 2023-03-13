`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/02 22:06:49
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCntr(
    input reset,
    input clock,
    input hold,
    input jumpEnabled,
    input[31:0] jumpInput,
    output[31:0] pcValue
    );
    reg[31:0] pcValueReg;
    always@(posedge clock)
    begin
        if(reset)
        begin
            pcValueReg <= 32'h00003000;
        end
        else if(!hold)
        begin
            if(jumpEnabled)
            begin
                pcValueReg <= jumpInput;
            end
            else
            begin
                pcValueReg <= pcValueReg + 32'h4;
            end
        end
    end
    assign pcValue = pcValueReg;
endmodule

