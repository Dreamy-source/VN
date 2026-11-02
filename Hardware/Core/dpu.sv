module DPU
(
    input  logic        clk,

    // IF
    input  logic [31:0] instr,

    output logic [7:0]  op,
    output logic [4:0]  wr,
    output logic [4:0]  rd0,
    output logic [4:0]  rd1,
    output logic [8:0]  imm,

    // отдаем alu (идут в top)
    output logic [7:0]  alu_op,
    output logic [63:0] alu_a, alu_b,

    // данные из rf (приходят из top)
    input  logic [63:0] rf_rd0, rf_rd1
);
    // ID
    always_comb begin
        op = instr[31:24];
        wr = instr[23:19];
        rd0 = instr[18:14];
        rd1 = instr[13:9];
        imm = instr[8:0];
    end

    // EX
    always_ff @(posedge clk) begin
        alu_op <= op;
        alu_a <= rf_rd0;
        alu_b <= rf_rd1;
    end
endmodule
