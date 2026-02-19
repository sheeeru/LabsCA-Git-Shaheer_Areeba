`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2026 10:09:17 AM
// Design Name: 
// Module Name: top_fsm
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

module top_fsm_system (
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // DEBOUNCER (Cleans up the physical reset button signal)
    wire rst_clean;
    debouncer rst_db (.clk(clk),
        .pbin(pbin), .pbout(rst_clean)); //generated a clean signal

    wire [31:0] switch_data; // hold the value read from the switches
    
    leds switch_reader (.clk(clk), .rst(rst_clean),
        .btns(16'd0),// Not used for this FSM
        .writeData(32'd0),// We don't write to switches
        .writeEnable(1'b0),// Disabled
        .readEnable(1'b1),// Always ON so we can monitor switches
        .memAddress(30'd0),       
        .switches(physical_sw),// Plug in the physical switches
        .readData(switch_data)// output data 
        );

    reg [31:0] led_write_data = 32'd0; // counter value here
    
    switches led_writer (.clk(clk), .rst(rst_clean),
        .writeData(led_write_data),
        .writeEnable(1'b1),         // Always ON so LEDs update instantly
        .readEnable(1'b0), .memAddress(30'd0),
        .readData(),                // Ignored
        .leds(physical_leds)      
    );
    wire slow_clk;
    clock_divider ticker (
        .clk_in(clk),          // Feed it the 100MHz fast clock
        .rst(rst_clean),       // Feed it the clean reset signal
        .clk_out(slow_clk)     // It spits out the 1Hz slow clock!
    );
    // FSM AND COUNTER LOGIC
    localparam WAIT  = 1'b0;
    localparam COUNT = 1'b1;
    reg state = WAIT;
    reg [15:0] counter = 0;

    // Synchronus
    always @(posedge slow_clk or posedge rst_clean) begin
        // SYNCHRONOUS RESET
        if (rst_clean == 1'b1) begin
            state <= WAIT;
            counter <= 16'd0;
            led_write_data <= 32'd0; // Turn off LEDs
        end 
        else begin
            case (state)
                // STATE 0: WAIT (Idling and Monitoring)
                WAIT: begin
                    // If switches are NOT zero, latch them and start
                    if (switch_data[15:0] != 16'd0) begin
                        counter <= switch_data[15:0];// Latch to counter
                        led_write_data <= switch_data;// Send to LEDs
                        state <= COUNT;// Transition State
                    end 
                    else begin
                        counter <= 16'd0;
                        led_write_data <= 32'd0;
                    end
                end
                // STATE 1: COUNT (Decrementing until 0)
                COUNT: begin
                    if (counter > 16'd0) begin
                        counter <= counter - 16'd1;// Decrement
                        led_write_data <= (counter - 16'd1);// Update LEDs
                    end
                    // hit zero so, go back to WAIT
                    if (counter == 16'd1 || counter == 16'd0) begin
                        state <= WAIT;
                    end
                end
            endcase
        end
    end
endmodule