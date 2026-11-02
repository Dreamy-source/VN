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

module COUNTER
(
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,

    output logic [63:0] counter
);
    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 0;
        end
        else if (enable) begin
            counter <= counter + 1;
        end
    end
endmodule
