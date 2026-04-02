`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_control
// Description: Integrated testbench for main_control and alu_control.
//              ALUOp wire connects the two modules, mirroring real hardware.
//////////////////////////////////////////////////////////////////////////////////

module tb_control;

    // -----------------------------------------------------------------------
    // Stimulus Inputs
    // -----------------------------------------------------------------------
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    // -----------------------------------------------------------------------
    // Internal Wires & Outputs
    // -----------------------------------------------------------------------
    wire       RegWrite;
    wire [1:0] ALUOp;       // Wire connecting main_control TO alu_control
    wire       MemRead;
    wire       MemWrite;
    wire       ALUSrc;
    wire       MemtoReg;
    wire       Branch;
    wire [3:0] ALUControl;

    // -----------------------------------------------------------------------
    // Instantiate main_control
    // -----------------------------------------------------------------------
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

    // -----------------------------------------------------------------------
    // Instantiate alu_control
    // -----------------------------------------------------------------------
    alu_control uut_alu (
        .ALUOp      (ALUOp),   // Receives from the wire
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // -----------------------------------------------------------------------
    // Waveform dump
    // -----------------------------------------------------------------------
    initial begin
        $dumpfile("tb_control.vcd");
        $dumpvars(0, tb_control);
    end

    // -----------------------------------------------------------------------
    // Task: check main control outputs
    // -----------------------------------------------------------------------
    task check_main;
        input [6:0]  op;
        input        exp_RegWrite;
        input [1:0]  exp_ALUOp;
        input        exp_MemRead;
        input        exp_MemWrite;
        input        exp_ALUSrc;
        input        exp_Branch;
        input [80:0] label;
        begin
            opcode = op;
            #10;
            $display("  [Main] %s | RegWrite=%b ALUOp=%b MemRead=%b MemWrite=%b ALUSrc=%b MemtoReg=%b Branch=%b",
                      label, RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch);
            if (RegWrite !== exp_RegWrite) $display("  FAIL RegWrite: exp=%b got=%b", exp_RegWrite, RegWrite);
            if (ALUOp    !== exp_ALUOp)    $display("  FAIL ALUOp:    exp=%b got=%b", exp_ALUOp,    ALUOp);
            if (MemRead  !== exp_MemRead)  $display("  FAIL MemRead:  exp=%b got=%b", exp_MemRead,  MemRead);
            if (MemWrite !== exp_MemWrite) $display("  FAIL MemWrite: exp=%b got=%b", exp_MemWrite, MemWrite);
            if (ALUSrc   !== exp_ALUSrc)   $display("  FAIL ALUSrc:   exp=%b got=%b", exp_ALUSrc,   ALUSrc);
            if (Branch   !== exp_Branch)   $display("  FAIL Branch:   exp=%b got=%b", exp_Branch,   Branch);
        end
    endtask

    // -----------------------------------------------------------------------
    // Task: check ALU control output
    // -----------------------------------------------------------------------
    task check_alu;
        input [6:0]  op;     // Now uses opcode to naturally set ALUOp
        input [2:0]  f3;
        input [6:0]  f7;
        input [3:0]  exp_ctrl;
        input [80:0] label;
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #10;
            $display("    Opcode=%b funct7[5]=%b funct3=%b -> ALUControl=%b  %s",
                      op, f7[5], f3, ALUControl,
                      (ALUControl === exp_ctrl) ? "PASS" : "FAIL");
        end
    endtask

    // -----------------------------------------------------------------------
    // Stimulus
    // -----------------------------------------------------------------------
    initial begin

        // Initialize all inputs to known values
        opcode = 7'b0000000;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #5;                       

        // ===================================================================
        // PART 1: Main Control Unit
        // ===================================================================
        $display("=== MAIN CONTROL UNIT ===");

        $display("-- ld (0000011) --");
        check_main(7'b0000011, 1, 2'b00, 1, 0, 1, 0, "ld");

        $display("-- sd (0100011) --");
        check_main(7'b0100011, 0, 2'b00, 0, 1, 1, 0, "sd");

        $display("-- beq (1100011) --");
        check_main(7'b1100011, 0, 2'b01, 0, 0, 0, 1, "beq");

        $display("-- R-type (0110011) --");
        check_main(7'b0110011, 1, 2'b10, 0, 0, 0, 0, "R-type");

        // ===================================================================
        // PART 2: ALU Control (Integrated test via Opcode)
        // ===================================================================
        $display("");
        $display("=== ALU CONTROL UNIT ===");

        // ALUOp=00 -> add (Test via ld opcode)
        $display("-- ALUOp=00 -> add (ld) --");
        check_alu(7'b0000011, 3'b000, 7'b0000000, 4'b0010, "ld f=0");
        check_alu(7'b0000011, 3'b000, 7'b0000000, 4'b0010, "ld f=1");

        // ALUOp=01 -> subtract (Test via beq opcode)
        $display("-- ALUOp=01 -> subtract (beq) --");
        check_alu(7'b1100011, 3'b000, 7'b0000000, 4'b0110, "beq f=0");
        check_alu(7'b1100011, 3'b000, 7'b0000000, 4'b0110, "beq f=1");

        // ALUOp=10 -> R-type computations (Test via R-type opcode)
        $display("-- ALUOp=10 -> R-type Operations --");
        check_alu(7'b0110011, 3'b000, 7'b0000000, 4'b0010, "R-add");
        check_alu(7'b0110011, 3'b000, 7'b0100000, 4'b0110, "R-sub");
        check_alu(7'b0110011, 3'b111, 7'b0000000, 4'b0000, "R-and");
        check_alu(7'b0110011, 3'b110, 7'b0000000, 4'b0001, "R-or");

        $display("");
        $display("=== SIMULATION COMPLETE ===");
        $finish;
    end

endmodule