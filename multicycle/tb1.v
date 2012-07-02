module top();

    parameter   CLK_UP = 8;
    parameter   CLK_DOWN = 8;

    reg         Clk;
    reg         iRst_n;

    initial
    begin
        Clk = 0;
        iRst_n = 1;
        @(posedge Clk)
        iRst_n = 0;
        @(negedge Clk)
        iRst_n = 1;
    end

    always
    begin
        #CLK_DOWN
        Clk = 1;
        #CLK_UP
        Clk = 0;
    end

    multicyc multicyc_inst(.iClk(Clk), .iRst_n(iRst_n));

    initial begin
        $dumpfile("v.lxt");
        $dumpvars(0, top);

        #10000

        $dumpflush;
        $stop;
    end
endmodule
