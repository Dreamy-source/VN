module RF
(
    input  logic        clk,
    input  logic        reset,
    input  logic        write,

    input  logic [4:0]  wr_addr,
    input  logic [63:0] wr_data,

    input  logic [4:0]  rd_addr0,
    output logic [63:0] rd_data0,

    input  logic [4:0]  rd_addr1,
    output logic [63:0] rd_data1
);
    logic [63:0] x [0:31];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                x[i] <= 0;
            end
        end
        else if (write && wr_addr != 0) begin
            x[wr_addr] <= wr_data;
        end
    end
    assign rd_data0 = x[rd_addr0];
    assign rd_data1 = x[rd_addr1];
endmodule
