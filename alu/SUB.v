`timescale 1ns / 1ps

module SUB( A, B, Sign, S, Z, V, N );

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
            S = A - B;
            if (S == 0)
            begin
                Z = 1;
                N = 0;
                V = 0;
            end
            else
            begin
                Z = 0;
                if (A < B)
                begin
                    N = 1;
                    V = 1;
                end
                else
                begin
                    N = 0;
                    V = 0;
                end
            end
        end
        else
        begin
            if ((A[31] == 0) && (B[31] == 0))
            begin
                V = 0;
                S = A - B;
                if (S == 0) Z = 1;
                else Z = 0;
                if (A < B) N = 1;
                else N = 0;
            end
            else if (A[31] != B[31])
            begin
                if (A[31])
                begin
                    N = 1;
                    Z = 0;
                    S = A - B;
                    if (S > 0) V = 1;
                    else V = 0;
                end
                else
                begin
                    N = 0;
                    Z = 0;
                    S = A - B;
                    if (S[31] == 1) V = 1;
                    else V = 0;
                end
            end
            else
            begin
                V = 0;
                S = A - B;
                if (S == 0) Z = 1;
                else Z = 0;
                if (A > B) N = 0;
                else N = 1;
            end
        end
    end
endmodule
