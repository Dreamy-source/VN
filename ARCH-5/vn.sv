module alu (
    input  logic [4:0]  Operation,
    input  logic [63:0] A, B,
    output logic [63:0] Result
);
    always_comb begin
        case (Operation)
            5'h00: Result = A + B;
            5'h01: Result = A - B;
            5'h02: Result = A * B;
            default: Result = '0;
        endcase
    end
endmodule

module regfile (
    input  logic        clock, reset, write,
    input  logic [3:0]  Register,
    input  logic [63:0] Data
);
    logic [63:0] rx [0:7];

    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 8; i++) begin
                rx[i] <= 'b0;
            end
        end else if (write) begin
            rx[Register] <= Data;
        end
    end
endmodule

module controlunit (
    input  logic clock, reset, write
);
    logic [4:0]  ALU_Operation;
    logic [63:0] ALU_A, ALU_B;
    logic [63:0] ALU_Result;
    
    logic [3:0]  RF_Register;
    logic [63:0] RF_Data;
    
    alu ALU (
        .Operation(ALU_Operation),
        .A(ALU_A),
        .B(ALU_B),
        .Result(ALU_Result)
    );

    regfile RF (
        .clock(clock),
        .reset(reset),
        .write(write),
        .Register(RF_Register),
        .Data(RF_Data)
    );

    // recipient = sender
    assign ALU_Operation = 5'h00;
    assign ALU_A = 'd5;
    assign ALU_B = 'd3;
    assign RF_Data = ALU_Result;
    assign RF_Register = 'd0;

    // testbench
    initial begin
        #10;
        $display("---- vanilla general ----");
        $display("Operation = 0x%h", ALU_Operation);
        $display("A = %0d (0x%0h)", ALU_A, ALU_A);
        $display("B = %0d (0x%0h)", ALU_B, ALU_B);
        $display("rx0 = %0d (0x%0h)", RF_Data, RF_Data);
        $finish;
    end
endmodule