`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: final_top
// Description: Complete top-level module with FSM and debouncer
//////////////////////////////////////////////////////////////////////////////////

module final_top (
    input        clk,       // 100 MHz clock
    input        rst,       // Reset button
    input  [15:0] sw,       // 16 switches
    output [15:0] led       // 16 LEDs
);

    //========================================================================
    // DEBOUNCER - Clean the reset signal
    // FIX: Updated port names to match pbin and pbout from your debouncer.v
    //========================================================================
    wire rst_debounced;
    
    debouncer rst_debouncer (
        .clk   (clk),
        .pbin  (rst),
        .pbout (rst_debounced)
    );

    //========================================================================
    // FSM State Encoding & Register
    //========================================================================
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DISPLAY = 2'b10;
    
    reg [1:0] state, next_state;

    always @(posedge clk or posedge rst_debounced) begin
        if (rst_debounced)
            state <= IDLE;
        else
            state <= next_state;
    end

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

    //========================================================================
    // Memory-Mapped I/O Modules (Disconnected from physical LEDs for this test)
    //========================================================================
    wire [31:0] cpu_writeData = 32'd0; 
    wire        cpu_writeEnable = 1'b0;
    wire        cpu_readEnable = 1'b0;
    wire [29:0] cpu_memAddress = 30'd0;
    
    wire [31:0] mmio_readData_sw;
    wire [31:0] mmio_readData_led;
    wire [15:0] internal_led_dummy; // Dummy wire so switches module doesn't drive physical LEDs

    switches mmio_switches_inst (
        .clk         (clk),
        .rst         (rst_debounced),
        .writeData   (cpu_writeData),
        .writeEnable (cpu_writeEnable),
        .readEnable  (cpu_readEnable),
        .memAddress  (cpu_memAddress),
        .readData    (mmio_readData_sw),
        .leds        (internal_led_dummy) // Prevent short circuit
    );

    leds mmio_leds_inst (
        .clk         (clk),
        .rst         (rst_debounced),
        .btns        (16'd0),            
        .writeData   (cpu_writeData),
        .writeEnable (cpu_writeEnable),
        .readEnable  (cpu_readEnable),
        .memAddress  (cpu_memAddress),
        .switches    (sw_sampled),      
        .readData    (mmio_readData_led)
    );

endmodule