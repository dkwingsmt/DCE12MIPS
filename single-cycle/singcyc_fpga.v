module singcyc_fpga(iClk, iRst, iSwitch, oLED, oDigi, oRstOut, oClkOut, iLEDSelect);
    input           iClk;
    input           iRst;
    input   [7:0]   iSwitch;
    output  [7:0]   oLED;
    output  [11:0]  oDigi;
    output          oRstOut;
    output          oClkOut;
    input          iLEDSelect;
    
    wire    [7:0]   LEDOrigin;
    wire    [31:0]   PC;
    
    reg [31:0] ClkReg;
    reg        ClkSig;
    always @(posedge iClk or posedge iRst)
    begin
        if(iRst)
        begin
            ClkReg <= 0;
        end
        else
        begin
            if(ClkReg == 10)//_000_000)
            begin
                ClkSig <= 1;
                ClkReg <= ClkReg + 1;
            end
            else if(ClkReg == 20)//_000_000)
            begin
                ClkReg <= 0;
                ClkSig <= 0;
            end
            else
                ClkReg <= ClkReg + 1;
        end
    end
    
    reg [31:0] ClkReg20ms;
    reg        ClkSig20ms;    
    always @(posedge iClk or posedge iRst)
    begin
        if(iRst)
        begin
            ClkReg20ms <= 0;
        end
        else
        begin
            if(ClkReg20ms == 1_000_000)
            begin
                ClkSig20ms <= 1;
                ClkReg20ms <= ClkReg20ms + 1;
            end
            else if(ClkReg20ms == 2_000_000)
            begin
                ClkReg20ms <= 0;
                ClkSig20ms <= 0;
            end
            else
                ClkReg20ms <= ClkReg20ms + 1;
        end
    end


    singcyc singcyc_inst(.iClk(ClkReg[3]), 
                         //.iClk(ClkSig),
                         .iRst_n(~iRst),
                         .iSwitch(iSwitch),
                         .oLED(LEDOrigin),
                         .oDigi(oDigi),
                         ._oPC(PC));
								 
    assign oRstOut = iRst;
    assign oClkOut = iClk;
    assign oLED = ~iLEDSelect ? PC[9:2]
                             : LEDOrigin;
endmodule
