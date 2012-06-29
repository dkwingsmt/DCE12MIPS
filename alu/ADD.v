`timescale 1ns / 1ps

module ADD(A,B,Sign,S,Z,V,N);

    input [31:0] A;
    input [31:0] B;
    input Sign;

    output reg [31:0] S;
    output reg Z;
    output reg V;
    output reg N;

    reg [31:0] tempA,tempB;

    always@(*)
    begin
        if (~Sign)
        begin
            S = A + B;
            N = 0;
            if (S == 0) Z = 1;
            else Z = 0;
            if ((S < A) || (S < B)) V = 1;
            else V = 0;
        end
        else
        begin
            if ((A[31] == 0) && (B[31] == 0))
            begin
                N = 0;
                S = A + B;
                if (S == 0) Z = 1;
                else Z = 0;
                if (S[31] == 1) V = 1;
                else V = 0;
            end
            else if (A[31] != B[31])
            begin
                V = 0;
                S = A + B;
                if (S == 0) Z = 1;
                else Z = 0;
                if (A[31])
                begin
                    tempA = A * (-1);
                    if (tempA > B) N = 1;
                    else N = 0;
                end
                else if (B[31])
                begin
                    tempB = B * (-1);
                    if (tempB > A) N = 1;
                    else N = 0;
                end
            end
            else
            begin
                N = 1;
                S = A + B;
                if (S == 0) Z = 1;
                else Z = 0;
                if (S[31] == 0) V = 1;
                else V = 0;
            end
        end
    end

endmodule
































