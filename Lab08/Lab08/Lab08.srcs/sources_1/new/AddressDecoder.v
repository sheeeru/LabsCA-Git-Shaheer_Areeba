`timescale 1ns / 1ps

module AddressDecoder (
    // --- Inputs ---
    input  wire [9:0] address,
    input  wire       readEnable,
    input  wire       writeEnable,
    
    // --- Outputs ---
    output wire       DataMemWrite,
    output wire       DataMemRead,
    output wire       LEDWrite,
    output wire       SwitchReadEnable
);
    // Data Memory control
    assign DataMemWrite     = (address[9]   == 1'b0)  && writeEnable;
    assign DataMemRead      = (address[9]   == 1'b0)  && readEnable;
    
    // Memory-mapped I/O control
    assign LEDWrite         = (address[9:8] == 2'b01) && writeEnable;
    assign SwitchReadEnable = (address[9:8] == 2'b10) && readEnable;

endmodule