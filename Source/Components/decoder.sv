module Decoder
(
    input  logic [63:0] Instruction,
    output logic [10:0] Operation,
    output logic [4:0]  Source0,
    output logic [4:0]  Source1,
    output logic [4:0]  Destination,
    output logic [37:0] Immediate
);
    always_comb begin
        Operation   = Instruction[63:53];
        Source0     = Instruction[52:48];
        Source1     = Instruction[47:43];
        Destination = Instruction[42:38];
        Immediate   = Instruction[37:0];
    end
endmodule
