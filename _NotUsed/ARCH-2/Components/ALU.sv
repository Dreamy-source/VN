module ALU (
    input  logic [8:0]  OPERATION,   // opcode
    input  logic [63:0] NUM0,
    input  logic [63:0] NUM1,
    output logic [63:0] RESULT,
    output logic        OVERFLOW_FLAG
);

    always_comb begin
        case (OPERATION)
            16'h0000: begin end
            16'h0001: begin {OVERFLOW_FLAG, RESULT} = NUM0 + NUM1; end
        endcase
    end
endmodule