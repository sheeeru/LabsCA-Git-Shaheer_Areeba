`timescale 1ns / 1ps
module alu_control(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUControl
);

//    wire [6:0]func= funct7;  // Bit 30 of instruction - distinguishes ADD/SUB

    always @(*) begin
        ALUControl = 4'b0000; // Default to AND or safe state

        case(ALUOp)
            2'b00:
                // Load/Store: Always performs an addition for address calculation
                ALUControl = 4'b0010; 

            2'b01: 
                // Branch: Always performs a subtraction to compare values
                ALUControl = 4'b0110; 

            2'b10: begin 
                // R-type: Operation depends on funct3 and funct7
                case(funct3)
                    3'b000: begin
                        if (funct7== 7'b0100000) 
                            ALUControl = 4'b0110; // SUB
                        else 
                            ALUControl = 4'b0010; // ADD
                    end
                    3'b001:  ALUControl = 4'b0100; // SLL
                    3'b101:  ALUControl = 4'b0101; // SRL
                    3'b111:  ALUControl = 4'b0000; // AND
                    3'b110:  ALUControl = 4'b0001; // OR
                    3'b100:  ALUControl = 4'b0011; // XOR
                    default: ALUControl = 4'b0000;
                endcase
            end

            2'b11: begin 
                // I-type: Logic based on funct3 (e.g., ADDI)
                case(funct3)
                    3'b000:  ALUControl = 4'b0010; // ADDI
                    default: ALUControl = 4'b0000;
                endcase
            end

            default: ALUControl = 4'b0000;
        endcase
    end

endmodule