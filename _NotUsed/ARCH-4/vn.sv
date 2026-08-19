// FUCK CISC and x86
// FUCK CISC and x86
// FUCK CISC and x86

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

module MSR (            // Machine State Register (64x256) (0x1FD) (mode: 00, 01)
    input  logic        clk,rst,we,
    input  logic [7:0]  wr_addr,
    input  logic [63:0] data,
    output logic [63:0] timer0,timer1,timer2
);
    logic [63:0] msr [0:255]; 

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 256; i++) begin
                msr[i] <= 64'b0;
            end
        end else if (we) begin
            msr[wr_addr] <= data;
        end
    end
    assign timer0 = msr[0];
    assign timer1 = msr[1];
    assign timer2 = msr[2];
endmodule

module RP (            // Root Pointer
    input  logic        clk,rst,we,
    input  logic [63:0] data,
    output logic [63:0] data_out
);
    logic [63:0] rp;

    always_ff @(posedge clk) begin
        if (rst) begin
            rp <= 64'h0000;
        end else if (we) begin
            rp <= data;
        end
    end
    assign data_out = rp;
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
                    DZ  = 1'b1;
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
    input  logic        clk,next,go,save,rst,
    input  logic [15:0] go_addr,
    output logic [15:0] count,
    output logic [15:0] saved_count
);
    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 16'b0;
            saved_count <= 16'b0;
        end else begin
            if (save) begin
                saved_count <= count + 1;
            end
            if (go) begin
                count <= go_addr;
            end else if (next) begin
                count <= count + 1;
            end
        end
    end
endmodule

