`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/09 00:43:19
// Design Name: 
// Module Name: ForwardUnit
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

module ForwardUnit(
    input ForwardPort port,
    input ForwardResult upstream,
    input hasUpstream,
    input RegAddr addr,
    output ForwardResult result
    );
    always_comb
    begin
        if((addr == port.addr) & (addr != 5'b00000) & port.write) begin
            result = '{port.write, port.write & port.eval, port.value};
        end else begin
            if(hasUpstream) begin
                result = upstream;
            end else begin
                result = '{1'b0, 1'b0, 32'b0};
            end
        end
    end
endmodule

module ForwardPreserver(
    input ForwardResult upstream,
    input clock,
    input reset,
    input hold,
    output ForwardResult result
    );
    ForwardResult last;
    logic held;
    always_ff @ (posedge clock) begin
        if(reset) begin
            last <= '{1'b0, 1'b0, 32'b0};
            held <= 1'b0;
        end else if(hold) begin
            if(held) begin
                if(!upstream.resolved)
                    last <= upstream;
            end else begin
                last <= upstream;
                held <= 1'b1;
            end
        end else begin
            held <= 1'b0;
        end
    end

    always_comb begin
        if(held) begin
            result = upstream.resolved ? upstream : last;
        end else begin
            result = upstream;
        end
    end
endmodule
