// test-bench passed x3 [07.08.2026]

// Master Interrupt Controller
module ICL (
    input  logic         CLK,
    input  logic         ICTL_R,
    input  logic         ICTL_E,
    input  logic [6:0]   RD_CATALOG_FLAG,
    input  logic [6:0]   RD_CATALOG_STATUS,
    input  logic [6:0]   INTERRUPT_LINE_ADDR,
    input  logic         INTERRUPT_LINE_FLAG,
    input  logic         INTERRUPT_LINE_STATUS,               // 0 - REJECTED, 1 - PENDING
    output logic [127:0] INTERRUPT_CATALOG_FLAG,
    output logic [127:0] INTERRUPT_CATALOG_STATUS,
    output logic         RD_INTERRUPT_CATALOG_FLAG,
    output logic         RD_INTERRUPT_CATALOG_STATUS
);

    // ICTL_R - Interrupt Catalog Reset
    // ICTL_E - Interrupt Catalog Enable

    always_ff @(posedge CLK) begin
        if (ICTL_R) begin
            INTERRUPT_CATALOG_FLAG   <= 128'b0;
            INTERRUPT_CATALOG_STATUS <= 128'b0;
        end else if (ICTL_E) begin
            INTERRUPT_CATALOG_FLAG[INTERRUPT_LINE_ADDR]   <= INTERRUPT_LINE_FLAG;
            INTERRUPT_CATALOG_STATUS[INTERRUPT_LINE_ADDR] <= INTERRUPT_LINE_STATUS;
        end
    end

    assign RD_INTERRUPT_CATALOG_FLAG   = INTERRUPT_CATALOG_FLAG[RD_CATALOG_FLAG];            // ictlif
    assign RD_INTERRUPT_CATALOG_STATUS = INTERRUPT_CATALOG_STATUS[RD_CATALOG_STATUS];        // ictlis
endmodule

///////////////////////////////////////////////////////////////////
// if you need to synthes this module, delete 'testbench' module//
/////////////////////////////////////////////////////////////////
module testbench;
    logic         CLK;
    logic         ICTL_R;
    logic         ICTL_E;
    logic [6:0]   RD_CATALOG_FLAG;
    logic [6:0]   RD_CATALOG_STATUS;
    logic [6:0]   INTERRUPT_LINE_ADDR;
    logic         INTERRUPT_LINE_FLAG;
    logic         INTERRUPT_LINE_STATUS;
    logic [127:0] INTERRUPT_CATALOG_FLAG;
    logic [127:0] INTERRUPT_CATALOG_STATUS;
    logic         RD_INTERRUPT_CATALOG_FLAG;
    logic         RD_INTERRUPT_CATALOG_STATUS;

    ICL icl (
        .CLK(CLK),
        .ICTL_R(ICTL_R),
        .ICTL_E(ICTL_E),
        .RD_CATALOG_FLAG(RD_CATALOG_FLAG),
        .RD_CATALOG_STATUS(RD_CATALOG_STATUS),
        .INTERRUPT_LINE_ADDR(INTERRUPT_LINE_ADDR),
        .INTERRUPT_LINE_FLAG(INTERRUPT_LINE_FLAG),
        .INTERRUPT_LINE_STATUS(INTERRUPT_LINE_STATUS),
        .INTERRUPT_CATALOG_FLAG(INTERRUPT_CATALOG_FLAG),
        .INTERRUPT_CATALOG_STATUS(INTERRUPT_CATALOG_STATUS),
        .RD_INTERRUPT_CATALOG_FLAG(RD_INTERRUPT_CATALOG_FLAG),
        .RD_INTERRUPT_CATALOG_STATUS(RD_INTERRUPT_CATALOG_STATUS)
    );

    always #5 CLK = ~CLK;

    initial begin
        $display("=== MIC | TB ===");

        CLK = 0;
        ICTL_R = 0;
        ICTL_E = 0;
        RD_CATALOG_FLAG = 7'd0;
        RD_CATALOG_STATUS = 7'd0;
        INTERRUPT_LINE_ADDR = 7'd0;
        INTERRUPT_LINE_FLAG = 0;
        INTERRUPT_LINE_STATUS = 0;
        #10;

        $display("[reset] CATALOG_FLAG=%0h CATALOG_STATUS=%0h", INTERRUPT_CATALOG_FLAG, INTERRUPT_CATALOG_STATUS);
        $display("");

        ICTL_R = 1;
        #10;
        ICTL_R = 0;
        #10;

        $display("[after_reset] CATALOG_FLAG=%0h CATALOG_STATUS=%0h", INTERRUPT_CATALOG_FLAG, INTERRUPT_CATALOG_STATUS);
        $display("");

        ICTL_E = 1;
        INTERRUPT_LINE_ADDR = 7'd3;
        INTERRUPT_LINE_FLAG = 1;
        INTERRUPT_LINE_STATUS = 1;
        #10;

        $display("[set_line_3] CATALOG_FLAG[3]=%b CATALOG_STATUS[3]=%b", INTERRUPT_CATALOG_FLAG[3], INTERRUPT_CATALOG_STATUS[3]);
        $display("");

        INTERRUPT_LINE_ADDR = 7'd7;
        INTERRUPT_LINE_FLAG = 1;
        INTERRUPT_LINE_STATUS = 0;
        #10;

        $display("[set_line_7] CATALOG_FLAG[7]=%b CATALOG_STATUS[7]=%b", INTERRUPT_CATALOG_FLAG[7], INTERRUPT_CATALOG_STATUS[7]);
        $display("");

        INTERRUPT_LINE_ADDR = 7'd127;
        INTERRUPT_LINE_FLAG = 1;
        INTERRUPT_LINE_STATUS = 1;
        #10;

        $display("[set_line_127] CATALOG_FLAG[127]=%b CATALOG_STATUS[127]=%b", INTERRUPT_CATALOG_FLAG[127], INTERRUPT_CATALOG_STATUS[127]);
        $display("");

        RD_CATALOG_FLAG = 7'd3;
        RD_CATALOG_STATUS = 7'd3;
        #10;

        $display("[read_line_3] RD_FLAG=%b RD_STATUS=%b", RD_INTERRUPT_CATALOG_FLAG, RD_INTERRUPT_CATALOG_STATUS);
        $display("");

        RD_CATALOG_FLAG = 7'd7;
        RD_CATALOG_STATUS = 7'd7;
        #10;

        $display("[read_line_7] RD_FLAG=%b RD_STATUS=%b", RD_INTERRUPT_CATALOG_FLAG, RD_INTERRUPT_CATALOG_STATUS);
        $display("");

        RD_CATALOG_FLAG = 7'd127;
        RD_CATALOG_STATUS = 7'd127;
        #10;

        $display("[read_line_127] RD_FLAG=%b RD_STATUS=%b", RD_INTERRUPT_CATALOG_FLAG, RD_INTERRUPT_CATALOG_STATUS);
        $display("");

        ICTL_E = 0;
        #10
        ICTL_R = 1;
        #10;
        ICTL_R = 0;
        #10;

        $display("[final_reset] CATALOG_FLAG=%0h CATALOG_STATUS=%0h", INTERRUPT_CATALOG_FLAG, INTERRUPT_CATALOG_STATUS);
        $display("================");
        $finish;
    end
endmodule