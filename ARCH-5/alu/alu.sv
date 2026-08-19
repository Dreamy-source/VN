module alu #(
    parameter Bits = 64,                // Bits for main inputs (A, B, Sum etc.)
    parameter Operations = 4            // Max operations in binary (decimal = 16)
) (
    input  logic [Operations-1:0] SelectOperation,    // Select ALU operation (MUX)
    input  logic [Bits-1:0]       A, B,               // Operands
    output logic [Bits-1:0]       Result              // Result of operands
    output logic                  OverflowFlag);      // If Result > 64-bits value: OverflowFlag = 1

    // Block diagram in file: alu/alu.drawio
    always_comb begin : ALU_Logic
        case (SelectOperation)
            4'b0000: {OverflowFlag, Result} = A + B;    // ADD (0x0)
            4'b0001: {OverflowFlag, Result} = A - B;    // SUB (0x1)
            4'b0010: {OverflowFlag, Result} = A * B;    // MUL (0x2)
            4'b0011: {OverflowFlag, Result} = A / B;    // DIV (0x3)
        endcase
    end
endmodule