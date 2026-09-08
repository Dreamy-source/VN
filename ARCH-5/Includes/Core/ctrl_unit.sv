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

    logic [4:0]  ALU_Operation;
    logic [63:0] ALU_A, ALU_B;
    logic [63:0] ALU_Result;

    logic [4:0]  RF_WriteAddress;
    logic [4:0]  RF_ReadData;
    logic [63:0] RF_Data;
    logic [63:0] RF_ReadenData;

    logic [63:0] DCD_Instruction;
    logic [4:0]  DCD_Operation;
    logic [4:0]  DCD_Destination;
    logic [4:0]  DCD_Source0;
    logic [4:0]  DCD_Source1;
    logic [47:0] DCD_Immediate;

    ALU alu (
        .Operation(ALU_Operation),
        .A(ALU_A),
        .B(ALU_B),
        .Result(ALU_Result)
    );
    RF rf (
        .WriteAddress(RF_WriteAddress),
        .ReadData(RF_ReadData),
        .Data(RF_Data),
        .ReadenData(RF_ReadenData)
    );
    DCD decoder (
        .Instruction(DCD_Instruction),
        .Operation(DCD_Operation),
        .Destination(DCD_Destination),
        .Source0(DCD_Source0),
        .Source1(DCD_Source1),
        .Immediate(DCD_Immediate)
    );
endmodule