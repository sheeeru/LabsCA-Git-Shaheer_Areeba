`timescale 1ns / 1ps

module tb_control;
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    
    wire       RegWrite;
    wire [1:0] ALUOp;       // Wire connecting main_control TO alu_control
    wire       MemRead;
    wire       MemWrite;
    wire       ALUSrc;
    wire       MemtoReg;
    wire       Branch;
    wire [3:0] ALUControl;
    
    main_control uut_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),     // Drives the wire
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );
    
     alu_control uut_alu (
        .ALUOp      (ALUOp),   // Receives from the wire
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );
    
    initial begin
        // 1. ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;

        // 2. SUB
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; #10;

        // 3. SLL
        opcode = 7'b0110011; funct3 = 3'b001; funct7 = 7'b0000000; #10;

        // 4. SRL
        opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0000000; #10;

        // 5. AND
        opcode = 7'b0110011; funct3 = 3'b111; funct7 = 7'b0000000; #10;

        // 6. OR
        opcode = 7'b0110011; funct3 = 3'b110; funct7 = 7'b0000000; #10;

        // 7. XOR
        opcode = 7'b0110011; funct3 = 3'b100; funct7 = 7'b0000000; #10;

        // 8. ADDI
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;

        // 9. Load (LW/LH/LB use same opcode for control paths)
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;

        // 10. Store (SW/SH/SB use same opcode for control paths)
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10;

        // 11. BEQ
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;

        $finish;
    end

endmodule