// Control Unit
`include "ALU.sv"
`include "DCD.sv"
`include "RF.sv"

module CU;
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
    logic [4:0]  rf_rd_addr;                    // input
    logic [4:0]  rf_wr_addr;                    // input
    logic [63:0] rf_data_input;                 // input
    logic [63:0] rf_data_out;                   // output

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
        .RD_ADDR(rf_rd_addr),
        .WR_ADDR(rf_wr_addr),
        .DATA_INPUT(rf_data_input),
        .DATA_OUT(rf_data_out)
    );
endmodule