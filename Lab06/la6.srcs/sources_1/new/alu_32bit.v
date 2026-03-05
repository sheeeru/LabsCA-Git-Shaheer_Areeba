`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:01:34 AM
// Design Name: 
// Module Name: alu_32bit
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

module alu_32bit(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUControl,
    output wire [31:0] ALUResult,
    output wire        Zero
);
    wire op_and = (ALUControl == 4'b0000);
    wire op_or  = (ALUControl == 4'b0001);
    wire op_add = (ALUControl == 4'b0010);
    wire op_sub = (ALUControl == 4'b0110);
    wire op_xor = (ALUControl == 4'b0100);
    wire op_sll = (ALUControl == 4'b1000);
    wire op_srl = (ALUControl == 4'b1001);

    wire [31:0] and_res;
    wire [31:0] or_res;
    wire [31:0] xor_res;

    genvar gi;
    generate
        for (gi=0; gi<32; gi=gi+1) begin : LOGIC
            assign and_res[gi] = A[gi] & B[gi];
            assign or_res[gi]  = A[gi] | B[gi];
            assign xor_res[gi] = A[gi] ^ B[gi];
        end
    endgenerate

    wire        is_sub = op_sub;
    wire [31:0] b_xor_sub;
    wire [31:0] addsub_sum;
    wire [32:0] c;            // carry chain

    assign c[0] = is_sub;     // cin = 1 for sub, 0 for add

    generate
        for (gi=0; gi<32; gi=gi+1) begin : ADDER
            // If SUB: use ~B, else use B
            assign b_xor_sub[gi] = B[gi] ^ is_sub;

            // Full adder
            assign addsub_sum[gi] = A[gi] ^ b_xor_sub[gi] ^ c[gi];
            assign c[gi+1] = (A[gi] & b_xor_sub[gi]) |
                             (A[gi] & c[gi]) |
                             (b_xor_sub[gi] & c[gi]);
        end
    endgenerate

    wire [4:0] shamt = B[4:0];

    // SLL stages
    wire [31:0] sll_s0 = A;
    wire [31:0] sll_s1;
    wire [31:0] sll_s2;
    wire [31:0] sll_s3;
    wire [31:0] sll_s4;
    wire [31:0] sll_s5;

    // SRL stages
    wire [31:0] srl_s0 = A;
    wire [31:0] srl_s1;
    wire [31:0] srl_s2;
    wire [31:0] srl_s3;
    wire [31:0] srl_s4;
    wire [31:0] srl_s5;

    generate
        for (gi=0; gi<32; gi=gi+1) begin : SHIFTERS
            // Stage 1: shift by 1
            assign sll_s1[gi] = shamt[0] ? ((gi>=1)  ? sll_s0[gi-1] : 1'b0) : sll_s0[gi];
            assign srl_s1[gi] = shamt[0] ? ((gi<=30) ? srl_s0[gi+1] : 1'b0) : srl_s0[gi];

            // Stage 2: shift by 2
            assign sll_s2[gi] = shamt[1] ? ((gi>=2)  ? sll_s1[gi-2] : 1'b0) : sll_s1[gi];
            assign srl_s2[gi] = shamt[1] ? ((gi<=29) ? srl_s1[gi+2] : 1'b0) : srl_s1[gi];

            // Stage 3: shift by 4
            assign sll_s3[gi] = shamt[2] ? ((gi>=4)  ? sll_s2[gi-4] : 1'b0) : sll_s2[gi];
            assign srl_s3[gi] = shamt[2] ? ((gi<=27) ? srl_s2[gi+4] : 1'b0) : srl_s2[gi];

            // Stage 4: shift by 8
            assign sll_s4[gi] = shamt[3] ? ((gi>=8)  ? sll_s3[gi-8] : 1'b0) : sll_s3[gi];
            assign srl_s4[gi] = shamt[3] ? ((gi<=23) ? srl_s3[gi+8] : 1'b0) : srl_s3[gi];

            // Stage 5: shift by 16
            assign sll_s5[gi] = shamt[4] ? ((gi>=16) ? sll_s4[gi-16] : 1'b0) : sll_s4[gi];
            assign srl_s5[gi] = shamt[4] ? ((gi<=15) ? srl_s4[gi+16] : 1'b0) : srl_s4[gi];
        end
    endgenerate

    wire [31:0] sll_res = sll_s5;
    wire [31:0] srl_res = srl_s5;


    wire [31:0] res_and = {32{op_and}} & and_res;
    wire [31:0] res_or  = {32{op_or }} & or_res;
    wire [31:0] res_xor = {32{op_xor}} & xor_res;
    wire [31:0] res_add = {32{op_add}} & addsub_sum;
    wire [31:0] res_sub = {32{op_sub}} & addsub_sum;
    wire [31:0] res_sll = {32{op_sll}} & sll_res;
    wire [31:0] res_srl = {32{op_srl}} & srl_res;

    assign ALUResult = res_and | res_or | res_xor | res_add | res_sub | res_sll | res_srl;

    wire any1;
    assign any1 = |ALUResult;      // reduction OR (synthesizes to OR tree)
    assign Zero = ~any1;

endmodule