module MMIO
(
    input  logic clock, reset, writeEnable
);
    always_ff @(posedge clock) begin
        if (reset) begin
            
        end
    end
endmodule
