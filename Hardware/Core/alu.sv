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
            0: result = a + b;
            1: result = a - b;
            2: result = a * b;
            3: begin
                if (b != 0) begin
                    result = a / b;
                end
                else begin
                    result = 0;
                end
            end
            4: result = a & b;
            5: result = a ^ b;
            6: result = ~a;
            7: result = a | b;
            8: result = a << b;
            9: result = a >> b;
            'hA: result = $unsigned($signed(a) <<< b);
            'hB: result = $unsigned($signed(a) >>> b);
            'hC: result = $unsigned($signed(a) * $signed(b));
            'hD: begin
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
