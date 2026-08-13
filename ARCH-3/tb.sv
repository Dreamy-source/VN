`timescale 1ns/1ps

module tb_CU;
    logic        clk;
    logic        rf_we, rf_rst;
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
    
    RF rf_inst (
        .clk(clk), .we(rf_we), .rst(rf_rst),
        .rd_addr0(rf_rd_addr0), .rd_addr1(rf_rd_addr1),
        .wr_addr(rf_wr_addr), .data_in(rf_data_in),
        .reg_rd_addr_data_out0(rf_reg_rd_addr_data_out0),
        .reg_rd_addr_data_out1(rf_reg_rd_addr_data_out1)
    );
    
    ALU alu_inst (
        .operation(alu_operation), .num0(alu_num0), .num1(alu_num1),
        .sum(alu_sum), .ov(alu_ov), .dz(alu_dz), .uo(alu_uo)
    );
    
    DCD dcd_inst (
        .instruction(dcd_instruction), .opcode(dcd_opcode),
        .reg_dst(dcd_reg_dst), .reg_src0(dcd_reg_src0), .reg_src1(dcd_reg_src1),
        .immediate(dcd_immediate)
    );
    
    // Генерация тактового сигнала
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Функция для проверки ALU
    task check_alu;
        input [8:0]  op;
        input [63:0] num0;
        input [63:0] num1;
        input [63:0] expected_sum;
        input        expected_ov;
        input        expected_dz;
        input        expected_uo;
        input string test_name;
        begin
            alu_operation = op;
            alu_num0 = num0;
            alu_num1 = num1;
            #1;
            
            if (alu_sum === expected_sum && alu_ov === expected_ov && 
                alu_dz === expected_dz && alu_uo === expected_uo) begin
                $display("✓ %s пройден: op=%0h, %0h op %0h = %0h (ov=%0b, dz=%0b, uo=%0b)", 
                         test_name, op, num0, num1, alu_sum, alu_ov, alu_dz, alu_uo);
            end else begin
                $display("✗ %s провален: op=%0h, %0h op %0h", test_name, op, num0, num1);
                $display("  Ожидалось: sum=%0h, ov=%0b, dz=%0b, uo=%0b", 
                         expected_sum, expected_ov, expected_dz, expected_uo);
                $display("  Получено:  sum=%0h, ov=%0b, dz=%0b, uo=%0b", 
                         alu_sum, alu_ov, alu_dz, alu_uo);
            end
        end
    endtask
    
    // Функция для проверки DCD
    task check_dcd;
        input [63:0] instruction;
        input [8:0]  expected_opcode;
        input [4:0]  expected_rd;
        input [4:0]  expected_rs0;
        input [4:0]  expected_rs1;
        input [39:0] expected_imm;
        input string test_name;
        begin
            dcd_instruction = instruction;
            #1;
            
            if (dcd_opcode === expected_opcode && dcd_reg_dst === expected_rd &&
                dcd_reg_src0 === expected_rs0 && dcd_reg_src1 === expected_rs1 &&
                dcd_immediate === expected_imm) begin
                $display("✓ %s пройден", test_name);
            end else begin
                $display("✗ %s провален", test_name);
                $display("  Инструкция: %0h", instruction);
                $display("  Ожидалось: opcode=%0h, rd=%0d, rs0=%0d, rs1=%0d, imm=%0h",
                         expected_opcode, expected_rd, expected_rs0, expected_rs1, expected_imm);
                $display("  Получено:  opcode=%0h, rd=%0d, rs0=%0d, rs1=%0d, imm=%0h",
                         dcd_opcode, dcd_reg_dst, dcd_reg_src0, dcd_reg_src1, dcd_immediate);
            end
        end
    endtask
    
    // Основной тестовый процесс
    initial begin
        $display("=== Начало полного тестирования процессора ===\n");
        
        // Инициализация
        rf_we = 1'b0;
        rf_rst = 1'b0;
        rf_rd_addr0 = 5'b0;
        rf_rd_addr1 = 5'b0;
        rf_wr_addr = 5'b0;
        rf_data_in = 64'b0;
        alu_operation = 9'b0;
        alu_num0 = 64'b0;
        alu_num1 = 64'b0;
        dcd_instruction = 64'b0;
        
        // ===== ТЕСТ 1: Сброс RF =====
        $display("--- Тест 1: Сброс RF ---");
        @(negedge clk);
        rf_rst = 1'b1;
        @(posedge clk);
        #1;
        rf_rst = 1'b0;
        @(posedge clk);  // Дополнительный такт для стабилизации
        #1;
        
        // Проверка, что все регистры нулевые
        rf_rd_addr0 = 5'd0;
        rf_rd_addr1 = 5'd1;
        #2;
        if (rf_reg_rd_addr_data_out0 === 64'b0 && rf_reg_rd_addr_data_out1 === 64'b0) begin
            $display("✓ Сброс RF пройден: все регистры нулевые");
        end else begin
            $display("✗ Сброс RF провален: reg[0]=%0h, reg[1]=%0h", 
                     rf_reg_rd_addr_data_out0, rf_reg_rd_addr_data_out1);
        end
        
        // ===== ТЕСТ 2: Запись и чтение RF =====
        $display("\n--- Тест 2: Запись и чтение RF ---");
        
        // Запись в несколько регистров
        @(negedge clk);
        rf_we = 1'b1;
        rf_wr_addr = 5'd0;
        rf_data_in = 64'hDEADBEEF_CAFEBABE;
        @(posedge clk);
        #1;
        rf_we = 1'b0;
        
        @(negedge clk);
        rf_we = 1'b1;
        rf_wr_addr = 5'd1;
        rf_data_in = 64'h12345678_90ABCDEF;
        @(posedge clk);
        #1;
        rf_we = 1'b0;
        
        @(negedge clk);
        rf_we = 1'b1;
        rf_wr_addr = 5'd31;
        rf_data_in = 64'hFFFF_FFFF_FFFF_FFFF;
        @(posedge clk);
        #1;
        rf_we = 1'b0;
        
        // Чтение регистров
        rf_rd_addr0 = 5'd0;
        rf_rd_addr1 = 5'd1;
        #1;
        if (rf_reg_rd_addr_data_out0 === 64'hDEADBEEF_CAFEBABE && 
            rf_reg_rd_addr_data_out1 === 64'h12345678_90ABCDEF) begin
            $display("✓ Чтение reg[0] и reg[1] пройдено");
        end else begin
            $display("✗ Чтение reg[0] и reg[1] провалено");
        end
        
        rf_rd_addr0 = 5'd31;
        rf_rd_addr1 = 5'd0;
        #1;
        if (rf_reg_rd_addr_data_out0 === 64'hFFFF_FFFF_FFFF_FFFF && 
            rf_reg_rd_addr_data_out1 === 64'hDEADBEEF_CAFEBABE) begin
            $display("✓ Чтение reg[31] и reg[0] пройдено");
        end else begin
            $display("✗ Чтение reg[31] и reg[0] провалено");
        end
        
        // ===== ТЕСТ 3: ALU - Сложение =====
        $display("\n--- Тест 3: ALU сложение ---");
        check_alu(9'h001, 64'h0000_0000_0000_000A, 64'h0000_0000_0000_0014, 
                  64'h0000_0000_0000_001E, 1'b0, 1'b0, 1'b0, "Сложение 10+20=30");
        check_alu(9'h001, 64'h0000_0000_0000_0000, 64'h0000_0000_0000_0000, 
                  64'h0000_0000_0000_0000, 1'b0, 1'b0, 1'b0, "Сложение 0+0=0");
        check_alu(9'h001, 64'hFFFF_FFFF_FFFF_FFFF, 64'h0000_0000_0000_0001, 
                  64'h0000_0000_0000_0000, 1'b1, 1'b0, 1'b0, "Сложение с переполнением");
        
        // ===== ТЕСТ 4: ALU - Вычитание =====
        $display("\n--- Тест 4: ALU вычитание ---");
        check_alu(9'h002, 64'h0000_0000_0000_0014, 64'h0000_0000_0000_000A, 
                  64'h0000_0000_0000_000A, 1'b0, 1'b0, 1'b0, "Вычитание 20-10=10");
        check_alu(9'h002, 64'h0000_0000_0000_0000, 64'h0000_0000_0000_0001, 
                  64'hFFFF_FFFF_FFFF_FFFF, 1'b1, 1'b0, 1'b0, "Вычитание с переполнением");
        check_alu(9'h002, 64'h0000_0000_0000_0005, 64'h0000_0000_0000_0005, 
                  64'h0000_0000_0000_0000, 1'b0, 1'b0, 1'b0, "Вычитание 5-5=0");
        
        // ===== ТЕСТ 5: ALU - Умножение =====
        $display("\n--- Тест 5: ALU умножение ---");
        check_alu(9'h003, 64'h0000_0000_0000_0006, 64'h0000_0000_0000_0007, 
                  64'h0000_0000_0000_002A, 1'b0, 1'b0, 1'b0, "Умножение 6*7=42");
        check_alu(9'h003, 64'h0000_0000_0000_0000, 64'h0000_0000_0000_0064, 
                  64'h0000_0000_0000_0000, 1'b0, 1'b0, 1'b0, "Умножение 0*100=0");
        
        // ===== ТЕСТ 6: ALU - Деление =====
        $display("\n--- Тест 6: ALU деление ---");
        check_alu(9'h004, 64'h0000_0000_0000_001E, 64'h0000_0000_0000_0006, 
                  64'h0000_0000_0000_0005, 1'b0, 1'b0, 1'b0, "Деление 30/6=5");
        check_alu(9'h004, 64'h0000_0000_0000_001E, 64'h0000_0000_0000_0000, 
                  64'h0000_0000_0000_0000, 1'b0, 1'b1, 1'b0, "Деление на ноль");
        check_alu(9'h004, 64'h0000_0000_0000_0000, 64'h0000_0000_0000_0005, 
                  64'h0000_0000_0000_0000, 1'b0, 1'b0, 1'b0, "Деление 0/5=0");
        
        // ===== ТЕСТ 7: ALU - Неизвестная операция =====
        $display("\n--- Тест 7: ALU неизвестная операция ---");
        check_alu(9'h0FF, 64'h0000_0000_0000_0001, 64'h0000_0000_0000_0001, 
                  64'h0000_0000_0000_0000, 1'b0, 1'b0, 1'b1, "Неизвестная операция");
        
        // ===== ТЕСТ 8: DCD - Декодер =====
        $display("\n--- Тест 8: Декодер инструкций ---");
        check_dcd({9'h001, 5'd10, 5'd1, 5'd2, 40'h1234_5678_90}, 
                  9'h001, 5'd10, 5'd1, 5'd2, 40'h1234_5678_90, 
                  "Декодирование сложения");
        check_dcd({9'h002, 5'd5, 5'd3, 5'd7, 40'hABCD_EF12_34}, 
                  9'h002, 5'd5, 5'd3, 5'd7, 40'hABCD_EF12_34, 
                  "Декодирование вычитания");
        check_dcd({9'h00C, 5'd0, 5'd0, 5'd0, 40'h0000_0000_FF}, 
                  9'h00C, 5'd0, 5'd0, 5'd0, 40'h0000_0000_FF, 
                  "Декодирование загрузки immediate");
        
        // ===== ТЕСТ 9: Интеграционный тест - все операции =====
        $display("\n--- Тест 9: Интеграционный тест ---");
        
        // Сброс RF
        @(negedge clk);
        rf_rst = 1'b1;
        @(posedge clk);
        #1;
        rf_rst = 1'b0;
        @(posedge clk);
        #1;
        
        // Записываем операнды в регистры
        @(negedge clk);
        rf_we = 1'b1;
        rf_wr_addr = 5'd1;
        rf_data_in = 64'h0000_0000_0000_000A; // reg[1] = 10
        @(posedge clk);
        #1;
        rf_we = 1'b0;
        
        @(negedge clk);
        rf_we = 1'b1;
        rf_wr_addr = 5'd2;
        rf_data_in = 64'h0000_0000_0000_0005; // reg[2] = 5
        @(posedge clk);
        #1;
        rf_we = 1'b0;
        
        // Читаем из регистров
        rf_rd_addr0 = 5'd1;
        rf_rd_addr1 = 5'd2;
        #1;
        
        // Тест сложения через RF
        alu_operation = 9'h001;
        alu_num0 = rf_reg_rd_addr_data_out0;
        alu_num1 = rf_reg_rd_addr_data_out1;
        #1;
        if (alu_sum === 64'h0000_0000_0000_000F) begin
            $display("✓ Интеграция: 10+5=15 через RF и ALU");
        end else begin
            $display("✗ Интеграция сложения провалена");
        end
        
        // Тест вычитания через RF
        alu_operation = 9'h002;
        #1;
        if (alu_sum === 64'h0000_0000_0000_0005) begin
            $display("✓ Интеграция: 10-5=5 через RF и ALU");
        end else begin
            $display("✗ Интеграция вычитания провалена");
        end
        
        // Тест умножения через RF
        alu_operation = 9'h003;
        #1;
        if (alu_sum === 64'h0000_0000_0000_0032) begin
            $display("✓ Интеграция: 10*5=50 через RF и ALU");
        end else begin
            $display("✗ Интеграция умножения провалена");
        end

        alu_operation = 9'h004;
        #1;
        if (alu_sum === 64'h0000_0000_0000_0002) begin
            $display("✓ Интеграция: 10/5=2 через RF и ALU");
        end else begin
            $display("✗ Интеграция деления провалена");
        end
        
        $display("\n--- Тест 10: Сброс после операций ---");
        @(negedge clk);
        rf_rst = 1'b1;
        @(posedge clk);
        #1;
        rf_rst = 1'b0;
        @(posedge clk);
        #1;
        
        rf_rd_addr0 = 5'd1;
        rf_rd_addr1 = 5'd2;
        #2;
        if (rf_reg_rd_addr_data_out0 === 64'b0 && rf_reg_rd_addr_data_out1 === 64'b0) begin
            $display("✓ Сброс после операций пройден");
        end else begin
            $display("✗ Сброс после операций провален: reg[1]=%0h, reg[2]=%0h", 
                     rf_reg_rd_addr_data_out0, rf_reg_rd_addr_data_out1);
        end
        
        $display("\n=== Полное тестирование завершено ===");
        $finish;
    end
endmodule