module top();

    parameter   CLK_UP = 8;
    parameter   CLK_DOWN = 8;

    reg         Clk;
    reg         iRst_n;
    reg  [7:0]  switch;
    initial
    begin
        switch = 8'hff;
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

    singcyc singcyc_inst(.iClk(Clk), .iRst_n(iRst_n),.iSwitch(switch));

    initial begin
        $dumpfile("v.lxt");
        $dumpvars(0, top);

        #20000

        $dumpflush;
        $stop;
    end
endmodule
