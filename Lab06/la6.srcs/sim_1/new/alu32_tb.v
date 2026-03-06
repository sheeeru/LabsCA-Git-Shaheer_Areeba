`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:03:15 AM
// Design Name: 
// Module Name: alu32_tb
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




module alu_32bit_tb;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0]  ALUControl;

    // Outputs
    wire [31:0] ALUResult;
    wire        Zero;

    // Instantiate the Unit Under Test (UUT)
    alu_32bit uut (
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

        // Wait 100 ns for global reset to finish
        #100;
        
       
        // Test 1: ADD
        A = 32'd250; 
        B = 32'd150; 
        ALUControl = 4'b0010; // ADD
        #10;
        
        // Test 2: SUB
        A = 32'd500; 
        B = 32'd500; 
        ALUControl = 4'b0110; // SUB
        #10;
        
        // Test 3: AND
        A = 32'hFFFF_0000;
        B = 32'hFF00_FF00;
        ALUControl = 4'b0000; // AND
        #10;
     

        // Test 4: OR
        A = 32'h0000_000F;
        B = 32'h0000_00F0;
        ALUControl = 4'b0001; // OR
        #10;
   

        // Test 5: XOR
        A = 32'hAAAA_AAAA;
        B = 32'h5555_5555;
        ALUControl = 4'b0100; // XOR
        #10;


        // Test 6: SLL (Shift Left Logical)
        A = 32'h0000_0001;
        B = 32'd4; // Shift left by 4
        ALUControl = 4'b1000; // SLL
        #10;
        
        // Test 7: SRL (Shift Right Logical)
        A = 32'h0000_00F0;
        B = 32'd4; // Shift right by 4
        ALUControl = 4'b1001; // SRL
        #10;
       
        // End simulation
        #10;
        $finish;
    end

endmodule