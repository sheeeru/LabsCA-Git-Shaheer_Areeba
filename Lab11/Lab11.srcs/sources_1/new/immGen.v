`timescale 1ns / 1ps

// Immediate Generator for I-type, S-type, and B-type immediates.
// B-type output does NOT include the trailing zero bit.
// branchAdder shifts left by 1, so the combined result is correct.
//
// Opcode map:
// 0000011 = Load  (I-type)
// 0010011 = Addi (I-type)
// 0100011 = Store (S-type)
// 1100011 = Branch
// 1100111 - jalr


module immGen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm
);

    always @(*) begin
        case (instruction[6:0])
            // I-type: addi, lw, jalr
            7'b0010011, 7'b0000011, 7'b1100111: 
                imm = {{20{instruction[31]}}, instruction[31:20]};
            
            // S-type: sw
            7'b0100011: 
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            
            // B-type: beq, bne
            7'b1100011: 
                imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            
            // J-type: jal
            // Immediate is scrambled: [31] -> bit 20, [30:21] -> bits 10:1, [20] -> bit 11, [19:12] -> bits 19:12
            // Bit 0 is always 0
            7'b1101111:
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

            // Default to zero
            default: 
                imm = 32'b0;
        endcase
    end

endmodule