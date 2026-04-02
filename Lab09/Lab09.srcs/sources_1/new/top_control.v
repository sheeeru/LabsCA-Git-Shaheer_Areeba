`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_control
// Description: Top-level FPGA design for RISC-V control path (Task 3).
//              Integrates main_control and alu_control with an FSM.
//              Reuses switches and leds modules from Lab 5.
//
// Switch Mapping (SW[15:0]):
//   SW[14:8] = opcode[6:0]
//   SW[7:5]  = funct3[2:0]
//   SW[4]    = funct7[5]   (only relevant bit of funct7)
//   SW[15]   = reserved
//   SW[3:0]  = reserved
//
// LED Mapping (LED[15:0]):
//   LED[0]    = RegWrite
//   LED[1]    = MemRead
//   LED[2]    = MemWrite
//   LED[3]    = ALUSrc
//   LED[4]    = MemtoReg
//   LED[5]    = Branch
//   LED[6]    = ALUOp[0]   (LSB)
//   LED[7]    = ALUOp[1]   (MSB)
//   LED[11:8] = ALUControl[3:0]
//   LED[15:12]= off (always 0)
//
// FSM States:
//   IDLE    -> COMPUTE -> DISPLAY -> IDLE
//   IDLE:    sample switch inputs
//   COMPUTE: run control logic (combinational, instant)
//   DISPLAY: latch results and drive LEDs
//////////////////////////////////////////////////////////////////////////////////

module top_control (
    input        clk,
    input        rst,
    input  [15:0] sw,
    output [15:0] led
);

    // -----------------------------------------------------------------------
    // FSM state encoding
    // -----------------------------------------------------------------------
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DISPLAY = 2'b10;

    reg [1:0] state, next_state;

    // -----------------------------------------------------------------------
    // Switches module - reads physical switch positions
    // -----------------------------------------------------------------------
    wire [31:0] sw_readData;

    switches sw_inst (
        .clk        (clk),
        .rst        (rst),
        .writeData  (32'b0),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress (30'b0),
        .readData   (sw_readData)
    );

    // -----------------------------------------------------------------------
    // Extract instruction fields from switch inputs
    // sw[14:8] = opcode, sw[7:5] = funct3, sw[4] = funct7[5]
    // -----------------------------------------------------------------------
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = sw[14:8];
    assign funct3 = sw[7:5];
    assign funct7 = {1'b0, sw[4], 5'b0};  // only bit [5] matters

    // -----------------------------------------------------------------------
    // Main Control Unit
    // -----------------------------------------------------------------------
    wire        RegWrite;
    wire        MemRead;
    wire        MemWrite;
    wire        ALUSrc;
    wire        MemtoReg;
    wire        Branch;
    wire [1:0]  ALUOp;

    main_control uut_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    // -----------------------------------------------------------------------
    // ALU Control Unit
    // -----------------------------------------------------------------------
    wire [3:0] ALUControl;

    alu_control uut_alu (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // -----------------------------------------------------------------------
    // FSM: state register (sequential)
    // -----------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    // -----------------------------------------------------------------------
    // FSM: next-state logic (combinational)
    // -----------------------------------------------------------------------
    always @(*) begin
        case (state)
            IDLE   : next_state = COMPUTE;
            COMPUTE: next_state = DISPLAY;
            DISPLAY: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // -----------------------------------------------------------------------
    // FSM: output logic - assemble LED word and write in DISPLAY state
    // -----------------------------------------------------------------------
    reg [15:0] led_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_reg <= 16'b0;
        end
        else if (state == DISPLAY) begin
            led_reg <= {
                4'b0,         // LED[15:12] = off
                ALUControl,   // LED[11:8]
                ALUOp[1],     // LED[7]
                ALUOp[0],     // LED[6]
                Branch,       // LED[5]
                MemtoReg,     // LED[4]
                ALUSrc,       // LED[3]
                MemWrite,     // LED[2]
                MemRead,      // LED[1]
                RegWrite      // LED[0]
            };
        end
    end

    // -----------------------------------------------------------------------
    // Drive LED output directly from register
    // -----------------------------------------------------------------------
    assign led = led_reg;

endmodule