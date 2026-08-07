module ALU (
    input  logic [15:0] OPCODE,
    input  logic [63:0] NUM0,
    input  logic [63:0] NUM1,
    output logic [63:0] SUM,
    output logic        OVERFLOW_FLAG,
    output logic        DIV_BY_ZERO_EXCEPTION,
    output logic        UNKNOWN_OPCODE_EXCEPTION
);

    always_comb begin
        SUM                      = 64'b0;
        OVERFLOW_FLAG            = 0;
        DIV_BY_ZERO_EXCEPTION    = 0;
        UNKNOWN_OPCODE_EXCEPTION = 0;
    end

endmodule