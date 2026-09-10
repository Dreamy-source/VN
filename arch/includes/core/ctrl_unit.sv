// Cache/
`include "../cache/l1.sv"
`include "../cache/l2.sv"
`include "../cache/l3.sv"

// Core/
`include "alu.sv"
`include "fpu.sv"
`include "pc.sv"
`include "rf.sv"
`include "decoder.sv"

// Memory/
`include "../memory/mmio.sv"
`include "../memory/mmu.sv"
`include "../memory/rom.sv"

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
        .Clock(Clock),
        .Reset(Reset),
        .WriteEnable(WriteEnable),
        .WriteAddress(RF_WriteAddress),
        .ReadData(RF_ReadData),
        .Data(RF_Data),
        .ReadenData(RF_ReadenData)
    );
    Decoder decoder (
        .Instruction(DCD_Instruction),
        .Operation(DCD_Operation),
        .Destination(DCD_Destination),
        .Source0(DCD_Source0),
        .Source1(DCD_Source1),
        .Immediate(DCD_Immediate)
    );
endmodule