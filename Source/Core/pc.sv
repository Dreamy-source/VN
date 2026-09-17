module PC
(
    input  logic        clock, reset, next,
    output logic [15:0] CurrentAddress
);
    always_ff @(posedge clock) begin
        if (reset) begin
            CurrentAddress <= 0;
        end else if (next) begin
            CurrentAddress <= CurrentAddress + 1;
        end
    end
endmodule
