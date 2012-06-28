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

            ADD ADD1(.A(iA), .B(iB), .Sign(iSign), .S(oSadd),
                     .Z(oZ), .V(oV), .N(oN));
            SUB SUB1(.A(iA), .B(iB), .Sign(iSign), .S(oSsub),
                     .Z(oZ), .V(oV), .N(oN));
            AND AND1(.A(iA), .B(iB), .Sign(iSign), .S(oSand)
                     .Z(oZ), .V(oV), .N(oN));
            OR OR1(.A(iA), .B(iB), .Sign(iSign), .S(oSor)
                   .Z(oZ), .V(oV), .N(oN));
            XOR XOR1(.A(iA), .B(iB), .Sign(iSign), .S(oSxor)
                     .Z(oZ), .V(oV), .N(oN));
            NOR NOR1(.A(iA), .B(iB), .Sign(iSign), .S(oSnor)
                     .Z(oZ), .V(oV), .N(oN));
            STA STA1(.A(iA), .B(iB), .Sign(iSign), .S(oSsta)
                     .Z(oZ), .V(oV), .N(oN));
            SLL SLL1(.A(iA), .B(iB), .Sign(iSign), .S(oSsll)
                     .Z(oZ), .V(oV), .N(oN));
            SRL SRL1(.A(iA), .B(iB), .Sign(iSign), .S(oSsrl)
                     .Z(oZ), .V(oV), .N(oN));
            SRA SRA1(.A(iA), .B(iB), .Sign(iSign), .S(oSsra)
                     .Z(oZ), .V(oV), .N(oN));
            EQ EQ1(.A(iA), .B(iB), .Sign(iSign), .S(oSeq)
                     .Z(oZ), .V(oV), .N(oN));
            NEQ NEQ1(.A(iA), .B(iB), .Sign(iSign), .S(oSneq)
                     .Z(oZ), .V(oV), .N(oN));
            LT LT1(.A(iA), .B(iB), .Sign(iSign), .S(oSlt)
                     .Z(oZ), .V(oV), .N(oN));
            LEZ LEZ1(.A(iA), .B(iB), .Sign(iSign), .S(oSlez)
                     .Z(oZ), .V(oV), .N(oN));
            GEZ GEZ1(.A(iA), .B(iB), .Sign(iSign), .S(oSgez)
                     .Z(oZ), .V(oV), .N(oN));
            GTZ STA1(.A(iA), .B(iB), .Sign(iSign), .S(oSgtz)
                     .Z(oZ), .V(oV), .N(oN));

    always@(*)
    begin
        case(ALUFun)
        `ADD:
        begin
	oS <= oSadd;
        end
        `SUB:
        begin
	oS <= oSsub;
        end
        `AND:
        begin
	oS <= oSand;
        end
        `OR:
        begin
	oS <= oSor;
        end
	`XOR:
        begin
	oS <= oSxor;
        end
	`NOR:
        begin
	oS <= oSnor; 
        end
        `STA:
        begin
	oS <= oSsta;
        end
        `SLL:
        begin
	oS <= oSsll;
        end
        `SRL:
        begin
	oS <= oSsrl;
        end
        `SRA:
        begin
	oS <= oSsra;
        end
        `EQ:
        begin
	oS <= oSeq;
        end
        `NEQ:
        begin
	oS <= oSneq;
        end
        `LT:
        begin
	oS <= oSlt;
        end
        `LEZ:
        begin
	oS <= oSlez;
        end
        `GEZ:
        begin
	oS <= oSgez;
        end
        `GTZ:
        begin
	oS <= oSgtz;
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


