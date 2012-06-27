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

    `define ADD (6'b000000)
    `define SUB (6'b000001)
                   
    `define AND (6'b011000)
    `define OR  (6'b011110)
    `define XOR (6'b010110)
    `define NOR (6'b010001)
    `define STA (6'b011010)
                   
    `define SLL (6'b100000)
    `define SRL (6'b100001)
    `define SRA (6'b100011)
                   
    `define EQ  (6'b110011)
    `define NEQ (6'b110001)
    `define LT  (6'b110101)
    `define LEZ (6'b111101)
    `define GEZ (6'b111001)
    `define GTZ (6'b111111)

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
        `SLL:
        begin
            SLL SLL1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `SRL:
        begin
            SRL SRL1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
                     .Z(oZ), .V(oV), .N(oN));
        end
        `SRA:
        begin
            SRA SRA1(.A(iA), .B(iB), .Sign(iSign), .S(oS)
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


