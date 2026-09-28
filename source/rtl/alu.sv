module alu (
    input  logic [7:0]  opcode,
    input  logic [63:0] a, b,
    output logic [63:0] result
);
    localparam ADD = 8'h00;
    localparam SUB = 8'h01;
    localparam MUL = 8'h02;
    localparam DIV = 8'h03;

    always_comb begin
        case (opcode)
            ADD: result = a + b;
            SUB: result = a - b;
            MUL: result = a * b;
            DIV: result = a / b;
            default: result = 0;
        endcase
    end
endmodule
