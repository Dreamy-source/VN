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

module STACK
(
    input  logic        clk,
    input  logic        reset,
    input  logic        push,
    input  logic        pop,

    input  logic [19:0] align,

    input  logic [19:0] stack_start,
    input  logic [19:0] stack_limit,

    output logic [19:0] sp,

    output logic        mf_exception
);
    logic [19:0] stack_start_act, stack_limit_act;
    logic [19:0] align_act;
    
    always_comb begin
        stack_start_act = stack_start;
        stack_limit_act = stack_limit;

        if (stack_start >= 20'h00000 && stack_start <= 20'h00fff) begin
            stack_start_act = 20'h10000;
        end

        if (stack_limit >= 20'h00000 && stack_limit <= 20'h00fff) begin
            stack_limit_act = 20'hfffff;
        end

        if (align == 0) begin
            align_act = 4;
        end else begin
            align_act = align;
        end
    end

    always_ff @(posedge clk) begin
        mf_exception <= 0;

        if (reset) begin
            sp <= stack_start_act;
        end
        else if (push) begin
            if (sp >= stack_limit_act) begin
                mf_exception <= 1;
                sp <= stack_start_act;
            end else begin
                sp <= sp + align_act;
            end
        end
        else if (pop) begin
            if (sp <= stack_start_act) begin
                mf_exception <= 1;
                sp <= stack_start_act;
            end else begin
                sp <= sp - align_act;
            end
        end
    end
endmodule
