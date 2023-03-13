`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/09 15:57:16
// Design Name: 
// Module Name: 
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

module IF_IDReg (
    input clock,
    input reset,
    input clear,
    input hold,
    input IFResult IFIn,
    output IFResult IFOut
    );
    always @(posedge clock) begin
        if(reset | clear) begin
            IFOut <= 0;
        end
        else if(!hold) begin
            IFOut <= IFIn;
        end
    end
endmodule

module ID_EXReg (
    input clock,
    input reset,
    input clear,
    input hold,
    input EXSignal EXIn,
    input MEMSignal MEMIn,
    input WBSignal WBIn,
    input IDResult IDIn,
    output ForwardPort port,
    output EXSignal EXOut,
    output MEMSignal MEMOut,
    output WBSignal WBOut,
    output IDResult IDOut
    );

    always @(posedge clock) begin
        if(reset | clear) begin
            EXOut <= 0;
            MEMOut <= 0;
            WBOut <= 0;
            IDOut <= 0;
        end
        else if(!hold) begin
            EXOut <= EXIn;
            MEMOut <= MEMIn;
            WBOut <= WBIn;
            IDOut <= IDIn;
        end
    end

    assign port.write = WBOut.regWrite;
    assign port.addr = IDOut.rdAddr;
    assign port.value = (WBOut.dataSrc == 2'd2) ? IDOut.pc8 : {IDOut.imm[15:0], 16'd0};
    assign port.eval = WBOut.dataSrc[1]; // 2:pc8 3:imm<<16
endmodule

module EX_MEMReg (
    input clock,
    input reset,
    input clear,
    input hold,
    input EXResult EXIn,
    input MEMSignal MEMIn,
    input WBSignal WBIn,
    output ForwardPort port,
    output EXResult EXOut,
    output MEMSignal MEMOut,
    output WBSignal WBOut
    );

    always @(posedge clock) begin
        if(reset | clear) begin
            EXOut <= 0;
            MEMOut <= 0;
            WBOut <= 0;
        end
        else if(!hold) begin
            EXOut <= EXIn;
            MEMOut <= MEMIn;
            WBOut <= WBIn;
        end
    end

    assign port.write = WBOut.regWrite;
    assign port.addr = EXOut.rdAddr;
    assign port.value   = ({32{WBOut.dataSrc == 2'd2}} & EXOut.pc8)
                        | ({32{WBOut.dataSrc == 2'd3}} & {EXOut.imm[15:0], 16'd0})
                        | ({32{WBOut.dataSrc == 2'd0}} & EXOut.evalResult);
    assign port.eval = WBOut.dataSrc[1] | (~WBOut.dataSrc[0]); // 0:alu 2:pc8 3:imm<<16
endmodule

module MEM_WBReg (
    input clock,
    input reset,
    input clear,
    input hold,
    input MEMResult MEMIn,
    input WBSignal WBIn,
    output ForwardPort port,
    output MEMResult MEMOut,
    output WBSignal WBOut
    );

    always @(posedge clock) begin
        if(reset | clear) begin
            MEMOut <= 0;
            WBOut <= 0;
        end
        else if(!hold) begin
            MEMOut <= MEMIn;
            WBOut <= WBIn;
        end
        if(WBOut.halt)
            $finish;
    end

    assign port.write = WBOut.regWrite;
    assign port.addr = MEMOut.rdAddr;
    assign port.value = ({32{WBOut.dataSrc == 2'd2}} & MEMOut.pc8)
                      | ({32{WBOut.dataSrc == 2'd3}} & {MEMOut.imm[15:0], 16'd0})
                      | ({32{WBOut.dataSrc == 2'd0}} & MEMOut.evalResult)
                      | ({32{WBOut.dataSrc == 2'd1}} & MEMOut.mem);
    assign port.eval = 1;
endmodule
