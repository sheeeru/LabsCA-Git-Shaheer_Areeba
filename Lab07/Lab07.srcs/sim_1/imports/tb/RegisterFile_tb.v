`timescale 1ns / 1ps
module RegisterFile_tb;

    // -------------------------------------------------------------------------
    // DUT Signals
    // -------------------------------------------------------------------------
    reg        clk;
    reg        rst;
    reg        WriteEnable;
    reg  [4:0] rs1, rs2, rd;
    reg  [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    // -------------------------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------------------------
    RegisterFile uut (
        .clk(clk),
        .rst(rst),
        .WriteEnable(WriteEnable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // Helper task: apply a synchronous write, then check read-back next cycle
    // -------------------------------------------------------------------------
    task write_reg;
        input [4:0]  addr;
        input [31:0] data;
        begin
            @(negedge clk);           // set up before rising edge
            WriteEnable = 1;
            rd          = addr;
            WriteData   = data;
            @(posedge clk); #1;       // capture on rising edge
            WriteEnable = 0;
        end
    endtask

    // -------------------------------------------------------------------------
    // Simulation
    // -------------------------------------------------------------------------
    integer pass_count = 0;
    integer fail_count = 0;

    initial begin
        // --- Initialise ---
        clk         = 0;
        rst         = 1;
        WriteEnable = 0;
        rs1         = 0;
        rs2         = 0;
        rd          = 0;
        WriteData   = 0;

        // Release reset after 3 clock cycles
        repeat (3) @(posedge clk);
        rst = 0;
        #1;

        // ===================================================================
        // TEST i: Write a value to x5 and verify read-back on ReadData1
        // ===================================================================
        write_reg(5'd5, 32'hDEAD_BEEF);

        rs1 = 5'd5;
        #1;  // asynchronous read settles immediately
        if (ReadData1 === 32'hDEAD_BEEF) begin
            $display("[PASS] Test i : x5 = 0x%08h (correct)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test i : x5 expected 0xDEADBEEF, got 0x%08h", ReadData1);
            fail_count = fail_count + 1;
        end

        // ===================================================================
        // TEST ii: Attempt to write to x0 – must remain 0
        // ===================================================================
        write_reg(5'd0, 32'hFFFF_FFFF);

        rs1 = 5'd0;
        #1;
        if (ReadData1 === 32'd0) begin
            $display("[PASS] Test ii: x0 = 0x%08h (correctly stays zero)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test ii: x0 expected 0x00000000, got 0x%08h", ReadData1);
            fail_count = fail_count + 1;
        end

        // ===================================================================
        // TEST iii: Simultaneous two-port read (x5 on port1, a new reg on port2)
        // ===================================================================
        write_reg(5'd10, 32'hCAFE_BABE);

        rs1 = 5'd5;   // should return 0xDEADBEEF
        rs2 = 5'd10;  // should return 0xCAFEBABE
        #1;
        if (ReadData1 === 32'hDEAD_BEEF && ReadData2 === 32'hCAFE_BABE) begin
            $display("[PASS] Test iii: Dual read OK  rs1=0x%08h  rs2=0x%08h", ReadData1, ReadData2);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test iii: rs1=0x%08h (exp 0xDEADBEEF)  rs2=0x%08h (exp 0xCAFEBABE)",
                     ReadData1, ReadData2);
            fail_count = fail_count + 1;
        end

        // ===================================================================
        // TEST iv: Overwrite x5 and verify old value is replaced
        // ===================================================================
        write_reg(5'd5, 32'h1234_5678);

        rs1 = 5'd5;
        #1;
        if (ReadData1 === 32'h1234_5678) begin
            $display("[PASS] Test iv : x5 overwritten to 0x%08h (correct)", ReadData1);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test iv : x5 expected 0x12345678, got 0x%08h", ReadData1);
            fail_count = fail_count + 1;
        end

        // ===================================================================
        // TEST v: Reset – all registers should go to 0
        // ===================================================================
        rst = 1;
        @(posedge clk); #1;
        rst = 0;

        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;
        if (ReadData1 === 32'd0 && ReadData2 === 32'd0) begin
            $display("[PASS] Test v  : Reset OK – x5=0x%08h, x10=0x%08h", ReadData1, ReadData2);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test v  : After reset x5=0x%08h, x10=0x%08h (expected 0)", ReadData1, ReadData2);
            fail_count = fail_count + 1;
        end

        // ===================================================================
        // Summary
        // ===================================================================
        $display("--------------------------------------------------");
        $display("RegisterFile_tb: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
