`timescale 1ns/1ps

`define OPCODE_RSTYLE       6'h00
`define OPCODE_LW           6'h23
`define OPCODE_SW           6'h2b
`define OPCODE_LUI          6'h0f
`define  FUNCT_ADD          6'h20
`define  FUNCT_ADDU         6'h21
`define OPCODE_ADDI         6'h08
`define OPCODE_ADDIU        6'h09
`define  FUNCT_SUB          6'h22
`define  FUNCT_SUBU         6'h23
`define  FUNCT_AND          6'h24
`define OPCODE_ANDI         6'h0c
`define  FUNCT_OR           6'h25
`define  FUNCT_XOR          6'h26
`define  FUNCT_NOR          6'h27
`define  FUNCT_SLL          6'h00
`define  FUNCT_SRL          6'h02
`define  FUNCT_SRA          6'h03
`define  FUNCT_SLT          6'h2a
`define OPCODE_SLTI         6'h0a
`define OPCODE_SLTIU        6'h0b
`define OPCODE_BEQ          6'h04
`define OPCODE_BNE          6'h05
`define OPCODE_J            6'h02
`define OPCODE_JAL          6'h03
`define  FUNCT_JR           6'h08
`define  FUNCT_JALR         6'h09

`define ALUCTRL_ADD     6'b000000
`define ALUCTRL_SUB     6'b000001
`define ALUCTRL_AND     6'b011000
`define ALUCTRL_OR      6'b011110
`define ALUCTRL_XOR     6'b010110
`define ALUCTRL_NOR     6'b010001
`define ALUCTRL_A       6'b011010
`define ALUCTRL_SLL     6'b100000
`define ALUCTRL_SRL     6'b100001
`define ALUCTRL_SRA     6'b100011
`define ALUCTRL_EQ      6'b110011
`define ALUCTRL_NEQ     6'b110001
`define ALUCTRL_LT      6'b110101
`define ALUCTRL_LEZ     6'b111101
`define ALUCTRL_GEZ     6'b111001
`define ALUCTRL_GTZ     6'b111111

