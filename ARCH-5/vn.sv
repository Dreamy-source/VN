// []
// | VN
// | Contributed by:
// |  | Dreamy-source (owner)
// |  | Discord: ilikethenature
// |  []
// | Last edited: 20.08.2026
// []

`include "alu/alu.sv"
`include "decoder/decoder.sv"
`include "regfile/regfile.sv"

module controlunit #(
    parameter ALU_Bits = 64,
    parameter ALU_Operations = 4,

    parameter RF_FileBits = 64,
    parameter RF_FileSize = 32,

    parameter Decoder_InstructionSize = 64,
    parameter Decoder_OperationSize = 9,
    parameter Decoder_DestinationSize = 5,
    parameter Decoder_Source0Size = 5,
    parameter Decoder_Source1Size = 5,
    parameter Decoder_ImmediateSize = 50
) (
    input logic Clock, Reset, WriteEnable
);
    // ALU bus
    logic [ALU_Operations-1:0] ALU_SelectOperation;
    logic [ALU_Bits-1:0]       ALU_A, ALU_B;
    logic [ALU_Bits-1:0]       ALU_Result;
    logic                      ALU_OverflowBit;
    logic                      ALU_DivideZeroBit;

    // Register File bus
    logic [RF_FileBits-1:0]         RF_Data;
    logic [$clog2(RF_FileSize)-1:0] RF_WriteAddress;
    logic [$clog2(RF_FileSize)-1:0] RF_ReadAddress_src0, RF_ReadAddress_src1;
    logic [RF_FileBits-1:0]         RF_ReadenValue_src0, RF_ReadenValue_src1;

    // Decoder bus
    logic                               Decoder_ModRS;
    logic [Decoder_InstructionSize-1:0] Decoder_Instruction;
    logic [Decoder_OperationSize-1:0]   Decoder_Operation;
    logic [Decoder_DestinationSize-1:0] Decoder_Destination;
    logic [Decoder_Source0Size-1:0]     Decoder_Source0;
    logic [Decoder_Source1Size-1:0]     Decoder_Source1;
    logic [Decoder_ImmediateSize-1:0]   Decoder_Immediate;


    alu #(
        .Bits(ALU_Bits),
        .Operations(ALU_Operations)
    ) ALU (
        .SelectOperation(ALU_SelectOperation),     // ALU SelectOperation --> connected to ALU bus, line=ALU.SelectOperation
        .A(ALU_A),                                 // ALU A --> connected to ALU bus, line=ALU.A
        .B(ALU_B),                                 // ALU B --> connected to ALU bus, line=ALU.B
        .Result(ALU_Result),                       // ALU Result --> connected to ALU bus, line=ALU.Result
        .OverflowBit(ALU_OverflowBit),             // ALU OverflowBit --> connected to ALU bus, line=ALU.OverflowBit
        .DivideZeroBit(ALU_DivideZeroBit)          // ALU DivideZeroBit --> connected to ALU bus, line=ALU.DivideZeroBit
    );
    regfile #(
        .FileBits(RF_FileBits),
        .FileSize(RF_FileSize)
    ) RegFile (
        .Clock(Clock),
        .Reset(Reset),
        .WriteEnable(WriteEnable),
        .Data(RF_Data),
        .WriteAddress(RF_WriteAddress),
        .ReadAddress_src0(RF_ReadAddress_src0),
        .ReadAddress_src1(RF_ReadAddress_src1),
        .ReadenValue_src0(RF_ReadenValue_src0),
        .ReadenValue_src1(RF_ReadenValue_src1)
    );
    decoder #(
        .InstructionSize(Decoder_InstructionSize),
        .OperationSize(Decoder_OperationSize),
        .DestinationSize(Decoder_DestinationSize),
        .Source0Size(Decoder_Source0Size),
        .Source1Size(Decoder_Source1Size),
        .ImmediateSize(Decoder_ImmediateSize)
    ) Decoder (
        .ModRS(Decoder_ModRS),
        .Instruction(Decoder_Instruction),
        .Operation(Decoder_Operation),
        .Destination(Decoder_Destination),
        .Source0(Decoder_Source0),
        .Source1(Decoder_Source1),
        .Immediate(Decoder_Immediate)
    );

    // who = to_whom
    assign ALU_SelectOperation = Decoder_Operation[3:0];
    assign RF_WriteAddress = Decoder_Destination;
    assign RF_ReadAddress_src0 = Decoder_Source0;
    assign RF_ReadAddress_src1 = Decoder_Source1;
    assign RF_Data = ALU_Result;
    assign ALU_A = RF_ReadenValue_src0;
    assign ALU_B = RF_ReadenValue_src1;
endmodule