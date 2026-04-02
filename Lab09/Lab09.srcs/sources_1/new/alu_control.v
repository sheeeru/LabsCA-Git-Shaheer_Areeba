`timescale 1ns / 1ps

module alu_control(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: begin
                // Load/Store - always ADD
                ALUControl = 4'b0010;
            end
            
            2'b01: begin
                // Branch - always SUB
                ALUControl = 4'b0110;
            end
            
            2'b10: begin
                // R-type - decode funct3 and funct7[5]
                case (funct3)
                    3'b000: begin
                        // ADD or SUB
                        if (funct7[5] == 1'b0)
                            ALUControl = 4'b0010;  // ADD
                        else
                            ALUControl = 4'b0110;  // SUB
                    end
                    3'b001: ALUControl = 4'b0011;  // SLL
                    3'b100: ALUControl = 4'b0100;  // XOR
                    3'b101: ALUControl = 4'b0101;  // SRL
                    3'b110: ALUControl = 4'b0001;  // OR
                    3'b111: ALUControl = 4'b0000;  // AND
                    default: ALUControl = 4'b0010;
                endcase
            end
            
            2'b11: begin
                // I-type ALU - decode funct3 only
                case (funct3)
                    3'b000: ALUControl = 4'b0010;  // ADDI
                    default: ALUControl = 4'b0010;
                endcase
            end
            
            default: ALUControl = 4'b0010;
        endcase
    end

endmodule