`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: alu_control
// Description: ALU Control Unit for RISC-V single-cycle datapath.
//
// Inputs:  ALUOp[1:0], funct3[2:0], funct7[6:0]
// Output:  ALUControl[3:0]
//
// Truth Table:
//   ALUOp1 ALUOp0 | funct7[5] | funct3 | ALUControl | Operation
//     0      0    |     X     |   X    |    0010    | add      (ld / sd)
//     X      1    |     X     |   X    |    0110    | subtract (beq)
//     1      X    |     0     |  000   |    0010    | add      (R-type)
//     1      X    |     1     |  000   |    0110    | subtract (R-type)
//     1      X    |     0     |  111   |    0000    | AND      (R-type)
//     1      X    |     0     |  110   |    0001    | OR       (R-type)
//
// Don't-care inputs (X) are handled by not checking that bit in the condition.
// Invalid/unrecognized combinations output 4'b1111 as a visible error flag.
//////////////////////////////////////////////////////////////////////////////////

module alu_control(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUControl
);

    wire ALUOp1   = ALUOp[1];   // MSB
    wire ALUOp0   = ALUOp[0];   // LSB
    wire funct7_5 = funct7[5];  // I[30] - distinguishes add vs subtract in R-type

    always @(*) begin
    // Default flag
    ALUControl = 4'b1111;

    if (ALUOp == 2'b00) begin
        ALUControl = 4'b0010; // add (ld / sd)
    end 
    else if (ALUOp == 2'b01) begin
        ALUControl = 4'b0110; // subtract (beq)
    end 
    else if (ALUOp == 2'b10) begin
        // R-type decodes
        if      (funct7_5 == 1'b0 && funct3 == 3'b000) ALUControl = 4'b0010; // add
        else if (funct7_5 == 1'b1 && funct3 == 3'b000) ALUControl = 4'b0110; // subtract
        else if (funct7_5 == 1'b0 && funct3 == 3'b111) ALUControl = 4'b0000; // AND
        else if (funct7_5 == 1'b0 && funct3 == 3'b110) ALUControl = 4'b0001; // OR
    end
end
endmodule