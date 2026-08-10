module DCD (
    input  logic [63:0] INSTRUCTION,
    output logic [8:0]  OPERATION,        // opcode
    output logic [4:0]  REG_0,            // dst
    output logic [4:0]  REG_1,            // src0
    output logic [4:0]  REG_2,            // src1
    output logic [39:0] VALUE,            // imm
);

    always_comb begin
        OPERATION = INSTRUCTION[63:55];
        REG_0     = INSTRUCTION[54:50];
        REG_1     = INSTRUCTION[49:45];
        REG_2     = INSTRUCTION[44:40];
        VALUE     = INSTRUCTION[39:0];
    end
endmodule