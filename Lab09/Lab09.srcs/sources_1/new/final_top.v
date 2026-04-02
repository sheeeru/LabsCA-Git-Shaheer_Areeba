`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: final_top
// Description: Complete top-level module with FSM and debouncer
//              Matches the schematic shown in lab requirements
//
// Architecture:
//   final_top
//     ??> debouncer (cleans reset signal)
//     ??> FSM (IDLE ? COMPUTE ? DISPLAY)
//     ??> switch sampling logic
//     ??> top_control (main_control + alu_control)
//     ??> LED output register
//////////////////////////////////////////////////////////////////////////////////

module final_top (
    input        clk,       // 100 MHz clock
    input        rst,       // Reset button (will be debounced)
    input  [15:0] sw,       // 16 switches
    output [15:0] led       // 16 LEDs
);

    //========================================================================
    // DEBOUNCER - Clean the reset signal
    //========================================================================
    wire rst_debounced;
    
    debouncer rst_debouncer (
        .clk   (clk),
        .btn_in (rst),
        .btn_out(rst_debounced)
    );

    //========================================================================
    // FSM State Encoding
    //========================================================================
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DISPLAY = 2'b10;
    
    reg [1:0] state, next_state;

    //========================================================================
    // FSM State Register
    //========================================================================
    always @(posedge clk or posedge rst_debounced) begin
        if (rst_debounced)
            state <= IDLE;
        else
            state <= next_state;
    end

    //========================================================================
    // FSM Next State Logic
    //========================================================================
    always @(*) begin
        case (state)
            IDLE:    next_state = COMPUTE;
            COMPUTE: next_state = DISPLAY;
            DISPLAY: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    //========================================================================
    // Switch Sampling (sample in IDLE state)
    //========================================================================
    reg [15:0] sw_sampled;
    
    always @(posedge clk or posedge rst_debounced) begin
        if (rst_debounced)
            sw_sampled <= 16'b0;
        else if (state == IDLE)
            sw_sampled <= sw;
    end

    //========================================================================
    // Control Path - instantiate top_control
    //========================================================================
    wire [15:0] control_output;
    
    top_control control_path (
        .clk (clk),
        .rst (rst_debounced),
        .sw  (sw_sampled),
        .led (control_output)
    );

    //========================================================================
    // LED Output Register (latch in DISPLAY state)
    //========================================================================
    reg [15:0] led_reg;
    
    always @(posedge clk or posedge rst_debounced) begin
        if (rst_debounced)
            led_reg <= 16'b0;
        else if (state == DISPLAY)
            led_reg <= control_output;
    end

    //========================================================================
    // LED Output Assignment
    //========================================================================
    assign led = led_reg;

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Module: debouncer
// Description: Debounces button inputs to provide clean signals
//////////////////////////////////////////////////////////////////////////////////
module debouncer (
    input  clk,
    input  btn_in,
    output reg btn_out
);
    
    // Debounce counter - counts to ~10ms at 100MHz
    reg [19:0] counter;
    reg btn_sync_0, btn_sync_1;
    
    // Synchronize button input to clock domain
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end
    
    // Debounce logic
    always @(posedge clk) begin
        if (btn_sync_1 != btn_out) begin
            counter <= counter + 1;
            if (counter == 20'd1000000)  // ~10ms at 100MHz
                btn_out <= btn_sync_1;
        end
        else begin
            counter <= 20'd0;
        end
    end
    
endmodule