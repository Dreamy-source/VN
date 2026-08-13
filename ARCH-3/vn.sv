module RF (
    input  logic        clk,we,rst,
    input  logic [4:0]  rd_addr0,rd_addr1,
    input  logic [4:0]  wr_addr,
    input  logic [63:0] data_in,
    output logic [63:0] reg_rd_addr_data_out0,reg_rd_addr_data_out1
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

    assign reg_rd_addr_data_out0 = rx[rd_addr0];
    assign reg_rd_addr_data_out1 = rx[rd_addr1];
endmodule

module ALU (
    input  logic [8:0]  operation,      // opcode
    input  logic [63:0] num0,num1,
    output logic [63:0] sum,
    output logic        ov,dz,uo        // overflow_flag, div_by_zero_exception, unknown_opcode_exception
);
    always_comb begin
        sum = 64'b0;
        ov  = 1'b0;
        dz  = 1'b0;
        uo  = 1'b0;

        case (operation)
            9'h001: {ov,sum} = num0 + num1;
            9'h002: {ov,sum} = num0 - num1;
            9'h003: sum      = num0 * num1;
            9'h004: begin if (num1 != 64'b0) begin sum = num0 / num1; end else begin sum = 64'b0; dz  = 1'b1; end end
            default: begin sum = 64'b0; uo = 1'b1; end
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
    logic        rf_clk, rf_we, rf_rst;
    logic [4:0]  rf_rd_addr0, rf_rd_addr1, rf_wr_addr;
    logic [63:0] rf_data_in;
    logic [63:0] rf_reg_rd_addr_data_out0, rf_reg_rd_addr_data_out1;

    logic [8:0]  alu_operation;
    logic [63:0] alu_num0, alu_num1;
    logic [63:0] alu_sum;
    logic        alu_ov, alu_dz, alu_uo;

    logic [63:0] dcd_instruction;
    logic [8:0]  dcd_opcode;
    logic [4:0]  dcd_reg_dst, dcd_reg_src0, dcd_reg_src1;
    logic [39:0] dcd_immediate;

    RF rf (
        .clk(rf_clk),.we(rf_we),.rst(rf_rst),
        .rd_addr0(rf_rd_addr0),.rd_addr1(rf_rd_addr1),.wr_addr(rf_wr_addr),
        .data_in(rf_data_in),.reg_rd_addr_data_out0(rf_reg_rd_addr_data_out0),.reg_rd_addr_data_out1(rf_reg_rd_addr_data_out1)
    );
    ALU alu (
        .operation(alu_operation),
        .num0(alu_num0),.num1(alu_num1),
        .sum(alu_sum),
        .ov(alu_ov),.dz(alu_dz),.uo(alu_uo)
    );
    DCD dcd (
        .instruction(dcd_instruction),
        .opcode(dcd_opcode),
        .reg_dst(dcd_reg_dst),.reg_src0(dcd_reg_src0),.reg_src1(dcd_reg_src1),
        .immediate(dcd_immediate)
    );

    // кого = к_кому
    assign alu_operation =  dcd_opcode;
    assign alu_num0      =  rf_reg_rd_addr_data_out0;
    assign alu_num1      =  rf_reg_rd_addr_data_out1;
    assign rf_wr_addr    =  dcd_reg_dst;
    assign rf_rd_addr0   =  dcd_reg_src0;
    assign rf_rd_addr1   =  dcd_reg_src1;
    assign rf_data_in    =  (dcd_opcode == 9'h00C) ? {24'b0, dcd_immediate} : alu_sum;
endmodule