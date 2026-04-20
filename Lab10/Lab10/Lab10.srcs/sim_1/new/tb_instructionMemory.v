`timescale 1ns / 1ps

module tb_instructionMemory();

    // ---- Inputs ----
    reg [31:0] instAddress;

    // ---- Outputs ----
    wire [31:0] instruction;

    // ---- Instantiate the module ----
    instructionMemory #(
        .OPERAND_LENGTH(31)
    ) uut (
        .instAddress(instAddress),
        .instruction(instruction)
    );

    // ---- Test Sequence ----
    initial begin

        // -----------------------------------------------
        // Test 1: Fetch instruction at address 0
        // Expected: 0x30000293 -> addi x5, x0, 768
        // -----------------------------------------------
//        instAddress = 32'd0;
//        #10;
//        $display("Addr: %0d | Instruction: %h | Expected: 30000293 | %s",
//            instAddress, instruction,
//            (instruction == 32'h30000293) ? "PASS" : "FAIL");

//        // -----------------------------------------------
//        // Test 2: Fetch instruction at address 4
//        // Expected: 0x20000313 -> addi x6, x0, 512
//        // -----------------------------------------------
//        instAddress = 32'd4;
//        #10;
//        $display("Addr: %0d | Instruction: %h | Expected: 20000313 | %s",
//            instAddress, instruction,
//            (instruction == 32'h20000313) ? "PASS" : "FAIL");

//        // -----------------------------------------------
//        // Test 3: Fetch instruction at address 8
//        // Expected: 0x40000393 -> addi x7, x0, 1024
//        // -----------------------------------------------
//        instAddress = 32'd8;
//        #10;
//        $display("Addr: %0d | Instruction: %h | Expected: 40000393 | %s",
//            instAddress, instruction,
//            (instruction == 32'h40000393) ? "PASS" : "FAIL");

//        // -----------------------------------------------
//        // Test 4: Fetch instruction at address 12
//        // Expected: 0x00300B13 -> addi x22, x0, 3
//        // -----------------------------------------------
//        instAddress = 32'd12;
//        #10;
//        $display("Addr: %0d | Instruction: %h | Expected: 00300B13 | %s",
//            instAddress, instruction,
//            (instruction == 32'h00300B13) ? "PASS" : "FAIL");

//        // -----------------------------------------------
//        // Test 5: Fetch instruction at address 16
//        // Expected: 0x00032023 -> sw x0, 0(x6) clear LEDs
//        // -----------------------------------------------
//        instAddress = 32'd16;
//        #10;
//        $display("Addr: %0d | Instruction: %h | Expected: 00032023 | %s",
//            instAddress, instruction,
//            (instruction == 32'h00032023) ? "PASS" : "FAIL");

//        // -----------------------------------------------
//        // Test 6: Sequential fetch - walk through 5 instructions
//        // Simulates PC incrementing by 4 each cycle
//        // -----------------------------------------------
        $display("---- Sequential Fetch Test ----");
        begin : seq_test
            integer i;
            for (i = 0; i < 41; i = i + 1) begin
                instAddress = i * 4;
                #10;
                $display("Addr: %0d | Instruction: %h", instAddress, instruction);
            end
        end

//        // -----------------------------------------------
//        // Test 7: Out of range address
//        // Address 1020 = word index 255 (last valid slot)
//        // -----------------------------------------------
//        instAddress = 32'd160;;
//        #10;
//        $display("Addr: %0d | Instruction: %h (last slot)",
//            instAddress, instruction);

//        // -----------------------------------------------
//        // Test 8: Check same address twice gives same result
//        instAddress = 32'd0;
//        #10;
//        $display("Addr: 0 first read:  %h", instruction);

//        instAddress = 32'd0;
//        #10;
//        $display("Addr: 0 second read: %h", instruction);

        $finish;
    end

endmodule