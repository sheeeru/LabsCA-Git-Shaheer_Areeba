`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 10:20:36 AM
// Design Name: 
// Module Name: alu
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

module alu_1bit (
    input  wire       A,
    input  wire       B,
    input  wire       Cin,        // carry in (for ADD/SUB)
    input  wire       A_left,     // neighbor bit for SLL (A[i-1])
    input  wire       A_right,    // neighbor bit for SRL (A[i+1])
    input  wire [3:0] ALUControl,
    output wire       ALUResult,
    output wire       Cout,       // carry out (for ADD/SUB)
    output wire       Zero
);

    // Decode ops
    wire op_and = (ALUControl == 4'b0000);
    wire op_or  = (ALUControl == 4'b0001);
    wire op_add = (ALUControl == 4'b0010);
    wire op_sub = (ALUControl == 4'b0110);
    wire op_xor = (ALUControl == 4'b0100);
    wire op_sll = (ALUControl == 4'b1000);
    wire op_srl = (ALUControl == 4'b1001);

    // Logic results (bitwise)
    wire and_r = A & B;
    wire or_r  = A | B;
    wire xor_r = A ^ B;

    // ADD/SUB using full-adder
    // SUB is implemented as A + (~B) + Cin, where Cin should be 1 for bit0 in SUB
    wire is_sub = op_sub;
    wire b_eff  = B ^ is_sub;     // if SUB, invert B

    wire addsub_sum;
    wire addsub_cout;

    assign addsub_sum  = A ^ b_eff ^ Cin;
    assign addsub_cout = (A & b_eff) | (A & Cin) | (b_eff & Cin);

    // Shift slice results using neighbor bits
    // For a proper 32-bit design:
    //  - SLL at bit i outputs A[i-1] (LSB gets 0)
    //  - SRL at bit i outputs A[i+1] (MSB gets 0)
    wire sll_r = A_left;
    wire srl_r = A_right;

    // Result mux (structural)
    wire res_logic =
        (op_and & and_r) |
        (op_or  & or_r ) |
        (op_xor & xor_r);

    wire res_addsub =
        ((op_add | op_sub) & addsub_sum);

    wire res_shift =
        (op_sll & sll_r) |
        (op_srl & srl_r);

    assign ALUResult = res_logic | res_addsub | res_shift;

    // Carry out only meaningful for ADD/SUB; otherwise 0
    assign Cout = (op_add | op_sub) ? addsub_cout : 1'b0;

    // Zero flag for 1-bit: result == 0
    assign Zero = (ALUResult == 1'b0);

endmodule