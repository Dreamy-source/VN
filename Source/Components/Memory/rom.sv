module ROM
(
    input  logic [15:0] AddressIndex,
    output logic [63:0] Instruction
);
    parameter ROM_SIZE = 65536;

    logic [63:0] ROM [0:ROM_SIZE-1];

    initial begin
        for (int i = 0; i < ROM_SIZE; i++)
            ROM[i] = 0;

        // path for firmware
        $readmemh("Build/Firmwares/vnfirmwaremgr.frm", ROM);
    end
    assign Instruction = ROM[AddressIndex];
endmodule
