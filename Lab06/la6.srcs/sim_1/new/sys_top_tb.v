`timescale 1ns / 1ps
module sys_top_tb;
    reg clk;
    reg pbin;
    reg [15:0] physical_sw;
    wire [15:0] physical_leds;
    sys_top uut (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .physical_leds(physical_leds)
    );
    always begin
        #5 clk = ~clk; 
    end
    initial begin
        clk = 0;
        pbin = 1;              
        physical_sw = 16'd0;
        #50;
        pbin = 0;
        #50;
        physical_sw = 16'b0000_0000_0000_0000;
        #40;
        physical_sw = 16'b0000_0000_0000_0001;
        #40;
        physical_sw = 16'b0000_0000_0000_0010;
        #40;
        physical_sw = 16'b0000_0000_0000_0100;
        #40;
        physical_sw = 16'b0000_0000_0000_0110;
        #40;
        physical_sw = 16'b0000_0000_0000_1000;
        #40;
        physical_sw = 16'b0000_0000_0000_1001;
        #40;
        $finish;
    end
endmodule