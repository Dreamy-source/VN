// UART (Universal Asynchronous Receiver-Transmitter)
module UART (
    input  logic       CLK,       // 100 MHz
    input  logic       BAUD,      // Divider
    input  logic [7:0] TX_DATA,   // Transmit
    output logic       TX_PIN,    // Physical output pin
    input  logic       RX_PIN,    // Physical input pin
    output logic [7:0] RX_DATA,   // Receive
    output logic       TX_START,  // Flag "send"
    output logic       TX_BUSY,   // Flag "sending"
    output logic       RX_READY   // Flag "data accepted"
);

endmodule