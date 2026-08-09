// PC (Program Counter)
module PC (
    input  logic        CLK,
    input  logic        RST,
    input  logic [63:0] NEXT_COUNT,
    input  logic        NEXT_COUNT_FLAG,
    output logic [63:0] COUNT
);
    always_ff @(posedge CLK) begin
        if (RST) begin
            COUNT <= 64'b0;
        end else if (NEXT_COUNT_FLAG) begin
            COUNT <= NEXT_COUNT;
        end else begin
            COUNT <= COUNT + 64'b1;
        end
    end
endmodule