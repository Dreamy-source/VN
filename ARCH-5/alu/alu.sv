// []
// | VN
// | Contributed by:
// |  | Dreamy-source (owner)
// |  | Discord: ilikethenature
// |  []
// | Last edited: 19.08.2026
// []

module alu #(
    parameter Bits = 64,                // Bits for main inputs (A, B, Sum etc.)
    parameter Operations = 4            // Max operations in binary (decimal = 16)
) (
    input  logic [Operations-1:0] SelectOperation,    // Select ALU operation (MUX)
    input  logic [Bits-1:0]       A, B,               // Operands
    output logic [Bits-1:0]       Result,             // Result of operands
    output logic                  OverflowBit,        // If Result > 64-bits, value: OverflowBit = 1
    output logic                  DivideZeroBit       // If B = 0, value: DivideZeroBit = 1, Result = 0
);
    // Block diagram in file: alu/alu.drawio
    always_comb begin : ALU_Logic
        // First initiate
        Result = '0;
        OverflowBit = 1'b0;
        DivideZeroBit = 1'b0;
        case (SelectOperation)
            4'b0000: {OverflowBit, Result} = A + B;    // ADD (0x0)
            4'b0001: {OverflowBit, Result} = A - B;    // SUB (0x1)
            4'b0010: {OverflowBit, Result} = A * B;    // MUL (0x2)
            4'b0011: begin                             // DIV (0x3)
                if (B != '0) begin {OverflowBit, Result} = A / B; end
                else begin
                    Result = '0;
                    DivideZeroBit = 1'b1;
                end
            end
            default: begin
                // Default values
                Result = '0;
                OverflowBit = 1'b0;
                DivideZeroBit = 1'b0;
            end
        endcase
    end
endmodule