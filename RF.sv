module RF (
    input  logic        CLK,
    input  logic        WE,
    input  logic        RST,
    input  logic [6:0]  RD_ADDR,        // В каком регистре читать данные
    input  logic [6:0]  WR_ADDR,        // В какой регистр ложить данные
    input  logic [63:0] DATA_INPUT,
    output logic [63:0] DATA_OUT
);
    logic [63:0] rx [0:127];            // 128x64
    assign DATA_OUT = rx[RD_ADDR];

    always_ff @(posedge CLK) begin
        if (RST) begin
            for (int i = 0; i < 128; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (WE) begin
            rx[WR_ADDR] <= DATA_INPUT;
        end
    end
endmodule