`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 03:46:01
// Design Name: 
// Module Name: ALU
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

module ladder(
    input[31:0] a,
    input[31:0] b,
    input cin,
    output cout,
    output[31:0] s
    );
    wire[3:0] carry;

    ladder8 a0(a[7:0], b[7:0], cin, carry[0], s[7:0]);
    ladder8 a1(a[15:8], b[15:8], carry[0], carry[1], s[15:8]);
    ladder8 a2(a[23:16], b[23:16], carry[1], carry[2], s[23:16]);
    ladder8 a3(a[31:24], b[31:24], carry[2], carry[3], s[31:24]);
    assign cout = carry[3];
endmodule

module ladder8(
    input[7:0] a,
    input[7:0] b,
    input cin,
    output cout,
    output[7:0] s
    );
    wire[7:0] p = a | b;
    wire[7:0] g = a & b;
    wire[8:0] c;

    assign c[0] = cin;
    assign cout = c[8];

    // generated code begin
    assign c[1] = g[0] | (cin & p[0]);
    assign c[2] = g[1] | (g[0] & p[1]) | (cin & p[1] & p[0]);
    assign c[3] = g[2] | (g[1] & p[2]) | (g[0] & p[2] & p[1]) | (cin & p[2] & p[1] & p[0]);
    assign c[4] = g[3] | (g[2] & p[3]) | (g[1] & p[3] & p[2]) | (g[0] & p[3] & p[2] & p[1]) | (cin & p[3] & p[2] & p[1] & p[0]);
    assign c[5] = g[4] | (g[3] & p[4]) | (g[2] & p[4] & p[3]) | (g[1] & p[4] & p[3] & p[2]) | (g[0] & p[4] & p[3] & p[2] & p[1]) | (cin & p[4] & p[3] & p[2] & p[1] & p[0]);
    assign c[6] = g[5] | (g[4] & p[5]) | (g[3] & p[5] & p[4]) | (g[2] & p[5] & p[4] & p[3]) | (g[1] & p[5] & p[4] & p[3] & p[2]) | (g[0] & p[5] & p[4] & p[3] & p[2] & p[1]) | (cin & p[5] & p[4] & p[3] & p[2] & p[1] & p[0]);
    assign c[7] = g[6] | (g[5] & p[6]) | (g[4] & p[6] & p[5]) | (g[3] & p[6] & p[5] & p[4]) | (g[2] & p[6] & p[5] & p[4] & p[3]) | (g[1] & p[6] & p[5] & p[4] & p[3] & p[2]) | (g[0] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1]) | (cin & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0]);
    assign c[8] = g[7] | (g[6] & p[7]) | (g[5] & p[7] & p[6]) | (g[4] & p[7] & p[6] & p[5]) | (g[3] & p[7] & p[6] & p[5] & p[4]) | (g[2] & p[7] & p[6] & p[5] & p[4] & p[3]) | (g[1] & p[7] & p[6] & p[5] & p[4] & p[3] & p[2]) | (g[0] & p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1]) | (cin & p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0]);
    // generated code end

    assign s = a ^ b ^ c[7:0];
endmodule



module ALU(
    input[31:0] A,
    input[31:0] B,
    input[5:0] Op,
    input[4:0] S,
    output Over,
    output Zero,
    output[31:0] C
    );
    wire op_add;
    wire op_addu;
    wire op_sub;
    wire op_subu;
    wire op_sll;
    wire op_srl;
    wire op_sra;
    wire op_and;
    wire op_or;
    wire op_xor;
    wire op_nor;

    assign op_jr   = Op[5:0] == 6'b001000;
    assign op_add  = Op[5:0] == 6'b100000;
    assign op_addu = Op[5:0] == 6'b100001;
    assign op_sub  = Op[5:0] == 6'b100010;
    assign op_subu = Op[5:0] == 6'b100011;
    assign op_sll  = Op[5:3] == 3'b000 && Op[1:0] == 2'b00;
    assign op_srl  = Op[5:3] == 3'b000 && Op[1:0] == 2'b10;
    assign op_sra  = Op[5:3] == 3'b000 && Op[1:0] == 2'b11;
    assign op_and  = Op[5:0] == 6'b100100;
    assign op_or   = Op[5:0] == 6'b100101;
    assign op_xor  = Op[5:0] == 6'b100110;
    assign op_nor  = Op[5:0] == 6'b100111;
    assign op_slt  = Op[5:0] == 6'b101010;
    assign op_sltu = Op[5:0] == 6'b101011;

    wire[4:0] shamt;
    wire[31:0] Bx;
    wire[31:0] add_sub_result;
    wire[31:0] sll_result;
    wire[31:0] srl_result;
    wire[31:0] sra_result;
    wire[31:0] and_result;
    wire[31:0] or_result;
    wire[31:0] xor_result;
    wire[31:0] nor_result;
    wire[31:0] slt_result;
    wire[31:0] sltu_result;

    assign Bx = {32{op_sub | op_subu}} ^ B;

    ladder add_sub_ladder(
        .a(A),
        .b(Bx),
        .cin(op_sub | op_subu),
        .cout(Z),
        .s(add_sub_result)
        );
    
    assign shamt = Op[2] ? A[4:0] : S;
    assign sll_result = B << shamt;
    assign srl_result = B >> shamt;
    assign sra_result = ($signed(B)) >>> shamt;
    assign and_result = A & B;
    assign or_result  = A | B;
    assign xor_result = A ^ B;
    assign nor_result = ~or_result;
    assign slt_result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
    assign sltu_result = (A < B) ? 32'b1 : 32'b0;

    assign C = (({32{op_add | op_addu | op_sub | op_subu}}) & add_sub_result) 
             | (({32{op_sll}}) & sll_result)
             | (({32{op_srl}}) & srl_result)
             | (({32{op_sra}}) & sra_result)
             | (({32{op_and}}) & and_result)
             | (({32{op_or}}) & or_result)
             | (({32{op_xor}}) & xor_result)
             | (({32{op_nor}}) & nor_result)
             | (({32{op_jr}}) & A)
             | (({32{op_slt}}) & slt_result)
             | (({32{op_sltu}}) & sltu_result);

    
    assign Over = (op_add & (A[31] == B[31] && A[31] != C[31]))
                | (op_sub & (A[31] != B[31] && A[31] != C[31]));
    
    assign Zero = (C == 32'b0);
endmodule
