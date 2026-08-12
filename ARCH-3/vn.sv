module RF (
    input  logic        clk,we,rst,
    input  logic [4:0]  rd_addr,
    input  logic [4:0]  wr_addr,
    input  logic [63:0] data_in,
    output logic [63:0] data_out
);
    logic [63:0] rx [0:31];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (we) begin
            rx[wr_addr] <= data_in;
        end
    end
    assign data_out = rx[rd_addr];
endmodule