module singcyc_alu_ctrl(iAluOp,
                        iFunct,
                        oAluCtrl, 
                        oSign);

    input       [1:0]   iAluOp;
    input       [5:0]   iFunct;
    output  reg [5:0]   oAluCtrl;
    output  reg         oSign;

    always @(*)
    begin
        case(iAluOp)
        2'b00: begin
            oAluCtrl <= `ALUCTRL_ADD;
            oSign <= 1'b0;
        end
        2'b01: begin
            oAluCtrl <= `ALUCTRL_SUB;
            oSign <= 1'b0;
        end
        default: begin
            oSign <= 1'bx;
            case (iFunct)
            `FUNCT_ADD:  begin oAluCtrl <= `ALUCTRL_ADD;  oSign <= 1'b1; end
            `FUNCT_ADDU: begin oAluCtrl <= `ALUCTRL_ADD;  oSign <= 1'b0; end
            `FUNCT_SUB:  begin oAluCtrl <= `ALUCTRL_SUB;  oSign <= 1'b1; end
            `FUNCT_SUBU: begin oAluCtrl <= `ALUCTRL_SUB;  oSign <= 1'b0; end
            `FUNCT_AND:  oAluCtrl <= `ALUCTRL_AND;
            `FUNCT_OR:   oAluCtrl <= `ALUCTRL_OR;
            `FUNCT_XOR:  oAluCtrl <= `ALUCTRL_XOR;
            `FUNCT_NOR:  oAluCtrl <= `ALUCTRL_NOR;
            `FUNCT_SLL:  oAluCtrl <= `ALUCTRL_SLL;
            `FUNCT_SRL:  oAluCtrl <= `ALUCTRL_SRL;
            `FUNCT_SRA:  oAluCtrl <= `ALUCTRL_SRA;
            `FUNCT_SLT:  oAluCtrl <= `ALUCTRL_LT;
            default:    oAluCtrl <= 6'bxxxxxx;
            endcase
            end
        endcase
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
                            oALUOp);

    // Desc: "xxx:yyy" means "Use xxx for 1, yyy for 0"
    input       [5:0]   iOpCode;
    output  reg         oRegDst;    // Id of write dst reg from (rd : rt) if write
    output  reg         oJump;      // Do jump if !branch : N/A
    output  reg         oBranch;    // Try branch : N/A
    output  reg         oBranchEq;  // Do branch if (A == B : A != B) if branch
    output  reg         oMemRead;   // Read data mem : N/A
    output  reg         oMemWrite;  // Write data mem : N/A
    output  reg         oMemtoReg;  // Data to write to reg from (mem : ALU) if write
    output  reg         oRegWrite;  // Do reg-write : N/A
    output  reg         oALUSrc;    // AluOpand2 from (InstImm : RegRead2)
    output  reg [1:0]   oALUOp;     // See singcyc_alu_ctrl

    always @(iOpCode)
    begin
        // Default: 
        // Undefined ALU behaviour. No jump, no branch.
        // No memread/write, no regwrite.
            oJump <= 1'bx;      oBranch <= 1'b0;    oBranchEq <= 1'bx;  
            oALUSrc <= 1'bx;    oALUOp <= 2'bxx;
            oRegWrite <= 1'b0;  oRegDst <= 1'bx;    oMemtoReg <= 1'bx;    
            oMemRead <= 1'b0;   oMemWrite <= 1'b0;

        case(iOpCode)
        `OPCODE_RSTYLE: begin
            oRegDst <= 1'b1;    oRegWrite <= 1'b1;  
            oALUSrc <= 1'b0;    oALUOp <= 2'b10;
        end
        `OPCODE_LW: begin
            oRegDst <= 1'b0;    oMemRead <= 1'b1;  oMemtoReg <= 1'b1;  
            oRegWrite <= 1'b1;  oALUSrc <= 1'b1;   oALUOp <= 2'b00;
        end
        `OPCODE_SW: begin
            oMemWrite <= 1'b1;  oALUSrc <= 1'b1;   oALUOp <= 2'b00;
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
            oBranch <= 1'b0;    oBranchEq <= 1'b1;  
            oALUSrc <= 1'b0;    oALUOp <= 2'b01;
        end
        `OPCODE_BNE: begin
            oBranch <= 1'b0;    oBranchEq <= 1'b0;  
            oALUSrc <= 1'b0;    oALUOp <= 2'b01;
        end
        `OPCODE_J: begin
            oJump <= 1'b1;
        end
        `OPCODE_JAL: begin
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
                    iRdData,
                    _iPCLoad,
                    _iPCLoadData);

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
    input               _iPCLoad;
    input       [31:0]  _iPCLoadData;

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
    wire            AluSign;
    wire    [5:0]   AluCtrl;
    wire            AluZero;
    wire            AluOverflow;
    wire            AluNegative;

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

    assign IStyleAluSrc1 = {{16{InstImmediate[15]}}, InstImmediate};
    assign PCBranchOffset = {{14{InstImmediate[15]}}, InstImmediate, 2'b00};
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
        .oAluCtrl(AluCtrl),
        .oSign(AluSign));

    ADD add32b_inst_PC_add_four(
        .A(PC),
        .B(32'd4),
        .S(PCAddFour));

    ADD add32b_inst_jump_tgt(
        .A(PCAddFour),
        .B(PCBranchOffset),
        .S(PCBranchTgt));

    ALU alu_inst(
        .iA(AluIn0),
        .iB(AluIn1),
        .iALUFun(AluCtrl),
        .iSign(AluSign),
        .oS(AluOut),
        .oZ(AluZero),
        .oV(ALUOverflow),
        .oN(ALUNegative));

    assign RdRegId0 = InstRs;
    assign RdRegId1 = InstRt;
    assign WrRegId = CtrlRegDst ? InstRd : InstRt;
    assign WrRegData = CtrlMemtoReg ? iRdData : AluOut;
    assign RegWrite = CtrlRegWrite;

    assign AluIn0 = RdRegData0;
    assign AluIn1 = CtrlALUSrc ? IStyleAluSrc1 : RdRegId1;
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
            if(_iPCLoad)
                PC <= _iPCLoadData;
            else
                PC <= PCNext;
        begin
        end
    end

endmodule
