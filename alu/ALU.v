`timescale 1ns / 1ps

module ALU( iA, iB, iALUFun, iSign, oS, oZ, oV, oN);

    input [31:0] iA;
    input [31:0] iB;
    input [5:0] iALUFun;
    input iSign;

    output [31:0] oS;
    output oZ;
    output oV;
    output oN;

    `define ADD (6b'000000)
    `define SUB (6b'000001)

    `define AND (6b'011000)
    `define OR  (6b'011110)
    `define XOR (6b'010110)
    `define NOR (6b'010001)
    `define STA (6b'011010)

    `define SLL (6b'100000)
    `define SRL (6b'100001)
    `define SRA (6b'100011)

    `define EQ  (6b'110011)
    `define NEQ (6b'110001)
    `define LT  (6b'110101)
    `define LEZ (6b'111101)
    `define GEZ (6b'111001)
    `define GTZ (6b'111111)

    always@(*)
    begin
        case(ALUFun)
        `ADD:
        begin
            ADD ADD1(.A(iA), .B(iB), .Sign(iSign), .S(oS),
                     .Z(oZ), .V(oV), .N(oN));
        end
        `SUB:
        begin
            SUB SUB1(.A(iA), .B(iB), .Sign(iSign), .S(oS),
                     .Z(oZ), .V(oV), .N(oN));
        end
        `AND:
        begin
            AND AND1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `OR:
        begin
            OR OR1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                   .Z(oZ), .V(oV), .N(oN));
        end
	    `XOR:
        begin
            XOR XOR1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
	    `NOR:
        begin
            NOR NOR1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `STA:
        begin
            STA STA1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `EQ:
        begin
            EQ EQ1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `NEQ:
        begin
            NEQ NEQ1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `LT:
        begin
            LT LT1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `LEZ:
        begin
            LEZ LEZ1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `GEZ:
        begin
            GEZ GEZ1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `GTZ:
        begin
            GTZ STA1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        default:
        begin
            oS <= 0;
            oZ <= 1;
            oV <= 0;
            oN <= 0;
        end
        endcase
    end

endmodule


