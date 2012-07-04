`timescale 1ns/1ps
`include "../peripheral/_SelectTest.v"

module DataMem (reset_n,clk,rd,wr,addr,wdata,rdata,accessable,
                switch, led, digi,peri_irqout);
    input               reset_n;
    input               clk;
    input               rd;
    input               wr;
    input       [31:0]  addr;
    output  reg [31:0]  rdata;
    input       [31:0]  wdata;
    output              accessable;  // 0 if invalid datamem addr
    input       [7:0]   switch;
    output      [7:0]   led;
    output      [11:0]  digi;
    output              peri_irqout;

//    wire        peri_irqout;
    wire [31:0] peri_rdata;
    wire        peri_racc;
    wire        peri_wacc;
    Peripheral peri_inst(
        .reset(reset_n),
        .clk(clk),
        .rd(rd),
        .wr(wr),
        .addr(addr),
        .wdata(wdata),
        .rdata(peri_rdata),
        .led(led),
        .switch(switch),
        .digi(digi),
        .irqout(peri_irqout),
        .r_accessible(peri_racc),
        .w_accessible(peri_wacc));

    parameter GLOBAL_SIZE = 32;
    parameter STACK_SIZE = 32;
    reg [31:0] global_data [GLOBAL_SIZE-1:0];
    reg [31:0] stack_data [12'hfff:12'hfff+1-STACK_SIZE];

    wire [30:12] upper_addr;
    wire [11:2]  eff_addr;
    wire [1:0]   lower_addr;
    assign upper_addr = addr[30:12];
    assign eff_addr = addr[11:2];
    assign lower_addr = addr[1:0];
    reg r_acc;
    reg w_acc;

    always @(*)
    begin
        if(rd)
        begin
            r_acc = 1'b0;
            rdata = 32'hcdcdcdcd; 
            if(lower_addr == 2'b00)
            begin
                case(upper_addr)
                19'b001_0000_0000_0001_0000: begin
                    if(eff_addr < GLOBAL_SIZE)
                    begin
                        rdata = global_data[eff_addr];
                        r_acc = 1'b1;
                    end
                end
                19'b111_1111_1111_1111_1111: begin
                    if(eff_addr < STACK_SIZE)
                    begin
                        rdata = stack_data[eff_addr];
                        r_acc = 1'b1;
                    end
                end
                19'b100_0000_0000_0000_0000: begin
                    r_acc = peri_racc;
                    if(peri_racc)
                    begin
                        rdata = peri_rdata;
                    end
                end
                default: begin
                    r_acc = 1'b0;
                    rdata = 32'hcccccccc;
                end
                endcase
            end
        end
    end

    always @(negedge reset_n or posedge clk) begin
        if(~reset_n)
        begin
            `include "../peripheral/DataMemInit.v"
        end
        else
        begin
            w_acc <= 1'b0;
            if(lower_addr == 2'b00)
            begin
                case(upper_addr)
                19'h10010: begin
                    if(eff_addr < GLOBAL_SIZE)
                    begin
                        global_data[eff_addr] <= wdata;
                        w_acc <= 1'b1;
                    end
                end
                19'h7ffff: begin
                    if(eff_addr < STACK_SIZE)
                    begin
                        stack_data[eff_addr] <= wdata;
                        w_acc <= 1'b1;
                    end
                end
                19'h40000: begin
                    w_acc <= peri_wacc;
                end
                endcase
            end
        end
    end

endmodule
