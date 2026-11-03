module PS2
(
    input  logic        clk,

    input  logic        ps2_clk,
    input  logic        ps2_data,
    output logic [7:0]  ps2_keycode,
    output logic        valid 
);
    logic clk_prev;
    logic [10:0] shift_reg;
    logic [3:0] bit_cnt;

    always_ff @(posedge clk) begin
        clk_prev <= ps2_clk;

        if (clk_prev == 1 && ps2_clk == 0) begin
            shift_reg <= {ps2_data, shift_reg[10:1]};

            bit_cnt <= bit_cnt + 1;

            if (bit_cnt == 10) begin
                bit_cnt <= 0;

                if (shift_reg[0] == 0 && shift_reg[10] == 1) begin
                    ps2_keycode <= shift_reg[8:1];
                    valid <= 1;
                end
            end
        end else begin
            valid <= 0;
        end
    end
endmodule
