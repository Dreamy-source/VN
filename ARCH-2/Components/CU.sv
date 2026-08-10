`include "RF.sv"
`include "DCD.sv"

module CU;
    logic        CLK;
    logic        WE;
    logic        RST;
    logic [4:0]  RF_WR_ADDR_REG_0;         // dst
    logic [4:0]  RF_RD_ADDR_REG_1;         // src0
    logic [4:0]  RF_RD_ADDR_REG_2;         // src1
    logic [63:0] RF_DATA_INPUT;
    logic [63:0] RF_DATA_OUTPUT_REG_1;
    logic [63:0] RF_DATA_OUTPUT_REG_2;

    logic [63:0] DCD_INSTRUCTION;
    logic [8:0]  DCD_OPERATION;
    logic [4:0]  DCD_REG_0;                // dst
    logic [4:0]  DCD_REG_1;                // src0
    logic [4:0]  DCD_REG_2;                // src1
    logic [39:0] DCD_VALUE;

    RF rf (
        .CLK(CLK),
        .WE(WE),
        .RST(RST),
        .WR_ADDR_REG_0(RF_WR_ADDR_REG_0),     // dst
        .RD_ADDR_REG_1(RF_RD_ADDR_REG_1),     // src0
        .RD_ADDR_REG_2(RF_RD_ADDR_REG_2),     // src1
        .DATA_INPUT(RF_DATA_INPUT),
        .DATA_OUTPUT_REG_1(RF_DATA_OUTPUT_REG_1),  // src0
        .DATA_OUTPUT_REG_2(RF_DATA_OUTPUT_REG_2)   // src1
    );
    DCD dcd (
        .INSTRUCTION(DCD_INSTRUCTION),
        .OPERATION(DCD_OPERATION),
        .REG_0(DCD_REG_0),           // dst
        .REG_1(DCD_REG_1),           // src0
        .REG_2(DCD_REG_2),           // src1
        .VALUE(DCD_VALUE)
    );

endmodule