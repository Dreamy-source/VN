// []
// | VN
// | Contributed by:
// |  | Dreamy-source (owner)
// |  | Discord: ilikethenature
// |  []
// | Last edited: 19.08.2026
// []

module decoder #(
    parameter InstructionSize = 64,
    parameter OperationSize = 9,
    parameter DestinationSize = 5,
    parameter Source0Size = 5,
    parameter Source1Size = 5,
    parameter ImmediateSize = 50
    // R-Type: 64 - 9 - 15 = 40
    // S-Type: 64 - 9 - 5 = 50
) (
    input  logic                       ModRS,         // Modification R/S
    input  logic [InstructionSize-1:0] Instruction,
    output logic [OperationSize-1:0]   Operation,
    output logic [DestinationSize-1:0] Destination,
    output logic [Source0Size-1:0]     Source0,
    output logic [Source1Size-1:0]     Source1,
    output logic [ImmediateSize-1:0]   Immediate
);

    always_comb begin : Decode
        Operation = Instruction[63:55];
        Destination = Instruction[54:50];

        if (ModRS) begin
            // ModR
            Source0 = Instruction[49:45];
            Source1 = Instruction[44:40];
            Immediate = '0;
        end else begin
            // ModS
            Source0 = '0;
            Source1 = '0;
            Immediate = Instruction[49:0];
        end
    end
endmodule