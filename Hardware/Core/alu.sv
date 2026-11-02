module ALU
(
    input  logic [7:0]  op,
    input  logic [63:0] a, b,
    
    output logic [63:0] result
);
    always_comb begin
        case (op)
            default: result = 0;
            8'h00: result = a + b;
            8'h01: result = a - b;
            8'h02: result = a * b;
            8'h03: begin
                if (b != 0) begin
                    result = a / b;
                end
                else begin
                    result = 0;
                end
            end
            8'h04: result = a & b;
            8'h05: result = a ^ b;
            8'h06: result = a | b;
            8'h07: result = ~a;
            8'h08: result = a << b;
            8'h09: result = a >> b;
            8'h0A: result = $unsigned($signed(a) * $signed(b));
            8'h0B: begin
                if ($signed(b) != 0) begin
                    result = $unsigned($signed(a) / $signed(b));
                end
                else begin
                    result = 0;
                end
            end
        endcase
    end
endmodule
