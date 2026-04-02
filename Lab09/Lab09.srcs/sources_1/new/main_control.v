`timescale 1ns / 1ps

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
        // Default values to prevent latches
        RegWrite = 0; 
        ALUSrc   = 0; 
        MemRead  = 0; 
        MemWrite = 0; 
        MemtoReg = 0; 
        Branch   = 0; 
        ALUOp    = 2'b00;

        case(opcode)
            7'b0110011: begin // R-type
                RegWrite = 1; 
                ALUOp    = 2'b10;
            end

            7'b0010011: begin // I-type (ADDI)
                RegWrite = 1; 
                ALUSrc   = 1; 
                ALUOp    = 2'b11;
            end

            7'b0000011: begin // Load (LW, LH, LB)
                RegWrite = 1; 
                ALUSrc   = 1; 
                MemRead  = 1; 
                MemtoReg = 1; 
                ALUOp    = 2'b00;
            end

            7'b0100011: begin // Store (SW, SH, SB)
                ALUSrc   = 1; 
                MemWrite = 1; 
                ALUOp    = 2'b00;
            end

            7'b1100011: begin // Branch (BEQ)
                Branch   = 1; 
                ALUOp    = 2'b01;
            end

            default: begin
                // Keeps safe zeros for undefined opcodes
            end
        endcase
    end

endmodule