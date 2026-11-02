// Copyright (c) 2026 Dreamy-source
// 
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2.
// 
// You may redistribute and modify this source and make products using it under
// the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).
// 
// This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
// INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
// PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
// 
// Source location: https://github.com/Dreamy-source/VN

module ALU_TEST;
    logic [7:0] alu_op;
    logic [63:0] alu_a, alu_b, alu_result;
    ALU alu (
        .op    (alu_op),
        .a     (alu_a),
        .b     (alu_b),
        .result(alu_result)
    );

    initial begin
        // add
        alu_op = 8'h00;
        alu_a = 5;
        alu_b = 3;
        #1;
        $display("[ADD] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a + alu_b);
        
        // sub
        alu_op = 8'h01;
        alu_a = 5;
        alu_b = 3;
        #1;
        $display("[SUB] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a - alu_b);
        
        // mul
        alu_op = 8'h02;
        alu_a = 5;
        alu_b = 2;
        #1;
        $display("[MUL] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a * alu_b);

        // div
        alu_op = 8'h03;
        alu_a = 4;
        alu_b = 2;
        #1;
        $display("[DIV] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a / alu_b);

        // and
        alu_op = 8'h04;
        alu_a = 1;
        alu_b = 1;
        #1;
        $display("[AND] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a & alu_b);

        // xor
        alu_op = 8'h05;
        alu_a = 1;
        alu_b = 1;
        #1;
        $display("[XOR] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a ^ alu_b);

        // or
        alu_op = 8'h06;
        alu_a = 0;
        alu_b = 0;
        #1;
        $display("[OR]  op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a | alu_b);

        // not
        alu_op = 8'h07;
        alu_a = 1;
        alu_b = 0;
        #1;
        $display("[NOT] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, ~alu_a);

        // shl
        alu_op = 8'h08;
        alu_a = 1;
        alu_b = 5;
        #1;
        $display("[SHL] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a << alu_b);

        // shr
        alu_op = 8'h09;
        alu_a = 2;
        alu_b = 1;
        #1;
        $display("[SHR] op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, alu_a, alu_b, alu_result, alu_a >> alu_b);

        // imul
        alu_op = 8'h0a;
        alu_a = -5;
        alu_b = 2;
        #1;
        $display("[IMUL]op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, $signed(alu_a), $signed(alu_b), $signed(alu_result), $signed(alu_a) * $signed(alu_b));

        // idiv
        alu_op = 8'h0b;
        alu_a = -5;
        alu_b = -2;
        #1;
        $display("[IDIV]op=0x%0h, a=%0d, b=%0d, result=%0d, preprocessor=%0d", alu_op, $signed(alu_a), $signed(alu_b), $signed(alu_result), $signed(alu_a) / $signed(alu_b));

        $finish;
    end
endmodule
