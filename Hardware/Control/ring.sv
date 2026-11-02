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

module RING
(
    input  logic       clk,
    input  logic       reset,
    input  logic       write,

    input  logic       ring_in,

    output logic       ring
);
    always_ff @(posedge clk) begin
        if (reset) begin
            ring <= 0;
        end
        else if (write) begin
            ring <= ring_in;
        end
    end
endmodule
