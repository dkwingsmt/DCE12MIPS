module singcyc_fpga(iClk, iRst, iSwitch, oLED, oDigi, oRstOut, oClkOut, iLEDSelect);
    input           iClk;
    input           iRst;
    input   [7:0]   iSwitch;
    output  [7:0]   oLED;
    output  [11:0]  oDigi;
    output          oRstOut;
    output          oClkOut;
    output          iLEDSelect;

    wire  [31:0]  _oPC;
    wire  [31:0]  _oPCNext;

    singcyc singcyc_inst(.iClk(iClk), 
                         .iRst_n(~iRst),
                         .iSwitch(iSwitch),
                         //.oLED(oLED),
                         .oDigi(oDigi),
                         ._oPC(_oPC),
                         ._oPCNext(_oPCNext));
								 
    assign oRstOut = iRst;
    assign oClkOut = iClk;
    assign oLED = iLEDSelect ? _oPC[7:0]
                             : _oPCNext[7:0];
endmodule
