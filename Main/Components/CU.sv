// Control Unit
`include "ALU.sv"
`include "DCD.sv"
`include "RF.sv"

module CU (
    input logic RF_CLK,
    input logic RF_WE,
    input logic RF_RST
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

    // откуда = куда
    assign alu_opcode    = dcd_opcode;    // выбор операции ALU идет от DCD
    assign alu_num0      = rf_data_out0;  // первое число подключено к RF.DATA_OUT1
    assign alu_num1      = rf_data_out1;  // второе число подключено к RF.DATA_OUT0
    
    assign rf_clk        = RF_CLK;
    assign rf_we         = RF_WE;
    assign rf_rst        = RF_RST;
    assign rf_data_input = alu_sum;       // результат ALU подключен к RF.DATA_INPUT
    assign rf_rd_addr0   = dcd_reg0;      // "читай регистр #0"
    assign rf_rd_addr1   = dcd_reg1;      // "читай регистр #1"
    assign rf_wr_addr    = dcd_reg_destination;
endmodule