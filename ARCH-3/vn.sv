module RF (
    input  logic        clk,we,rst,
    input  logic [4:0]  rd_addr0,rd_addr1,
    input  logic [4:0]  wr_addr,
    input  logic [63:0] data_in,
    output logic [63:0] reg_rd_addr_data_out0,reg_rd_addr_data_out1
);
    logic [63:0] rx [0:31];
    logic [11:0] crrx;        // control-register

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
            9'h000: begin end                         // nothing
            9'h001: {ov,sum} = num0 +  num1;          // add
            9'h002: {ov,sum} = num0 -  num1;          // sub
            9'h003: sum      = num0 *  num1;          // mul
            9'h004: begin if (num1 != 64'b0) begin sum = num0 / num1; end else begin sum = 64'b0; dz  = 1'b1; end end  // div
            9'h005: {ov,sum} = num0 &  num1;          // and
            9'h006: {ov,sum} = num0 |  num1;          // or
            9'h007: {ov,sum} = num0 ^  num1;          // xor
            9'h008: {ov,sum} =~num1;                  // not
            9'h009: {ov,sum} = num0 << num1;          // lshft
            9'h00A: {ov,sum} = num0 >> num1;          // rshft
            9'h00B: {ov,sum} = $signed(num0) >>> num1;// asr
            default: begin
                sum = 64'b0;
                uo = 1'b1;
            end
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

module ROM (
    input  logic [15:0] addr,
    output logic [63:0] instruction
);
    logic [63:0] rom [0:65535];

    initial begin
        for (int i = 0; i < 65536; i++) begin
            rom[i] = 64'b0;
        end
        $readmemh("/home/dreamy/VN/ARCH-3/firmware/firmware.hex", rom);
    end
    
    assign instruction = rom[addr];
endmodule

module PC (
    input  logic        clk,
    input  logic        rst,
    input  logic        next,
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

module MMIO (
    input  logic [11:0] addr,
    input  logic        setbit,
    output logic        umd,          // unknown_mmio_device_exception

    output logic        UART,
    output logic        TIMER,
    output logic        GPIO [0:63]
);

    always_comb begin
        umd   = 1'b0;
        UART  = 1'b0;
        TIMER = 1'b0;

        for (int i = 0; i < 64; i++) begin
            GPIO[i] = 1'b0;
        end

        case (addr)
            12'h01: UART            = setbit;   // 0x01 - UART (Universal Asynchronous Receiver-Transmitter)
            12'h02: TIMER           = setbit;   // 0x02 - TIMER
            12'h03: GPIO[addr[5:0]] = setbit;   // 0x03 - GPIO (General-Purpose Input/Output)
            default: begin umd = 1'b1; end
        endcase
    end
endmodule

module CU (
    input  logic clk,rst
);
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

    logic [15:0] rom_addr;
    logic [63:0] rom_instruction;

    logic        pc_clk,pc_rst,pc_next;
    logic [15:0] pc_count;

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
    ROM rom (
        .addr(rom_addr),
        .instruction(rom_instruction)
    );
    PC pc (
        .clk(pc_clk),.rst(pc_rst),.next(pc_next),
        .count(pc_count)
    );

    assign rf_clk = clk;
    assign pc_clk = clk;
    assign rf_rst = rst;
    assign pc_rst = rst;

    // кого = к_кому
    assign alu_operation   =  dcd_opcode;
    assign alu_num0        =  rf_reg_rd_addr_data_out0;
    assign alu_num1        =  rf_reg_rd_addr_data_out1;
    assign rf_wr_addr      =  dcd_reg_dst;
    assign rf_rd_addr0     =  dcd_reg_src0;
    assign rf_rd_addr1     =  dcd_reg_src1;
    assign rf_data_in      =  (dcd_opcode == 9'h00C) ? {24'b0, dcd_immediate} : alu_sum;

    assign rom_addr        =  pc_count;
    assign dcd_instruction =  rom_instruction;

    always_comb begin
        rf_we   = 1'b0;
        pc_next = 1'b0;

        case (dcd_opcode)
            9'h000: begin rf_we   = 1'b0; pc_next = 1'b0; end
            9'h001: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h002: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h003: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h004: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h005: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h006: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h007: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h008: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h009: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h00A: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h00B: begin rf_we   = 1'b1; pc_next = 1'b1; end
            9'h00C: begin rf_we   = 1'b1; pc_next = 1'b1; end
            default: begin rf_we  = 1'b0; pc_next = 1'b0; end
        endcase
    end
endmodule

module TB;
    logic clk, rst;
    
    CU cu_inst (
        .clk(clk),
        .rst(rst)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst = 1;
        #10;
        rst = 0;
        #1000;
        $finish;
    end
    
    initial begin
        $monitor("t=%0t | PC=%0d | op=%h | dst=%0d | src0=%0d | src1=%0d | imm=%0d | alu=%0d | rf_we=%b | pc_next=%b",
                 $time,
                 cu_inst.pc_count,
                 cu_inst.dcd_opcode,
                 cu_inst.dcd_reg_dst,
                 cu_inst.dcd_reg_src0,
                 cu_inst.dcd_reg_src1,
                 cu_inst.dcd_immediate,
                 cu_inst.alu_sum,
                 cu_inst.rf_we,
                 cu_inst.pc_next);
    end
endmodule