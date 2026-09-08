module RF (
    input  logic        Clock, Reset, WriteEnable,
    input  logic [4:0]  WriteAddress,
    input  logic [63:0] Data,
    output logic [63:0] ReadData,
    output logic [63:0] ReadenData
);
    logic [63:0] x [0:31];  // x0-x31

    always_ff @(posedge Clock) begin
        if (Reset) begin
            for (int i = 0; i < 32; i++)
                x[i] <= 0;            
        end else if (WriteEnable) begin
            x[WriteAddress] <= Data;
        end
    end
    assign ReadenData = x[ReadData];
endmodule