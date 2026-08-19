// DCL (Device Control Lines)
module DCL (
    input  logic         CLK,
    input  logic [15:0]  OPCODE,
    input  logic         DEVICE_LINE_SET,
    input  logic         DEVICE_LINES_RESET,
    input  logic [7:0]   DEVICE_LINE_ADDR,     // 11111111 = 255 (max)
    output logic [255:0] DEVICE_LINES          // [1 - UART] [2 - TIMER] [3 - ...]
);
    always_ff @(posedge CLK) begin
        case (OPCODE)
            16'h000D: begin                    // dclr (device lines reset)
                if (DEVICE_LINES_RESET) begin
                    DEVICE_LINES <= 256'b0;
                end
            end
            16'h000E: begin                    // dcls 1 | 1  (LINE ADDR, BIT)
                // MMIO
                case (DEVICE_LINE_ADDR)
                    8'h01: begin DEVICE_LINES[1] <= DEVICE_LINE_SET; end   // 0x01 - UART
                    8'h02: begin DEVICE_LINES[2] <= DEVICE_LINE_SET; end   // 0x02 - TIMER
                endcase
            end
        endcase
    end
endmodule

