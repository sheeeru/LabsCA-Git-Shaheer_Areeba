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

    wire op_add = (ALUControl == 4'b0010);
    wire op_sub = (ALUControl == 4'b0110);

    // Ripple carry chain (only meaningful for ADD/SUB, but safe for all ops)
    wire [32:0] c;
    assign c[0] = op_sub; // SUB: start with Cin=1, ADD: Cin=0

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : SLICES
            // Neighbor bits for 1-bit shift operations (shift-by-1 behavior)
            // SLL: result[i] = A[i-1], so A_left = A[i-1] (LSB gets 0)
            // SRL: result[i] = A[i+1], so A_right = A[i+1] (MSB gets 0)
            wire a_left  = (i == 0)  ? 1'b0 : A[i-1];
            wire a_right = (i == 31) ? 1'b0 : A[i+1];

            wire slice_res;
            wire slice_cout;
            wire slice_zero; // not used for overall 32-bit Zero

            alu_1bit u_alu_1bit (
                .A(A[i]),
                .B(B[i]),
                .Cin(c[i]),
                .A_left(a_left),
                .A_right(a_right),
                .ALUControl(ALUControl),
                .ALUResult(slice_res),
                .Cout(slice_cout),
                .Zero(slice_zero)
            );

            assign ALUResult[i] = slice_res;

            // Only propagate carry meaningfully for ADD/SUB; otherwise force 0 chain
            // (prevents useless toggling / makes behavior well-defined)
            assign c[i+1] = (op_add | op_sub) ? slice_cout : 1'b0;
        end
    endgenerate

    assign Zero = (ALUResult == 32'd0);

endmodule