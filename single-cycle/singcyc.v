`timescale 1ns/1ps

module singcyc(iClk, 
               iRst_n,
               _iPCLoad,
               _IPCLoadData);

    wire            DataMemRd;
    wire            DataMemWr;
    reg     [31:0]  DataMemAddr;
    reg     [31:0]  DataMemWrData;
    wire    [31:0]  DataMemRdData;
    wire            DataMemAccssable;
    DataMem data_mem_inst(.reset_n(iRst_n), 
                          .clk(iClk),
                          .rd(DataMemRd),
                          .wr(DataMemWr),
                          .addr(DataMemAddr),
                          .wdata(DataMemWrData),
                          .rdata(DataMemRdData),
                          .accessable(DataMemAccssable));
endmodule
