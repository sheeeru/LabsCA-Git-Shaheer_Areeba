`timescale 1ns / 1ps

// Lab 8 — Switches peripheral
// Per instructor swap: drives physical LEDs
// Activated by LEDWrite when address[9:8]=10 → use address 32'd512

module switches (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] writeData,
    input  wire        writeEnable,
    input  wire        readEnable,
    input  wire [29:0] memAddress,
    output reg  [31:0] readData,
    output reg  [15:0] leds
);
    always @(posedge clk) begin
        if (rst) begin
            leds     <= 16'd0;
            readData <= 32'd0;
        end else if (writeEnable) begin
            leds     <= writeData[15:0];
            readData <= 32'd0;
        end
    end
endmodule
