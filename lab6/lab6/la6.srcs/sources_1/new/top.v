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
    input  wire [15:0] sw,   // 16 slide switches 
    output wire [15:0] led   // 16 LEDs 
);

    // Internal wires to connect to the 32-bit ALU
    wire [31:0] alu_A;
    wire [31:0] alu_B;
    wire [3:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;

    // -----------------------------------------------------------------
    // I/O Mapping Strategy:
    // sw[15:12] -> ALUControl (4 bits to select operation)
    // sw[11:6]  -> Input A lower 6 bits (Values 0 to 63)
    // sw[5:0]   -> Input B lower 6 bits (Values 0 to 63)
    // -----------------------------------------------------------------
    
    assign alu_ctrl = sw[15:12];
    
    // Pad the upper 26 bits with 0s
    assign alu_A = {26'd0, sw[11:6]}; 
    assign alu_B = {26'd0, sw[5:0]};  



    alu_32bit ALU_Inst (
        .A(alu_A),
        .B(alu_B),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

    // -----------------------------------------------------------------
    // Output Mapping:
    // led[15]   -> Zero Flag (Leftmost LED)
    // led[14:8] -> Tied to 0 (Turned off for visual separation)
    // led[7:0]  -> Lower 8 bits of the Result (Rightmost LEDs)
    // -----------------------------------------------------------------
    
    assign led[15] = alu_zero;
    assign led[14:8] = 7'b0000000;
    assign led[7:0] = alu_result[7:0];

endmodule