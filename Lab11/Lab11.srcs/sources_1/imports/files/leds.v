`timescale 1ns / 1ps

module leds (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] btns,
    input  wire [31:0] writeData,
    input  wire        writeEnable,
    input  wire        readEnable,
    input  wire [29:0] memAddress,
    input  wire [15:0] switches,
    output wire [31:0] readData
);
    assign readData = (readEnable) ? {16'd0, switches} : 32'd0;
endmodule
