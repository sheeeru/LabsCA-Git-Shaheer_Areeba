`timescale 1ns / 1ps

module tb_task_b;
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] led;

    // Task B: Demonstrates LUI, JAL, BNE
    TopLevelProcessor #(
        .INIT_FILE("taskb.mem")
    ) dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw = 16'h0000; 
        #20 rst = 0;
        
        // Let it run to verify ALU result shown on LEDs
        #500;
        
        $finish;
    end
endmodule
