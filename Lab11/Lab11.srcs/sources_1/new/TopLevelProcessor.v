`timescale 1ns / 1ps

module TopLevelProcessor(
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] sw,   // Physical switches mapped to address 768
    output wire [15:0] led   // Physical LEDs mapped to address 512
);

    // ========================================================
    // 1. WIRES & INTERNAL SIGNALS
    // (Names match your testbench hooks exactly)
    // ========================================================
    reg  [31:0] PC;
    wire [31:0] next_PC, PC_plus_4, target_PC;
    wire [31:0] instruction;
    
    // Control Signals
    wire RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg;
    wire Branch, Jump, JumpR, LUI, WritePC, InstrValid;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    
    // Data Path Wires
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] WriteData;
    wire [31:0] imm;
    wire [31:0] SrcA, SrcB;
    wire [31:0] ALUResult;
    wire        Zero;
    wire [31:0] ReadDataMem; // Output from the Address Decoder/MMIO

    // ========================================================
    // 2. PROGRAM COUNTER (PC) LOGIC
    // ========================================================
    assign PC_plus_4 = PC + 4;
    assign target_PC = PC + imm; // Branch or JAL target

    // Next PC Multiplexers
    wire take_branch = Branch & Zero;
    wire [31:0] jump_mux_out = (Jump | take_branch) ? target_PC : PC_plus_4;
    assign next_PC = JumpR ? ALUResult : jump_mux_out; // JALR uses ALUResult

    always @(posedge clk or posedge rst) begin
        if (rst) 
            PC <= 32'd0;
        else 
            PC <= next_PC;
    end

    // ========================================================
    // 3. INSTRUCTION MEMORY
    // ========================================================
    instructionMemory u_instrMem (
        .instAddress(PC),
        .instruction(instruction)
    );

    // ========================================================
    // 4. CONTROL UNIT
    // ========================================================
    main_control ctrl_inst (
        .opcode(instruction[6:0]),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .JumpR(JumpR),
        .LUI(LUI),
        .WritePC(WritePC),
        .InstrValid(InstrValid)
    );

    // ========================================================
    // 5. REGISTER FILE
    // ========================================================
    // WriteData Multiplexer: Choose between ALU, Memory/MMIO, or PC+4 (for JAL/JALR)
    wire [31:0] mem_or_alu = MemtoReg ? ReadDataMem : ALUResult;
    assign WriteData = WritePC ? PC_plus_4 : mem_or_alu;

    RegisterFile u_regFile (
        .clk(clk),
        .rst(rst),
        .WriteEnable(RegWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // ========================================================
    // 6. IMMEDIATE GENERATOR
    // ========================================================
    immGen u_immGen (
        .instruction(instruction),
        .imm(imm)
    );

    // ========================================================
    // 7. ALU INPUT MULTIPLEXERS
    // ========================================================
    // LUI Mux: If LUI is active, force Operand A to 0. Otherwise use rs1.
    assign SrcA = LUI ? 32'd0 : ReadData1;
    
    // ALUSrc Mux: If ALUSrc is 1, use Immediate. Otherwise use rs2.
    assign SrcB = ALUSrc ? imm : ReadData2;

    // ========================================================
    // 8. ALU CONTROL
    // ========================================================
    alu_control u_aluCtrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .ALUControl(ALUControl)
    );

    // ========================================================
    // 9. ALU
    // ========================================================
    alu_32bit alu_inst (
        .A(SrcA),
        .B(SrcB),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // ========================================================
    // 10. MEMORY MAPPED I/O & DATA MEMORY
    // ========================================================
    // Uses your addressDecoderTop to handle RAM, Switches, and LEDs seamlessly
    addressDecoderTop u_mmio (
        .clk(clk),
        .rst(rst),
        .address(ALUResult),        // ALU calculates the address
        .readEnable(MemRead),
        .writeEnable(MemWrite),
        .writeData(ReadData2),      // Data to store comes from rs2
        .switches(sw),              // Physical switch inputs
        .readData(ReadDataMem),     // Output from memory/switches
        .leds(led)                  // Physical LED outputs
    );

endmodule