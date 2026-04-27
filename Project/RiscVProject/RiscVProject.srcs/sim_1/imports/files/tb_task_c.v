`timescale 1ns / 1ps

module tb_task_c;
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] led;

    // Task C: Demonstrates summation of arithmetic sequence
    TopLevelProcessor #(
        .INIT_FILE("taskc.mem")
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
        sw = 16'h0004; // Set switch to 4 to compute 4+3+2+1=10 (0xA)
        #20 rst = 0;
        
        // Let it run to compute sum and display on LEDs
        #500;
        
        $finish;
    end
endmodule
