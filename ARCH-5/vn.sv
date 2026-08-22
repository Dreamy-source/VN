module alu (
    input  logic [63:0] A, B,
    output logic [63:0] Result
);
    assign Result = A + B;
endmodule

module regfile (
    input  logic        clock, reset, write,
    input  logic [3:0]  register,
    input  logic [63:0] data
);
    logic [63:0] rx [0:7];

    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 8; i++) begin
                rx[i] <= 'b0;
            end
        end else if (write) begin
            rx[register] <= data;
        end
    end
endmodule

module controlunit (
    input  logic clock, reset, write
);
    logic [63:0] ALU_A, ALU_B;
    logic [63:0] ALU_Result;
    
    logic [63:0] RF_Data;
    logic [3:0]  RF_Register;
    
    alu ALU (
        .A(ALU_A),
        .B(ALU_B),
        .Result(ALU_Result)
    );
    
    regfile RF (
        .clock(clock),
        .reset(reset),
        .write(write),
        .register(RF_Register),
        .data(RF_Data)
    );

    // получатель = отправитель
    assign ALU_A = 'd5;
    assign ALU_B = 'd3;
    assign RF_Data = ALU_Result;
    assign RF_Register = 'd0;

    // testbench
    initial begin
        $display("A = %0d (0x%0h)", ALU_A, ALU_A);
        $display("B = %0d (0x%0h)", ALU_B, ALU_B);
        $display("rx0 = %0d (0x%0h)", RF_Data, RF_Data);
    end
endmodul