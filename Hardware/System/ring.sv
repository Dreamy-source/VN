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
