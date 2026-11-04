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

module PS2
(
    input  logic        clk,

    input  logic        ps2_clk,
    input  logic        ps2_data,
    
    output logic [7:0]  ps2_keycode,

    output logic        valid
);
    logic clk_prev;
    logic [10:0] shift_reg;
    logic [3:0] bit_cnt;

    always_ff @(posedge clk) begin
        clk_prev <= ps2_clk;
        valid <= 0;

        if (clk_prev == 1 && ps2_clk == 0) begin
            shift_reg <= {ps2_data, shift_reg[10:1]};
            bit_cnt <= bit_cnt + 1;

            if (bit_cnt == 10) begin
                bit_cnt <= 0;
                if (shift_reg[10] == 0 && ps2_data == 1) begin
                    ps2_keycode <= shift_reg[8:1];
                    valid <= 1;
                end
            end
        end
    end
endmodule
