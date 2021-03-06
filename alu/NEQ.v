`timescale 1ns / 1ps

module NEQ( A, B, Sign, S, V);

    input [31:0] A;
    input [31:0] B;
    input Sign;

    output reg [31:0] S;
    output reg V;

    always@(*)
    begin
        if (A != B) S = 1;
	    else S = 0;
        V = 0;
    end

endmodule

module NEQ_BACKUP( A, B, Sign, S, Z, V, N);

    input [31:0] A;
    input [31:0] B;
    input Sign;

    output [31:0] S;
    output reg Z;
    output reg V;
    output reg N;

    wire   [31:0] temp;
    eq u1(A,B,temp);
    assign S = 32'b1&(~temp);

    always@(*)
    begin
      //  if (A != B) S = 1;
	  //  else S = 0;
        V = 0;
        N = 0;
        if (S == 0) Z = 1;
        else Z = 0;
    end

endmodule