module TIMER (
    input  logic        interrupt,
    input  logic        clk,rst,we,
    input  logic        IA_reset,
    input  logic [63:0] ms,
    input  logic [63:0] hz,
    output logic [63:0] sum,
    output logic [63:0] ticks,

    output logic        EX,          // exception
    output logic        IA           // interrupt_active_flag
);
    logic [63:0] counter;
    logic [63:0] ms_align;

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= 64'b0;
            ticks <= 64'h0000;
            sum <= 64'h0000;
            ms_align <= 64'd1000;
            EX  <= 1'b0;
            IA  <= 1'b0;
        end else if (IA_reset) begin
            IA <= 1'b0;
        end else if (we) begin
            if (interrupt) begin
                if (ms == 64'b0) begin
                    ms_align <= 64'd1000;
                end else begin
                    ms_align <= ms;
                end

                sum <= ms_align / hz;

                if (counter >= sum) begin
                    counter <= 64'h0;
                    ticks <= ticks + 1;
                    IA <= 1'b1;
                end else begin
                    counter <= counter + 1;
                    IA <= 1'b0;
                end
            end else begin
                sum <= 64'b0;
                ticks <= 64'b0;
                counter <= 64'b0;
                EX    <= 1'b1;
                IA    <= 1'b0;
            end
        end
    end
endmodule

module RDT (                           // Root Device Tree
    input  logic [7:0]  block,         // Root Block
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

        case (block)
            8'h01: begin                              // Master Base Block  (mode: 00, 01)
                case (device)
                    8'h01: GPIO_handler = handler_addr;   // MBB.0x01 - GPIO
                    default: UF = 1'b1;                   // Unknown Device
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
            default: UF = 1'b1;                           // Unknown Root Block
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

    logic        msr_clk,msr_rst,msr_we;
    logic [7:0]  msr_wr_addr;
    logic [63:0] msr_data;
    logic [63:0] msr_timer0,msr_timer1,msr_timer2;

    logic        rp_clk,rp_rst,rp_we;
    logic [63:0] rp_data;
    logic [63:0] rp_data_out;

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

    logic        pc_clk,pc_next,pc_go,pc_save,pc_rst;
    logic [15:0] pc_go_addr;
    logic [15:0] pc_count;
    logic [15:0] pc_saved_count;

    logic        timer_interrupt;
    logic        timer_we;
    logic [63:0] timer_ms;
    logic [63:0] timer_hz;
    logic [63:0] timer_sum;
    logic [63:0] timer_ticks;
    logic        timer_EX;
    logic        timer_IA;
    logic        timer_IA_reset;

    logic [7:0]  rdt_block;
    logic [7:0]  rdt_device;
    logic [63:0] rdt_handler_addr;
    logic [63:0] rdt_GPIO_handler;
    logic [63:0] rdt_TIMER_handler;
    logic [63:0] rdt_AUDIO_handler;
    logic [63:0] rdt_UART_handler;
    logic        rdt_UF;

    RF rf (
        .clk(rf_clk),.rst(rf_rst),.we(rf_we),
        .wr_addr(rf_wr_addr),
        .rd_addr0(rf_rd_addr0),.rd_addr1(rf_rd_addr1),
        .data(rf_data),
        .data_out0(rf_data_out0),.data_out1(rf_data_out1)
    );
    MSR msr (
        .clk(msr_clk),
        .rst(msr_rst),
        .we(msr_we),
        .wr_addr(msr_wr_addr),
        .data(msr_data),
        .timer0(msr_timer0),
        .timer1(msr_timer1),
        .timer2(msr_timer2)
    );
    RP rp (
        .clk(rp_clk),
        .rst(rp_rst),
        .we(rp_we),
        .data(rp_data),
        .data_out(rp_data_out)
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
        .clk(pc_clk),.next(pc_next),.go(pc_go),.save(pc_save),.rst(pc_rst),
        .go_addr(pc_go_addr),
        .count(pc_count),
        .saved_count(pc_saved_count)
    );
    TIMER timer (
        .interrupt(timer_interrupt),
        .clk(clk),
        .rst(rst),
        .we(timer_we),
        .IA_reset(timer_IA_reset),
        .ms(timer_ms),
        .hz(timer_hz),
        .sum(timer_sum),
        .ticks(timer_ticks),
        .EX(timer_EX),
        .IA(timer_IA)
    );
    RDT rdt (
        .block(rdt_block),
        .device(rdt_device),
        .handler_addr(rdt_handler_addr),
        .GPIO_handler(rdt_GPIO_handler),
        .TIMER_handler(rdt_TIMER_handler),
        .AUDIO_handler(rdt_AUDIO_handler),
        .UART_handler(rdt_UART_handler),
        .UF(rdt_UF)
    );

    // clk
    assign pc_clk = clk;
    assign rf_clk = clk;

    assign rp_clk = clk;

    assign msr_clk = clk;

    // rst
    assign pc_rst = rst;
    assign rf_rst = rst;

    assign rp_rst = rst;

    assign msr_rst = rst;

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

    assign rdt_handler_addr = rp_data_out[63:16];
    assign rdt_device       = rp_data_out[15:8];
    assign rdt_block        = rp_data_out[7:0];

    assign timer_interrupt  = msr_timer0[0];
    assign timer_we         = msr_timer0[0];
    assign timer_ms         = msr_timer1;
    assign timer_hz         = msr_timer2;

    logic [1:0] mode_next;
    logic [1:0] mode;      // 2'h0 = machine, 2'h1 = kernel

    logic       EX;

    always_comb begin
        pc_go = 1'b0;
        pc_next = 1'b0;     
        pc_save = 1'b0;

        rp_we = 1'b0;
        rp_data = 64'h0;

        msr_we = 1'b0;
        msr_wr_addr = 8'h0;
        msr_data = 64'h0;

        mode_next = mode;
        EX = 1'b0;

        timer_IA_reset = 1'b0;

        if (timer_IA) begin
            pc_go = 1'b1;
            pc_go_addr = rdt_TIMER_handler[15:0];
            pc_save    = 1'b1;
            timer_IA_reset   = 1'b1;
        end else begin
            timer_IA_reset   = 1'b0;
            case (dcd_opcode)
                9'h00D: begin   // GOLABL  ( golabl <label/num> )
                    pc_go = 1'b1;
                    pc_go_addr = dcd_imm[15:0];
                    pc_next = 1'b0;
                    mode_next = mode;
                end
                9'h00E: begin   // STOP    ( stop )
                    pc_next = 1'b0;
                    pc_go = 1'b0;
                    mode_next = mode;
                end
                9'h00F: begin   // CALLSV  ( callsv <label/num> )
                    pc_save = 1'b1;
                    pc_go = 1'b1;
                    pc_go_addr = dcd_imm[15:0];
                    pc_next = 1'b0;
                    mode_next = mode;
                end
                9'h010: begin   // RETB  ( retb )
                    pc_go = 1'b1;
                    pc_go_addr = pc_saved_count;
                    pc_next = 1'b0;
                    mode_next = mode;
                end
                9'h011: begin   // RP  ( rp <block> <device> <handler> )
                    rp_we = 1'b1;
                    rp_data = {
                        dcd_imm[39:16],   // handler (24-bits)
                        dcd_imm[15:8],    // device  (8-bits)
                        dcd_imm[7:0]      // block   (8-bits)
                    };
                    pc_next = 1'b1;
                    pc_go = 1'b0;
                    mode_next = mode;
                end
                9'h1FF: begin   // MMLOAD  ( mmload <addr> )
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
                9'h1FE: begin   // MMENTER  ( mmenter )
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
                9'h1FD: begin   // MSR  ( msr <addr> <val> )
                    msr_we = 1'b1;
                    msr_wr_addr = dcd_reg_dst[7:0];
                    msr_data = dcd_imm;
                    pc_next = 1'b1;
                    pc_go   = 1'b0;
                    mode_next = mode;
                end
                default: begin
                    pc_next = 1'b1;
                    pc_go = 1'b0;
                    mode_next = mode;
                    EX = 1'b0;
                end
            endcase
        end
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

        $monitor("pc=%0d | timer_IA=%0d | ticks=%0d | opcode=%h | msr_we=%0d", 
             cu.pc.count, cu.timer_IA, cu.timer_ticks, cu.dcd_opcode, cu.msr_we);
    
        #10000;

        repeat(10) begin
            @(posedge clk);
            $display("pc=%0d | instruction=%h | opcode=%h",
                 cu.pc.count, cu.dcd_instruction, cu.dcd_opcode);
        end
        #10;
    
        $display("");
        $display("===== RF =====");
        $display("RF[0] = %h", cu.rf.rx[0]);
        $display("RF[1] = %h", cu.rf.rx[1]);
        $display("RF[2] = %h", cu.rf.rx[2]);
        $display("RF[3] = %h", cu.rf.rx[3]);

        $display("");
        $display("===== RDT =====");
        $display("opcode = %h", cu.dcd_opcode);
        $display("RP data_out   = %h", cu.rp_data_out);
        $display("RDT block     = %h", cu.rdt_block);
        $display("RDT device    = %h", cu.rdt_device);
        $display("RDT handler   = %h", cu.rdt_handler_addr);
        $display("TIMER handler = %h", cu.rdt_TIMER_handler);

        $display("");
        $display("===== MSR =====");
        $display("opcode = %h", cu.dcd_opcode);
        $display("MSR data    = %h", cu.msr_data);
        $display("MSR timer0  = %h", cu.msr_timer0);
        $display("MSR timer1  = %h", cu.msr_timer1);
        $display("MSR timer2  = %h", cu.msr_timer2);
        $display("MSR wr_addr = %h", cu.msr_wr_addr);

        $display("");
        $finish;
    end
endmodule