`timescale 1ns/1ps

module singcyc( iClk, 
                iRst_n,
                iSwitch, 
                oLED, 
                oDigi);

    input           iClk;
    input           iRst_n;
    input   [7:0]   iSwitch;
    output  [7:0]   oLED;
    output  [11:0]  oDigi;

    wire            DataMemRd;
    wire            DataMemWr;
    wire    [31:0]  DataMemAddr;
    wire    [31:0]  DataMemWrData;
    wire    [31:0]  DataMemRdData;
    wire            DataMemAccssable;
    DataMem data_mem_inst(.reset_n(iRst_n), 
                          .clk(iClk),
                          .rd(DataMemRd),
                          .wr(DataMemWr),
                          .addr(DataMemAddr),
                          .wdata(DataMemWrData),
                          .rdata(DataMemRdData),
                          .accessable(DataMemAccssable),
                          .switch(iSwitch),
                          .led(oLED),
                          .digi(oDigi));

    wire    [31:0]  RomAddr;
    wire    [31:0]  RomRdData;
    wire            RomAccessable;
    ROM rom_inst(.addr(RomAddr),
                 .data(RomRdData),
                 .accessable(RomAccessable));

    wire            _PCLoad;
    wire    [31:0]  _PCLoadData;
    assign _PCLoad = 1'b0;
    singcyc_core core_inst(.iClk(iClk),
                           .iRst_n(iRst_n), 
                           .oRdInstAddr(RomAddr), 
                           .iRdInst(RomRdData), 
                           .oRdWrMemAddr(DataMemAddr), 
                           .oMemWrite(DataMemWr), 
                           .oMemRead(DataMemRd), 
                           .oWrData(DataMemWrData), 
                           .iRdData(DataMemRdData),
                           ._iPCLoad(_PCLoad),
                           ._iPCLoadData(_PCLoadData));
endmodule
