// test-bench passed x2 [07.08.2026]

module DCD (
    input  logic [63:0] INSTRUCTION,
    output logic [15:0] OPCODE,
    output logic [4:0]  REG_DESTINATION,
    output logic [4:0]  REG0,
    output logic [4:0]  REG1,
    output logic [32:0] IMMEDIATE
);
    always_comb begin
        OPCODE          = INSTRUCTION[63:48];
        REG_DESTINATION = INSTRUCTION[47:43]; 
        REG0            = INSTRUCTION[42:38];
        REG1            = INSTRUCTION[37:33];
        IMMEDIATE       = INSTRUCTION[32:0];
    end
endmodule

///////////////////////////////////////////////////////////////////
// if you need to synthes this module, delete 'testbench' module//
/////////////////////////////////////////////////////////////////
module testbench;
    logic [63:0] INSTRUCTION;
    logic [15:0] OPCODE;
    logic [4:0]  REG_DESTINATION;
    logic [4:0]  REG0;
    logic [4:0]  REG1;
    logic [32:0] IMMEDIATE;

    DCD dcd (
        .INSTRUCTION(INSTRUCTION),
        .OPCODE(OPCODE),
        .REG_DESTINATION(REG_DESTINATION),
        .REG0(REG0),
        .REG1(REG1),
        .IMMEDIATE(IMMEDIATE)
    );

    initial begin
        $display("=== DCD | TB ===");

        INSTRUCTION = 64'h0001000000000000; #1;
        $display("[add] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h0002080400000000; #1;
        $display("[sub] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h0003100C00000000; #1;
        $display("[mul] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h00041F1803000000; #1;
        $display("[div] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h00050000000000FF; #1;
        $display("[and] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h000600001F1FFFFF; #1;
        $display("[or]  OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'hFFFF000000000000; #1;
        $display("[max] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h00000B1C11111111; #1;
        $display("[regs] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'h0000101010101010; #1;
        $display("[bits] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("");

        INSTRUCTION = 64'hDEADBEEFDEADBEEF; #1;
        $display("[rnj] OPCODE=%0h REG_DEST=%0d REG0=%0d REG1=%0d IMMEDIATE=%0h", OPCODE, REG_DESTINATION, REG0, REG1, IMMEDIATE);
        $display("================");
        $finish;
    end
endmodule