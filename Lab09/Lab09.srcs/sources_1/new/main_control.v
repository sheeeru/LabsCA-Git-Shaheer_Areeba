`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: main_control
// Description: Main Control Unit for RISC-V single-cycle datapath.
//              Decodes opcode[6:0] and outputs all control signals.
//
// Truth Table:
//   opcode        | RegWrite ALUOp MemRead MemWrite ALUSrc MemtoReg Branch
//   0000011 (ld)  |    1      00      1       0       1       1       0
//   0100011 (sd)  |    0      00      0       1       1       1(X)    0
//   1100011 (beq) |    0      01      0       0       0       1(X)    1
//   0110011 (R)   |    1      10      0       0       0       0       0
//
// Don't-care (X) outputs are hardcoded to 1.
// Invalid/unrecognized opcodes output all 1s as a visible error flag.
//////////////////////////////////////////////////////////////////////////////////

module main_control(
    input  [6:0] opcode,
    output reg       RegWrite,
    output reg [1:0] ALUOp,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       Branch
);

    always @(*) begin

        // Default: all 1s - invalid opcode flag
        RegWrite = 1'b1;
        ALUOp    = 2'b10;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;

        case (opcode)
            7'b0000011: begin  // ld
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;  // defined
                Branch   = 1'b0;
            end
            7'b0100011: begin  // sd
                RegWrite = 1'b0;
                ALUOp    = 2'b00;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;  // X -> 1
                Branch   = 1'b0;
            end
            7'b1100011: begin  // beq
                RegWrite = 1'b0;
                ALUOp    = 2'b01;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b1;  // X -> 1
                Branch   = 1'b1;
            end
            7'b0110011: begin  // R-type
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;  // defined
                Branch   = 1'b0;
            end
            // unrecognized opcode -> stays at all-1s default
        endcase
    end

endmodule