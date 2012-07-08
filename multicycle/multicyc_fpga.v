module multicyc_fpga(iClk, iRst, iSwitch, oLED, oDigi, oRstOut, oClkOut, iLEDSelect);
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
    
    reg [3:0] ClkReg;
    always @(posedge iClk or posedge iRst)
    begin
        if(iRst)
        begin
            ClkReg <= 4'b0;
        end
        else
        begin
            if(ClkReg == 4'b0100)
                ClkReg <= 4'b1000;
            else if(ClkReg == 4'b1100)
                ClkReg <= 4'b0000;
            else
                ClkReg <= ClkReg + 1;
        end
    end

    multicyc multicyc_inst(.iClk(ClkReg[3]), 
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
