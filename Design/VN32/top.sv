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

module TOP;
    logic clk;
    logic r;
    logic w;
    
    ALU_INTF alu_if ();
    REGFILE_INTF rf_if ();
    DECODER_INTF dcd_if ();

    ALU alu (alu_if.bus);
    REGFILE rf (rf_if.bus);
    DECODER dcd (dcd_if.bus);

    /* ALU */
    assign alu_if.op_in = dcd_if.alu_op_out;
    assign alu_if.a_in = dcd_if.alu_a_out;
    assign alu_if.b_in = dcd_if.alu_b_out;
    
    /* DECODER */
    assign dcd_if.rf_rd_data_in0 = rf_if.rd_data_out0;
    assign dcd_if.rf_rd_data_in1 = rf_if.rd_data_out1;
    
    /* REGFILE */
    assign rf_if.r = dcd_if.rf_r;
    assign rf_if.w = dcd_if.rf_w;

    assign rf_if.rd_addr_in0 = dcd_if.rf_rd_addr_out0;
    assign rf_if.rd_addr_in1 = dcd_if.rf_rd_addr_out1;
    
    assign rf_if.wr_addr_in = dcd_if.rf_wr_addr_out;
    assign rf_if.wr_data_in = dcd_if.rf_wr_data_out;
endmodule
