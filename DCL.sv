// DCL (Device Control Lines)
module DCL (
    input  logic       CLK,
    input  logic [7:0] DEVICE_LINE_ADDR,           // 11111111 = 255 (max)
);
    always_ff @(posedge CLK) begin
        // MMIO
        case (DEVICE_LINE_ADDR)
            8'h01: begin end                       // 0x01 - UART
        endcase
    end
endmodule