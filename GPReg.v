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


module GPReg(
    input reset,
    input clock,
    input[4:0] rd1,
    input[4:0] rd2,
    input[4:0] wr,
    input[31:0] wrData,
    input[31:0] pc8,
    input wrEnable,
    output[31:0] rd1Data,
    output[31:0] rd2Data
    );
    reg[31:0] regs[0:31];

    assign rd1Data = regs[rd1];
    assign rd2Data = regs[rd2];

    // reset function
    genvar i;
    generate
        for(i = 0; i < 32; i = i + 1)
        begin
            always@(posedge clock) begin
                if(reset) begin
                    regs[i] <= 32'h00000000;
                end
                else if(wrEnable && (wr == i)) begin
                    if(wr != 5'h0)
                        regs[i] <= wrData;
                    if(pc8 >= 8)
                        $display("@%h: $%d <= %h", pc8 - 8, wr, wrData);
                end
            end
        end
    endgenerate
endmodule
