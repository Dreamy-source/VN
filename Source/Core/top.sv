// Core/
`include "alu.sv"
`include "regfile.sv"
`include "decoder.sv"
`include "pc.sv"

// Memory/
`include "../Memory/rom.sv"

module top
(
    input logic clock, reset 
);
    logic writeEnable;

    // ALU (Arithmetic Logic Unit)
    logic [10:0] ALU_Operation;
    logic [63:0] ALU_A, ALU_B;
    logic [63:0] ALU_Result;   

    // Register File
    logic [4:0]  RegFile_WriteAddress;
    logic [63:0] RegFile_Data;
    logic [4:0]  RegFile_ReadRegister0;
    logic [4:0]  RegFile_ReadRegister1;
    logic [63:0] RegFile_ReadedRegister0;
    logic [63:0] RegFile_ReadedRegister1;

    // Decoder
    logic [63:0] Decoder_Instruction;
    logic [10:0] Decoder_Operation;
    logic [4:0]  Decoder_Destination;
    logic [4:0]  Decoder_Source0;
    logic [4:0]  Decoder_Source1;
    logic [37:0] Decoder_Immediate;

    // Program Counter
    logic        PC_next;
    logic [15:0] PC_CurrentAddress;

    // ROM (Read-Only Memory)
    logic [63:0] ROM_Instruction;


    // Connections
    // ALU
    ALU alu
    (
        .Operation(ALU_Operation),
        .A(ALU_A),
        .B(ALU_B),
        .Result(ALU_Result)
    );

    // Register File
    RegFile regfile
    (
        .clock(clock),
        .reset(reset),
        .writeEnable(writeEnable),
        .WriteAddress(RegFile_WriteAddress),
        .Data(RegFile_Data),
        .ReadRegister0(RegFile_ReadRegister0),
        .ReadRegister1(RegFile_ReadRegister1),
        .ReadedRegister0(RegFile_ReadedRegister0),
        .ReadedRegister1(RegFile_ReadedRegister1)
    );

    // Decoder
    Decoder decoder
    (
        .Instruction(Decoder_Instruction),
        .Operation(Decoder_Operation),
        .Destination(Decoder_Destination),
        .Source0(Decoder_Source0),
        .Source1(Decoder_Source1),
        .Immediate(Decoder_Immediate)
    );

    // PC
    PC pc
    (
        .clock(clock),
        .reset(reset),
        .next(PC_next),
        .CurrentAddress(PC_CurrentAddress)
    );

    // ROM
    ROM rom
    (
        .AddressIndex(PC_CurrentAddress),
        .Instruction(ROM_Instruction)
    );

    // кто получает --> кто отдает
    // Classic
    logic is_mov_inst;
    logic is_nop_inst;
    logic is_hlt_inst;
    assign is_mov_inst = (Decoder_Operation == 11'h00A);
    assign is_nop_inst = (Decoder_Operation == 11'h00B);
    assign is_hlt_inst = (Decoder_Operation == 11'h00C);

    assign ALU_Operation = Decoder_Operation;
    assign ALU_A = RegFile_ReadedRegister0;
    assign ALU_B = RegFile_ReadedRegister1;
    assign RegFile_Data = is_mov_inst ? {26'b0, Decoder_Immediate} : ALU_Result;
    assign RegFile_WriteAddress = Decoder_Destination;

    assign Decoder_Instruction = ROM_Instruction;
    assign RegFile_ReadRegister0 = Decoder_Source0;
    assign RegFile_ReadRegister1 = Decoder_Source1;

    assign writeEnable = ~(is_nop_inst | is_hlt_inst);
    assign PC_next = ~is_hlt_inst;
endmodule

`timescale 1ns/1ps
module Testbench;
    logic clock, reset;

    top dut (
        .clock(clock),
        .reset(reset)
    );

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset = 1;
        #10 reset = 0;

        for (int i = 0; i < 10; i++) begin
            @(posedge clock);

            $display("op=0x%0h | x0=%0d x1=%0d x2=%0d", dut.ALU_Operation, dut.regfile.x[0], dut.regfile.x[1], dut.regfile.x[2]);
        end
        $finish;
    end
endmodule
