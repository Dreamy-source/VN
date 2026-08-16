module RDT (                          // Root Device Tree
    input  logic [7:0]  rp,           // Root Pointer
    input  logic [7:0]  block,        // Root Block
    input  logic [7:0]  device,
    input  logic [15:0] data,         // Handler (PC Address)

    output logic [15:0] UART_handler, // need PC Address

    output logic        u_rdt_b,      // unknown_root_device_tree_block_exception
    output logic        u_rdt_d       // unknown_root_device_tree_device_exception
);
    always_comb begin
        UART_handler = 16'b0;

        u_rdt_b = 1'b0;
        u_rdt_d = 1'b0;

        case (rp)       
            8'h01: begin             // Root Device Tree (0x01)
                case (block)
                8'h01: begin         // MIB (Master Interrupt Block)
                    case (device)
                        8'h01:   UART_handler = data;   // UART
                        default: u_rdt_d = 1'b1;        // unknown_root_device_tree_device_exception
                    endcase
                end
                default: u_rdt_b = 1'b1;                // unknown_root_device_tree_block_exception
            endcase
            end
        endcase
    end
endmodule

