module rom #(
    parameter FirmwarePath = "~/VN/ARCH-5/Firmware/vnfirmware.hex",
    parameter InstructionBits = 64,
    parameter Entries = 4096         // base = 32kb (4096 entries)
) (
    input  logic [$clog2(Entries)-1:0] Address,
    output logic [InstructionBits-1:0] Instruction
);
    logic [InstructionBits-1:0] ROM [0:Entries-1];

    initial begin
        for (int i = 0; i < Entries; i++) begin
            ROM[i] = '0;
        end
        $readmemh(FirmwarePath, ROM);
    end
    assign Instruction = ROM[Address];
endmodule