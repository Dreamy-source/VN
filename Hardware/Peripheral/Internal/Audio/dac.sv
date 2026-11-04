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

module DAC
(
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,

    input  logic [1:0]  mode,

    input  logic [7:0]  bin8,
    input  logic [15:0] bin16,
    input  logic [23:0] bin24,

    output logic        analog,

    output logic        mf_exception
);
    logic [23:0] counter;
    logic [23:0] max_bin;

    always_comb begin
        case (mode)
            2'h0: max_bin = 24'h0000FF;
            2'h1: max_bin = 24'h00FFFF;
            default: max_bin = 24'hFFFFFF;
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            analog <= 0;
            counter <= 0;
            mf_exception <= 0;
        end
        else if (enable) begin
            mf_exception <= 0;

            if (counter >= max_bin) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            case (mode)
                2'h0: analog <= (counter < {16'b0, bin8});
                2'h1: analog <= (counter < {8'b0, bin16});
                2'h2: analog <= (counter < bin24);
                default: begin
                    analog <= 0;
                    mf_exception <= 1;
                end
            endcase
        end
    end
endmodule
