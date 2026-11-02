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

module DPU
(
    input  logic        clk,

    // IF
    input  logic [31:0] instr,

    output logic [7:0]  op,
    output logic [4:0]  wr,
    output logic [4:0]  rd0,
    output logic [4:0]  rd1,
    output logic [8:0]  imm,

    // delete: отдаем alu (идут в top)
    output logic [7:0]  alu_op,
    output logic [63:0] alu_a, alu_b,

    // delete: данные из rf (приходят из top)
    input  logic [63:0] rf_rd0, rf_rd1
);
    // ID
    always_comb begin
        op = instr[31:24];
        wr = instr[23:19];
        rd0 = instr[18:14];
        rd1 = instr[13:9];
        imm = instr[8:0];
    end

    // EX
    always_ff @(posedge clk) begin
        alu_op <= op;
        alu_a <= rf_rd0;
        alu_b <= rf_rd1;
    end
endmodule
