module RF (
    input  logic        CLK,
    input  logic        WE,
    input  logic        RST,
    input  logic [4:0]  WR_ADDR_REG_0,     // dst
    input  logic [4:0]  RD_ADDR_REG_1,     // src0
    input  logic [4:0]  RD_ADDR_REG_2,     // src1
    input  logic [63:0] DATA_INPUT,
    output logic [63:0] DATA_OUTPUT_REG_1,  // src0
    output logic [63:0] DATA_OUTPUT_REG_2   // src1
);
    logic [63:0] rx [0:31];

    assign DATA_OUTPUT_REG_1 = rx[RD_ADDR_REG_1];
    assign DATA_OUTPUT_REG_2 = rx[RD_ADDR_REG_2];

    always_ff @(posedge CLK) begin
        if (RST) begin
            for (int i = 0; i < 32; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (WE) begin
            rx[WR_ADDR_REG_0] <= DATA_INPUT;    // если WE, тогда записать в регистр N на вход значение
        end
    end
endmodule