`include "MIC.sv"

module DCD (
    input  logic        RS_TYPE,
    input  logic [63:0] INSTRUCTION,
    output logic [15:0] OPCODE,
    output logic [6:0]  REG_DESTINATION,
    output logic [6:0]  REG_0,
    output logic [6:0]  REG_1,
    output logic [40:0] IMMEDIATE
);
    always_comb @(*) begin
        OPCODE          = INSTRUCTION[63:48];
        REG_DESTINATION = INSTRUCTION[47:41]; 

        if (RS_TYPE == 1'b0) begin                   // 0 = S
            REG_0           = 7'b0;
            REG_1           = 7'b0;
            IMMEDIATE       = INSTRUCTION[40:0];
        end else begin                               // 1 = R
            REG_0           = INSTRUCTION[40:34];
            REG_1           = INSTRUCTION[33:27];
            IMMEDIATE       = 41'b0;
        end
    end
endmodule