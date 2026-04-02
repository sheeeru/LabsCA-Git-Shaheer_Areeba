`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_control
// Description: Simple top-level FPGA design for RISC-V control path (Lab 9 Task 3)
//              Directly reads switches and drives LEDs without FSM complexity
//////////////////////////////////////////////////////////////////////////////////

module top_control (
    input        clk,
    input        rst,
    input  [15:0] sw,
    output [15:0] led
);

    // -----------------------------------------------------------------------
    // Extract instruction fields DIRECTLY from switches
    // -----------------------------------------------------------------------
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = sw[14:8];
    assign funct3 = sw[7:5];
    assign funct7 = {1'b0, sw[4], 5'b0};

    // -----------------------------------------------------------------------
    // Main Control Unit
    // -----------------------------------------------------------------------
    wire        RegWrite;
    wire        MemRead;
    wire        MemWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire        Branch;
    wire [1:0]  ALUOp;

    main_control uut_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    // -----------------------------------------------------------------------
    // ALU Control Unit
    // -----------------------------------------------------------------------
    wire [3:0] ALUControl;

    alu_control uut_alu (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // -----------------------------------------------------------------------
    // Register to hold LED values (updates every clock cycle)
    // -----------------------------------------------------------------------
    reg [15:0] led_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_reg <= 16'b0;
        end
        else begin
            led_reg <= {
                4'b0,         // LED[15:12] = off
                ALUControl,   // LED[11:8]
                ALUOp[1],     // LED[7]
                ALUOp[0],     // LED[6]
                Branch,       // LED[5]
                MemtoReg,     // LED[4]
                ALUSrc,       // LED[3]
                MemWrite,     // LED[2]
                MemRead,      // LED[1]
                RegWrite      // LED[0]
            };
        end
    end

    // -----------------------------------------------------------------------
    // Drive LED output
    // -----------------------------------------------------------------------
    assign led = led_reg;

endmodule