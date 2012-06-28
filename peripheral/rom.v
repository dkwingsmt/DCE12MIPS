`timescale 1ns/1ps

module ROM (addr,data,accessable);
    input       [31:0]  addr;
    output  reg [31:0]  data;
    output  reg         accessable;

    always@(*)
    begin
        accessable <= 1'b0;
        data <= 32'h00000000;
        if(addr[1:0] == 2'b00)
        begin
            if(addr[31:8] == 24'h000000)
            begin
                accessable <= 1'b1;
                case(addr[7:2])
                    6'h00:      data <= 32'h3c110400;   // lui $17, 0x0040
                    6'h01:      data <= 32'h26310000;   // addiu $17, 0
                    6'h02:      data <= 32'h02200008;   // jr $17
                    default: accessable <= 1'b0;
                endcase
            end
            else if(addr[31:16] == 16'h0040)
            begin
                accessable <= 1'b1;
                case(addr[15:2])
                    `include "../peripheral/InstRom.v"
                    default: accessable <= 1'b0;
                endcase
            end
        end
    end
endmodule
