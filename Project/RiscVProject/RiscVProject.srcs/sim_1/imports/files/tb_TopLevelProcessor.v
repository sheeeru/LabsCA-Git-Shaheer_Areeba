`timescale 1ns / 1ps

module tb_TopLevelProcessor;

    // --- Standard Testbench Inputs/Outputs ---
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] led;

    // Instantiate your processor
    TopLevelProcessor dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );
    wire [31:0] SHOW_PC          = dut.PC;
    wire [31:0] SHOW_Instruction = dut.instruction;
    wire [31:0] SHOW_ALU_Result  = dut.ALUResult;
    wire [31:0] SHOW_Reg_WriteData = dut.WriteData;
    wire        SHOW_Zero_Flag   = dut.Zero;
    wire        SHOW_RegWrite    = dut.RegWrite;
    wire        SHOW_BranchCtrl  = dut.Branch;
    wire        SHOW_JumpCtrl    = dut.Jump;

    // Clock generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;       // KEEP RESET HIGH
        sw = 16'h0000; 

        // ========================================================
        // HARDCODED INSTRUCTIONS
        // ========================================================
        dut.u_instrMem.memory[0]  = 32'h12345237; // lui x4 0x12345
//        dut.u_instrMem.memory[0]  = 32'h00600113; // addi x2, x0, 6   (li x2, 6)
        dut.u_instrMem.memory[1]  = 32'h00800193; // addi x3, x0, 8   (li x3, 8)
        dut.u_instrMem.memory[2]  = 32'h00310233; // add x4, x2, x3   (x4 = 6 + 8 = 14)
        dut.u_instrMem.memory[3]  = 32'h40310233; // sub x4, x2, x3   (x4 = 6 - 8 = -2)
        dut.u_instrMem.memory[4]  = 32'h00314233; // xor x4, x2, x3   (x4 = 6 ^ 8)
        dut.u_instrMem.memory[5]  = 32'h00316233; // or  x4, x2, x3   (x4 = 6 | 8)
        dut.u_instrMem.memory[6]  = 32'h00317233; // and x4, x2, x3   (x4 = 6 & 8)
        dut.u_instrMem.memory[7]  = 32'h00210463; // beq x2, x2, +8 
        dut.u_instrMem.memory[8]  = 32'h06300213; // addi x4, x0, 99  (DUMMY)
        dut.u_instrMem.memory[9]  = 32'h008000EF; // jal x1, +8 
        dut.u_instrMem.memory[10] = 32'h06400213; // addi x4, x0, 100 (DUMMY)
        dut.u_instrMem.memory[11] = 32'h00000063; // beq x0, x0, 0    (Infinite loop)

        // Hold reset for 20ns to ENSURE the PC module initializes to 0
        #20;
        rst = 0;

        // Allow enough time for the instructions to execute.
        #300;
        
        $finish;
    end

    // Console Output Table
    initial begin
        $display("=======================================================================");
        $display(" Time |    PC    | Instruction | ALU Result | Zero | Branch | RegWrite ");
        $display("=======================================================================");
        
        $monitor("%5t | %8h |   %8h  |  %8h  |   %b  |   %b    |    %b", 
                 $time, 
                 SHOW_PC, 
                 SHOW_Instruction, 
                 SHOW_ALU_Result,
                 SHOW_Zero_Flag, 
                 SHOW_BranchCtrl, 
                 SHOW_RegWrite);
    end

    // Waveform dump
    initial begin
        $dumpfile("processor_wave.vcd");
        $dumpvars(0, tb_TopLevelProcessor);
    end

endmodule