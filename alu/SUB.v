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
        S = A - B;
        if (S == 0) Z = 1;
        else Z = 0;
        if (~Sign)
        begin
            N = 0;
            V = (A < B);
        end
        else
        begin
            if ((A[31] == B[31]))
            begin
                V = 0;
                N = (S[31] == 1);
            end
            else
            begin
                if (A[31])
                begin
                    if (S[31] == 0)
                    begin
                        V = 1;
                        N = 0;
                    end
                    else
                    begin
                        V = 0;
                        N = 1;
                    end
                end
                else
                begin
                    if (S[31] == 1)
                    begin
                        V = 1;
                        N = 1;
                    end
                    else
                    begin
                        V = 0;
                        N = 0;
                    end
                end
            end
        end
    end
endmodule
