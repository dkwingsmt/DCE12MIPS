`timescale 1ns / 1ps

module LEZ( A, B, Sign, S, V);

    input [31:0] A;
    input [31:0] B;
    input Sign;

    output reg [31:0] S;
    output reg V;

    always@(*)
    begin
        if (~Sign)
        begin
            if (A == 0) S = 1;
            else S = 0;
        end
        else
        begin
            if ((A == 0) || (A[31] == 1)) S = 1;
	        else S = 0;
        end
        V = 0;
    end

endmodule
