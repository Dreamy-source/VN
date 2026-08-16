module DAC8 (      // Digital-to-Analog Converter
    input  logic        clk,
    input  logic [2:0]  wave_type,
    input  logic [7:0]  volume,
    input  logic [15:0] divisor,   // must be float
    output logic        out
);
endmodule





module DAC16 (
    input  logic [3:0] wave_type,
    input  logic [15:0] volume
);

endmodule

module DAC24 (
    input  logic [4:0] wave_type,
    input  logic [23:0] volume
);

endmodule

module DAC32 (
    input  logic [5:0] wave_type,
    input  logic [31:0] volume
);

endmodule