`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout);
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

reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
		rdata <= 32'b0;
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
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000001: TL <= wdata;
				32'h40000002: TCON <= wdata[2:0];		
				32'h40000004: led <= wdata[7:0];			
				32'h40000006: digi <= wdata[11:0];
				default: ;
			endcase
		end
		else if(rd) begin
			case(addr)
				32'h40000000: rdata <= TH;			
				32'h40000001: rdata <= TL;			
				32'h40000002: rdata <= {29'b0,TCON};				
				32'h40000004: rdata <= {24'b0,led};			
				32'h40000005: rdata <= {24'b0,switch};
				32'h40000006: rdata <= {20'b0,digi};
				default: rdata <= 32'b0;
			endcase
		end
	end
end
endmodule

