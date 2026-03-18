`timescale 1ns / 1ps

// Address map (from AddressDecoder.v):
//   address[9]=0            ? DataMemory  (0x000 to 0x1FF)
//   address[9:8]=2'b01=256  ? LED write   (switches module drives LEDs)
//   address[9:8]=2'b10=512  ? Switch read (leds module reads switches)

module top(
    input  wire        clk,
    input  wire        btnC,
    input  wire [15:0] switches,
    output wire [15:0] leds
);
    wire rst_clean;

    // FSM states
    localparam S_IDLE         = 3'd0;
    localparam S_WRITE_SETUP  = 3'd1;
    localparam S_WRITE_EXEC   = 3'd2;
    localparam S_READ_SETUP   = 3'd3;
    localparam S_READ_CAPTURE = 3'd4;
    localparam S_LED_SETUP    = 3'd5;
    localparam S_LED_EXEC     = 3'd6;

    reg [2:0]  state;
    reg [31:0] address;
    reg        readEnable, writeEnable;
    reg [31:0] writeData;
    wire [31:0] readData;
    reg [31:0]  readReg;

    reg sw8_prev, sw9_prev, sw10_prev;
    wire sw8_rise  = switches[8]  & ~sw8_prev;  // WRITE to DataMemory
    wire sw9_rise  = switches[9]  & ~sw9_prev;  // READ from DataMemory
    wire sw10_rise = switches[10] & ~sw10_prev; // WRITE readReg to LEDs

    debouncer db(
        .clk(clk),
        .pbin(btnC),
        .pbout(rst_clean)
    );

    addressDecoderTop adt(
        .clk(clk),
        .rst(rst_clean),
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeData(writeData),
        .switches(switches),
        .readData(readData),
        .leds(leds)
    );

    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean) begin
            state       <= S_IDLE;
            address     <= 0;
            readEnable  <= 0;
            writeEnable <= 0;
            writeData   <= 0;
            readReg     <= 0;
            sw8_prev    <= 0;
            sw9_prev    <= 0;
            sw10_prev   <= 0;
        end else begin
            sw8_prev  <= switches[8];
            sw9_prev  <= switches[9];
            sw10_prev <= switches[10];

            readEnable  <= 0;
            writeEnable <= 0;

            case (state)

                S_IDLE: begin
                    if (sw8_rise) begin
                        // Write sw[7:0] into DataMemory at address sw[15:11]
                        address   <= {27'b0, switches[15:11]};
                        writeData <= {24'b0, switches[7:0]};
                        state     <= S_WRITE_SETUP;

                    end else if (sw9_rise) begin
                        // Read from DataMemory at address sw[15:11]
                        address <= {27'b0, switches[15:11]};
                        state   <= S_READ_SETUP;

                    end else if (sw10_rise) begin
                        // Write readReg to LED peripheral
                        // address[9:8] must be 2'b01 = 32'd256
                        address   <= 32'd256;
                        writeData <= readReg;
                        state     <= S_LED_SETUP;
                    end
                end

                // --- WRITE to DataMemory ---
                // Cycle 1: address + writeData stable on bus
                S_WRITE_SETUP: begin
                    writeEnable <= 1;
                    state       <= S_WRITE_EXEC;
                end
                // Cycle 2: DataMemory clocks in the write
                S_WRITE_EXEC: begin
                    state <= S_IDLE;
                end

                // --- READ from DataMemory ---
                // Cycle 1: address stable, readEnable asserted
                S_READ_SETUP: begin
                    readEnable <= 1;
                    state      <= S_READ_CAPTURE;
                end
                // Cycle 2: DataMemory combinatorial output valid, capture it
                S_READ_CAPTURE: begin
                    readReg <= readData;
                    state   <= S_IDLE;
                end

                // --- WRITE readReg to LED peripheral ---
                // Cycle 1: address=256, writeData=readReg stable, assert writeEnable
                S_LED_SETUP: begin
                    writeEnable <= 1;
                    state       <= S_LED_EXEC;
                end
                // Cycle 2: switches module (LED peripheral) clocks in the data
                S_LED_EXEC: begin
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;

            endcase
        end
    end
endmodule