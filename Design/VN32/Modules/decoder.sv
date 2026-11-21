/*
// SPDX-License-Identifier: CERN-OHL-S-2.0
// Copyright (C) 2026 VN
//
// This source file is licensed under the CERN Open Hardware Licence
// Version 2 - Strongly Reciprocal (CERN-OHL-S-2.0).
// See the LICENSE file in the root of the repository for the full text.
//
// Source: github.com/Dreamy-source/VN
*/

interface DECODER_INTF;
    logic clk;

    /* ALU */
    logic [9:0]  alu_op_out;
    logic [31:0] alu_a_out;
    logic [31:0] alu_b_out;

    /* REGFILE */
    logic rf_r;
    logic rf_w;

    logic [4:0]  rf_wr_addr_out;
    logic [31:0] rf_wr_data_out;

    logic [4:0]  rf_rd_addr_out0, rf_rd_addr_out1;
    logic [31:0] rf_rd_data_in0, rf_rd_data_in1;

    /* MEM */
    logic [31:0] instr_in;

    modport bus (
        input  clk,
               instr_in,

               rf_rd_data_in0, rf_rd_data_in1,
               
        output alu_op_out,
               alu_a_out,
               alu_b_out,

               rf_r, rf_w,
               rf_wr_addr_out, rf_wr_data_out,
               rf_rd_addr_out0, rf_rd_addr_out1
    );
endinterface

module DECODER (
    DECODER_INTF.bus bus
);
    /* IF */
    logic [31:0] if_instr;
    assign if_instr = bus.instr_in;

    /* ID */
    logic [8:0]  id_branch;

    logic [9:0]  id_op;
    logic [4:0]  id_wr;
    logic [4:0]  id_rd0;
    logic [4:0]  id_rd1;
    logic [22:0] id_imm;

    always_comb begin
        id_branch = 0;

        id_op = if_instr[31:22];
        id_wr = 0;
        id_rd0 = 0;
        id_rd1 = 0;
        id_imm = 0;
        
        case (id_op)
            default: ;
            // max 1
            0, 1: begin
                /* ADD, SUB */
                id_branch = 0;
                
                id_op = {9'b0, if_instr[31]};
                id_wr = if_instr[30:26];
                id_rd0 = if_instr[25:21];
                id_rd1 = if_instr[20:16];
            end
            // max 4
            2, 3: begin
                /* MUL, AND */
                id_branch = 0;

                id_op = {8'b0, if_instr[31:30]};
                id_wr = if_instr[29:25];
                id_rd0 = if_instr[24:20];
                id_rd1 = if_instr[19:15];
            end
            // max 8
            4, 5, 6, 7: begin
                /* OR, XOR, NOT, SHL */
                id_branch = 0;

                id_op = {7'b0, if_instr[31:29]};
                id_wr = if_instr[28:24];
                id_rd0 = if_instr[23:19];
                id_rd1 = if_instr[18:14];
            end
            // max 16
            8, 9, 10, 11: begin
                /* SHR, SIADD, SISUB, SIMUL */
                id_branch = 0;

                id_op = {6'b0, if_instr[31:28]};
                id_wr = if_instr[27:23];
                id_rd0 = if_instr[22:18];
                id_rd1 = if_instr[17:13];
            end
            12, 14, 15: begin
                /* MOV, LOAD, STORE */
                id_branch = 1;

                id_op = {6'b0, if_instr[31:28]};
                id_wr = if_instr[27:23];
                id_rd0 = if_instr[22:18];
            end
            13: begin
                /* IMOV */
                id_branch = 1;

                id_op = {6'b0, if_instr[31:28]};
                id_wr = if_instr[27:23];
                id_imm = if_instr[22:0];
            end
            // max 32
            16: begin
                /* NOP */
                id_op = {5'b0, if_instr[31:27]};
            end
        endcase
    end

    /* RD */
    logic [8:0] rd_branch;

    logic [9:0]  rd_op;
    logic [4:0]  rd_wr;
    logic [4:0]  rd_rd0;
    logic [4:0]  rd_rd1;
    logic [22:0] rd_imm;

    always_ff @(posedge bus.clk) begin
        bus.rf_r <= 0;

        rd_branch <= id_branch;

        rd_op <= id_op;
        rd_wr <= id_wr;
        rd_rd0 <= id_rd0;
        rd_rd1 <= id_rd1;
        rd_imm <= id_imm;

        case (rd_branch)
            default: ;
            0: begin
                bus.rf_r <= 1;
                bus.rf_rd_addr_out0 <= rd_rd0;
                bus.rf_rd_addr_out1 <= rd_rd1;
            end
        endcase
    end

    /* EX */
    logic [8:0] ex_branch;

    logic [9:0]  ex_op;
    logic [4:0]  ex_wr;
    logic [4:0]  ex_rd0;
    logic [4:0]  ex_rd1;
    logic [22:0] ex_imm;

    always_ff @(posedge bus.clk) begin
        bus.rf_w <= 0;

        ex_branch <= rd_branch;

        ex_op <= rd_op;
        ex_wr <= rd_wr;
        ex_rd0 <= rd_rd0;
        ex_rd1 <= rd_rd1;
        ex_imm <= rd_imm;

        case (ex_branch)
            default: ;
            0: begin
                bus.alu_op_out <= ex_op;
                bus.alu_a_out <= bus.rf_rd_data_in0;
                bus.alu_b_out <= bus.rf_rd_data_in1;
            end
            1: begin
                bus.rf_w <= 1;
                if (ex_op == 12) begin
                    bus.rf_wr_addr_out <= ex_wr;
                    bus.rf_wr_data_out <= bus.rf_rd_data_in0;
                end
                if (ex_op == 13) begin
                    bus.rf_wr_addr_out <= ex_wr;
                    bus.rf_wr_data_out <= {9'b0, ex_imm};
                end
            end
        endcase
    end
endmodule
