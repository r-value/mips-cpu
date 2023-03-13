`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/09 00:01:29
// Design Name: 
// Module Name: PipelineMIPS
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

`include "MultiplicationDivisionUnit.sv"

module TopLevel(
    input reset,
    input clock
    );

    IFResult IFIn;
    IFResult IFOut;
    IF_IDReg IF_ID (
        .clock(clock),
        .reset(reset),
        .IFIn(IFIn),
        .IFOut(IFOut)
    );

    IDResult IDIn;
    IDResult IDOut;
    EXSignal EX;
    ID_EXReg ID_EX (
        .clock(clock),
        .reset(reset),
        .IDIn(IDIn),
        .IDOut(IDOut),
        .EXOut(EX)
    );
    EXResult EXIn;
    EXResult EXOut;
    MEMSignal MEM;
    EX_MEMReg EX_MEM (
        .clock(clock),
        .reset(reset),
        .EXIn(EXIn),
        .EXOut(EXOut),
        .MEMIn(ID_EX.MEMOut),
        .WBIn(ID_EX.WBOut),
        .MEMOut(MEM),
        .hold(1'b0)
    );
    MEMResult MEMIn;
    MEMResult MEMOut;
    WBSignal WB;
    MEM_WBReg MEM_WB (
        .clock(clock),
        .reset(reset),
        .MEMIn(MEMIn),
        .MEMOut(MEMOut),
        .WBIn(EX_MEM.WBOut),
        .WBOut(WB),
        .hold(1'b0),
        .clear(1'b0)
    );

    ProgramCntr PC (
        .clock(clock),
        .reset(reset)
    );

    assign PC.hold = ID_Stall | EX_Stall;

    InstrMem IMem(
        .pc(PC.pcValue),
        .instr(IFIn.instr)
    );

    assign IFIn.pc4 = PC.pcValue + 4;

    //  ======================== ID (IFOut -> IDIn) ========================

    assign IF_ID.hold = ID_Stall | EX_Stall;

    IDSignal ID;

    CtrlUnit CU (
        .opcode(IF_ID.IFOut.instr.R.opcode),
        .funct(IF_ID.IFOut.instr.R.funct),
        .i16(IF_ID.IFOut.instr.bits[16]),
        .ID(ID),
        .EX(ID_EX.EXIn),
        .MEM(ID_EX.MEMIn),
        .WB(ID_EX.WBIn)
    );

    BranchCtrlUnit BCU (
        .bcuEnable(ID.bcuEnable),
        .bcuAlways(ID.bcuAlways),
        .bcuComp(ID.bcuComp),
        .bcuReg(ID.bcuReg),
        .bcuEq(ID.bcuEq),
        .bcuCond(ID.bcuCond),
        .rs(IDIn.rsData),
        .rt(IDIn.rtData),
        .pc4(IFOut.pc4),
        .instr(IFOut.instr),
        .pcWrite(PC.jumpEnabled),
        .pcValue(PC.jumpInput)
    );

    GPReg RegFile (
        .clock(clock),
        .reset(reset),
        .rd1(IFOut.instr.R.rs),
        .rd2(IFOut.instr.R.rt)
    );

    ForwardUnit IDrsID(
        .port(ID_EX.port),
        .addr(IDIn.rsAddr),
        .hasUpstream(1'b1)
    );
    ForwardUnit IDrtID(
        .port(ID_EX.port),
        .addr(IDIn.rtAddr),
        .hasUpstream(1'b1)
    );

    ForwardPreserver IDrs(
        .clock(clock),
        .reset(reset),
        .hold(ID_Stall | EX_Stall),
        .upstream(IDrsID.result)
    );

    ForwardPreserver IDrt(
        .clock(clock),
        .reset(reset),
        .hold(ID_Stall | EX_Stall),
        .upstream(IDrtID.result)
    );

    assign IDIn.imm = {{16{ID.immSign & IFOut.instr.I.imm[15]}} , IFOut.instr.I.imm};
    assign IDIn.rsAddr = IFOut.instr.R.rs;
    assign IDIn.rtAddr = IFOut.instr.R.rt;
    assign IDIn.rdAddr = {5{ID.regLink}} | (ID.regDst ? IFOut.instr.R.rd : IFOut.instr.R.rt);
    assign IDIn.rsData = IDrs.result.resolved ? IDrs.result.value : RegFile.rd1Data;
    assign IDIn.rtData = IDrt.result.resolved ? IDrt.result.value : RegFile.rd2Data;
    assign IDIn.shamt = IFOut.instr.R.shamt;
    assign IDIn.pc8 = IFOut.pc4 + 32'd4;

    assign ID_Stall = (ID.rsReq & (IDrs.result.hazard & (~IDrs.result.resolved)))
                    | (ID.rtReq & (IDrt.result.hazard & (~IDrt.result.resolved)));

    assign ID_EX.clear = ID_Stall & ~EX_Stall;

    //  ===================== EX (IDOut -> EXIn)  ============================

    assign ID_EX.hold = EX_Stall;

    ForwardUnit IDrsEX(
        .port(EX_MEM.port),
        .addr(IDIn.rsAddr),
        .hasUpstream(1'b1),
        .result(IDrsID.upstream)
    );
    ForwardUnit IDrtEX(
        .port(EX_MEM.port),
        .addr(IDIn.rtAddr),
        .hasUpstream(1'b1),
        .result(IDrtID.upstream)
    );

    ForwardUnit EXrsEX(
        .port(EX_MEM.port),
        .addr(IDOut.rsAddr),
        .hasUpstream(1'b1)
    );
    ForwardUnit EXrtEX(
        .port(EX_MEM.port),
        .addr(IDOut.rtAddr),
        .hasUpstream(1'b1)
    );

    ForwardPreserver EXrs(
        .clock(clock),
        .reset(reset),
        .hold(EX_Stall),
        .upstream(EXrsEX.result)
    );
    ForwardPreserver EXrt(
        .clock(clock),
        .reset(reset),
        .hold(EX_Stall),
        .upstream(EXrtEX.result)
    );

    wire[31:0] rsData;
    wire[31:0] rtData;

    assign rsData = EXrs.result.resolved ? EXrs.result.value : IDOut.rsData;
    assign rtData = EXrt.result.resolved ? EXrt.result.value : IDOut.rtData;

    ALU alu(
        .A(rsData),
        .B(EX.aluSrc ? IDOut.imm : rtData),
        .Op(EX.aluOp),
        .S(IDOut.shamt)
    );

    MultiplicationDivisionUnit mdu(
        .clock(clock),
        .reset(reset),
        .operand1(rsData),
        .operand2(rtData),
        .operation(mdu_operation_t'(EX.mduOp)),
        .start(EX.mduStart & ~EX_Stall)
    );

    assign EXIn.evalResult = EX.exResult ? mdu.dataRead : alu.C;
    assign EXIn.pc8 = IDOut.pc8;
    assign EXIn.rdAddr = IDOut.rdAddr;
    assign EXIn.rtData = IDOut.rtData;
    assign EXIn.imm = IDOut.imm;
    assign EXIn.rtAddr = IDOut.rtAddr;

    assign EX_Stall = (EX.rsReq & (EXrs.result.hazard & (~EXrs.result.resolved)))
                    | (EX.rtReq & (EXrt.result.hazard & (~EXrt.result.resolved)))
                    | (mdu.busy & EX.mduEnable);

    assign EX_MEM.clear = EX_Stall;

    //  ======================== MEM (EXOut -> MEMIn) ========================

    ForwardUnit IDrsMEM(
        .port(MEM_WB.port),
        .addr(IDIn.rsAddr),
        .hasUpstream(1'b0),
        .result(IDrsEX.upstream)
    );
    ForwardUnit IDrtMEM(
        .port(MEM_WB.port),
        .addr(IDIn.rtAddr),
        .hasUpstream(1'b0),
        .result(IDrtEX.upstream)
    );

    ForwardUnit EXrsMEM(
        .port(MEM_WB.port),
        .addr(IDOut.rsAddr),
        .hasUpstream(1'b0),
        .result(EXrsEX.upstream)
    );
    ForwardUnit EXrtMEM(
        .port(MEM_WB.port),
        .addr(IDOut.rtAddr),
        .hasUpstream(1'b0),
        .result(EXrtEX.upstream)
    );

    ForwardUnit MEMrtMEM(
        .port(MEM_WB.port),
        .addr(EXOut.rtAddr),
        .hasUpstream(1'b0)
    );

    DataMem DMem(
        .pc8(EXOut.pc8),
        .clock(clock),
        .reset(reset),
        .address(EXOut.evalResult),
        .readResult(MEMIn.mem),
        .extendSign(MEM.memSign),
        .width(MEM.memWidth),
        .writeInput(MEMrtMEM.result.resolved ? MEMrtMEM.result.value : EXOut.rtData),
        .memWrite(MEM.memWrite),
        .memRead(MEM.memRead)
    );

    assign MEMIn.evalResult = EXOut.evalResult;
    assign MEMIn.rdAddr = EXOut.rdAddr;
    assign MEMIn.pc8 = EXOut.pc8;
    assign MEMIn.imm = EXOut.imm;

    //  ======================== WB (MEMOut -> RegFile) ========================

    assign RegFile.wr = MEMOut.rdAddr;
    assign RegFile.pc8 = MEMOut.pc8;
    assign RegFile.wrData   = ({32{WB.dataSrc == 2'd0}} & MEMOut.evalResult)
                            | ({32{WB.dataSrc == 2'd1}} & MEMOut.mem)
                            | ({32{WB.dataSrc == 2'd2}} & MEMOut.pc8)
                            | ({32{WB.dataSrc == 2'd3}} & {MEMOut.imm[15:0], 16'h0000});
    
    assign RegFile.wrEnable = WB.regWrite;

endmodule
