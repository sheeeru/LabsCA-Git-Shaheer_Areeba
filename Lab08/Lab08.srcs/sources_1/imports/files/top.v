`timescale 1ns / 1ps

module top (
    input  wire        clk,
    input  wire        btnC,
    input  wire [15:0] switches,
    output wire [15:0] leds
);
    wire rst_clean;

    localparam S_IDLE         = 3'd0;
    localparam S_WRITE_SETUP  = 3'd1;
    localparam S_WRITE_EXEC   = 3'd2;
    localparam S_READ_SETUP   = 3'd3;
    localparam S_READ_CAPTURE = 3'd4;
    localparam S_LED_SETUP    = 3'd5;
    localparam S_LED_EXEC     = 3'd6;

    reg [2:0]  state;
    reg [31:0] address;
    reg        readEnable;
    reg        writeEnable;
    reg [31:0] writeData;
    wire [31:0] readData;
    reg [31:0]  readReg;

    reg sw8_prev, sw9_prev, sw10_prev;
    wire sw8_rise  = switches[8]  & ~sw8_prev;
    wire sw9_rise  = switches[9]  & ~sw9_prev;
    wire sw10_rise = switches[10] & ~sw10_prev;

    debouncer db (
        .clk  (clk),
        .pbin (btnC),
        .pbout(rst_clean)
    );

    addressDecoderTop adt (
        .clk        (clk),
        .rst        (rst_clean),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (switches),
        .readData   (readData),
        .leds       (leds)
    );

    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean) begin
            state       <= S_IDLE;
            address     <= 32'd0;
            readEnable  <= 1'b0;
            writeEnable <= 1'b0;
            writeData   <= 32'd0;
            readReg     <= 32'd0;
            sw8_prev    <= 1'b0;
            sw9_prev    <= 1'b0;
            sw10_prev   <= 1'b0;
        end else begin

            sw8_prev  <= switches[8];
            sw9_prev  <= switches[9];
            sw10_prev <= switches[10];

            readEnable  <= 1'b0;
            writeEnable <= 1'b0;

            case (state)

                S_IDLE: begin
                    if (sw8_rise) begin
                        address   <= {27'b0, switches[15:11]};
                        writeData <= {24'b0, switches[7:0]};
                        state     <= S_WRITE_SETUP;
                    end else if (sw9_rise) begin
                        address <= {27'b0, switches[15:11]};
                        state   <= S_READ_SETUP;
                    end else if (sw10_rise) begin
                        address   <= 32'd512;  // address[9:8]=10 → LEDWrite ✓
                        writeData <= readReg;
                        state     <= S_LED_SETUP;
                    end
                end

                // WRITE to DataMemory
                S_WRITE_SETUP: begin
                    writeEnable <= 1'b1;
                    state       <= S_WRITE_EXEC;
                end
                S_WRITE_EXEC: begin
                    state <= S_IDLE;
                end

                // READ from DataMemory
                S_READ_SETUP: begin
                    readEnable <= 1'b1;
                    state      <= S_READ_CAPTURE;
                end
                S_READ_CAPTURE: begin
                    readReg <= readData;
                    state   <= S_IDLE;
                end

                // WRITE to LED peripheral
                S_LED_SETUP: begin
                    writeEnable <= 1'b1;
                    state       <= S_LED_EXEC;
                end
                S_LED_EXEC: begin
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;

            endcase
        end
    end
endmodule
