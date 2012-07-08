`timescale 1ns/1ps

module RegFile (reset,clk,addr1,data1,addr2,data2,wr,addr3,data3);
input reset,clk;
input wr;
input [4:0] addr1,addr2,addr3;
output [31:0] data1,data2;
input [31:0] data3;

reg [31:0] RF_DATA[31:1];
integer i;

assign data1=(addr1==5'b0)?32'b0:	//$0 MUST be all zeros
             RF_DATA[addr1];
assign data2=(addr2==5'b0)?32'b0:	//$0 MUST be all zeros
             RF_DATA[addr2];

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		for(i=1;i<32;i=i+1) RF_DATA[i]<=32'b0;
        RF_DATA[29] <= 32'h7ffffffc;
	end
	else begin
		if(wr && addr3) RF_DATA[addr3] <= data3;
	end
end

wire [31:0] R00_zero;       assign R00_zero = 32'b0;
wire [31:0] R01_at;         assign R01_at = RF_DATA[1];
wire [31:0] R02_v0;         assign R02_v0 = RF_DATA[2];
wire [31:0] R03_v1;         assign R03_v1 = RF_DATA[3];
wire [31:0] R04_a0;         assign R04_a0 = RF_DATA[4];
wire [31:0] R05_a1;         assign R05_a1 = RF_DATA[5];
wire [31:0] R06_a2;         assign R06_a2 = RF_DATA[6];
wire [31:0] R07_a3;         assign R07_a3 = RF_DATA[7];
wire [31:0] R08_t0;         assign R08_t0 = RF_DATA[8];
wire [31:0] R09_t1;         assign R09_t1 = RF_DATA[9];
wire [31:0] R10_t2;         assign R10_t2 = RF_DATA[10];
wire [31:0] R11_t3;         assign R11_t3 = RF_DATA[11];
wire [31:0] R12_t4;         assign R12_t4 = RF_DATA[12];
wire [31:0] R13_t5;         assign R13_t5 = RF_DATA[13];
wire [31:0] R14_t6;         assign R14_t6 = RF_DATA[14];
wire [31:0] R15_t7;         assign R15_t7 = RF_DATA[15];
wire [31:0] R16_s0;         assign R16_s0 = RF_DATA[16];
wire [31:0] R17_s1;         assign R17_s1 = RF_DATA[17];
wire [31:0] R18_s2;         assign R18_s2 = RF_DATA[18];
wire [31:0] R19_s3;         assign R19_s3 = RF_DATA[19];
wire [31:0] R20_s4;         assign R20_s4 = RF_DATA[20];
wire [31:0] R21_s5;         assign R21_s5 = RF_DATA[21];
wire [31:0] R22_s6;         assign R22_s6 = RF_DATA[22];
wire [31:0] R23_s7;         assign R23_s7 = RF_DATA[23];
wire [31:0] R24_t8;         assign R24_t8 = RF_DATA[24];
wire [31:0] R25_t9;         assign R25_t9 = RF_DATA[25];
wire [31:0] R26_k0;         assign R26_k0 = RF_DATA[26];
wire [31:0] R27_k1;         assign R27_k1 = RF_DATA[27];
wire [31:0] R28_gp;         assign R28_gp = RF_DATA[28];
wire [31:0] R29_sp;         assign R29_sp = RF_DATA[29];
wire [31:0] R30_fp;         assign R30_fp = RF_DATA[30];
wire [31:0] R31_ra;         assign R31_ra = RF_DATA[31];

endmodule
