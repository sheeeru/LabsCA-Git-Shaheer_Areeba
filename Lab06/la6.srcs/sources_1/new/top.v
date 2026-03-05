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
    input wire clk,
    input wire pbin,                  // Reset button
    input wire [15:0] physical_sw,    // FPGA Switches
    output wire [15:0] physical_leds  // FPGA LEDs
);

    
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

   
    wire [31:0] fixed_A = 32'h10101010; 
    wire [31:0] fixed_B = 32'h01010101; 
    
    reg  [3:0]  current_alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;

    alu_32bit ALU_Inst (
        .A(fixed_A),
        .B(fixed_B),
        .ALUControl(current_alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );

  
    localparam READ_INPUTS = 1'b0;
    localparam UPDATE_LEDS = 1'b1;
    reg state = READ_INPUTS;

    always @(posedge clk) begin
        if (rst_clean) begin
            state <= READ_INPUTS;
            current_alu_ctrl <= 4'd0;
            led_write_data <= 32'd0;
        end else begin
            case (state)
                READ_INPUTS: begin
                    // Read the bottom 4 switches to select the ALU operation
                    current_alu_ctrl <= switch_data[3:0];
                    state <= UPDATE_LEDS;
                end
                
                UPDATE_LEDS: begin
                    // Format the LED output: 
                    // LED 15 = Zero Flag
                    // LEDs 14:0 = Bottom 15 bits of the math result
                    led_write_data <= {16'd0, alu_zero, alu_result[14:0]};
                    state <= READ_INPUTS; // Loop back
                end
            endcase
        end
    end

endmodule   