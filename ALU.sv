module ALU (
    input  logic [15:0] OPCODE,
    input  logic [63:0] NUMBER0,
    input  logic [63:0] NUMBER1,
    output logic [63:0] SUM,
    output logic        OVERFLOW_FLAG,
    output logic        DIVIDE_BY_ZERO_EXCEPTION,
    output logic        UNDEFINED_OPCODE_EXCEPTION
);
    always_comb begin
        SUM = 64'h0000000000000000;
        OVERFLOW_FLAG = 0;
        DIVIDE_BY_ZERO_EXCEPTION = 0;
        UNDEFINED_OPCODE_EXCEPTION = 0;

        case (OPCODE)
            16'h0000: begin end                                                        // NOTHING
            16'h0001: begin {OVERFLOW_FLAG, SUM} = NUMBER0 + NUMBER1; end              // ADD
            16'h0002: begin {OVERFLOW_FLAG, SUM} = NUMBER0 - NUMBER1; end              // SUB
            16'h0003: begin {OVERFLOW_FLAG, SUM} = NUMBER0 * NUMBER1; end              // MUL
            16'h0004: begin                                                            // DIV 
                if (NUMBER1 != 64'b0) begin
                    {OVERFLOW_FLAG, SUM} = NUMBER0 / NUMBER1;
                end else begin
                    SUM = 64'b0;
                    DIVIDE_BY_ZERO_EXCEPTION = 1;
                end
            end
            16'h0005: begin SUM = NUMBER0 & NUMBER1; end                               // AND
            16'h0006: begin SUM = NUMBER0 | NUMBER1; end                               // OR
            16'h0007: begin SUM = NUMBER0 ^ NUMBER1; end                               // XOR
            16'h0008: begin SUM = ~NUMBER0; end                                        // NOT
            16'h0009: begin {OVERFLOW_FLAG, SUM} = NUMBER0 << NUMBER1; end             // LSHIFT
            16'h000A: begin {OVERFLOW_FLAG, SUM} = NUMBER0 >> NUMBER1; end             // RSHIFT
            16'h000B: begin {OVERFLOW_FLAG, SUM} = $signed(NUMBER0) >>> NUMBER1; end   // ASR
            default: begin
                SUM = 64'h0000000000000000;
                OVERFLOW_FLAG = 0;
                DIVIDE_BY_ZERO_EXCEPTION = 0;
                UNDEFINED_OPCODE_EXCEPTION = 1;
            end
        endcase
    end
endmodule