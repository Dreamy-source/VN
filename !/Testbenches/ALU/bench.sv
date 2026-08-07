// test-bench passed 2x [07.08.2026]

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
            16'h0004: begin                                                        // 0x0004 - div
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
            default: begin
                SUM                      = 64'b0;
                UNKNOWN_OPCODE_EXCEPTION = 1;
            end
        endcase
    end
endmodule

///////////////////////////////////////////////////////////////////
// if you need to synthes this module, delete 'testbench' module//
/////////////////////////////////////////////////////////////////
module testbench;
    logic [15:0] OPCODE;
    logic [63:0] NUM0, NUM1;
    logic [63:0] SUM;
    logic OVERFLOW_FLAG;
    logic DIV_BY_ZERO_EXCEPTION;
    logic UNKNOWN_OPCODE_EXCEPTION;

    ALU alu (
        .OPCODE(OPCODE),
        .NUM0(NUM0),
        .NUM1(NUM1),
        .SUM(SUM),
        .OVERFLOW_FLAG(OVERFLOW_FLAG),
        .DIV_BY_ZERO_EXCEPTION(DIV_BY_ZERO_EXCEPTION),
        .UNKNOWN_OPCODE_EXCEPTION(UNKNOWN_OPCODE_EXCEPTION)
    );

        initial begin
        $display("=== ALU | TB ===");

        OPCODE = 16'h0001; NUM0 = 64'h0005; NUM1 = 64'h0005; #1;
        $display("[add] NUM0 + NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");
        
        OPCODE = 16'h0002; NUM0 = 64'h0005; NUM1 = 64'h0003; #1;
        $display("[sub] NUM0 - NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0003; NUM0 = 64'h0005; NUM1 = 64'h0003; #1;
        $display("[mul] NUM0 * NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0004; NUM0 = 64'h0005; NUM1 = 64'h0005; #1;
        $display("[div] NUM0 / NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("DIV_BY_ZERO_EXCEPTION = %b", DIV_BY_ZERO_EXCEPTION);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0004; NUM0 = 64'h0005; NUM1 = 64'h0000; #1;
        $display("[div] NUM0 / 0 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("DIV_BY_ZERO_EXCEPTION = %b", DIV_BY_ZERO_EXCEPTION);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0005; NUM0 = 64'h00FF; NUM1 = 64'h0F0F; #1;
        $display("[and] NUM0 & NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0006; NUM0 = 64'h00FF; NUM1 = 64'h0F0F; #1;
        $display("[or] NUM0 | NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0007; NUM0 = 64'h00FF; NUM1 = 64'h0F0F; #1;
        $display("[xor] NUM0 ^ NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0008; NUM0 = 64'h0000; #1;
        $display("[not] ~NUM0 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h0009; NUM0 = 64'h0001; NUM1 = 64'h0004; #1;
        $display("[lshft] NUM0 << NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h000A; NUM0 = 64'h0010; NUM1 = 64'h0002; #1;
        $display("[rshft] NUM0 >> NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'h000B; NUM0 = 64'hFFFFFFFFFFFFFFF0; NUM1 = 64'h0002; #1;
        $display("[asr] NUM0 >>> NUM1 = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("");

        OPCODE = 16'hFFFF; #1;
        $display("[unknown] = (hex=%0h, dec=%0d, bin=%0b)", SUM, SUM, SUM);
        $display("OVERFLOW_FLAG = %b", OVERFLOW_FLAG);
        $display("UNKNOWN_OPCODE_EXCEPTION = %b", UNKNOWN_OPCODE_EXCEPTION);
        $display("================");
    end
endmodule