`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2026 10:12:48 AM
// Design Name: 
// Module Name: tb_top_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_fsm_system();
    reg clk; 
    reg pbin; 
    reg [15:0] physical_sw; 
    wire [15:0] physical_leds;

    top_fsm_system uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds)
    );

    // 100MHz Fast Clock Heartbeat
    always begin
        #5 clk = ~clk; 
    end

    initial begin
        // --- STARTUP ---
        clk = 0;
        pbin = 1;        // Hold down Reset
        physical_sw = 16'd0; 
        
        // Wait a few fast clock cycles, then release reset
        #50;
        pbin = 0;
        
        // --- TEST 1: The Natural Countdown ---
        physical_sw = 16'd4;
        
        // Wait until the FSM's slow clock ticks so it can grab the '4'
        @(posedge uut.slow_clk);
        #1; // Tiny delay to let the wires settle
        
        physical_sw = 16'd0; // Turn switches off
        
        // Tell the testbench to wait for 6 slow clock ticks
        // It will count: 4 -> 3 -> 2 -> 1 -> WAIT
        repeat(6) @(posedge uut.slow_clk);

        // --- TEST 2: The Emergency Stop ---
        physical_sw = 16'd10;
        @(posedge uut.slow_clk);
        #1;
        physical_sw = 16'd0;
        
        // Let it count down exactly 3 times (10 -> 9 -> 8)
        repeat(3) @(posedge uut.slow_clk);
        
        // SMASH THE RESET BUTTON!
        pbin = 1;
        #50; // Hold it for a bit
        pbin = 0; 
        
        // Wait a couple more slow ticks to prove the LEDs stay OFF
        repeat(2) @(posedge uut.slow_clk);

        // End simulation
        $finish;
    end
endmodule