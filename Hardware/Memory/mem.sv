module MEM
(
    input  logic        clk,
    input  logic        write,

    input  logic [19:0] wr_addr,
    input  logic [63:0] wr_data,

    input  logic [19:0] rd_addr,
    output logic [63:0] rd_data
);
    logic [63:0] mem [0:(1 << 20) - 1];

    always_ff @(posedge clk) begin
        if (write) begin
            mem[wr_addr] <= wr_data;
        end
    end
    assign rd_data = mem[rd_addr];
endmodule
