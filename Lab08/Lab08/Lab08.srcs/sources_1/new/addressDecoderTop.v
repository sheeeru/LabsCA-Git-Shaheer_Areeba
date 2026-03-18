module addressDecoderTop(
    input clk, 
    input rst, 
    input [31:0] address, 
    input readEnable, 
    input writeEnable, input [31:0] writeData, input [15:0] switches, output [31:0] readData, output [15:0] leds);
    
    wire DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
    wire [31:0] dataMemReadData, ledReadData, switchReadData;

    AddressDecoder dec(.address(address[9:0]), .readEnable(readEnable), .writeEnable(writeEnable), .DataMemWrite(DataMemWrite), .DataMemRead(DataMemRead), .LEDWrite(LEDWrite), .SwitchReadEnable(SwitchReadEnable));
    DataMemory dm(.clk(clk), .MemWrite(DataMemWrite), .address(address[8:0]), .write_data(writeData), .read_data(dataMemReadData));
    switches led_periph(.clk(clk), .rst(rst), .writeData(writeData), .writeEnable(LEDWrite), .readEnable(1'b0), .memAddress(address[29:0]), .readData(ledReadData), .leds(leds));
    leds sw_periph(.clk(clk), .rst(rst), .btns(16'b0), .writeData(32'b0), .writeEnable(1'b0), .readEnable(SwitchReadEnable), .memAddress(address[29:0]), .switches(switches), .readData(switchReadData));

    assign readData = (address[9] == 1'b0) ? dataMemReadData : (address[9:8] == 2'b10) ? ledReadData : (address[9:8] == 2'b11) ? switchReadData : 32'b0;
endmodule