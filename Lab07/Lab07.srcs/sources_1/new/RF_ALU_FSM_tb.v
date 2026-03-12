`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name : RF_ALU_FSM_tb
// Project     : Lab 7 - Single-Cycle RISC-V Register File
// Description : Integrated testbench – instantiates the RegisterFile from
//               Lab 7 and the alu_32bit from Lab 6, then drives an FSM that:
//               i.   Writes constants into several registers
//               ii.  Reads pairs, feeds them through the ALU (7 operations)
//                    and writes results back
//               iii. Performs a BEQ-style check via ALU Zero flag
//               iv.  Tests read-after-write timing (write then read next cycle)
//
// IMPORTANT   : Add the Lab 6 source files (alu_32bit.v, alu.v, and_gate.v,
//               or_gate.v, xor_gate.v, full_adder.v, shifter_32bit.v) to the
//               same Vivado project / simulation fileset as this testbench.
////////////////////////////////////////////////////////////////////////////////

module RF_ALU_FSM_tb;

    // =========================================================================
    // 1. Clock & Global Signals
    // =========================================================================
    reg clk;
    reg rst;
    always #5 clk = ~clk;   // 100 MHz

    // =========================================================================
    // 2. Register File wires
    // =========================================================================
    reg         rf_we;
    reg  [4:0]  rf_rs1, rf_rs2, rf_rd;
    reg  [31:0] rf_wd;
    wire [31:0] rf_rd1, rf_rd2;

    RegisterFile RF (
        .clk(clk), .rst(rst),
        .WriteEnable(rf_we),
        .rs1(rf_rs1), .rs2(rf_rs2), .rd(rf_rd),
        .WriteData(rf_wd),
        .ReadData1(rf_rd1), .ReadData2(rf_rd2)
    );

    // =========================================================================
    // 3. ALU wires  (reusing Lab 6 alu_32bit directly)
    // =========================================================================
    reg  [3:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;

    alu_32bit ALU (
        .A(rf_rd1),
        .B(rf_rd2),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

    // =========================================================================
    // 4. FSM State Encoding
    // =========================================================================
    localparam [3:0]
        IDLE        = 4'd0,
        WRITE_REGS  = 4'd1,   // write x1, x2, x3 with known constants
        ALU_ADD     = 4'd2,   // x4  = x1 ADD x2
        ALU_SUB     = 4'd3,   // x5  = x1 SUB x2
        ALU_AND     = 4'd4,   // x6  = x1 AND x2
        ALU_OR      = 4'd5,   // x7  = x1 OR  x2
        ALU_XOR     = 4'd6,   // x8  = x1 XOR x2
        ALU_SLL     = 4'd7,   // x9  = x1 SLL x3 (shift amount = x3 = 5)
        ALU_SRL     = 4'd8,   // x10 = x1 SRL x3
        BEQ_CHECK   = 4'd9,   // Zero check: x1 SUB x1 → Zero should be 1 → write flag to x11
        RAW_WRITE   = 4'd10,  // write x12 = 0xABCD1234
        RAW_READ    = 4'd11,  // read x12 next cycle and check
        DONE        = 4'd12;

    reg [3:0] state, next_state;

    // =========================================================================
    // 5. FSM Sequential (state register)
    // =========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    // =========================================================================
    // 6. FSM Combinational (outputs + next-state logic)
    // =========================================================================

    // ALU control codes matching Lab 6 alu_32bit
    localparam [3:0]
        CTRL_AND = 4'b0000,
        CTRL_OR  = 4'b0001,
        CTRL_ADD = 4'b0010,
        CTRL_SUB = 4'b0110,
        CTRL_XOR = 4'b0100,
        CTRL_SLL = 4'b1000,
        CTRL_SRL = 4'b1001;

    // Tracking results for assertions
    reg [31:0] saved_alu;
    reg        saved_zero;

    always @(posedge clk) begin
        if (rst) begin
            rf_we      <= 0; rf_rd <= 0; rf_wd <= 0;
            rf_rs1     <= 0; rf_rs2 <= 0;
            alu_ctrl   <= CTRL_ADD;
            saved_alu  <= 0; saved_zero <= 0;
        end else begin
            // Defaults: no write, no op change
            rf_we <= 0;

            case (state)
                // --------------------------------------------------------
                IDLE: begin
                    // nothing – transition immediately
                end

                // --------------------------------------------------------
                WRITE_REGS: begin
                    // Write x1 = 0x10101010, x2 = 0x01010101, x3 = 5
                    // We do all three writes in consecutive cycles via sub-steps.
                    // Simple approach: use a shift register for sub-stepping.
                    // (For clarity the lab FSM handles one write per state tick.
                    //  Three writes: we'll split across WRITE_REGS → two helper
                    //  states by reusing the DONE state trick.)
                    //
                    // In this simplified implementation we write all three using
                    // a counter that increments each cycle while we stay here.
                    rf_we   <= 1;
                    rf_rd   <= 5'd1;
                    rf_wd   <= 32'h10101010;
                end

                // We need extra states to write x2, x3.
                // Add them in next_state logic below; the write happens one
                // cycle later thanks to the synchronous RF.

                ALU_ADD: begin
                    // x4 = ADD(x1, x2) – set RF read addresses, set ALU op
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd2;
                    alu_ctrl <= CTRL_ADD;
                    // Capture result and write to x4 in the SAME state
                    // (ALU is combinational from RF reads)
                    rf_we    <= 1;
                    rf_rd    <= 5'd4;
                    rf_wd    <= alu_result;
                end

                ALU_SUB: begin
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd2;
                    alu_ctrl <= CTRL_SUB;
                    rf_we <= 1; rf_rd <= 5'd5; rf_wd <= alu_result;
                end

                ALU_AND: begin
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd2;
                    alu_ctrl <= CTRL_AND;
                    rf_we <= 1; rf_rd <= 5'd6; rf_wd <= alu_result;
                end

                ALU_OR: begin
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd2;
                    alu_ctrl <= CTRL_OR;
                    rf_we <= 1; rf_rd <= 5'd7; rf_wd <= alu_result;
                end

                ALU_XOR: begin
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd2;
                    alu_ctrl <= CTRL_XOR;
                    rf_we <= 1; rf_rd <= 5'd8; rf_wd <= alu_result;
                end

                ALU_SLL: begin
                    // SLL: A=x1, B=x3 (shamt = 5)
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd3;
                    alu_ctrl <= CTRL_SLL;
                    rf_we <= 1; rf_rd <= 5'd9; rf_wd <= alu_result;
                end

                ALU_SRL: begin
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd3;
                    alu_ctrl <= CTRL_SRL;
                    rf_we <= 1; rf_rd <= 5'd10; rf_wd <= alu_result;
                end

                BEQ_CHECK: begin
                    // SUB x1-x1 → Zero should be HIGH → write 1 into x11
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd1;
                    alu_ctrl <= CTRL_SUB;
                    saved_zero <= alu_zero;
                    rf_we <= 1; rf_rd <= 5'd11;
                    rf_wd <= alu_zero ? 32'd1 : 32'd0;
                end

                RAW_WRITE: begin
                    // Write x12 = 0xABCD1234
                    rf_we  <= 1;
                    rf_rd  <= 5'd12;
                    rf_wd  <= 32'hABCD1234;
                end

                RAW_READ: begin
                    // Read x12 – one cycle after write (synchronous RF)
                    rf_rs1 <= 5'd12;
                    // Data will be on ReadData1 after posedge (checked in assertions)
                end

                DONE: ; // sit here

            endcase
        end
    end

    // =========================================================================
    // 7. Next-State Logic – written as a separate combinational block
    //    We also expand WRITE_REGS into three micro-steps using a small counter.
    // =========================================================================
    reg [1:0] wr_cnt;   // sub-step counter for the three initial writes

    always @(posedge clk or posedge rst) begin
        if (rst) wr_cnt <= 0;
        else if (state == WRITE_REGS) wr_cnt <= wr_cnt + 1;
        else wr_cnt <= 0;
    end

    // Parallel write handler for x2, x3 during sub-steps
    // (Separate always block that fires in the same cycle)
    // NB: We override rf_we/rd/wd for sub-steps 1 and 2
    always @(posedge clk) begin
        if (!rst && state == WRITE_REGS) begin
            case (wr_cnt)
                2'd0: begin rf_we <= 1; rf_rd <= 5'd1; rf_wd <= 32'h10101010; end
                2'd1: begin rf_we <= 1; rf_rd <= 5'd2; rf_wd <= 32'h01010101; end
                2'd2: begin rf_we <= 1; rf_rd <= 5'd3; rf_wd <= 32'd5;        end
                default: rf_we <= 0;
            endcase
        end
    end

    always @(*) begin
        case (state)
            IDLE:       next_state = WRITE_REGS;
            WRITE_REGS: next_state = (wr_cnt == 2'd2) ? ALU_ADD : WRITE_REGS;
            ALU_ADD:    next_state = ALU_SUB;
            ALU_SUB:    next_state = ALU_AND;
            ALU_AND:    next_state = ALU_OR;
            ALU_OR:     next_state = ALU_XOR;
            ALU_XOR:    next_state = ALU_SLL;
            ALU_SLL:    next_state = ALU_SRL;
            ALU_SRL:    next_state = BEQ_CHECK;
            BEQ_CHECK:  next_state = RAW_WRITE;
            RAW_WRITE:  next_state = RAW_READ;
            RAW_READ:   next_state = DONE;
            default:    next_state = DONE;
        endcase
    end

    // =========================================================================
    // 8. Assertions / Checker (runs after each state change)
    // =========================================================================
    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input [63:0] label_int;   // just a numeric code for display
        input [31:0] got;
        input [31:0] expected;
        begin
            if (got === expected) begin
                $display("[PASS] State %0d : got=0x%08h  exp=0x%08h", label_int, got, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] State %0d : got=0x%08h  exp=0x%08h", label_int, got, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Monitor – fire after each rising edge when state changes
    reg [3:0] prev_state;
    always @(posedge clk) begin
        prev_state <= state;

        // One cycle after a result has been committed to the RF, check it
        case (prev_state)
            ALU_ADD: begin
                // x4 should hold ADD result = 0x10101010 + 0x01010101 = 0x11111111
                rf_rs1 = 5'd4; #1;
                check(ALU_ADD, rf_rd1, 32'h11111111);
            end
            ALU_SUB: begin
                // x5 = SUB = 0x10101010 - 0x01010101 = 0x0F0F0F0F
                rf_rs1 = 5'd5; #1;
                check(ALU_SUB, rf_rd1, 32'h0F0F0F0F);
            end
            ALU_AND: begin
                // x6 = AND = 0x10101010 & 0x01010101 = 0x00000000
                rf_rs1 = 5'd6; #1;
                check(ALU_AND, rf_rd1, 32'h00000000);
            end
            ALU_OR: begin
                // x7 = OR = 0x10101010 | 0x01010101 = 0x11111111
                rf_rs1 = 5'd7; #1;
                check(ALU_OR, rf_rd1, 32'h11111111);
            end
            ALU_XOR: begin
                // x8 = XOR = 0x10101010 ^ 0x01010101 = 0x11111111
                rf_rs1 = 5'd8; #1;
                check(ALU_XOR, rf_rd1, 32'h11111111);
            end
            ALU_SLL: begin
                // x9 = SLL x1 by 5 = 0x10101010 << 5 = 0x20202200
                rf_rs1 = 5'd9; #1;
                check(ALU_SLL, rf_rd1, 32'h20202200);
            end
            ALU_SRL: begin
                // x10 = SRL x1 by 5 = 0x10101010 >> 5 = 0x00808080
                rf_rs1 = 5'd10; #1;
                check(ALU_SRL, rf_rd1, 32'h00808080);
            end
            BEQ_CHECK: begin
                // x11 should be 1 (BEQ matched)
                rf_rs1 = 5'd11; #1;
                check(BEQ_CHECK, rf_rd1, 32'd1);
            end
            RAW_READ: begin
                // x12 should be 0xABCD1234 (read-after-write next cycle)
                rf_rs1 = 5'd12; #1;
                check(RAW_READ, rf_rd1, 32'hABCD1234);
            end
            DONE: begin
                if (prev_state != DONE) begin   // only print once
                    $display("==================================================");
                    $display("RF_ALU_FSM_tb: %0d PASSED, %0d FAILED", pass_count, fail_count);
                    $display("==================================================");
                    $finish;
                end
            end
        endcase
    end

    // =========================================================================
    // 9. Stimulus Entry Point
    // =========================================================================
    initial begin
        clk = 0; rst = 1;
        repeat (4) @(posedge clk);
        rst = 0;
        // FSM runs autonomously; the monitor above does all checking.
        // Safety timeout
        #10000;
        $display("[TIMEOUT] Simulation did not finish within budget");
        $finish;
    end

endmodule
