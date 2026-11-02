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

module MMU
(
    input  logic        clk,
    input  logic        write,
    input  logic        read,

    input  logic        ring,

    input  logic [19:0] userspace_start,
    input  logic [19:0] userspace_end,

    input  logic [19:0] wr_addr_in,
    input  logic [63:0] wr_data_in,

    output logic [19:0] wr_addr_out,
    output logic [63:0] wr_data_out,

    input  logic [19:0] rd_addr_in,
    input  logic [63:0] rd_data_in,

    output logic [19:0] rd_addr_out,
    output logic [63:0] rd_data_out,

    output logic        mf_exception
);
    logic [19:0] user_start_act, user_end_act;

    always_comb begin
        if (userspace_start == 0 && userspace_end == 0) begin
            user_start_act = 20'h10000;
            user_end_act = 20'hfffff;
        end else begin
            user_start_act = userspace_start;
            user_end_act = userspace_end;
        end
    end

    always_ff @(posedge clk) begin
        mf_exception <= 0;

        if (write) begin
            if (ring == 0 && wr_addr_in > 20'h00000) begin
                wr_addr_out <= wr_addr_in;
                wr_data_out <= wr_data_in;
            end

            else if (wr_addr_in >= user_start_act && wr_addr_in <= user_end_act) begin
                wr_addr_out <= wr_addr_in;
                wr_data_out <= wr_data_in;
            end else begin
                mf_exception <= 1;
            end
        end
        
        if (read) begin
            if (ring == 0) begin
                rd_addr_out <= rd_addr_in;
                rd_data_out <= rd_data_in;
            end

            else if (ring == 1) begin
                if (rd_addr_in >= user_start_act && rd_addr_in <= user_end_act) begin
                    rd_addr_out <= rd_addr_in;
                    rd_data_out <= rd_data_in;
                end else begin
                    mf_exception <= 1;
                end
            end
        end
    end
endmodule
