// Cache/
`include "../Cache/l1.sv"
`include "../Cache/l2.sv"
`include "../Cache/l3.sv"
`include "../Cache/l4.sv"

// Core/
`include "alu.sv"
`include "pc.sv"
`include "rf.sv"
`include "decoder.sv"

// Memory/
`include "../Memory/mmio.sv"
`include "../Memory/mmu.sv"
`include "../Memory/rom.sv"

module ControlUnit;
    logic Clock, Reset, WriteEnable;

endmodule