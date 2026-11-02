module TIMER
(
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,

    input  logic [63:0] target,

    output logic [63:0] timer,

    output logic        ready
);
    always_ff @(posedge clk) begin
        if (reset) begin
            timer <= 0;
            ready <= 0;
        end
        else if (enable) begin
            if (target != 0 && timer >= target - 1) begin
                timer <= 0;
                ready <= 1;
            end
            else begin
                timer <= timer + 1;
                ready <= 0;
            end
        end
        else begin
            ready <= 0;
        end
    end
endmodule
