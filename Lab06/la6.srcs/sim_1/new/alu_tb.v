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

`timescale 1ns / 1ps

module alu_tb;

    // Inputs
    reg a;
    reg b;
    reg a_invert;
    reg b_invert;
    reg cin;
    reg less;
    reg [1:0] operation;

    // Outputs
    wire res;
    wire cout;
    wire set;

    // Instantiate the Unit Under Test (UUT)
    alu_1bit uut (
        .a(a),
        .b(b),
        .a_invert(a_invert),
        .b_invert(b_invert),
        .cin(cin),
        .less(less),
        .operation(operation),
        .res(res),
        .cout(cout),
        .set(set)
    );

    initial begin
        // Initialize Inputs
        a = 0; b = 0; a_invert = 0; b_invert = 0; cin = 0; less = 0; operation = 0;

        #100;
        
        // Test 1: AND (operation = 00)
        a = 1; b = 1; operation = 2'b00; #10;
        a = 1; b = 0; operation = 2'b00; #10;

        // Test 2: OR (operation = 01)
        a = 0; b = 1; operation = 2'b01; #10;
        a = 0; b = 0; operation = 2'b01; #10;

        // Test 3: ADD (operation = 10)
        a = 1; b = 0; cin = 0; operation = 2'b10; #10; // 1 + 0 = 1
        a = 1; b = 1; cin = 0; operation = 2'b10; #10; // 1 + 1 = 0, carry 1
        a = 1; b = 1; cin = 1; operation = 2'b10; #10; // 1 + 1 + 1 = 1, carry 1

        // Test 4: SUB (Invert B, Cin = 1, operation = 10)
        // 1 - 1 = 0
        a = 1; b = 1; b_invert = 1; cin = 1; operation = 2'b10; #10;
        
        // 0 - 1 = 1 (borrow)
        a = 0; b = 1; b_invert = 1; cin = 1; operation = 2'b10; #10;

        $finish;
    end

endmodule