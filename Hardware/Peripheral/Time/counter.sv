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
