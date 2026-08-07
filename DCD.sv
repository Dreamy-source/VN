module DCD (
    input  logic [63:0] INSTRUCTION,
    output logic [15:0] OPCODE,
    output logic [6:0]  REG_DESTINATION,
    output logic [6:0]  REG0,
    output logic [6:0]  REG1,
    output logic [26:0] IMMEDIATE
);
    always_comb @(*) begin
        OPCODE          = INSTRUCTION[63:48];
        REG_DESTINATION = INSTRUCTION[47:41]; 
        REG0            = INSTRUCTION[40:34];
        REG1            = INSTRUCTION[33:27];
        IMMEDIATE       = INSTRUCTION[26:0];
    end
endmodule