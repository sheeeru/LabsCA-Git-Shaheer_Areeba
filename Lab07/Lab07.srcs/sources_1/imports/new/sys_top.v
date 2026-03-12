`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 07:55:49 PM
// Design Name: 
// Module Name: sys_top
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


module sys_top (
    input  wire        clk,
    input  wire        pbin,
    input  wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

    // Internal wires acting as the "traces" on our motherboard
    // to connect the FSM to the ALU
    wire [3:0]  bus_alu_ctrl;
    wire [31:0] bus_alu_result;
    wire        bus_alu_zero;

    // Plug in the ALU Module
    alu_top math_coprocessor (
        .alu_ctrl(bus_alu_ctrl),        // Input from FSM
        .alu_result(bus_alu_result),    // Output to FSM
        .alu_zero(bus_alu_zero)         // Output to FSM
    );

    // Plug in the FSM Module
    fsm_top control_unit (
        .clk(clk),
        .pbin(pbin),
        .physical_sw(physical_sw),
        .alu_result(bus_alu_result),    // Input from ALU
        .alu_zero(bus_alu_zero),        // Input from ALU
        .physical_leds(physical_leds),
        .alu_ctrl_out(bus_alu_ctrl)     // Output to ALU
    );

endmodule
