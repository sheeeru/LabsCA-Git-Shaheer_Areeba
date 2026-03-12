`timescale 1ns / 1ps

module top_rf_alu (
    input  wire        clk,
    input  wire        pbin,
    input  wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // =========================================================================
    // 1. Debounce the reset button  (Lab 5 debouncer reused)
    // =========================================================================
    wire rst_clean;
    debouncer rst_db (
        .clk  (clk),
        .pbin (pbin),
        .pbout(rst_clean)
    );

    // =========================================================================
    // 2. Read physical switches via Lab 5 leds module
    //    (confusingly named, but it is the switch-reading wrapper from Lab 5)
    // =========================================================================
    wire [31:0] sw_data;
    leds switch_reader (
        .clk        (clk),
        .rst        (rst_clean),
        .btns       (16'd0),
        .writeData  (32'd0),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress (30'd0),
        .switches   (physical_sw),
        .readData   (sw_data)
    );

    // =========================================================================
    // 3. Internal buses connecting the three functional blocks
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
    // 4. RegisterFile  (Lab 7)
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
    // 5. ALU  (Lab 6 alu_32bit reused directly)
    //    In demo mode the FSM supplies A and B via the register file outputs.
    //    Fixed constants 0x10101010 / 0x01010101 match the Lab 6 convention.
    // =========================================================================
    // The FSM decides which registers to read; their values flow into the ALU.
    alu_32bit ALU (
        .A         (rf_rd1),
        .B         (rf_rd2),
        .ALUControl(fsm_alu_ctrl),
        .ALUResult (alu_result),
        .Zero      (alu_zero)
    );

    // =========================================================================
    // 6. FSM  (rf_alu_fsm – defined below in this file)
    // =========================================================================
    rf_alu_fsm FSM (
        .clk         (clk),
        .rst         (rst_clean),
        .manual_mode (sw_data[15]),          // SW15 → manual override
        .manual_op   (sw_data[3:0]),         // SW[3:0] → ALU op in manual mode
        .alu_result  (alu_result),
        .alu_zero    (alu_zero),
        // RF control outputs
        .rf_we       (fsm_we),
        .rf_rs1      (fsm_rs1),
        .rf_rs2      (fsm_rs2),
        .rf_rd       (fsm_rd),
        .rf_wd       (fsm_wd),
        // ALU control output
        .alu_ctrl    (fsm_alu_ctrl),
        // Status
        .state_out   (fsm_state_out)
    );

    // =========================================================================
    // 7. Drive LEDs via Lab 5 switches module
    // =========================================================================
    reg [31:0] led_data;
    always @(*) begin
        // LED[15]     = Zero flag
        // LED[14:11]  = FSM state
        // LED[10:0]   = ALU result[10:0]
        led_data = {16'd0,
                    alu_zero,
                    fsm_state_out,
                    alu_result[10:0]};
    end

    switches led_writer (
        .clk        (clk),
        .rst        (rst_clean),
        .writeData  (led_data),
        .writeEnable(1'b1),
        .readEnable (1'b0),
        .memAddress (30'd0),
        .readData   (),
        .leds       (physical_leds)
    );

endmodule


////////////////////////////////////////////////////////////////////////////////
// Sub-module : rf_alu_fsm
// Drives the RegisterFile and ALU through a deterministic demo sequence,
// then loops.  Also supports a live "manual mode" where SW[3:0] selects the
// ALU operation on the fly (the FSM still supplies the two fixed operands from
// the register file).
////////////////////////////////////////////////////////////////////////////////
module rf_alu_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire        manual_mode,
    input  wire [3:0]  manual_op,
    input  wire [31:0] alu_result,
    input  wire        alu_zero,
    // Register-File control
    output reg         rf_we,
    output reg  [4:0]  rf_rs1,
    output reg  [4:0]  rf_rs2,
    output reg  [4:0]  rf_rd,
    output reg  [31:0] rf_wd,
    // ALU control
    output reg  [3:0]  alu_ctrl,
    // Status
    output reg  [3:0]  state_out
);

    // -------------------------------------------------------------------------
    // ALU op codes (must match Lab 6 alu_32bit)
    // -------------------------------------------------------------------------
    localparam [3:0]
        CTRL_AND = 4'b0000,
        CTRL_OR  = 4'b0001,
        CTRL_ADD = 4'b0010,
        CTRL_SUB = 4'b0110,
        CTRL_XOR = 4'b0100,
        CTRL_SLL = 4'b1000,
        CTRL_SRL = 4'b1001;

    // -------------------------------------------------------------------------
    // FSM States
    // -------------------------------------------------------------------------
    localparam [3:0]
        S_INIT0   = 4'd0,   // write x1 = 0x10101010
        S_INIT1   = 4'd1,   // write x2 = 0x01010101
        S_INIT2   = 4'd2,   // write x3 = 5  (shift amount)
        S_ADD     = 4'd3,   // x4  = ADD(x1, x2)
        S_SUB     = 4'd4,   // x5  = SUB(x1, x2)
        S_AND     = 4'd5,   // x6  = AND(x1, x2)
        S_OR      = 4'd6,   // x7  = OR(x1, x2)
        S_XOR     = 4'd7,   // x8  = XOR(x1, x2)
        S_SLL     = 4'd8,   // x9  = SLL(x1, x3)
        S_SRL     = 4'd9,   // x10 = SRL(x1, x3)
        S_BEQ     = 4'd10,  // x11 = Zero flag (x1 SUB x1)
        S_MANUAL  = 4'd11,  // live manual mode (no RF write)
        S_DONE    = 4'd12;  // loop back to S_INIT0

    reg [3:0] state;

    // Expose state on output pins for LED display
    always @(*) state_out = state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= S_INIT0;
            rf_we    <= 0;
            rf_rs1   <= 0; rf_rs2 <= 0; rf_rd <= 0;
            rf_wd    <= 0;
            alu_ctrl <= CTRL_ADD;
        end else if (manual_mode) begin
            // ----------------------------------------------------------------
            // Manual Mode: present x1 and x2 to the ALU with the user-chosen op
            // ----------------------------------------------------------------
            state    <= S_MANUAL;
            rf_we    <= 0;
            rf_rs1   <= 5'd1;
            rf_rs2   <= 5'd2;
            alu_ctrl <= manual_op;
        end else begin
            case (state)
                // ------------------------------------------------------------
                // Initialisation – write constants into x1, x2, x3
                // ------------------------------------------------------------
                S_INIT0: begin
                    rf_we <= 1; rf_rd <= 5'd1; rf_wd <= 32'h10101010;
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2;
                    alu_ctrl <= CTRL_ADD;
                    state <= S_INIT1;
                end
                S_INIT1: begin
                    rf_we <= 1; rf_rd <= 5'd2; rf_wd <= 32'h01010101;
                    state <= S_INIT2;
                end
                S_INIT2: begin
                    rf_we <= 1; rf_rd <= 5'd3; rf_wd <= 32'd5;
                    state <= S_ADD;
                end

                // ------------------------------------------------------------
                // ALU operations – read RF ports, compute, write result
                // The ALU is combinational so the result is available
                // in the same cycle as rs1/rs2 are set.
                // ------------------------------------------------------------
                S_ADD: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_ADD;
                    rf_we  <= 1;    rf_rd   <= 5'd4; rf_wd    <= alu_result;
                    state  <= S_SUB;
                end
                S_SUB: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_SUB;
                    rf_we  <= 1;    rf_rd   <= 5'd5; rf_wd    <= alu_result;
                    state  <= S_AND;
                end
                S_AND: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_AND;
                    rf_we  <= 1;    rf_rd   <= 5'd6; rf_wd    <= alu_result;
                    state  <= S_OR;
                end
                S_OR: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_OR;
                    rf_we  <= 1;    rf_rd   <= 5'd7; rf_wd    <= alu_result;
                    state  <= S_XOR;
                end
                S_XOR: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd2; alu_ctrl <= CTRL_XOR;
                    rf_we  <= 1;    rf_rd   <= 5'd8; rf_wd    <= alu_result;
                    state  <= S_SLL;
                end
                S_SLL: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd3; alu_ctrl <= CTRL_SLL;
                    rf_we  <= 1;    rf_rd   <= 5'd9; rf_wd    <= alu_result;
                    state  <= S_SRL;
                end
                S_SRL: begin
                    rf_rs1 <= 5'd1; rf_rs2 <= 5'd3; alu_ctrl <= CTRL_SRL;
                    rf_we  <= 1;    rf_rd   <= 5'd10; rf_wd   <= alu_result;
                    state  <= S_BEQ;
                end

                // ------------------------------------------------------------
                // BEQ-style check: SUB x1-x1 should set Zero flag
                // Write 1 into x11 if Zero is asserted
                // ------------------------------------------------------------
                S_BEQ: begin
                    rf_rs1   <= 5'd1; rf_rs2 <= 5'd1; alu_ctrl <= CTRL_SUB;
                    rf_we    <= 1;
                    rf_rd    <= 5'd11;
                    rf_wd    <= alu_zero ? 32'd1 : 32'd0;
                    state    <= S_DONE;
                end

                // ------------------------------------------------------------
                // Loop
                // ------------------------------------------------------------
                S_DONE: begin
                    rf_we <= 0;
                    state <= S_INIT0;   // restart demo
                end

                S_MANUAL: begin
                    rf_we  <= 0;
                    state  <= S_MANUAL;
                end

                default: state <= S_INIT0;
            endcase
        end
    end

endmodule
