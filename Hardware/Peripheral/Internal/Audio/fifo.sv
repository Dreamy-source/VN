module FIFO
(
    input  logic        clk,
    input  logic        reset,
    input  logic        write,
    input  logic        take,

    input  logic [23:0] data_in,
    output logic [23:0] data_out,

    output logic        empty,
    output logic        full
);
    logic [23:0] fifo [0:2047];
    logic [10:0] wr_addr, rd_addr;
    logic [10:0] ptr;

    assign empty = (ptr == 0);
    assign full = (ptr == 2048);

    always_ff @(posedge clk) begin
        if (reset) begin
            wr_addr <= 0;
            rd_addr <= 0;
            ptr <= 0;
        end

        else if (write && !full) begin
            fifo[wr_addr] <= data_in;
            wr_addr <= wr_addr + 1;
            ptr <= ptr + 1;
        end
        if (take && !empty) begin
            data_out <= fifo[rd_addr];
            rd_addr <= rd_addr + 1;
            ptr <= ptr - 1;
        end
    end
endmodule
