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

module INT
(
    input  logic        clk,
    input  logic        reset,
    input  logic        write,
    input  logic        handle,
    input  logic        eoi,

    input  logic [7:0]  irq,

    input  logic [7:0]  idv_irq,
    input  logic [19:0] idv_handler_addr,
    
    input  logic [7:0]  mvec_irq,
    input  logic        mvec_bit,

    output logic [19:0] irq_handler_addr,

    output logic        irq_active
);
    logic mvec [0:255];        // mask vector
    logic [19:0] idv [0:255];  // interrupt description vector

    always_ff @(posedge clk) begin
        if (reset) begin
            irq_active <= 0;
            for (int i = 0; i < 256; i++) begin
                mvec[i] <= 0;
                idv[i] <= 0;
            end
        end
        else if (write) begin
            if (mvec_irq < 256) begin
                mvec[mvec_irq] <= mvec_bit;
            end
            if (idv_irq < 256) begin
                idv[idv_irq] <= idv_handler_addr;
            end
        end
        else if (handle) begin
            if (!mvec[irq] && !irq_active) begin
                irq_active <= 1;
                irq_handler_addr <= idv[irq];
            end
        end
        else if (eoi) begin
            irq_active <= 0;
        end
    end
endmodule
