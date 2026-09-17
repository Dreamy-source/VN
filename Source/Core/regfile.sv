module RegFile
(
    input  logic        clock, reset, writeEnable,
    input  logic [4:0]  WriteAddress,
    input  logic [4:0]  ReadRegister0,
    input  logic [4:0]  ReadRegister1,
    input  logic [63:0] Data,
    output logic [63:0] ReadedRegister0,
    output logic [63:0] ReadedRegister1
);
    logic [63:0] x [0:31];

    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 32; i++)
                x[i] <= 0;
        end else if (writeEnable)
            x[WriteAddress] <= Data;
    end
    assign ReadedRegister0 = x[ReadRegister0];
    assign ReadedRegister1 = x[ReadRegister1];
endmodule
