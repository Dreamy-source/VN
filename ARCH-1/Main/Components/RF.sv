// Register File
module RF (
    input  logic        CLK,
    input  logic        WE,
    input  logic        RST,
    input  logic [4:0]  RD_ADDR0,
    input  logic [4:0]  RD_ADDR1,
    input  logic [4:0]  WR_ADDR,
    input  logic [63:0] DATA_INPUT,
    output logic [63:0] DATA_OUT0,
    output logic [63:0] DATA_OUT1
);
    logic [63:0] rx [0:31];             // 32x64
    assign DATA_OUT0 = rx[RD_ADDR0];
    assign DATA_OUT1 = rx[RD_ADDR1];

    always_ff @(posedge CLK) begin
        if (RST) begin
            for (int i = 0; i < 32; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (WE) begin
            rx[WR_ADDR] <= DATA_INPUT;
        end
    end
endmodule


