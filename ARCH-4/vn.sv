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
    output logic        OF,DZ,UF        // OFerflow_flag, div_by_zero_exception, unknown_opcode_exception
);
    always_comb begin
        sum        = 64'b0;
        {OF,DZ,UF} = 3'b0;

        case (operation)
            9'h001: {OF,sum} = num0 + num1;             // ADD
            9'h002: {OF,sum} = num0 - num1;             // SUB
            9'h003: {OF,sum} = num0 * num1;             // MUL
            9'h004: begin                               // DIV
                if (num1 != 64'b0) begin
                    {OF,sum} = num0 / num1;
                end else begin
                    sum = 64'b0;
                    dz  = 1'b1;
                end
            end
            9'h005: {OF,sum} = num0 & num1;             // AND
            9'h006: {OF,sum} = num0 | num1;             // OR
            9'h007: {OF,sum} = num0 ^ num1;             // XOR
            9'h008: {OF,sum} = ~num0;                   // NOT
            9'h009: {OF,sum} = num0 >> num1;            // RSH
            9'h00A: {OF,sum} = num0 << num1;            // LSH
            9'h00B: {OF,sum} = $signed(num0) >>> num1;  // ASHR (All Shift Right)
            default: begin
                sum = 64'b0;
                UF  = 1'b1;
            end
            // 00C - Taken (load)
            // 1FF - Taken (mmload)
            // 1FE - Taken (mmenter)
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
        $readmemh("/home/dreamy/VN/ARCH-4/Firmware/src/firmware.hex", rom);
    end
    assign instruction = rom[addr];
endmodule

module PC (
    input  logic        clk,next,go,rst,
    input  logic [15:0] go_addr,
    output logic [15:0] count
);
    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 16'b0;
        end else if (go) begin
            count <= go_addr;
        end else if (next) begin
            count <= count + 1;
        end
    end
endmodule

module RDT (                      // Root Device Tree
    input  logic [7:0]  rp,       // Root Pointer
    input  logic [7:0]  device,
    input  logic [63:0] handler_addr,  // PC Address

    // Master Base Block (MBB)
    output logic [63:0] GPIO_handler,

    // Master Interrupt Block (MIB)
    output logic [63:0] TIMER_handler,
    output logic [63:0] AUDIO_handler,
    output logic [63:0] UART_handler,

    output logic        UF              // Unknown Flag
);
    always_comb begin
        GPIO_handler  = 64'h0;
        TIMER_handler = 64'h0;
        AUDIO_handler = 64'h0;
        UART_handler  = 64'h0;

        UF = 1'b0;

        case (rp)
            8'h01: begin                              // Master Base Block  (mode: 00, 01)
                case (device)
                    8'h01: GPIO_handler = handler_addr;  // MBB.0x01 - GPIO
                    default: UF = 1'b1;                  // Unknown Device
                endcase
            end
            8'h02: begin                              // Master Interrupt Block (mode: 00, 01)
                case (device)
                    8'h01: TIMER_handler = handler_addr;  // MIB.0x01 - TIMER
                    8'h02: AUDIO_handler = handler_addr;  // MIB.0x02 - AUDIO
                    8'h03: UART_handler  = handler_addr;  // MIB.0x03 - UART
                    default: UF = 1'b1;                   // Unknown Device
                endcase
            end
            default: UF = 1'b1;                                // Unknown Root Block
        endcase
    end
endmodule

module CU (
    input  logic clk,rst,we
);
    logic        rf_clk,rf_rst,rf_we;
    logic [4:0]  rf_wr_addr;
    logic [4:0]  rf_rd_addr0,rf_rd_addr1;
    logic [63:0] rf_data;
    logic [63:0] rf_data_out0,rf_data_out1;

    logic [8:0]  alu_operation;
    logic [63:0] alu_num0,alu_num1;
    logic [63:0] alu_sum;
    logic        alu_OF,alu_DZ,alu_UF;

    logic [63:0] dcd_instruction;
    logic [8:0]  dcd_opcode;
    logic [4:0]  dcd_reg_dst,dcd_reg_src0,dcd_reg_src1;
    logic [39:0] dcd_imm;

    logic [15:0] rom_addr;
    logic [63:0] rom_instruction;

    logic        pc_clk,pc_next,pc_go,pc_rst;
    logic [15:0] pc_go_addr;
    logic [15:0] pc_count;

    RF rf (
        .clk(rf_clk),.rst(rf_rst),.we(rf_we),
        .wr_addr(rf_wr_addr),
        .rd_addr0(rf_rd_addr0),.rd_addr1(rf_rd_addr1),
        .data(rf_data),
        .data_out0(rf_data_out0),.data_out1(rf_data_out1)
    );
    ALU alu (
        .operation(alu_operation),
        .num0(alu_num0),.num1(alu_num1),
        .sum(alu_sum),
        .OF(alu_OF),.DZ(alu_DZ),.UF(alu_UF)
    );
    DCD dcd (
        .instruction(dcd_instruction),
        .opcode(dcd_opcode),
        .reg_dst(dcd_reg_dst),.reg_src0(dcd_reg_src0),.reg_src1(dcd_reg_src1),
        .imm(dcd_imm)
    );
    ROM rom (
        .addr(rom_addr),
        .instruction(rom_instruction)
    );
    PC pc (
        .clk(pc_clk),.next(pc_next),.go(pc_go),.rst(pc_rst),
        .go_addr(pc_go_addr),
        .count(pc_count)
    );

    // clk
    assign pc_clk = clk;
    assign rf_clk = clk;

    // rst
    assign pc_rst = rst;
    assign rf_rst = rst;

    // we
    assign rf_we   = we;

    // multi
    // получатель = отправитель
    assign alu_operation = dcd_opcode;
    assign rf_wr_addr    = dcd_reg_dst;
    assign rf_rd_addr0   = dcd_reg_src0;
    assign rf_rd_addr1   = dcd_reg_src1;
    assign rf_data       = (dcd_opcode == 9'h00C) ? dcd_imm : alu_sum;  // dcd_opcode - true? then = dcd_imm, else = alu_sum

    assign alu_num0      = rf_data_out0;
    assign alu_num1      = rf_data_out1;
    
    assign dcd_instruction = rom_instruction;
    assign rom_addr        = pc_count;

    logic [1:0] mode_next;
    logic [1:0] mode;      // 2'h0 = machine, 2'h1 = kernel

    logic       EX;

    always_comb begin
        pc_go = 1'b0;
        pc_next = 1'b0;
        mode_next = 2'h0;
        EX = 1'b0;

        case (dcd_opcode)
            9'h1FF: begin   // MMLOAD
                if (mode == 2'h0) begin
                    pc_go = 1'b1;
                    pc_go_addr = dcd_imm[15:0];
                    pc_next = 1'b0;
                    mode_next = 2'h0;
                end else begin
                    pc_next = 1'b0;
                    pc_go = 1'b0;
                    EX = 1'b1;
                end
            end
            9'h1FE: begin   // MMENTER
                if (mode == 2'h1 || mode == 2'h0) begin
                    pc_go = 1'b0;
                    pc_next = 1'b1;
                    mode_next = 2'h1;
                end else begin
                    pc_next = 1'b0;
                    pc_go = 1'b0;
                    EX = 1'b1;
                end
            end
            default: begin
                pc_next = 1'b1;
                pc_go = 1'b0;
                mode_next = mode;
                EX = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mode <= 2'h0;
        end else begin
            mode <= mode_next;
        end
    end

    always_ff @(posedge clk) begin
        if (dcd_opcode == 9'h1FF) begin
            $display("machine: MMLOAD (finding signature)");
            $display("mode: %0d", mode);
        end
        if (dcd_opcode == 9'h1FE) begin
            $display("machine: MMENTER (signature found)");
            $display("mode: %0d -> %0d (next)", mode, mode_next);
        end
    end
endmodule

module CU_Testbench;
    logic clk, rst, we;
    
    CU cu (.clk(clk), .rst(rst), .we(we));
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        we = 0;
        
        #10 rst = 0;
        we = 1;

        repeat(5) begin
            @(posedge clk);
            $display("pc=%0d | instruction=%h | opcode=%h",
                 cu.pc.count, cu.dcd_instruction, cu.dcd_opcode);
        end
        #90;
    
        $display("RF[0] = %h", cu.rf.rx[0]);
        $display("RF[1] = %h", cu.rf.rx[1]);
        $display("RF[2] = %h", cu.rf.rx[2]);
        $display("RF[3] = %h", cu.rf.rx[3]);

        $finish;
    end
endmodule