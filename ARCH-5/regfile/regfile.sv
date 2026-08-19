// []
// | VN
// | Contributed by:
// |  | Dreamy-source (owner)
// |  | Discord: ilikethenature
// |  []
// | Last edited: 19.08.2026
// []

module regfile #(
    parameter FileBits = 64,            // File bits
    parameter FileSize = 32             // File size
) (
    input  logic                        Clock, Reset, WriteEnable,
    input  logic [FileBits-1:0]         Data,
    input  logic [$clog2(FileSize)-1:0] WriteAddress,
    input  logic [$clog2(FileSize)-1:0] ReadAddress_src0, ReadAddress_src1,
    output logic [FileBits-1:0]         ReadenValue_src0, ReadenValue_src1
);
    logic [FileBits-1:0] rx [0:FileSize-1];     // Vector with name (ex: regName[0], regName[1] ...)
    // rx = regName

    always_ff @(posedge Clock) begin : RegFile_Logic      // whenever 0 -> 1 do ...
        if (Reset) begin
            for (int i = 0; i < FileSize; i++) begin
                rx[i] <= '0;                              // regName[0]..regName[FileSize - 1] = 0
            end
        end else if (WriteEnable) begin
            rx[WriteAddress] <= Data;                     // ex: regName[3] = Data (whats at the input)
        end
    end
    
    assign ReadenValue_src0 = rx[ReadAddress_src0];       // ReadenValue_src0 = whats in the register src0
    assign ReadenValue_src1 = rx[ReadAddress_src1];       // ReadenValue_src1 = whats in the register src1
endmodule