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

module ALU (
    input  logic [8:0]  operation,      // opcode
    input  logic [63:0] num0,num1,
    output logic [63:0] sum,
    output logic        ov,dz,uo        // overflow_flag, div_by_zero_exception, unknown_opcode_exception
);
    always_comb begin
        ov = 1'b0;
        dz = 1'b0;
        uo = 1'b0;

        case (operation)
            9'h001: {ov,sum} = num0 + num1;
            9'h002: {ov,sum} = num0 - num1;
            9'h003: {ov,sum} = num0 * num1;
            9'h004: if (num1 != 64'b0) {ov,sum} = num0 / num1; else dz = 1'b1; 
            default: sum = 64'b0; uo = 1'b1;
        endcase
    end
endmodule

module DCD (
    input  logic [63:0] instruction,
    output logic [8:0]  opcode,
    output logic [4:0]  reg_dst,reg_src0,reg_src1,
    output logic [39:0] immediate
);
    always_comb begin
        opcode    =  instruction[63:55];
        reg_dst   =  instruction[54:50];
        reg_src0  =  instruction[49:45];
        reg_src1  =  instruction[44:40];
        immediate =  instruction[39:0];
    end
endmodule

module CU;
    logic        rf_clk,rf_we,rf_rst;
    logic [4:0]  rf_rd_addr,rd_wr_addr;
    logic [63:0] rf_data_in,rf_data_out;

    logic [8:0]  alu_operation;
    logic [63:0] alu_num0,alu_num1;
    logic [63:0] alu_sum;
    logic        alu_ov,alu_dz,alu_uo;

    logic [63:0] dcd_instruction;
    logic [8:0]  dcd_opcode;
    logic [4:0]  dcd_reg_dst,dcd_reg_src0,dcd_reg_src1;
    logic [39:0] dcd_immediate;

    RF rf (
        .clk(rf_clk),.we(rf_we),.rst(rf_rst),
        .rd_addr(rf_rd_addr),.wr_addr(rf_wr_addr),
        .data_in(rf_data_in),.data_out(rf_data_out)
    );
    ALU alu (
        .operation(alu_operation),
        .num0(alu_num0),.num1(alu_num1),
        .sum(alu_sum),
        .ov(alu_ov),.dz(alu_dz),.uo(alu_ou)
    );
    DCD dcd (
        .instruction(dcd_instruction),
        .opcode(dcd_opcode),
        .reg_dst(dcd_reg_dst),.reg_src0(dcd_reg_src0),.reg_src1(dcd_reg_src1),
        .immediate(dcd_immediate)
    );
endmodule