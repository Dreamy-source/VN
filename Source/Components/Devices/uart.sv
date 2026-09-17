module UART
(
    input  logic        clock, reset, writeEnable,
    input  logic [63:0] WriteAddress,
    input  logic [63:0] WriteData,
    output logic [63:0] ReadedData
);
    logic [7:0] TX_Data;

    always_ff @(posedge clock) begin
        if (reset)
            TX_Data <= 0;
        else if (writeEnable && WriteAddress[3:0] == 4'h0) begin
            TX_Data <= WriteData[7:0];
            $write("%c", WriteData[7:0]);
            $fflush;
        end
    end

    assign ReadedData = (WriteAddress[3:0] == 4'h0) ? {56'b0, TX_Data} : 0;
endmodule
