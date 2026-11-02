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
