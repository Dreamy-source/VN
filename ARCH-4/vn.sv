interface RF_if;
    logic        clk;
    logic        rst,we;
    logic [4:0]  wr_addr;
    logic [63:0] data;

    modport rf (input clk, rst, we, wr_addr, data); 
endinterface

interface ALU_if;
    logic [8:0]  operation;
    logic [63:0] num0,num1;
    logic [63:0] sum;

    modport alu (
        input  operation, num0, num1
        output sum
    );
endinterface


module ALU (ALU_if.alu intf);

endmodule

module RF (RF_if.rf intf);
    logic [63:0] rx [0:31];

    always_ff @(posedge intf.clk) begin
        if (intf.rst) begin
            for (int i = 0; i < 32; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (intf.we) begin
            rx[intf.wr_addr] <= intf.data;
        end
    end
endmodul