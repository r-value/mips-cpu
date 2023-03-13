`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/02 23:23:54
// Design Name: 
// Module Name: DataMemory
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

typedef union packed{
    logic[31:0] w;
    logic[1:0][15:0] h;
    logic[3:0][7:0] b;
} MemWord;

module DataMem(
    input reset,
    input clock,
    input[31:0] address,
    input memRead,
    input memWrite,
    input extendSign,
    input[1:0] width,
    input[31:0] pc8,
    input[31:0] writeInput,
    output[31:0] readResult
    );
    MemWord memory[0:4095];

    logic[31:0] lb;
    logic[31:0] lh;
    logic[31:0] lw;

    assign lb = extendSign?
                32'(signed'(memory[address[13:2]].b[address[1:0]])):
                32'(unsigned'(memory[address[13:2]].b[address[1:0]]));
    assign lh = extendSign?
                32'(signed'(memory[address[13:2]].h[address[1]])):
                32'(unsigned'(memory[address[13:2]].h[address[1]]));
    assign lw = memory[address[13:2]].w;

    assign readResult = width[1] ? lw : (width[0] ? lh : lb);

    // always_comb begin
        // case (width)
            // 2'b00: // byte
            // 2'b01: // half
            // 2'b11: // word
                // readResult = memory[address[13:2]].w;
            // default:
                // readResult = 32'h00000000;
        // endcase
    // end

    genvar i;
    generate
        for(i = 0; i < 4096; i = i + 1)
        begin
            always_ff@(posedge clock) begin
                if(reset) begin
                    memory[i] <= 32'h00000000;
                end
                else if(memWrite & (address[13:2] == i)) begin
                    if(width == 2'b00) // byte
                    begin
                        memory[i].b[address[1:0]] = writeInput[7:0];
                        $display("@%h: *%h <= %h", pc8 - 8, {address[31:2], 2'b00}, memory[i]);
                    end
                    else if(width == 2'b01) // half
                    begin
                        memory[i].h[address[1]] = writeInput[15:0];
                        $display("@%h: *%h <= %h", pc8 - 8, {address[31:2], 2'b00}, memory[i]);
                    end
                    else
                    begin
                        memory[i].w = writeInput;
                        $display("@%h: *%h <= %h", pc8 - 8, {address[31:2], 2'b00}, memory[i]);
                    end
                end
            end
        end
    endgenerate
endmodule
