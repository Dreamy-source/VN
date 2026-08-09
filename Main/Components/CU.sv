// Control Unit
`include "ALU.sv"
`include "DCD.sv"
`include "ROM.sv"
`include "PC.sv"
`include "RF.sv"

module CU (
    input logic RF_CLK,
    input logic RF_WE,
    input logic RF_RST,

    input logic PC_CLK,
    input logic PC_RST
);
    logic [15:0] alu_opcode;                    // input
    logic [63:0] alu_num0;                      // input
    logic [63:0] alu_num1;                      // input
    logic [63:0] alu_sum;                       // output
    logic        alu_overflow_flag;             // output
    logic        alu_div_by_zero_exception;     // output
    logic        alu_unknown_opcode_exception;  // output

    logic [63:0] dcd_instruction;               // input
    logic [15:0] dcd_opcode;                    // output
    logic [4:0]  dcd_reg_destination;           // output
    logic [4:0]  dcd_reg0;                      // output
    logic [4:0]  dcd_reg1;                      // output
    logic [32:0] dcd_immediate;                 // output

    logic [63:0] rom_addr;                      // input
    logic [63:0] rom_instruction;               // output

    logic        pc_clk;                        // input
    logic        pc_rst;                        // input
    logic [63:0] pc_next_count;                 // input
    logic        pc_next_count_flag;            // input
    logic [63:0] pc_count;                      // output

    logic        rf_clk;                        // input
    logic        rf_we;                         // input
    logic        rf_rst;                        // input
    logic [4:0]  rf_rd_addr0;                   // input
    logic [4:0]  rf_rd_addr1;                   // input
    logic [4:0]  rf_wr_addr;                    // input
    logic [63:0] rf_data_input;                 // input
    logic [63:0] rf_data_out0;                  // output
    logic [63:0] rf_data_out1;                  // output

    ALU alu (
        .OPCODE(alu_opcode),
        .NUM0(alu_num0),
        .NUM1(alu_num1),
        .SUM(alu_sum),
        .OVERFLOW_FLAG(alu_overflow_flag),
        .DIV_BY_ZERO_EXCEPTION(alu_div_by_zero_exception),
        .UNKNOWN_OPCODE_EXCEPTION(alu_unknown_opcode_exception)
    );
    DCD dcd (
        .INSTRUCTION(dcd_instruction),
        .OPCODE(dcd_opcode),
        .REG_DESTINATION(dcd_reg_destination),
        .REG0(dcd_reg0),
        .REG1(dcd_reg1),
        .IMMEDIATE(dcd_immediate)
    );
    ROM rom (
        .ADDR(rom_addr),
        .INSTRUCTION(rom_instruction)
    );
    PC pc (
        .CLK(pc_clk),
        .RST(pc_rst),
        .NEXT_COUNT(pc_next_count),
        .NEXT_COUNT_FLAG(pc_next_count_flag),
        .COUNT(pc_count)
    );
    RF rf (
        .CLK(rf_clk),
        .WE(rf_we),
        .RST(rf_rst),
        .RD_ADDR0(rf_rd_addr0),
        .RD_ADDR1(rf_rd_addr1),
        .WR_ADDR(rf_wr_addr),
        .DATA_INPUT(rf_data_input),
        .DATA_OUT0(rf_data_out0),
        .DATA_OUT1(rf_data_out1)
    );

    // where from = where to
    assign alu_opcode         = dcd_opcode;    // the ALU operation selection comes from the DCD
    assign alu_num0           = rf_data_out0;  // the first number is connected to RF.DATA_OUT0.
    assign alu_num1           = rf_data_out1;  // The second number is connected to RF.DATA_OUT1.
    
    assign rom_addr           = pc_count;
    assign dcd_instruction    = rom_instruction;

    assign pc_clk             = PC_CLK;
    assign pc_rst             = PC_RST;
    assign pc_next_count      = 0;
    assign pc_next_count_flag = 0;

    assign rf_clk             = RF_CLK;
    assign rf_we              = RF_WE;
    assign rf_rst             = RF_RST;
    assign rf_data_input      = alu_sum;       // result of ALU connected to RF.DATA_INPUT
    assign rf_rd_addr0        = dcd_reg0;      // read register #0
    assign rf_rd_addr1        = dcd_reg1;      // read register #1
    assign rf_wr_addr         = dcd_reg_destination;
endmodule