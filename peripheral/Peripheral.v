`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,
    digi,irqout,r_accessible,w_accessible);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;

output reg r_accessible;
output reg w_accessible;

reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];

always@(*) begin
    if(rd) begin
        r_accessible = 1'b1;
        case(addr[30:0])
            31'h40000000: rdata = TH;			
            31'h40000004: rdata = TL;			
            31'h40000008: rdata = {29'b0,TCON};				
            31'h40000010: rdata = {24'b0,led};			
            31'h40000014: rdata = {24'b0,switch};
            31'h40000018: rdata = {20'b0,digi};
            default: begin
                rdata = 32'hcdcdcdcd;
                r_accessible = 1'b0;
            end
        endcase
    end
end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
        //led <= 8'b0;
        digi <= 12'b0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr) begin
            w_accessible <= 1'b1;
			case(addr[30:0])
				31'h40000000: TH <= wdata;
				31'h40000004: TL <= wdata;
				31'h40000008: TCON <= wdata[2:0];		
				31'h40000010: led <= wdata[7:0];			
				31'h40000018: digi <= wdata[11:0];
                default: w_accessible <= 1'b0;
			endcase
		end
	end
end
endmodule

