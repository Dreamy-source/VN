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

module POWER
(
    input  logic       clk,
    input  logic       enable,
    input  logic       reset,

    input  logic [5:0] wr_addr,
    input  logic       wr_data,
    output logic       pwrvec [0:63]
);
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 64; i++) begin
                pwrvec[i] <= 0;
            end
        end
        else if (enable) begin
            pwrvec[wr_addr] <= wr_data;
        end
    end
endmodule
