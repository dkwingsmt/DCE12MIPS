`timescale 1ns/1ps
`include "../peripheral/_SelectTest.v"

module ROM (addr,data,accessable);
    input       [31:0]  addr;
    output  reg [31:0]  data;
    output  reg         accessable;

    wire [15:2] eff_addr;
    assign eff_addr = addr[15:2];
    always@(*)
    begin
        accessable = 1'b0;
        data = 32'h00000000;
        if(addr[1:0] == 2'b00)
        begin
            if(addr[30:8] == 23'h000000)
            begin
                accessable = 1'b1;
                case(addr[7:2])
                    6'h00:      data = 32'h3c110040;   // lui $17, 0x0040
                    6'h01:      data = 32'h08100055;   // addiu $17, 0
                    6'h02:      data = 32'h02200008;   // jr $17
                    default: accessable = 1'b0;
                endcase
            end
            else if(addr[30:16] == 15'h0040)
            begin
                accessable = 1'b1;
                case(addr[15:2])
                    `include "../peripheral/InstRom.v"
                    default: accessable = 1'b0;
                endcase
            end
        end
    end
endmodule
