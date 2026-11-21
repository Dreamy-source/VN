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

interface ALU_INTF;
    logic [9:0]  op_in;
    logic [31:0] a_in, b_in;
    logic [31:0] result_out;

    modport bus (
        input op_in, a_in, b_in,
        output result_out
    );
endinterface

module ALU (
    ALU_INTF.bus bus
);
    always_comb begin
        case (bus.op_in)
            default: bus.result_out = 0;
            0:  bus.result_out = bus.a_in + bus.b_in;
            1:  bus.result_out = bus.a_in - bus.b_in;
            2:  bus.result_out = bus.a_in * bus.b_in;

            3:  bus.result_out = bus.a_in & bus.b_in;
            4:  bus.result_out = bus.a_in | bus.b_in;
            5:  bus.result_out = bus.a_in ^ bus.b_in;
            6:  bus.result_out =~bus.a_in;

            7:  bus.result_out = bus.a_in << bus.b_in;
            8:  bus.result_out =~bus.a_in >> bus.b_in;

            9:  bus.result_out = $unsigned($signed(bus.a_in) + $signed(bus.b_in));
            10: bus.result_out = $unsigned($signed(bus.a_in) - $signed(bus.b_in));
            11: bus.result_out = $unsigned($signed(bus.a_in) * $signed(bus.b_in));
        endcase
    end
endmodule
