`timescale 1ns / 1ps

module AND( A, B, Sign, S, Z, V, N);

    input [31:0] A;
    input [31:0] B;
    input Sign;

    output reg [31:0] S;
    output reg Z;
    output reg V;
    output reg N;

    always@(*)
    begin
        S = A & B;
        V <= 0;
        N <= 0;
        if (S == 0) Z <= 1;
        else Z <= 0;
    end

endmodule