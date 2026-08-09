module RF (
    input  logic        CLK,
    input  logic        WE,
    input  logic        RST,
    input  logic [4:0]  WRITE_ADDR,
    input  logic [63:0] DATA_INPUT
);
    logic [63:0] rx [0:31];

    always_ff @(posedge CLK) begin
        if (RST) begin
            for (int i = 0; i < 32; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (WE) begin
            rx[WRITE_ADDR] <= DATA_INPUT;    // если WE, тогда записать в регистр N на вход значение
        end
    end
endmodule

module TB;
    logic        CLK;
    logic        WE;
    logic        RST;
    logic [4:0]  WRITE_ADDR;
    logic [63:0] DATA_INPUT;

    RF rf (.*);

    always #5 CLK = ~CLK;

    initial begin
        $display("register count: %0d", $size(rf.rx));

        for (int i = 0; i < 32; i++) begin
            $display("rx[%0d] = 0x%0h", i, rf.rx[i]);
        end
        $finish;
    end
endmodule