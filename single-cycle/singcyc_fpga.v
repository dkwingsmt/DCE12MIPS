module singcyc_fpga(iClk, iRst, iSwitch, oLED, oDigi);
    input           iClk;
    input           iRst;
    input   [7:0]   iSwitch;
    output  [7:0]   oLED;
    output  [11:0]  oDigi;

    singcyc singcyc_inst(.iClk(iClk), 
                         .iRst_n(~iRst),
                         .iSwitch(iSwitch),
                         .oLED(oLED),
                         .oDigi(oDigi));
endmodule
