`timescale 1ns/1ps

`define OPCODE_RSTYLE       6'h00;
`define OPCODE_LW           6'h23;
`define OPCODE_SW           6'h2b;
`define OPCODE_LUI          6'h0f;
`define  FUNCT_ADD          6'h20;
`define  FUNCT_ADDU         6'h21;
`define OPCODE_ADDI         6'h08;
`define OPCODE_ADDIU        6'h09;
`define  FUNCT_SUB          6'h22;
`define  FUNCT_SUBU         6'h23;
`define  FUNCT_AND          6'h24;
`define OPCODE_ANDI         6'h0c;
`define  FUNCT_OR           6'h25;
`define  FUNCT_XOR          6'h26;
`define  FUNCT_NOR          6'h27;
`define  FUNCT_SLL          6'h00;
`define  FUNCT_SRL          6'h02;
`define  FUNCT_SRA          6'h03;
`define  FUNCT_SLT          6'h2a;
`define OPCODE_SLTI         6'h0a;
`define OPCODE_SLTIU        6'h0b;
`define OPCODE_BEQ          6'h04;
`define OPCODE_BNE          6'h05;
`define OPCODE_J            6'h02;
`define OPCODE_JAL          6'h03;
`define  FUNCT_JR           6'h08;
`define  FUNCT_JALR         6'h09;

module singcyc_alu_ctrl(iAluOp,
                        iFunct,
                        oAluCtrl)
    input       [1:0]   iAluOp;
    input       [5:0]   iFunct;
    output  reg [5:0]   oAluCtrl;
ADD 000000
SUB 000001
AND 011000
OR 011110
XOR 010110
NOR 010001
"A" 011010
S=A
ç§»ä½è¿ç®
SLL
100000
S=B>>A[4:0]
SRL
100001
S=B<<A[4:0]
SRA
100011
S=B<<a[4:0] ç®æ¯ç§»ä½
å³ç³»è¿ç®
EQ
110011
If(A==B) S=1 else S=0
NEQ
110001
If(A!=B) S=1 else S=0
LT
110101
If(A<B) S=1 else S=0
LEZ
111101
If(A<=0) S=1 else S=0
GEZ
111001
If(A>=0) S=1 else S=0
GTZ
111111

    always @(CtrlSrc)
    begin
        case(iAluOp)
        2'b00:
            oAluCtrl <= 4'b0010;
        2'b01:
            oAluCtrl <= 4'b0110;
        2'b10: begin
            casex (iFunct)
            6'bxx0000:  oAluCtrl <= 4'b0010;
            6'bxx0010:  oAluCtrl <= 4'b0110;
            6'bxx1010:  oAluCtrl <= 4'b0010;
            endcase
        end
        2'b11: begin
            casex (iFunct)
            6'bxx0000:  oAluCtrl <= 4'b0010;
            6'bxx0010:  oAluCtrl <= 4'b0110;
            6'bxx1010:  oAluCtrl <= 4'b0010;
            endcase
        end
    end
endmodule

