`timescale 1ns / 1ps
module tb_Task1;

    reg         clk, rst, PCSrc;
    wire [31:0] PC, PCPlus4, BranchTarget, PCNext;
    reg  [31:0] instruction;
    wire [31:0] imm;

    ProgramCounter uut_pc  (.clk(clk), .rst(rst), .PCNext(PCNext), .PC(PC));
    pcAdder        uut_pca (.PC(PC), .PCPlus4(PCPlus4));
    branchAdder    uut_bra (.PC(PC), .imm(imm), .BranchTarget(BranchTarget));
    mux2           uut_mux (.select(PCSrc), .in0(PCPlus4), .in1(BranchTarget), .out(PCNext));
    immGen         uut_imm (.instruction(instruction), .imm(imm));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; PCSrc = 0; instruction = 0;
        #10; rst = 0; // relase reset pc should be 0
        
        //testcase 1 pc increment:
        #10 //pc =4
        #10 //pc =8

        // Test 2: Immediate generation
        instruction = 32'h1FF00113; #10;  // addi x2, x0, 511  (I-type positive)
        // pc should be 12
        instruction = 32'hFFC10113; #10;  // addi x2, x2, -4   (I-type negative)
        //pc =16

        // Test 3: PC updates to branch target when PCSrc=1
   
        instruction = 32'hFE050AE3;      // beq x10, x0, -12

        PCSrc = 1;
        #10; //pc shoudl be 4 (16-12)
        PCSrc = 0;
        #10 
        //pc becomes 0 again because pcssrc is 0 now 

        $finish;
    end
endmodule