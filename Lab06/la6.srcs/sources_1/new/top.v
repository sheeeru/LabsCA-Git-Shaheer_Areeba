`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:31:09 AM
// Design Name: 
// Module Name: top
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


module alu_top (
    input  wire        clk,
    input  wire        pbin,               // Center button = reset
    input  wire [15:0] physical_sw,        // FPGA Switches
    output wire [15:0] physical_leds       // FPGA LEDs
);

    // --- Reset (debouncer is pass-through, active-high) ---
    wire rst_clean;
    debouncer rst_db (.clk(clk), .pbin(pbin), .pbout(rst_clean));

    // --- Read switches combinationally ---
    wire [31:0] switch_data;
    leds switch_reader (
        .clk(clk), .rst(rst_clean), .btns(16'd0), .writeData(32'd0),
        .writeEnable(1'b0), .readEnable(1'b1), .memAddress(30'd0),
        .switches(physical_sw), .readData(switch_data)
    );

    // --- Fixed operands as per lab spec ---
    wire [31:0] fixed_A = 32'h10101010;
    wire [31:0] fixed_B = 32'h01010101;

    // --- ALUControl directly from switches (combinational, no FSM lag) ---
    wire [3:0] alu_ctrl = switch_data[3:0];

    // --- ALU (purely combinational) ---
    wire [31:0] alu_result;
    wire        alu_zero;

    alu_32bit ALU_Inst (
        .A(fixed_A),
        .B(fixed_B),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

    // --- Register LED output for clean glitch-free display ---
    reg [15:0] led_reg = 16'd0;

    always @(posedge clk) begin
        if (rst_clean)
            led_reg <= 16'd0;
        else
            // LED[15]   = Zero flag
            // LED[14:0] = bottom 15 bits of ALU result
            led_reg <= {alu_zero, alu_result[14:0]};
    end

    // --- Drive LEDs via switches module ---
    switches led_writer (
        .clk(clk), .rst(rst_clean), .writeData({16'd0, led_reg}),
        .writeEnable(1'b1), .readEnable(1'b0), .memAddress(30'd0),
        .readData(), .leds(physical_leds)
    );

endmodule