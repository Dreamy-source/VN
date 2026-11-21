interface REGFILE_INTF;
    logic clk;
    logic r;
    logic w;

    logic [4:0]  wr_addr_in;
    logic [31:0] wr_data_in;

    logic [4:0]  rd_addr_in0, rd_addr_in1;
    logic [31:0] rd_data_out0, rd_data_out1;

    modport bus (
        input clk, r, w,
              wr_addr_in, wr_data_in,
              rd_addr_in0, rd_addr_in1,

        output rd_data_out0, rd_data_out1
    );
endinterface

module REGFILE (
    REGFILE_INTF.bus bus
);
    logic [31:0] x [0:31];

    always_ff @(posedge bus.clk) begin
        if (bus.w && bus.wr_addr_in != 0) begin
            x[bus.wr_addr_in] = bus.wr_data_in;
        end
        if (bus.r) begin
            bus.rd_data_out0 = x[bus.rd_addr_in0];
            bus.rd_data_out1 = x[bus.rd_addr_in1];
        end
    end    
endmodule
