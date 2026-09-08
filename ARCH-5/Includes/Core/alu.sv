module ALU (
    input  logic [4:0]  Operation,
    input  logic [63:0] A, B,
    output logic [63:0] Result
);
    always_comb begin
        case (Operation)
            5'h00: Result = A + B;
            5'h01: Result = A - B;
            5'h02: Result = A * B;
            5'h03: Result = A / B;
            default: Result = 0;
        endcase
    end
endmodule