module RF (
    input  logic        clk,rst,we,
    input  logic [4:0]  wr_addr,            // for dst
    input  logic [4:0]  rd_addr0,rd_addr1,  // for src0, src1
    input  logic [63:0] data,
    output logic [63:0] data_out0,data_out1
);
    logic [63:0] rx [0:31];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                rx[i] <= 64'b0;
            end
        end else if (we) begin
            rx[wr_addr] <= data;
        end
    end
    assign data_out0 = rx[rd_addr0];
    assign data_out1 = rx[rd_addr1];
endmodule

module ALU (
    input  logic [8:0]  operation,
    input  logic [63:0] num0,num1,
    output logic [63:0] sum,
    output logic        ov,dz,uo        // overflow_flag, div_by_zero_exception, unknown_opcode
);
    always_comb begin
        sum        = 64'b0;
        {ov,dz,uo} = 3'b0;

        case (operation)
            9'h001: {ov,sum} = num0 + num1;
            9'h002: {ov,sum} = num0 - num1;
            9'h003: {ov,sum} = num0 * num1;
            9'h004: begin
                if (num1 != 64'b0) begin
                    {ov,sum} = num0 / num1;
                end else begin
                    sum = 64'b0;
                    dz  = 1'b1;
                end
            end
            default: begin
                sum = 64'b0;
                uo  = 1'b1;
            end
        endcase
    end
endmodule

module DCD (
    input  logic [63:0] instruction,
    output logic [8:0]  opcode,
    output logic [4:0]  reg_dst,reg_src0,reg_src1,
    output logic [39:0] imm
);
    always_comb begin
        opcode   = instruction[63:55];
        reg_dst  = instruction[54:50];
        reg_src0 = instruction[49:45];
        reg_src1 = instruction[44:40];
        imm      = instruction[39:0];
    end
endmodule

module ROM (
    input   logic [15:0] addr,
    output  logic [63:0] instruction
);
    logic [63:0] rom [0:65535];

    initial begin
        for (int i = 0; i < 65536; i++) begin
            rom[i] = 64'b0;
        end
        $readmemh("/home/dreamy/VN/ARCH-4/Firmware/firmware.hex", rom);
    end
    assign instruction = rom[addr];
endmodule

module PC (
    input  logic        clk,next,rst,
    output logic [15:0] count 
);
    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 16'b0;
        end else if (next) begin
            count <= count + 1;
        end
    end
endmodule

module CU (
    input  logic clk,rst,we
);

endmodule