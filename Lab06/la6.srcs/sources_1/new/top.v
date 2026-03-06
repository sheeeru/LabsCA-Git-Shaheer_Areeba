`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:31:09 AM
// Design Name: 
// Module Name: top
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

module alu_top (
    input  wire [3:0]  alu_ctrl,
    output wire [31:0] alu_result,
    output wire        alu_zero
);

    // Fixed operands per Lab 6 manual Task 3.e
    // (You can change these to 32'd6 and 32'd3 for easier testing on the board!)
    wire [31:0] fixed_A = 32'h10101010; 
    wire [31:0] fixed_B = 32'h01010101; 

    // Instantiate the 32-bit ALU from Level 3
    alu_32bit ALU_Inst (
        .A(fixed_A),
        .B(fixed_B),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

endmodule   