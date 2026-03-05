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
    input  wire [3:0] ALUControl,
    output reg        ALUResult,  
    output wire       Zero
);

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A & B;           // AND
            4'b0001: ALUResult = A | B;           // OR
            4'b0010: ALUResult = A ^ B;           // ADD 
            4'b0110: ALUResult = A ^ B;           // SUB 
            4'b0100: ALUResult = A ^ B;           // XOR
            4'b1000: ALUResult = 1'b0;            // SLL 
            4'b1001: ALUResult = 1'b0;            // SRL 
            default: ALUResult = 1'b0;           
        endcase
    end


    assign Zero = ~ALUResult;

endmodule