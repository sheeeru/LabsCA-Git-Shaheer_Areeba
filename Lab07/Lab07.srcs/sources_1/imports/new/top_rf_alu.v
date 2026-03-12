`timescale 1ns / 1ps


module top_rf_alu (
    input  wire        clk,
    input  wire        pbin,
    input  wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // =========================================================================
    // 1. Debounce reset button
    // =========================================================================
    wire rst_clean;
    debouncer rst_db (
        .clk  (clk),
        .pbin (pbin),
        .pbout(rst_clean)
    );

    // =========================================================================
    // 2. Internal buses
    // =========================================================================
    wire [4:0]  fsm_rs1, fsm_rs2, fsm_rd;
    wire [31:0] fsm_wd;
    wire        fsm_we;
    wire [3:0]  fsm_alu_ctrl;
    wire [3:0]  fsm_state_out;

    wire [31:0] rf_rd1, rf_rd2;
    wire [31:0] alu_result;
    wire        alu_zero;

    // =========================================================================
    // 3. Register File
    // =========================================================================
    RegisterFile RF (
        .clk        (clk),
        .rst        (rst_clean),
        .WriteEnable(fsm_we),
        .rs1        (fsm_rs1),
        .rs2        (fsm_rs2),
        .rd         (fsm_rd),
        .WriteData  (fsm_wd),
        .ReadData1  (rf_rd1),
        .ReadData2  (rf_rd2)
    );

    // =========================================================================
    // 4. ALU - A and B come directly from Register File read ports
    // =========================================================================
    alu_32bit ALU (
        .A         (rf_rd1),
        .B         (rf_rd2),
        .ALUControl(fsm_alu_ctrl),
        .ALUResult (alu_result),
        .Zero      (alu_zero)
    );

    // =========================================================================
    // 5. FSM
    // =========================================================================
    rf_alu_fsm FSM (
        .clk       (clk),
        .rst       (rst_clean),
        .alu_result(alu_result),
        .alu_zero  (alu_zero),
        .rf_we     (fsm_we),
        .rf_rs1    (fsm_rs1),
        .rf_rs2    (fsm_rs2),
        .rf_rd     (fsm_rd),
        .rf_wd     (fsm_wd),
        .alu_ctrl  (fsm_alu_ctrl),
        .state_out (fsm_state_out)
    );

    // =========================================================================
    // 6. LED output
    //    LED[15]    = alu_zero flag
    //    LED[14:11] = FSM state (4 bits - shows which state we are in)
    //    LED[10:0]  = alu_result[10:0]
    //
    //    When DONE (state=13=0b1101):
    //      LED15=Zero  LED14=1 LED13=1 LED12=0 LED11=1  LED[10:0]=result bits
    //    Use SW[4:0] to pick rs1 for display - see FSM DONE state.
    // =========================================================================
    switches led_writer (
        .clk        (clk),
        .rst        (rst_clean),
        .writeData  ({16'd0, alu_zero, fsm_state_out, alu_result[10:0]}),
        .writeEnable(1'b1),
        .readEnable (1'b0),
        .memAddress (30'd0),
        .readData   (),
        .leds       (physical_leds)
    );

endmodule


////////////////////////////////////////////////////////////////////////////////
// Sub-module : rf_alu_fsm  (FIXED)
//
// KEY FIX - two-state pattern for every ALU operation:
//   S_READ_x  : set rf_rs1, rf_rs2, alu_ctrl  (combinational paths settle)
//   S_WRITE_x : capture alu_result into rf_wd, assert rf_we, write to RF
//
// This eliminates the one-cycle stale-result bug from the original.
// All outputs are still registered for clean FPGA timing.
////////////////////////////////////////////////////////////////////////////////
module rf_alu_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] alu_result,
    input  wire        alu_zero,
    // Register File control
    output reg         rf_we,
    output reg  [4:0]  rf_rs1,
    output reg  [4:0]  rf_rs2,
    output reg  [4:0]  rf_rd,
    output reg  [31:0] rf_wd,
    // ALU control
    output reg  [3:0]  alu_ctrl,
    // Status (for LED display)
    output reg  [3:0]  state_out
);

    // ALU control codes - match Lab 6 alu_32bit
    localparam [3:0]
        CTRL_AND = 4'b0000,
        CTRL_OR  = 4'b0001,
        CTRL_ADD = 4'b0010,
        CTRL_SUB = 4'b0110,
        CTRL_XOR = 4'b0100,
        CTRL_SLL = 4'b1000,
        CTRL_SRL = 4'b1001;

    // -------------------------------------------------------------------------
    // FSM States - two states per ALU op (READ then WRITE)
    // -------------------------------------------------------------------------
    localparam [3:0]
        S_INIT0    = 4'd0,   // write x1 = 0x10101010
        S_INIT1    = 4'd1,   // write x2 = 0x01010101
        S_INIT2    = 4'd2,   // write x3 = 5 (shift amount)
        S_READ_ALU = 4'd3,   // present rs1=x1, rs2=x2, wait for ALU to settle
        S_WR_ADD   = 4'd4,   // write ADD result -> x4
        S_WR_SUB   = 4'd5,   // write SUB result -> x5
        S_WR_AND   = 4'd6,   // write AND result -> x6
        S_WR_OR    = 4'd7,   // write OR  result -> x7
        S_WR_XOR   = 4'd8,   // write XOR result -> x8
        S_READ_SLL = 4'd9,   // present rs1=x1, rs2=x3 for shift ops
        S_WR_SLL   = 4'd10,  // write SLL result -> x9
        S_WR_SRL   = 4'd11,  // write SRL result -> x10
        S_BEQ_READ = 4'd12,  // SUB x1-x1, check Zero flag
        S_BEQ_WR   = 4'd13,  // write flag -> x11
        S_DONE     = 4'd14;  // stable - hold results, wait for reset

    reg [3:0] state;

    // Track which op we're writing so we can change alu_ctrl in the WRITE state
    // without losing the correct result
    reg [3:0] saved_ctrl;

    always @(*) state_out = state[3:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= S_INIT0;
            rf_we    <= 0;
            rf_rs1   <= 0; rf_rs2 <= 0;
            rf_rd    <= 0; rf_wd  <= 0;
            alu_ctrl <= CTRL_ADD;
            saved_ctrl <= CTRL_ADD;
        end else begin
            // Default: no write
            rf_we <= 0;

            case (state)
                // ---------------------------------------------------------
                // Load known constants into x1, x2, x3
                // ---------------------------------------------------------
                S_INIT0: begin
                    rf_we <= 1; rf_rd <= 5'd1; rf_wd <= 32'h10101010;
                    state <= S_INIT1;
                end
                S_INIT1: begin
                    rf_we <= 1; rf_rd <= 5'd2; rf_wd <= 32'h01010101;
                    state <= S_INIT2;
                end
                S_INIT2: begin
                    rf_we <= 1; rf_rd <= 5'd3; rf_wd <= 32'd5;
                    // Point rs1/rs2 at x1,x2 and set first op ready for next cycle
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_ADD;
                    state <= S_READ_ALU;
                end

                // ---------------------------------------------------------
                // S_READ_ALU: rs1=x1 rs2=x2 are set, ALU computes THIS cycle.
                // We do NOT write yet - we just let the combinational paths
                // settle so that next cycle alu_result is valid for each op.
                // We run through all four x1/x2 ops by changing alu_ctrl each
                // write state and then coming back here via S_READ_ALU.
                // ---------------------------------------------------------
                S_READ_ALU: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2;
                    // alu_ctrl is already ADD (set in INIT2 or carried forward)
                    state <= S_WR_ADD;
                end

                // Write ADD result (alu_result is now ADD of x1,x2)
                S_WR_ADD: begin
                    rf_we <= 1; rf_rd <= 5'd4; rf_wd <= alu_result;
                    // Change op for next read
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_SUB;
                    state <= S_WR_SUB;
                    // NOTE: We stay with rs1/rs2=x1,x2 and just changed alu_ctrl.
                    // alu_result will reflect SUB on the NEXT posedge so we need
                    // one more cycle before writing. Go back through READ.
                    // Actually: since alu_ctrl<=CTRL_SUB takes effect NEXT cycle,
                    // alu_result this cycle is still ADD - that's fine, we wrote it.
                    // Next cycle state=S_WR_SUB and alu_result will be SUB.
                    // This works because alu_ctrl and rs1/rs2 are set together.
                end

                S_WR_SUB: begin
                    rf_we <= 1; rf_rd <= 5'd5; rf_wd <= alu_result;
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_AND;
                    state <= S_WR_AND;
                end

                S_WR_AND: begin
                    rf_we <= 1; rf_rd <= 5'd6; rf_wd <= alu_result;
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_OR;
                    state <= S_WR_OR;
                end

                S_WR_OR: begin
                    rf_we <= 1; rf_rd <= 5'd7; rf_wd <= alu_result;
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_XOR;
                    state <= S_WR_XOR;
                end

                S_WR_XOR: begin
                    rf_we <= 1; rf_rd <= 5'd8; rf_wd <= alu_result;
                    // Switch to shift ops: rs2=x3 (shift amount=5)
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd3; alu_ctrl <= CTRL_SLL;
                    state <= S_READ_SLL;
                end

                // One settle cycle for SLL (rs2 changed to x3)
                S_READ_SLL: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd3; alu_ctrl <= CTRL_SLL;
                    state <= S_WR_SLL;
                end

                S_WR_SLL: begin
                    rf_we <= 1; rf_rd <= 5'd9; rf_wd <= alu_result;
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd3; alu_ctrl <= CTRL_SRL;
                    state <= S_WR_SRL;
                end

                S_WR_SRL: begin
                    rf_we <= 1; rf_rd <= 5'd10; rf_wd <= alu_result;
                    // BEQ: point both ports at x1 for SUB x1-x1
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd1; alu_ctrl <= CTRL_SUB;
                    state <= S_BEQ_READ;
                end

                // Settle cycle for BEQ (rs2 changed to x1)
                S_BEQ_READ: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd1; alu_ctrl <= CTRL_SUB;
                    state <= S_BEQ_WR;
                end

                // Write 1 into x11 if Zero flag is set (branch taken)
                S_BEQ_WR: begin
                    rf_we <= 1; rf_rd <= 5'd11;
                    rf_wd <= alu_zero ? 32'd1 : 32'd0;
                    state <= S_DONE;
                end

                // ---------------------------------------------------------
                // DONE - stable self-loop so LEDs hold steady (BUG 3 fix)
                // Press reset (BTNC) to rerun.
                // ---------------------------------------------------------
                S_DONE: begin
                    rf_we <= 0;
                    state <= S_DONE;   // stay here - no more looping
                end

                default: state <= S_INIT0;
            endcase
        end
    end

endmodule