module singcyc_ctrl_unit(   iOpCode,
                            oRegDst,     
                            oJump,       
                            oBranch,
                            oBranchEq,
                            oMemRead,
                            oMemWrite,
                            oMemtoReg,
                            oRegWrite,
                            oALUSrc,
                            oALUOp)

    input               iOpCode;
    output  reg         oRegDst,     // 
    output  reg         oJump,       
    output  reg         oBranch,
    output  reg         oBranchEq,
    output  reg         oMemRead,
    output  reg         oMemWrite,
    output  reg         oMemtoReg,
    output  reg         oRegWrite,
    output  reg         oALUSrc,
    output  reg [1:0]   oALUOp;

    always @(iOpCode)
    begin
        case(iOpCode)
        `OPCODE_RSTYLE: begin
            oRegDst <= 1'b1;    oJump <= 1'b0;      oBranch <= 1'b0;   
            oBranchEq <= 1'bx;  oMemRead <= 1'b0;   oMemWrite <= 1'b0;
            oMemtoReg <= 1'b0;  oRegWrite <= 1'b1;  oALUSrc <= 1'b0;
            oALUOp <= 2'b10;
        end
        `OPCODE_LW: begin
            oRegDst <= 1'b0;    oJump <= 1'b0;      oBranch <= 1'b0;   
            oBranchEq <= 1'bx;  oMemRead <= 1'b1;   oMemWrite <= 1'b0;
            oMemtoReg <= 1'b1;  oRegWrite <= 1'b1;  oALUSrc <= 1'b1;
            oALUOp <= 2'b00;
        end
        `OPCODE_SW: begin
            oRegDst <= 1'bx;    oJump <= 1'b0;      oBranch <= 1'b0;   
            oBranchEq <= 1'bx;  oMemRead <= 1'b0;   oMemWrite <= 1'b1;
            oMemtoReg <= 1'bx;  oRegWrite <= 1'b0;  oALUSrc <= 1'b1;
            oALUOp <= 2'b00;
        end
        `OPCODE_LUI: begin
        end
        `OPCODE_ADDI: begin
        end
        `OPCODE_ADDIU: begin
        end
        `OPCODE_ANDI: begin
        end
        `OPCODE_SLTI: begin
        end
        `OPCODE_SLTIU: begin
        end
        `OPCODE_BEQ: begin
            oRegDst <= 1'bx;    oJump <= 1'b0;      oBranch <= 1'b1;   
            oBranchEq <= 1'b1;  oMemRead <= 1'b0;   oMemWrite <= 1'b0;
            oMemtoReg <= 1'bx;  oRegWrite <= 1'b0;  oALUSrc <= 1'b0;
            oALUOp <= 2'b01;
        end
        `OPCODE_BNE: begin
            oRegDst <= 1'bx;    oJump <= 1'b0;      oBranch <= 1'b1;   
            oBranchEq <= 1'b0;  oMemRead <= 1'b0;   oMemWrite <= 1'b0;
            oMemtoReg <= 1'bx;  oRegWrite <= 1'b0;  oALUSrc <= 1'b0;
            oALUOp <= 2'b01;
        end
        `OPCODE_J: begin
            oRegDst <= 1'bx;    oJump <= 1'b0;      oBranch <= 1'b1;   
            oBranchEq <= 1'b1;  oMemRead <= 1'b0;   oMemWrite <= 1'b0;
            oMemtoReg <= 1'bx;  oRegWrite <= 1'b0;  oALUSrc <= 1'b0;
            oALUOp <= 2'b01;
        end
        `OPCODE_JAL: begin
        end
        default: begin
            oRegDst <= 1'bx;    oJump <= 1'b0;      oBranch <= 1'b0;   
            oBranchEq <= 1'bx;  oMemRead <= 1'b0;   oMemWrite <= 1'b0;
            oMemtoReg <= 1'bx;  oRegWrite <= 1'b0;  oALUSrc <= 1'bx;
            oALUOp <= 2'bxx;
        end
        endcase
    end

endmodule

module singcyc_core(iClk,
                    iRst_n, 
                    oRdInstAddr, 
                    iRdInst, 
                    oRdWrMemAddr, 
                    oMemWrite, 
                    oMemRead, 
                    oWrData, 
                    iRdData)

    //====== Input/Output ======
    input               iClk;
    input               iRst_n;
    output      [31:0]  oRdInstAddr;
    input       [31:0]  iRdInst;
    output              oRdWrMemAddr;
    output              oMemWrite;
    output              oMemRead;
    output      [31:0]  oWrData;
    input       [31:0]  iRdData;

    //====== Essential ======
    reg     [31:0]  PC;
    wire    [5:0]   InstOpCode;
    wire    [4:0]   InstRs;
    wire    [4:0]   InstRt;
    wire    [4:0]   InstRd;
    wire    [4:0]   InstShamt;
    wire    [5:0]   InstFunct;
    wire    [15:0]  InstImmediate;
    wire    [25:0]  InstJumpAddr;

    //====== Registers ======
    wire    [4:0]   RdRegId0;
    wire    [4:0]   RdRegId1;
    wire    [4:0]   WrRegId;
    wire    [31:0]  RdRegData0;
    wire    [31:0]  RdRegData1;
    wire    [31:0]  WrRegData;
    wire            RegWrite;

    //====== ALU ======
    wire    [31:0]  AluIn0;
    wire    [31:0]  AluIn1;
    wire    [31:0]  AluOut;
    wire            AluZero;
    wire    [3:0]   AluFunct;

    //====== Control unit ======
    wire            CtrlRegDst;     
    wire            CtrlJump;       
    wire            CtrlBranch;
    wire            CtrlBranchEq;
    wire            CtrlMemRead;
    wire            CtrlMemWrite;
    wire            CtrlMemtoReg;
    wire            CtrlRegWrite;
    wire            CtrlALUSrc;
    wire    [1:0]   CtrlALUOp;
    
    //====== Other ======
    wire    [31:0]  PCAddFour;
    wire    [31:0]  PCBranchOffset;
    wire    [31:0]  PCBranchTgt;
    wire    [31:0]  PCJumpTgt;
    wire            PCNext;
    wire            DoBranch;

    // ====== Instantialization ======
    assign InstOpCode    = iRdInst[31:26];
    assign InstRs        = iRdInst[25:21];
    assign InstRt        = iRdInst[20:16];
    assign InstRd        = iRdInst[15:11];
    assign InstShamt     = iRdInst[10:6];
    assign InstFunct     = iRdInst[5:0];
    assign InstImmediate = iRdInst[15:0];
    assign InstJumpAddr  = iRdInst[25:0];

    assign IStyleAluSrc1 = {{16{InstImmediate[15]}, InstImmediate};
    assign PCBranchOffset = {{14{InstImmediate[15]}, InstImmediate, 2'b00};
    assign PCJumpTgt = {PCAddFour[31:28], InstJumpAddr, 2'b00};

    RegFile reg_inst(
        .clk(iClk),
        .reset(iRst_n),
        .addr1(RdRegId0),
        .data1(RdRegData0),
        .addr2(RdRegId1),
        .data2(RdRegData1),
        .addr3(WrRegId),
        .data3(WrRegData),
        .wr(RegWrite));

    singcyc_ctrl_unit ctrl_unit_inst(   
        .iOpCode    (iRdInst[31:26]),
        .oRegDst    (CtrlRegDst),     
        .oJump      (CtrlJump),       
        .oBranch    (CtrlBranch),
        .oBranchEq  (CtrlBranchEq),
        .oMemRead   (CtrlMemRead),
        .oMemWrite  (CtrlMemWrite),
        .oMemtoReg  (CtrlMemtoReg),
        .oRegWrite  (CtrlRegWrite),
        .oALUSrc    (CtrlALUSrc),
        .oALUOp     (CtrlALUOp));

    singcyc_alu_ctrl alu_ctrl_inst(
        .iAluOp(CtrlALUOp),
        .iFunct(InstFunct),
        .oAluCtrl(AluFunct));

    add32b add32b_inst_PC_add_four(
        .iA(PC),
        .iB(32'd4),
        .oS(PCAddFour));

    add32b add32b_inst_jump_tgt(
        .iA(PCAddFour),
        .iB(PCBranchOffset),
        .oS(PCBranchTgt));

    alu alu_inst(
        .iA(AluIn0),
        .iB(AluIn1),
        .iS(AluOut),
        .iFunct(AluFunct),
        .Z(AluZero));

    assign RdRegId0 = InstRs;
    assign RdRegId1 = InstRt;
    assign WrRegId = CtrlRegDst ? InstRd : InstRt;
    assign WrRegData = CtrlMemtoReg ? iRdData : AluOut;
    assign RegWrite = CtrlRegWrite;

    assign AluIn0 = RdRegData0;
    assign AluIn1 = CtrlALUSrc : IStyleAluSrc1 ? RdRegId1;
    assign DoBranch = CtrlBranch & ~(CtrlBranchEq ^ AluZero);

    assign oRdWrMemAddr = AluOut;
    assign oWrData = RdRegData1;
    assign oMemWrite = CtrlMemWrite;
    assign oMemRead = CtrlMemRead;
    assign oRdInstAddr = PC;

    assign PCNext = DoBranch ? PCBranchTgt :
                    CtrlJump ? PCJumpTgt :
                               PCAddFour;

    always @(posedge iClk or negedge iRst_n)
    begin
        if(~iRst_n)
        begin
            PC <= 0;
        end
        else
            PC <= PCNext;
        begin
        end
    end

endmodule
