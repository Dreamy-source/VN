// Interrupt Control Lines
// TODO: MMIO (Memory-Mapped I/O)
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