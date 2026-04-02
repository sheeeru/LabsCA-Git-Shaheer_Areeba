`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_control
// Description: Top-level FPGA design for RISC-V control path (Lab 9 Task 3)
//              Reads switches, decodes control signals, drives LEDs.
//              Uses InstrValid to gate outputs - LEDs stay off for invalid opcodes.
//////////////////////////////////////////////////////////////////////////////////

module top_control (
    input        clk,
    input        rst,
    input  [15:0] sw,
    output [15:0] led
);

    // -----------------------------------------------------------------------
    // Extract instruction fields from switches
    //   SW[14:8] = opcode[6:0]
    //   SW[7:5]  = funct3[2:0]
    //   SW[4]    = funct7 bit 5 (ADD vs SUB)
    //   SW[15], SW[3:0] = reserved (unused)
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
    wire        InstrValid;

    main_control uut_main (
        .opcode     (opcode),
        .RegWrite   (RegWrite),
        .ALUOp      (ALUOp),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .ALUSrc     (ALUSrc),
        .MemtoReg   (MemtoReg),
        .Branch     (Branch),
        .InstrValid (InstrValid)
    );

    // -----------------------------------------------------------------------
    // ALU Control Unit
    // -----------------------------------------------------------------------
    wire [3:0] ALUControl_raw;
    wire [3:0] ALUControl;

    alu_control uut_alu (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl_raw)
    );

    // Gate ALU control output: force 0000 when no valid instruction is decoded.
    // This prevents LED[9] (ALUControl[1]) from being permanently ON due to 
    // the default ALUOp=00 hitting the Load/Store case (ALUControl=0010).
    assign ALUControl = InstrValid ? ALUControl_raw : 4'b0000;

    // Valid opcode list used to suppress ALUControl display on invalid settings.
    wire valid_opcode;
    assign valid_opcode = (opcode == 7'b0110011) || // R-type
                          (opcode == 7'b0010011) || // I-type ALU (ADDI)
                          (opcode == 7'b0000011) || // Load
                          (opcode == 7'b0100011) || // Store
                          (opcode == 7'b1100011);   // Branch (BEQ)

    wire [3:0] ALUControl_led;
    assign ALUControl_led = valid_opcode ? ALUControl : 4'b0000;

    // -----------------------------------------------------------------------
    // Drive LED output directly from combinational decode logic
    // -----------------------------------------------------------------------
    assign led = rst ? 16'b0 : {
        4'b0,           // LED[15:12] = off
        ALUControl_led, // LED[11:8]
        ALUOp[1],       // LED[7]
        ALUOp[0],       // LED[6]
        Branch,         // LED[5]
        MemtoReg,       // LED[4]
        ALUSrc,         // LED[3]
        MemWrite,       // LED[2]
        MemRead,        // LED[1]
        RegWrite        // LED[0]
    };

endmodule