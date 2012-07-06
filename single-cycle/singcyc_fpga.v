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
    
    reg [3:0] ClkRegDec;
    always @(posedge iClk or posedge iRst)
    begin
        if(iRst)
        begin
            ClkRegDec <= 4'b0;
        end
        else
        begin
            if(ClkRegDec == 4'b0100)
                ClkRegDec <= 4'b1000;
            else if(ClkRegDec == 4'b1100)
                ClkRegDec <= 4'b0000;
            else
                ClkRegDec <= ClkRegDec + 1;
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


    singcyc singcyc_inst(.iClk(ClkRegDec[3]), 
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
