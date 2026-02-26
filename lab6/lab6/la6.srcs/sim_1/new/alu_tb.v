`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 10:24:58 AM
// Design Name: 
// Module Name: alu_tb
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

module alu_1bit_tb;

    // Inputs
    reg A;
    reg B;
    reg [3:0] ALUControl;

    // Outputs
    wire ALUResult;
    wire Zero;

    // Instantiate the Unit Under Test (UUT)
    alu_1bit uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
        // Initialize Inputs
        A = 0;
        B = 0;
        ALUControl = 0;

        // Wait 10 ns for global reset to finish
        #10;
        
        // Print header for the console output
       

        // Test 1: AND
        ALUControl = 4'b0000; A = 1'b1; B = 1'b1; #10;
        ALUControl = 4'b0000; A = 1'b1; B = 1'b0; #10;

        // Test 2: OR
        ALUControl = 4'b0001; A = 1'b0; B = 1'b1; #10;
        ALUControl = 4'b0001; A = 1'b0; B = 1'b0; #10;

        // Test 3: ADD (Acts as XOR in this dataless 1-bit version)
        ALUControl = 4'b0010; A = 1'b1; B = 1'b0; #10;
        ALUControl = 4'b0010; A = 1'b1; B = 1'b1; #10; // Result should be 0, Zero flag 1

        // Test 4: SUB (Acts as XOR)
        ALUControl = 4'b0110; A = 1'b1; B = 1'b1; #10; // Result should be 0, Zero flag 1
        ALUControl = 4'b0110; A = 1'b0; B = 1'b1; #10;

        // Test 5: XOR
        ALUControl = 4'b0100; A = 1'b1; B = 1'b0; #10;

        // Test 6: SLL (Expected to output 0 as per our 1-bit module)
        ALUControl = 4'b1000; A = 1'b1; B = 1'b1; #10;

        // Test 7: SRL (Expected to output 0)
        ALUControl = 4'b1001; A = 1'b1; B = 1'b0; #10;

        // End simulation
        #10;
        $finish;
    end

endmodule