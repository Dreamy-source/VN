// Decoder
module DCD (
    input  logic [63:0] INSTRUCTION,
    output logic [15:0] OPCODE,
    output logic [4:0]  REG_DESTINATION,
    output logic [4:0]  REG0,
    output logic [4:0]  REG1,
    output logic [32:0] IMMEDIATE
);
    always_comb begin
        OPCODE          = INSTRUCTION[63:48];
        REG_DESTINATION = INSTRUCTION[47:43]; 
        REG0            = INSTRUCTION[42:38];
        REG1            = INSTRUCTION[37:33];
        IMMEDIATE       = INSTRUCTION[32:0];
    end
endmodule