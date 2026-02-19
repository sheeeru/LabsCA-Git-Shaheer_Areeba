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


module tb_fsm_system();
    reg clk; reg pbin; reg [15:0] physical_sw; wire [15:0] physical_leds;

    top_fsm_system uut (.clk(clk),.pbin(pbin),
        .physical_sw(physical_sw),.physical_leds(physical_leds));

    always begin
        #5 clk = ~clk; 
    end

    initial begin
        clk = 0;
        pbin = 1;        
        physical_sw = 16'd0; 
        #20;
        pbin = 0;
        #20;
        
        // --- TEST 1: 
        physical_sw = 16'd4;
        #10; 
        physical_sw = 16'd0; 
        #100;

        // --- TEST 2:
        physical_sw = 16'd10;
        #10;
        physical_sw = 16'd0;
        #30;
        pbin = 1;
        #20;
        pbin = 0; 
        #50;
        $finish;
    end
endmodule