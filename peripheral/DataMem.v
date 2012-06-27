`timescale 1ns/1ps

module DataMem (reset_n,clk,rd,wr,addr,wdata,rdata,accessable);
    input reset_n;
    input clk;
    input rd;
    input wr;
    input [31:0] addr;
    output [31:0] rdata;
    input [31:0] wdata;
    output accessable;  // 0 if invalid datamem addr

    parameter RAM_SIZE = 256;
    reg [31:0] RAMDATA [RAM_SIZE-1:0];

    assign rdata = (rd && (addr < RAM_SIZE)) ? RAMDATA[addr] : 32'b0;
    assign accessable = ~((rd | wr) & (addr >= RAM_SIZE));

    always @(negedge reset_n or posedge clk) begin
        if(~reset_n)
        begin
            `define RAM RAMDATA;
            `include "DataMemInit.v"
        end
        else
        begin
            if(wr && (addr < RAM_SIZE)) 
                RAMDATA[addr] <= wdata;
        end
    end

endmodule
