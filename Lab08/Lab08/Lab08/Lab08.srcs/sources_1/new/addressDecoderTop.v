`timescale 1ns / 1ps

// BUG FIXED: Peripheral roles swapped per instructor requirement
//   - 'switches' module now drives physical LEDs (write peripheral)
//   - 'leds' module now reads physical switches (read peripheral)
// BUG FIXED: DataMemory now receives rst and MemRead signals
// BUG FIXED: switches input widened to [15:0] to match top.v
module addressDecoderTop(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    input  wire [15:0] switches,      // full 16-bit physical switches
    output wire [31:0] readData,
    output wire [15:0] leds           // physical LEDs output
);

    wire DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
    wire [31:0] dataMemReadData, ledReadData, switchReadData;

    // Address Decoder
    AddressDecoder dec(
        .address(address[9:0]),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .DataMemWrite(DataMemWrite),
        .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    // Data Memory - rst and MemRead added
    DataMemory dm(
        .clk(clk),
        .rst(rst),
        .MemWrite(DataMemWrite),
        .MemRead(DataMemRead),
        .address(address[8:0]),
        .write_data(writeData),
        .read_data(dataMemReadData)
    );

    // 'switches' module now drives LEDs (write peripheral)
    switches led_periph(
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(LEDWrite),
        .readEnable(1'b0),
        .memAddress(address[29:0]),
        .readData(ledReadData),
        .leds(leds)                   // physical LEDs
    );

    // 'leds' module now reads switches (read peripheral)
    leds sw_periph(
        .clk(clk),
        .rst(rst),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(SwitchReadEnable),
        .memAddress(address[29:0]),
        .switches(switches),          // physical switches [15:0]
        .readData(switchReadData)
    );

    // Read data mux - route correct peripheral back to top
    assign readData = (address[9] == 1'b0)    ? dataMemReadData :
                      (address[9:8] == 2'b10)  ? switchReadData  :
                      (address[9:8] == 2'b11)  ? ledReadData     :
                      32'b0;

endmodule