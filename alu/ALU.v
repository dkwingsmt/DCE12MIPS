`timescale 1ns / 1ps

module ALU( iA, iB, iALUFun, iSign, oS, oZ, oV, oN);

    input [31:0] iA;
    input [31:0] iB;
    input [5:0] iALUFun;
    input iSign;

    output reg [31:0] oS;
    output reg oZ;
    output reg oV;
    output reg oN;

    wire [31:0] oSadd, oSsub, oSand, oSor, oSxor, oSnor, oSsta;
    wire [31:0] oSsll, oSsrl, oSsra, oSeq, oSneq, oSlt, oSlez;
    wire [31:0] oSgez, oSgtz, oSlui;

    `define oADD (6'b000000)
    `define oSUB (6'b000001)
                    
    `define oAND (6'b011000)
    `define oOR  (6'b011110)
    `define oXOR (6'b010110)
    `define oNOR (6'b010001)
    `define oSTA (6'b011010)
                    
    `define oSLL (6'b100000)
    `define oSRL (6'b100001)
    `define oSRA (6'b100011)
                    
    `define oEQ  (6'b110011)
    `define oNEQ (6'b110001)
    `define oLT  (6'b110101)
    `define oLEZ (6'b111101)
    `define oGEZ (6'b111001)
    `define oGTZ (6'b111111)

    `define oLUI (6'b011011)

            ADD_BACKUP ADD1(.A(iA), .B(iB), .Sign(iSign), .S(oSadd),
                     .Z(oZadd), .V(oVadd), .N(oNadd));
            SUB_BACKUP SUB1(.A(iA), .B(iB), .Sign(iSign), .S(oSsub),
                     .Z(oZsub), .V(oVsub), .N(oNsub));
            AND AND1(.A(iA), .B(iB), .Sign(iSign), .S(oSand),
                     .Z(oZand), .V(oVand), .N(oNand));
            OR OR1(.A(iA), .B(iB), .Sign(iSign), .S(oSor),
                     .Z(oZor), .V(oVor), .N(oNor));
            XOR XOR1(.A(iA), .B(iB), .Sign(iSign), .S(oSxor),
                     .Z(oZxor), .V(oVxor), .N(oNxor));
            NOR NOR1(.A(iA), .B(iB), .Sign(iSign), .S(oSnor),
                     .Z(oZnor), .V(oVnor), .N(oNnor));
            STA STA1(.A(iA), .B(iB), .Sign(iSign), .S(oSsta),
                     .Z(oZsta), .V(oVsta), .N(oNsta));
            SLL SLL1(.A(iA), .B(iB), .Sign(iSign), .S(oSsll),
                     .Z(oZsll), .V(oVsll), .N(oNsll));
            SRL SRL1(.A(iA), .B(iB), .Sign(iSign), .S(oSsrl),
                     .Z(oZsrl), .V(oVsrl), .N(oNsrl));
            SRA SRA1(.A(iA), .B(iB), .Sign(iSign), .S(oSsra),
                     .Z(oZsra), .V(oVsra), .N(oNsra));
            EQ_BACKUP EQ1(.A(iA), .B(iB), .Sign(iSign), .S(oSeq),
                     .Z(oZeq), .V(oVeq), .N(oNeq));
            NEQ_BACKUP NEQ1(.A(iA), .B(iB), .Sign(iSign), .S(oSneq),
                     .Z(oZneq), .V(oVneq), .N(oNneq));
            LT LT1(.A(iA), .B(iB), .Sign(iSign), .S(oSlt),
                     .Z(oZlt), .V(oVlt), .N(oNlt));
            LEZ LEZ1(.A(iA), .B(iB), .Sign(iSign), .S(oSlez),
                     .Z(oZlez), .V(oVlez), .N(oNlez));
            GEZ GEZ1(.A(iA), .B(iB), .Sign(iSign), .S(oSgez),
                     .Z(oZgez), .V(oVgez), .N(oNgez));
            GTZ GTZ1(.A(iA), .B(iB), .Sign(iSign), .S(oSgtz),
                     .Z(oZgtz), .V(oVgtz), .N(oNgtz));
            LUI LUI1(.A(iA), .B(iB), .Sign(iSign), .S(oSlui),
                     .Z(oZlui), .V(oVlui), .N(oNlui));

    always@(*)
    begin
        case(iALUFun)
        `oADD:
        begin
	    oS = oSadd;
        oN = oNadd;
        oZ = oZadd;
        oV = oVadd;
        end
        `oSUB:
        begin
	    oS = oSsub;
        oN = oNsub;
        oZ = oZsub;
        oV = oVsub;
        end
        `oAND:
        begin
	    oS = oSand;
        oN = oNand;
        oZ = oZand;
        oV = oVand;
        end
        `oOR:
        begin
	    oS = oSor;
        oN = oNor;
        oZ = oZor;
        oV = oVor;
        end
	    `oXOR:
        begin
	    oS = oSxor;
        oN = oNxor;
        oZ = oZxor;
        oV = oVxor;
        end
	    `oNOR:
        begin
	    oS = oSnor;
        oN = oNnor;
        oZ = oZnor;
        oV = oVnor;
        end
        `oSTA:
        begin
	    oS = oSsta;
        oN = oNsta;
        oZ = oZsta;
        oV = oVsta;
        end
        `oSLL:
        begin
	    oS = oSsll;
        oN = oNsll;
        oZ = oZsll;
        oV = oVsll;
        end
        `oSRL:
        begin
	    oS = oSsrl;
        oN = oNsrl;
        oZ = oZsrl;
        oV = oVsrl;
        end
        `oSRA:
        begin
	    oS = oSsra;
        oN = oNsra;
        oZ = oZsra;
        oV = oVsra;
        end
        `oEQ:
        begin
	    oS = oSeq;
        oN = oNeq;
        oZ = oZeq;
        oV = oVeq;
        end
        `oNEQ:
        begin
	    oS = oSneq;
        oN = oNneq;
        oZ = oZneq;
        oV = oVneq;
        end
        `oLT:
        begin
	    oS = oSlt;
        oN = oNlt;
        oZ = oZlt;
        oV = oVlt;
        end
        `oLEZ:
        begin
	    oS = oSlez;
        oN = oNlez;
        oZ = oZlez;
        oV = oVlez;
        end
        `oGEZ:
        begin
	    oS = oSgez;
        oN = oNgez;
        oZ = oZgez;
        oV = oVgez;
        end
        `oGTZ:
        begin
	    oS = oSgtz;
        oN = oNgtz;
        oZ = oZgtz;
        oV = oVgtz;
        end
        `oLUI:
        begin
	    oS = oSlui;
        oN = oNlui;
        oZ = oZlui;
        oV = oVlui;
        end
        default:
        begin
            oS = 0;
            oZ = 1;
            oV = 0;
            oN = 0;
        end
        endcase
    end

endmodule


