`timescale 1ns / 1ps

module top(input wire clk, input wire rst, input wire [15:0] switches, output wire [15:0] leds);
    wire rst_clean;
    reg [31:0] address;
    reg readEnable, writeEnable;
    reg [31:0] writeData;
    wire [31:0] readData;
    reg [31:0] readReg;

    reg sw8_prev, sw9_prev, sw10_prev;
    wire sw8_rise = switches[8] & ~sw8_prev;
    wire sw9_rise = switches[9] & ~sw9_prev;
    wire sw10_rise = switches[10] & ~sw10_prev;

    debouncer db(.clk(clk), .pbin(rst), .pbout(rst_clean));
    addressDecoderTop adt(.clk(clk), .rst(rst_clean), .address(address), .readEnable(readEnable), .writeEnable(writeEnable), .writeData(writeData), .switches(switches[7:0]), .readData(readData), .leds(leds));

    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean) begin
            address <= 0; readEnable <= 0; writeEnable <= 0; writeData <= 0; readReg <= 0;
            sw8_prev <= 0; sw9_prev <= 0; sw10_prev <= 0;
        end else begin
            sw8_prev <= switches[8];
            sw9_prev <= switches[9];
            sw10_prev <= switches[10];
            readEnable <= 0; writeEnable <= 0;

            if (sw8_rise) begin
                address <= {27'b0, switches[15:11]}; writeData <= {24'b0, switches[7:0]}; writeEnable <= 1;
            end else if (sw9_rise) begin
                address <= {27'b0, switches[15:11]}; readEnable <= 1;
            end else if (sw10_rise) begin
                address <= 32'd512; writeData <= readReg; writeEnable <= 1;
            end

            if (readEnable) readReg <= readData;
        end
    end
endmodule