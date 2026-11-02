// Copyright (c) 2026 Dreamy-source
// 
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2.
// 
// You may redistribute and modify this source and make products using it under
// the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).
// 
// This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
// INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
// PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
// 
// Source location: https://github.com/Dreamy-source/VN

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
