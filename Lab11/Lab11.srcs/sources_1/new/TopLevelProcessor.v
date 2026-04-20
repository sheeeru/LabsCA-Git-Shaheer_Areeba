`timescale 1ns / 1ps

// TopLevelProcessor.v
// Single-cycle RISC-V processor - Lab 11 Task 2


module TopLevelProcessor (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] sw,   // physical switches connected via MMIO
    output wire [15:0] led   // physical LEDs connected via MMIO
);

    // =========================================================
    // STEP 1: PC and instruction fetch wires
    // =========================================================

    wire [31:0] PC;           // current program counter
    wire [31:0] PCPlus4;      // PC + 4 (next sequential instruction)
    wire [31:0] BranchTarget; // PC + imm (branch or JAL target)
    reg  [31:0] PCNext;       // what goes into PC on next clock edge

    wire [31:0] instruction;  // 32-bit instruction from memory

    // =========================================================
    // STEP 2: Slice instruction into fields
    // =========================================================

    wire [6:0] opcode = instruction[6:0];    // tells us what kind of instruction
    wire [4:0] rs1    = instruction[19:15];  // source register 1
    wire [4:0] rs2    = instruction[24:20];  // source register 2
    wire [4:0] rd     = instruction[11:7];   // destination register
    wire [2:0] funct3 = instruction[14:12];  // selects sub-operation
    wire [6:0] funct7 = instruction[31:25];  // selects ADD vs SUB etc

    // =========================================================
    // STEP 3: Control signals from main_control
    // =========================================================

    wire        RegWrite;  // 1 = write result back to register file
    wire        ALUSrc;    // 1 = use immediate, 0 = use ReadData2
    wire        MemRead;   // 1 = read from data memory (load)
    wire        MemWrite;  // 1 = write to data memory (store)
    wire        MemtoReg;  // 1 = write-back from memory, 0 = from ALU
    wire        Branch;    // 1 = this is a branch instruction
    wire        Jump;      // 1 = this is JAL
    wire        JumpR;     // 1 = this is JALR
    wire        LUI;       // 1 = this is LUI (force ALU A input to 0)
    wire        WritePC;   // 1 = write PC+4 into rd (JAL/JALR)
    wire        InstrValid;// 1 = opcode was recognised
    wire [1:0]  ALUOp;     // tells alu_control what kind of operation

    wire [3:0]  ALUControl; // exact ALU operation code

    // =========================================================
    // STEP 4: Register file wires
    // =========================================================

    wire [31:0] ReadData1; // value of rs1
    wire [31:0] ReadData2; // value of rs2
    reg  [31:0] WriteData; // value to write into rd

    // =========================================================
    // STEP 5: Immediate and ALU wires
    // =========================================================

    wire [31:0] imm;       // sign-extended immediate from immGen
    reg  [31:0] ALU_A;     // first ALU input
    reg  [31:0] ALU_B;     // second ALU input (ReadData2 or imm)
    wire [31:0] ALUResult; // ALU output
    wire        Zero;      // 1 when ALUResult == 0 (used for BEQ)

    wire [31:0] MemReadData; // data read from memory

    // =========================================================
    // BRANCH DECISION
    // Branch is taken when instruction is BEQ and Zero=1
    // OR when instruction is JAL (unconditional jump)
    // =========================================================

    wire TakeBranch;
    assign TakeBranch = (Branch & Zero) | Jump;

    // =========================================================
    // PC MUX
    // JALR: jump to rs1 + imm (that is ALUResult), clear bit 0
    // Branch/JAL: jump to PC + imm (that is BranchTarget)
    // Otherwise: go to PC + 4
    // =========================================================

    always @(*) begin
        if (JumpR == 1)
            PCNext = ALUResult & 32'hFFFFFFFE; // clear bit 0 per RISC-V spec
        else if (TakeBranch == 1)
            PCNext = BranchTarget;
        else
            PCNext = PCPlus4;
    end

    // =========================================================
    // ALU A INPUT MUX
    // LUI forces A to 0 so result = 0 + imm = imm (upper immediate)
    // All other instructions use ReadData1
    // =========================================================

    always @(*) begin
        if (LUI == 1)
            ALU_A = 32'd0;
        else
            ALU_A = ReadData1;
    end

    // =========================================================
    // ALU B INPUT MUX
    // ALUSrc=1: use immediate (I-type, S-type, loads, stores)
    // ALUSrc=0: use ReadData2 (R-type)
    // =========================================================

    always @(*) begin
        if (ALUSrc == 1)
            ALU_B = imm;
        else
            ALU_B = ReadData2;
    end

    // =========================================================
    // WRITE-BACK MUX
    // JAL/JALR: save PC+4 into rd so we can return later
    // Load:     save data read from memory into rd
    // Others:   save ALU result into rd
    // =========================================================

    always @(*) begin
        if (WritePC == 1)
            WriteData = PCPlus4;
        else if (MemtoReg == 1)
            WriteData = MemReadData;
        else
            WriteData = ALUResult;
    end

    // =========================================================
    // MODULE INSTANTIATIONS
    // =========================================================

    // PC register - updates on every clock edge
    ProgramCounter u_pc (
        .clk    (clk),
        .rst    (rst),
        .PCNext (PCNext),
        .PC     (PC)
    );

    // Adds 4 to PC
    pcAdder u_pcAdder (
        .PC      (PC),
        .PCPlus4 (PCPlus4)
    );

    // Adds imm to PC for branch and JAL targets
    branchAdder u_branchAdder (
        .PC           (PC),
        .imm          (imm),
        .BranchTarget (BranchTarget)
    );

    // Reads instruction at address PC
    instructionMemory u_instrMem (
        .instAddress (PC),
        .instruction (instruction)
    );

    // Decodes opcode into control signals
    main_control u_mainCtrl (
        .opcode     (opcode),
        .RegWrite   (RegWrite),
        .ALUOp      (ALUOp),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .ALUSrc     (ALUSrc),
        .MemtoReg   (MemtoReg),
        .Branch     (Branch),
        .Jump       (Jump),
        .JumpR      (JumpR),
        .LUI        (LUI),
        .WritePC    (WritePC),
        .InstrValid (InstrValid)
    );

    // Decodes funct3/funct7 into exact ALU operation
    alu_control u_aluCtrl (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // Holds 32 registers, reads rs1/rs2, writes rd
    RegisterFile u_rf (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(RegWrite),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WriteData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    // Extracts the immediate value from the instruction
    immGen u_immGen (
        .instruction (instruction),
        .imm         (imm)
    );

    // Performs the arithmetic or logic operation
    alu_32bit u_alu (
        .A          (ALU_A),
        .B          (ALU_B),
        .ALUControl (ALUControl),
        .ALUResult  (ALUResult),
        .Zero       (Zero)
    );

    // Data memory + MMIO (switches and LEDs)
    // address 512 = LED output
    // address 768 = switch input
    // address 0-511 = data memory (stack)
    addressDecoderTop u_mem (
        .clk        (clk),
        .rst        (rst),
        .address    (ALUResult),
        .readEnable (MemRead),
        .writeEnable(MemWrite),
        .writeData  (ReadData2),
        .switches   (sw),
        .readData   (MemReadData),
        .leds       (led)
    );

endmodule