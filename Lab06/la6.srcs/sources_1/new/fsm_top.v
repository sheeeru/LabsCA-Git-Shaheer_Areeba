`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2026 07:54:54 PM
// Design Name: 
// Module Name: fsm_top
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

module fsm_top (
    input  wire        clk,
    input  wire        pbin,
    input  wire [15:0] physical_sw,
    input  wire [31:0] alu_result,    // Getting the answer FROM the ALU
    input  wire        alu_zero,      // Getting the zero flag FROM the ALU
    output wire [15:0] physical_leds,
    output reg  [3:0]  alu_ctrl_out   // Sending the command TO the ALU
);

    // --- Lab 5 Module Reuse ---
    wire rst_clean;
    debouncer rst_db (.clk(clk), .pbin(pbin), .pbout(rst_clean));

    wire [31:0] switch_data; 
    leds switch_reader (
        .clk(clk), .rst(rst_clean), .btns(16'd0), .writeData(32'd0), 
        .writeEnable(1'b0), .readEnable(1'b1), .memAddress(30'd0), 
        .switches(physical_sw), .readData(switch_data)
    );

    reg [31:0] led_write_data = 32'd0; 
    switches led_writer (
        .clk(clk), .rst(rst_clean), .writeData(led_write_data), 
        .writeEnable(1'b1), .readEnable(1'b0), .memAddress(30'd0), 
        .readData(), .leds(physical_leds)
    );

    // --- The FSM ---
    localparam READ_INPUTS = 1'b0;
    localparam UPDATE_LEDS = 1'b1;
    reg state = READ_INPUTS;

    always @(posedge clk) begin
        if (rst_clean) begin
            state <= READ_INPUTS;
            alu_ctrl_out <= 4'd0;
            led_write_data <= 32'd0;
        end else begin
            case (state)
                READ_INPUTS: begin
                    // Grab the bottom 4 switches to use as the ALU command
                    alu_ctrl_out <= switch_data[3:0];
                    state <= UPDATE_LEDS;
                end
                
                UPDATE_LEDS: begin
                    // Format the LED output using the math answers provided by the ALU
                    // LED 15 = Zero Flag
                    // LEDs 14:0 = Bottom 15 bits of the math result
                    led_write_data <= {16'd0, alu_zero, alu_result[14:0]};
                    state <= READ_INPUTS;
                end
            endcase
        end
    end

endmodule
