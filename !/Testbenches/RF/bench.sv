// test-bench passed x2 [07.08.2026]

module RF (
    input  logic        CLK,
    input  logic        WE,
    input  logic        RST,
    input  logic [4:0]  RD_ADDR,
    input  logic [4:0]  WR_ADDR,
    input  logic [63:0] DATA_INPUT,
    output logic [63:0] DATA_OUT
);
    logic [63:0] rx [0:31];             // 32x64
    assign DATA_OUT = rx[RD_ADDR];

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

///////////////////////////////////////////////////////////////////
// if you need to synthes this module, delete 'testbench' module//
/////////////////////////////////////////////////////////////////
module testbench;
    logic        CLK;
    logic        WE;
    logic        RST;
    logic [4:0]  RD_ADDR;
    logic [4:0]  WR_ADDR;
    logic [63:0] DATA_INPUT;
    logic [63:0] DATA_OUT;

    RF rf (
        .CLK(CLK),
        .WE(WE),
        .RST(RST),
        .RD_ADDR(RD_ADDR),
        .WR_ADDR(WR_ADDR),
        .DATA_INPUT(DATA_INPUT),
        .DATA_OUT(DATA_OUT)
    );

    always #5 CLK = ~CLK;

    initial begin
        $display("=== RF | TB ===");

        CLK = 0;
        WE = 0;
        RST = 0;
        RD_ADDR = 5'd0;
        WR_ADDR = 5'd0;
        DATA_INPUT = 64'h0000000000000000;
        #10;

        $display("[reset] DATA_OUT=%0h", DATA_OUT);
        $display("");

        RST = 1;
        #10;
        RST = 0;
        #10;

        RD_ADDR = 5'd0;
        #10;
        $display("[after_reset_r0] DATA_OUT=%0h", DATA_OUT);
        $display("");

        WE = 1;
        WR_ADDR = 5'd1;
        DATA_INPUT = 64'hDEADBEEFDEADBEEF;
        #10;
        WE = 0;
        #10;

        RD_ADDR = 5'd1;
        #10;
        $display("[write_read_r1] DATA_OUT=%0h", DATA_OUT);
        $display("");

        WE = 1;
        WR_ADDR = 5'd31;
        DATA_INPUT = 64'hFFFFFFFFFFFFFFFF;
        #10;
        WE = 0;
        #10;

        RD_ADDR = 5'd31;
        #10;
        $display("[write_read_r31] DATA_OUT=%0h", DATA_OUT);
        $display("");

        WE = 1;
        WR_ADDR = 5'd0;
        DATA_INPUT = 64'hCAFEBABECAFEBABE;
        #10;
        WE = 0;
        #10;

        RD_ADDR = 5'd0;
        #10;
        $display("[write_read_r0] DATA_OUT=%0h", DATA_OUT);
        $display("");

        RD_ADDR = 5'd1;
        #10;
        $display("[verify_r1] DATA_OUT=%0h", DATA_OUT);
        $display("");

        WE = 1;
        WR_ADDR = 5'd1;
        DATA_INPUT = 64'h0000000000000000;
        #10;
        WE = 0;
        #10;

        RD_ADDR = 5'd1;
        #10;
        $display("[overwrite_r1] DATA_OUT=%0h", DATA_OUT);
        $display("");

        RST = 1;
        #10;
        RST = 0;
        #10;

        RD_ADDR = 5'd0;
        #10;
        $display("[final_reset_r0] DATA_OUT=%0h", DATA_OUT);

        RD_ADDR = 5'd1;
        #10;
        $display("[final_reset_r1] DATA_OUT=%0h", DATA_OUT);

        RD_ADDR = 5'd31;
        #10;
        $display("[final_reset_r31] DATA_OUT=%0h", DATA_OUT);
        $display("================");
        $finish;
    end
endmodule