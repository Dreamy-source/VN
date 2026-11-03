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

module GPIO
(
    input  logic       clk,
    input  logic       reset,
    input  logic       write,

    input  logic [4:0] wr_addr,
    input  logic       wr_data,

    input  logic [4:0] rd_addr,
    output logic       rd_data,

    output logic       pin [0:31]
);
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                pin[i] <= 0;
            end
        end
        else if (write) begin
            pin[wr_addr] <= wr_data;
        end
    end
    assign rd_data = pin[rd_addr];
endmodule
