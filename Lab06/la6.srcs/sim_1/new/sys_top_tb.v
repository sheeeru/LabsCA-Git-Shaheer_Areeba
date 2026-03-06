`timescale 1ns / 1ps

module sys_top_tb;

    // Inputs
    reg clk;
    reg pbin;
    reg [15:0] physical_sw;

    // Outputs
    wire [15:0] physical_leds;

    // Instantiate the Top Level Module
    sys_top uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds)
    );

    // 100 MHz Clock Generation (10ns period)
    always begin
        #5 clk = ~clk; 
    end

    initial begin
        // --- System Startup ---
        clk = 0;
        pbin = 1;              // Hold down the reset button
        physical_sw = 16'd0;   // All switches down
        
        #50;                   // Wait 50ns
        pbin = 0;              // Release the reset button
        #50;
        
        // --- Test 1: AND Operation ---
        // Switches = 0000 (AND). 
        // Fixed A and B inside are 10101010 and 01010101. Result should be 0.
        // LED 15 (Zero flag) should turn ON.
        physical_sw = 16'b0000_0000_0000_0000;
        #40; // Wait a few clock cycles for the FSM to cycle through states
        
        // --- Test 2: ADD Operation ---
        // Switches = 0010 (ADD). 
        physical_sw = 16'b0000_0000_0000_0010;
        #40;
        
        // --- Test 3: SUB Operation ---
        // Switches = 0110 (SUB). 
        physical_sw = 16'b0000_0000_0000_0110;
        #40;

        // --- Test 4: SRL (Shift Right) ---
        // Switches = 1001 (SRL). 
        physical_sw = 16'b0000_0000_0000_1001;
        #40;

        $finish;
    end

endmodule