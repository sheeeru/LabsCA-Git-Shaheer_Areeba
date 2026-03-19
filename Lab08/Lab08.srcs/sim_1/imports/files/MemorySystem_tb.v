`timescale 1ns / 1ps

module MemorySystem_tb;

    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    reg        rst;
    reg        readEnable;
    reg        writeEnable;
    reg [31:0] address;
    reg [31:0] writeData;
    reg [15:0] switches;
    wire [31:0] readData;
    wire [15:0] leds;

    // Instantiate Device Under Test
    addressDecoderTop adt (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (switches),
        .readData   (readData),
        .leds       (leds)
    );

    initial begin
        // -----------------------------------------------------------
        // Reset
        // -----------------------------------------------------------
        rst = 1; address = 0; readEnable = 0;
        writeEnable = 0; writeData = 0; switches = 16'hA55A;
        @(posedge clk); @(negedge clk);
        rst = 0;
        $display("--- Reset complete ---");

        // -----------------------------------------------------------
        // Test 1: Write to DataMemory
        // address=4 → address[9:8]=00 → DataMemWrite fires
        // -----------------------------------------------------------
        @(negedge clk);
        address = 32'd4; writeData = 32'hDEADBEEF;
        writeEnable = 1; readEnable = 0;
        @(posedge clk); @(negedge clk);
        writeEnable = 0;
        $display("Test 1 WRITE DataMem : addr=4   address[9:8]=%b (expect 00)", address[9:8]);

        // -----------------------------------------------------------
        // Test 2: Read from DataMemory
        // address=4 → address[9:8]=00 → DataMemRead fires
        // DataMemory is combinatorial read — valid same cycle as readEnable
        // -----------------------------------------------------------
        @(negedge clk);
        address = 32'd4; readEnable = 1; writeEnable = 0;
        @(posedge clk); @(negedge clk);
        $display("Test 2 READ  DataMem : addr=4   readData=0x%h (expect DEADBEEF)", readData);
        readEnable = 0;

        // -----------------------------------------------------------
        // Test 3: Write to LEDs
        // address=512 → address[9:8]=10 → LEDWrite fires
        // 'switches' module latches leds<=writeData[15:0] on posedge
        // -----------------------------------------------------------
        @(negedge clk);
        address = 32'd512; writeData = 32'h000000F3;
        writeEnable = 1; readEnable = 0;
        @(posedge clk); @(negedge clk);
        writeEnable = 0;
        $display("Test 3 WRITE LEDs    : addr=512  address[9:8]=%b (expect 10)", address[9:8]);
        @(posedge clk); // one extra cycle — leds register updated on previous posedge
        $display("         leds=0x%h (expect 00F3)", leds);

        // -----------------------------------------------------------
        // Test 4: Read from Switches
        // address=768 → address[9:8]=11 → SwitchReadEnable fires
        // 'leds' module is combinatorial — readData valid same cycle
        // switches=16'hA55A → expect readData=0x0000A55A
        // -----------------------------------------------------------
        @(negedge clk);
        address = 32'd768; readEnable = 1; writeEnable = 0;
        @(posedge clk); @(negedge clk);
        $display("Test 4 READ  Switches: addr=768  readData=0x%h (expect 0000A55A)", readData);
        readEnable = 0;

        // -----------------------------------------------------------
        // Test 5: Confirm address[9:8] decode values explicitly
        // -----------------------------------------------------------
        repeat(2) @(posedge clk);

        @(negedge clk);
        address = 32'd512; writeData = 32'h000000F3; writeEnable = 1; readEnable = 0;
        $display("Test 5 LED  write: address[9:8]=%b (expect 10)", address[9:8]);

        @(negedge clk);
        address = 32'd768; readEnable = 1; writeEnable = 0;
        $display("Test 5 SW   read : address[9:8]=%b (expect 11)", address[9:8]);

        @(posedge clk); @(negedge clk);
        writeEnable = 0; readEnable = 0;

        repeat(4) @(posedge clk);
        $display("--- All tests complete ---");
        $finish;
    end

endmodule
