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
    
    always_comb begin
        stack_start_act = stack_start;
        stack_limit_act = stack_limit;

        if (stack_start >= 20'h00000 && stack_start <= 20'h00fff) begin
            stack_start_act = 20'h10000;
        end

        if (stack_limit >= 20'h00000 && stack_limit <= 20'h00fff) begin
            stack_limit_act = 20'hfffff;
        end
    end

    always_ff @(posedge clk) begin
        mf_exception <= 0;

        if (reset) begin
            sp <= stack_start_act;
        end
        else if (push) begin
            if (sp >= stack_limit_act || align == 0) begin
                mf_exception <= 1;
                sp <= stack_start_act;
            end else begin
                sp <= sp + align;
            end
        end
        else if (pop) begin
            if (sp <= stack_start_act || align == 0) begin
                mf_exception <= 1;
                sp <= stack_start_act;
            end else begin
                sp <= sp - align;
            end
        end
    end
endmodule
