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
        // Instructions are loaded automatically from instruction.mem
        // by the instructionMemory module.
        // ========================================================

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