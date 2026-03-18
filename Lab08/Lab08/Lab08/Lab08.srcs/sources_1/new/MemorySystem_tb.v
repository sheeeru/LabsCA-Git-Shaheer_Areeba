`timescale 1ns / 1ps
module MemorySystem_tb;

reg clk = 0;
always #5 clk = ~clk;

reg rst, readEnable, writeEnable;
reg [31:0] address, writeData;
reg [15:0] switches;
wire [31:0] readData;
wire [15:0] leds;

addressDecoderTop adt(.clk(clk), .rst(rst), .address(address), .readEnable(readEnable), .writeEnable(writeEnable), .writeData(writeData), .switches(switches), .readData(readData), .leds(leds));

initial begin
    rst = 1; address = 0; readEnable = 0; writeEnable = 0; writeData = 0; switches = 16'hA55A;
    @(posedge clk); @(negedge clk); rst = 0;

    // Write to Data Memory
    @(negedge clk); address = 32'd4; writeData = 32'hDEADBEEF; writeEnable = 1; readEnable = 0;
    @(posedge clk); @(negedge clk); writeEnable = 0;

    // Read from Data Memory
    @(negedge clk); address = 32'd4; readEnable = 1; writeEnable = 0;
    @(posedge clk); @(negedge clk); readEnable = 0;

    // Write to LEDs
    @(negedge clk); address = 32'd512; writeData = 32'h000000F3; writeEnable = 1; readEnable = 0;
    @(posedge clk); @(negedge clk); writeEnable = 0;

    // Read from Switches
    @(negedge clk); address = 32'd768; readEnable = 1; writeEnable = 0;
    @(posedge clk); @(negedge clk); readEnable = 0;
    repeat(4) @(posedge clk);
    
    // After LED write
    @(negedge clk); address = 32'd512; writeData = 32'h000000F3; writeEnable = 1;
    $display("LED write: address[9:8] = %b", address[9:8]); // should print 01
    
    // After switch read  
    @(negedge clk); address = 32'd768; readEnable = 1;
    $display("SW read:   address[9:8] = %b", address[9:8]); // should print 10
    
end

endmodule