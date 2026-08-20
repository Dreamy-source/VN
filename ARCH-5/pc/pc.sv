module pc #(
    parameter AddressBits = 12,        // because in ROM 4096 entries
    parameter AddressAfterReturn = 1   // how many instructions skip after return from call
) (
    input  logic                   Clock, Reset, Next, Jump,
    input  logic [AddressBits-1:0] JumpAddress,
    output logic [AddressBits-1:0] SavedAddress,
    output logic [AddressBits-1:0] Address 
);
    always_ff @(posedge Clock) begin : PC_Logic
        if (Reset) begin
            Address <= '0;
            SavedAddress <= '0;
        end else if (Jump) begin
            SavedAddress <= Address + AddressAfterReturn;
            Address <= JumpAddress;
        end else if (Next) begin
            Address <= Address + 12'h001;   // +0x001
        end
    end
endmodule