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

module MEM
(
    input  logic        clk,
    input  logic        write,

    input  logic [19:0] wr_addr,
    input  logic [63:0] wr_data,

    input  logic [19:0] rd_addr,
    output logic [63:0] rd_data
);
    logic [63:0] mem [0:(1 << 20) - 1];

    always_ff @(posedge clk) begin
        if (write) begin
            mem[wr_addr] <= wr_data;
        end
    end
    assign rd_data = mem[rd_addr];
endmodule
