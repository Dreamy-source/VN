module ALU
(
    input  logic [10:0] Operation,
    input  logic [63:0] A, B,
    output logic [63:0] Result
);
    always_comb begin
        case (Operation)
            11'h000: Result = A + B;
            11'h001: Result = A - B;
            11'h002: Result = A * B;
            11'h003: Result = (B == 0) ? 0 : A / B;
            11'h004: Result = A & B;
            11'h005: Result = A | B;
            11'h006: Result = A ^ B;
            11'h007: Result =~A;
            11'h008: Result = A << B;
            11'h009: Result = A >> B;
            default: Result = 0;
        endcase
    end
endmodule
