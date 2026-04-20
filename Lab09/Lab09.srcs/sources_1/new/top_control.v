`timescale 1ns / 1ps

module top_control(
    input         clk,   // W5 on Basys3 (100MHz)
    input         rst,   // U18 on Basys3 (Center Button)
    input  [15:0] sw,    // Physical Switches
    output [15:0] led    // Physical LEDs
);

    wire rst_db;
    debouncer db_rst (
        .clk(clk),
        .pbin(rst),
        .pbout(rst_db)
    );

    // ==========================================
    // 2. Accelerated FSM Clock (100 Hz / 10ms)
    // ==========================================
    reg [25:0] counter = 26'd0; 
    // Changed from 50,000,000 to 1,000,000 for instant physical feedback
    wire fast_pulse = (counter == 26'd1_000_000); 

    always @(posedge clk) begin
        if (rst_db)
            counter <= 0;
        else if (fast_pulse)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // ==========================================
    // 3. Finite State Machine (FSM)
    // ==========================================
    reg [1:0] state = 2'b00; 
    
    localparam IDLE    = 2'b00;
    localparam READ    = 2'b01;
    localparam DISPLAY = 2'b10;

    always @(posedge clk) begin
        if (rst_db)
            state <= IDLE;
        else if (fast_pulse) begin // FSM transitions instantly now
            case(state)
                IDLE:    state <= READ;
                READ:    state <= DISPLAY;
                DISPLAY: state <= READ;
                default: state <= IDLE;
            endcase
        end
    end

    // ==========================================
    // 4. Switch Reader
    // ==========================================
    wire [31:0] switchData;
    
    leds sw_reader_inst(
        .clk(clk),
        .rst(rst_db),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(state == READ), 
        .memAddress(30'b0),
        .switches(sw),
        .readData(switchData)
    );

    // ==========================================
    // 5. Instruction Field Extraction (Mapped to XDC)
    // ==========================================
    // REQUIRED: You must use the LEFT-side switches for the Opcode
    wire [6:0] opcode = switchData[14:8];
    wire [2:0] funct3 = switchData[7:5];
    wire [6:0] funct7 = {1'b0, switchData[4], 5'b00000};

    // ==========================================
    // 6. Control Path Logic
    // ==========================================
    wire       RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    main_control ctrl_main(
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    alu_control ctrl_alu(
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // ==========================================
    // 7. Bundle LED Data
    // ==========================================
    wire [31:0] ledData = {
        16'd0,         
        4'b0000,       
        ALUControl,    
        ALUOp[1],      
        ALUOp[0],      
        Branch,        
        MemtoReg,      
        ALUSrc,        
        MemWrite,      
        MemRead,       
        RegWrite       
    };

    // ==========================================
    // 8. LED Writer 
    // ==========================================
    switches led_writer_inst(
        .clk(clk),
        .rst(rst_db),
        .writeData(ledData),
        .writeEnable(state == DISPLAY), 
        .readEnable(1'b0),
        .memAddress(30'b0),
        .readData(),
        .leds(led)
    );

endmodule