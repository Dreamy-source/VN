// ROM (Read-Only Memory)
module ROM (
    input  logic [63:0] ADDR,
    output logic [63:0] INSTRUCTION
);
     localparam rom_maxsize      = 65536;
     localparam rom_maxsize_bits = 16;
     logic [63:0] rom [0:rom_maxsize-1];

     initial begin
        $readmemh("rom.hex", rom);
     end

     assign INSTRUCTION = rom[ADDR[rom_maxsize_bits-1:0]];
endmodule