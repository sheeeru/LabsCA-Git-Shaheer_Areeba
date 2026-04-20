`timescale 1ns / 1ps
// main_control.v
// Updated for Lab11 - adds JAL, JALR, LUI on top of Lab09 version.
//
// New output signals:
//   Jump   - asserted for JAL  (PC = PC + imm, rd = PC+4)
//   JumpR  - asserted for JALR (PC = rs1 + imm,   rd = PC+4)
//   LUI    - asserted for LUI  (forces ALU A-input to 0)
//   WritePC- asserted for JAL and JALR (writes PC+4 into rd)

module main_control (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg  [1:0] ALUOp,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        MemtoReg,
    output reg        Branch,
    output reg        Jump,
    output reg        JumpR,
    output reg        LUI,
    output reg        WritePC,
    output reg        InstrValid
);

    always @(*) begin
        // Defaults
        RegWrite   = 0;
        ALUSrc     = 0;
        MemRead    = 0;
        MemWrite   = 0;
        MemtoReg   = 0;
        Branch     = 0;
        Jump       = 0;
        JumpR      = 0;
        LUI        = 0;
        WritePC    = 0;
        InstrValid = 0;
        ALUOp      = 2'b00;
 
        case (opcode)
 
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, SLL, SRL)
                RegWrite   = 1; // write ALU result to rd
                ALUOp      = 2'b10; // alu_control will look at funct3/funct7
                InstrValid = 1;
            end
 
            7'b0010011: begin // I-type ALU (ADDI, XORI, ORI, ANDI)
                RegWrite   = 1; // write ALU result to rd
                ALUSrc     = 1; // use immediate as ALU B input
                ALUOp      = 2'b11; // alu_control will look at funct3 only
                InstrValid = 1;
            end
 
            7'b0000011: begin // Load (LW, LH, LB)
                RegWrite   = 1; // write memory data to rd
                ALUSrc     = 1; // address = rs1 + imm
                MemRead    = 1; // read from memory
                MemtoReg   = 1; // write-back comes from memory not ALU
                ALUOp      = 2'b00; // ADD for address calculation
                InstrValid = 1;
            end
 
            7'b0100011: begin // Store (SW, SH, SB)
                ALUSrc     = 1; // address = rs1 + imm
                MemWrite   = 1; // write to memory
                ALUOp      = 2'b00; // ADD for address calculation
                InstrValid = 1;
            end
 
            7'b1100011: begin // Branch (BEQ, BNE)
                Branch     = 1; // tell PC mux to check Zero flag
                ALUOp      = 2'b01; // SUB to compare rs1 and rs2
                InstrValid = 1;
            end
 
            7'b1101111: begin // JAL (jump and link, PC-relative)
                RegWrite   = 1; // write return address into rd
                Jump       = 1; // always take this jump
                WritePC    = 1; // the value written is PC+4 (return address)
                InstrValid = 1;
            end
 
            7'b1100111: begin // JALR (jump to rs1 + imm)
                RegWrite   = 1; // write return address into rd
                ALUSrc     = 1; // target = rs1 + imm, so use imm as ALU B
                ALUOp      = 2'b00; // ADD for target calculation
                JumpR      = 1; // jump to ALU result (rs1 + imm)
                WritePC    = 1; // the value written is PC+4 (return address)
                InstrValid = 1;
            end
 
            7'b0110111: begin // LUI (load upper immediate)
                RegWrite   = 1; // write imm into rd
                ALUSrc     = 1; // use immediate as ALU B
                ALUOp      = 2'b00; // ADD: 0 + imm = imm
                LUI        = 1; // force ALU A to 0
                InstrValid = 1;
            end

            default: begin
                RegWrite   = 0;
                ALUSrc     = 0;
                MemRead    = 0;
                MemWrite   = 0;
                MemtoReg   = 0;
                Branch     = 0;
                Jump       = 0;
                JumpR      = 0;
                LUI        = 0;
                WritePC    = 0;
                ALUOp      = 2'b00;
                InstrValid = 0;
            end

        endcase
    end

endmodule