module Decoder (
    input  logic [63:0] Instruction,
    output logic [4:0]  Operation,
    output logic [4:0]  Destination,
    output logic [4:0]  Source0,
    output logic [4:0]  Source1,
    output logic [47:0] Immediate
);
    always_comb begin
        Operation   = Instruction[63:60];
        Destination = Instruction[59:56];
        Source0     = Instruction[55:52];
        Source1     = Instruction[51:48];
        Immediate   = Instruction[47:0];
    end
endmodule