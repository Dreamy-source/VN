// Control Unit

`include "ALU.sv"
`include "DCD.sv"
`include "RF.sv"

module CU;
    logic [15:0] alu_opcode;
    logic [63:0] alu_num0;
    logic [63:0] alu_num1;
    logic [63:0] alu_sum;
    logic        alu_overflow_flag;
    logic        alu_div_by_zero_exception;
    logic        alu_unknown_opcode_exception;

    ALU alu (
        .OPCODE(alu_opcode),
        .NUM0(alu_num0),
        .NUM1(alu_num1),
        .SUM(alu_sum),
        .OVERFLOW_FLAG(alu_overflow_flag),
        .DIV_BY_ZERO_EXCEPTION(alu_div_by_zero_exception),
        .UNKNOWN_OPCODE_EXCEPTION(alu_unknown_opcode_exception)
    );

endmodule