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
    output reg  [31:0] ALUResult,
    output wire        Zero
);

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A & B;           // AND
            4'b0001: ALUResult = A | B;           // OR
            4'b0010: ALUResult = A + B;           // ADD 
            4'b0110: ALUResult = A - B;           // SUB 
            4'b0100: ALUResult = A ^ B;           // XOR
            4'b1000: ALUResult = A << B[4:0];     // SLL (Shift Left Logical)
            4'b1001: ALUResult = A >> B[4:0];     // SRL (Shift Right Logical)
            default: ALUResult = 32'd0;           // Default to 0
        endcase
    end


    assign Zero = (ALUResult == 32'd0) ? 1'b1 : 1'b0;

endmodule