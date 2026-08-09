// Arithmetic Logic Unit
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

        case (OPCODE)
            16'h0000: begin end                                                    // 0x0000 - nothing
            16'h0001: begin {OVERFLOW_FLAG, SUM} = NUM0  +  NUM1;          end     // 0x0001 - add
            16'h0002: begin {OVERFLOW_FLAG, SUM} = NUM0  -  NUM1;          end     // 0x0002 - sub
            16'h0003: begin {OVERFLOW_FLAG, SUM} = NUM0  *  NUM1;          end     // 0x0003 - mul
            16'h0004: begin                                                     // 0x0004 - div
                if (NUM1 != 64'b0) begin
                    {OVERFLOW_FLAG, SUM} = NUM0 / NUM1;
                end else begin
                    SUM                   = 64'b0;
                    DIV_BY_ZERO_EXCEPTION = 1;
                end
            end
            16'h0005: begin {OVERFLOW_FLAG, SUM} = NUM0  &  NUM1;          end     // 0x0005 - and
            16'h0006: begin {OVERFLOW_FLAG, SUM} = NUM0  |  NUM1;          end     // 0x0006 - or
            16'h0007: begin {OVERFLOW_FLAG, SUM} = NUM0  ^  NUM1;          end     // 0x0007 - xor
            16'h0008: begin {OVERFLOW_FLAG, SUM} =~NUM0;                   end     // 0x0008 - not
            16'h0009: begin {OVERFLOW_FLAG, SUM} = NUM0  << NUM1;          end     // 0x0009 - lshft
            16'h000A: begin {OVERFLOW_FLAG, SUM} = NUM0  >> NUM1;          end     // 0x000A - rshft
            16'h000B: begin {OVERFLOW_FLAG, SUM} = $signed(NUM0) >>> NUM1; end     // 0x000B - asr
            // 000C - reg DST, REG0
            // 000D - dclr (resets the DCL all devices bits)                      (DCL)
            // 000E - dcls DEVICE_LINE | BIT (sets the DCL device line and bit)   (DCL)
            default: begin
                SUM                      = 64'b0;
                UNKNOWN_OPCODE_EXCEPTION = 1;
            end
        endcase
    end
endmodule