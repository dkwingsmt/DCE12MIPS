`timescale 1ns/1ps
`include "../alu/isa_define.v"

module multicyc_alu_ctrl(iAluOp,
                        iInstOp,
                        iFunct,
                        oAluCtrl, 
                        oSign,
                        oShamt,
                        oJR,
                        oJRLink);

    input       [1:0]   iAluOp;
    input       [5:0]   iInstOp;
    input       [5:0]   iFunct;
    output  reg [5:0]   oAluCtrl;
    output  reg         oSign;
    output  reg         oShamt;
    output  reg         oJR;
    output  reg         oJRLink;

    always @(*)
    begin
        oAluCtrl = 6'bxxxxxx;
        oSign = 1'bx;
        oShamt = 1'b0;
        oJR = 1'b0;
        oJRLink = 1'b0;
        case(iAluOp)
        2'b00: begin
            oAluCtrl = `ALUCTRL_ADD;
            oSign = 1'b0;
        end
        2'b01: begin
            oAluCtrl = `ALUCTRL_SUB;
            oSign = 1'b0;
        end
        2'b10: begin
            case (iFunct)
            `FUNCT_ADD:  begin oAluCtrl = `ALUCTRL_ADD;  oSign = 1'b1; end
            `FUNCT_ADDU: begin oAluCtrl = `ALUCTRL_ADD;  oSign = 1'b0; end
            `FUNCT_SUB:  begin oAluCtrl = `ALUCTRL_SUB;  oSign = 1'b1; end
            `FUNCT_SUBU: begin oAluCtrl = `ALUCTRL_SUB;  oSign = 1'b0; end
            `FUNCT_AND:  oAluCtrl = `ALUCTRL_AND;
            `FUNCT_OR:   oAluCtrl = `ALUCTRL_OR;
            `FUNCT_XOR:  oAluCtrl = `ALUCTRL_XOR;
            `FUNCT_NOR:  oAluCtrl = `ALUCTRL_NOR;
            `FUNCT_SLLV:  oAluCtrl = `ALUCTRL_SLL;
            `FUNCT_SRLV:  oAluCtrl = `ALUCTRL_SRL;
            `FUNCT_SRAV:  oAluCtrl = `ALUCTRL_SRA;
            `FUNCT_SLL: begin oShamt = 1'b1; oAluCtrl = `ALUCTRL_SLL; end
            `FUNCT_SRL: begin oShamt = 1'b1; oAluCtrl = `ALUCTRL_SRL; end
            `FUNCT_SRA: begin oShamt = 1'b1; oAluCtrl = `ALUCTRL_SRA; end
            `FUNCT_SLT:  oAluCtrl = `ALUCTRL_LT;
            `FUNCT_JR:   begin oJR = 1'b1;   oJRLink = 1'b0; end
            `FUNCT_JALR: begin oJR = 1'b1;   oJRLink = 1'b1; end
            endcase
            end
        2'b11: begin
            case (iInstOp)
            `OPCODE_ADDI:   begin oAluCtrl = `ALUCTRL_ADD;  oSign = 1'b1; end
            `OPCODE_ADDIU:  begin oAluCtrl = `ALUCTRL_ADD;  oSign = 1'b0; end   
            `OPCODE_ANDI:   oAluCtrl = `ALUCTRL_AND;
            `OPCODE_ORI:    oAluCtrl = `ALUCTRL_OR;
            `OPCODE_SLTI:   begin oAluCtrl = `ALUCTRL_LT;   oSign = 1'b1; end    
            `OPCODE_SLTIU:  begin oAluCtrl = `ALUCTRL_LT;   oSign = 1'b0; end   
            `OPCODE_LUI:    oAluCtrl = `ALUCTRL_LUI;
            endcase
            end
        endcase
    end
endmodule

module multicyc_ctrl_unit(  iOpCode,
                            oRegDst,     
                            oJump,       
                            oJLink,       
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
    output  reg         oJLink;     // Addr of jump from (RegRead0 : InstJumpAddr)
    output  reg         oBranch;    // Try branch : N/A
    output  reg         oBranchEq;  // Do branch if (A == B : A != B) if branch
    output  reg         oMemRead;   // Read data mem : N/A
    output  reg         oMemWrite;  // Write data mem : N/A
    output  reg         oMemtoReg;  // Data to write to reg from (mem : ALU) if write
    output  reg         oRegWrite;  // Do reg-write : N/A
    output  reg         oALUSrc;    // AluOpand2 from (InstImm : RegRead1)
    output  reg [1:0]   oALUOp;     // See singcyc_alu_ctrl

    always @(iOpCode)
    begin
        // Default: 
        // Undefined ALU behaviour. No jump, no branch.
        // No memread/write, no regwrite.
            oBranch = 1'b0;    oBranchEq = 1'bx;  
            oJump = 1'b0;      oJLink = 1'b0;
            oALUSrc = 1'bx;    oALUOp = 2'bxx;
            oRegWrite = 1'b0;  oRegDst = 1'bx;    oMemtoReg = 1'bx;    
            oMemRead = 1'b0;   oMemWrite = 1'b0;

        // RStyle behaviour: 
        // ALU behaviour defined by Funct. No jump, no branch.
        // ALU Op2 read from reg.
        // No memread/write. Write reg rt with alu result.
            `define CTRL_RSTYLE_BEHAVIOUR begin \
                oRegDst = 1'b1;    oRegWrite = 1'b1;  oMemtoReg = 1'b0; \
                oALUSrc = 1'b0;    oALUOp = 2'b10; \
                end

        // IStyle behaviour: 
        // ALU behaviour defined by OpCode. No jump, no branch.
        // ALU Op2 from instImm.
        // No memread/write. Write reg rd with alu result.
            `define CTRL_ISTYLE_BEHAVIOUR begin \
                oRegDst = 1'b0;    oRegWrite = 1'b1;  oMemtoReg = 1'b0; \
                oALUSrc = 1'b1;    oALUOp = 2'b11; \
                end

        case(iOpCode)
        `OPCODE_RSTYLE: begin
            `CTRL_RSTYLE_BEHAVIOUR 
        end
        `OPCODE_LW: begin
            oRegDst = 1'b0;    oMemRead = 1'b1;  oMemtoReg = 1'b1;  
            oRegWrite = 1'b1;  oALUSrc = 1'b1;   oALUOp = 2'b00;
        end
        `OPCODE_SW: begin
            oMemWrite = 1'b1;  oALUSrc = 1'b1;   oALUOp = 2'b00;
        end
        `OPCODE_LUI: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_ADDI: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_ADDIU: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_ANDI: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_ORI: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_SLTI: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_SLTIU: begin
            `CTRL_ISTYLE_BEHAVIOUR
        end
        `OPCODE_BEQ: begin
            oBranch = 1'b1;    oBranchEq = 1'b1;  oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b01;
        end
        `OPCODE_BNE: begin
            oBranch = 1'b1;    oBranchEq = 1'b0;  oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b01;
        end
        `OPCODE_J: begin
            oJump = 1'b1;      oJLink = 1'b0;
        end
        `OPCODE_JAL: begin
            oJump = 1'b1;      oJLink = 1'b1;
        end
        endcase
    end

endmodule

module multicyc_core(iClk,
                     iRst_n, 
                     oRdInstAddr, 
                     iRdInst, 
                     oRdWrMemAddr, 
                     oMemWrite, 
                     oMemRead, 
                     oWrData, 
                     iRdData,
                     _iPCLoad,
                     _iPCLoadData,
                     _oPC,
                     _oPCNext);

    input               iClk;
    input               iRst_n;
    output      [31:0]  oRdInstAddr;
    input       [31:0]  iRdInst;
    output      [31:0]  oRdWrMemAddr;
    output              oMemWrite;
    output              oMemRead;
    output      [31:0]  oWrData;
    input       [31:0]  iRdData;
    input               _iPCLoad;
    input       [31:0]  _iPCLoadData;
    output      [31:0]  _oPC;
    output      [31:0]  _oPCNext;

    reg     [31:0]  PC;

    wire    [31:0]  IF_PCAddFour;/*S*/

    reg     [31:0]  IFID_PCAddFour;/*S*/
    reg     [31:0]  IFID_Inst;/*S*/

    wire    [4:0]   ID_InstRs;/*S*/
    wire    [4:0]   ID_InstRt;/*S*/
    wire    [4:0]   ID_RdRegId0;/*S*/
    wire    [31:0]  ID_RdRegData0;/*S*/
    wire    [4:0]   ID_RdRegId1;/*S*/
    wire    [31:0]  ID_RdRegData1;/*S*/

    wire            ID_CtrlRegDst;/*S*/
    wire            ID_CtrlJump;/*S*/
    wire            ID_CtrlJLink;/*S*/
    wire            ID_CtrlBranch;/*S*/
    wire            ID_CtrlBranchEq;/*S*/
    wire            ID_CtrlMemRead;/*S*/
    wire            ID_CtrlMemWrite;/*S*/
    wire            ID_CtrlMemtoReg;/*S*/
    wire            ID_CtrlRegWrite;/*S*/
    wire            ID_CtrlALUSrc;/*S*/
    wire    [1:0]   ID_CtrlALUOp;/*S*/

    reg     [31:0]  IDEX_Inst;/*S*/
    reg     [9:0]   IDEX_CtrlWb;/*S*/
    reg     [31:0]  IDEX_CtrlMem;/*S*/
    reg     [31:0]  IDEX_CtrlEx;/*S*/
    reg     [31:0]  IDEX_RdRegData0;/*S*/
    reg     [31:0]  IDEX_RdRegData1;/*S*/

    reg     [31:0]  IDEX_PCAddFour;/*S*/

    wire    [31:0]  EX_IStyleAluSrc1;/*S*/
    wire    [4:0]   EX_WrRegId;/*S*/
    wire            EX_RegWrite;/*S*/
    wire            EX_Link;/*S*/
    wire    [31:0]  EX_PCBranchOffset;/*S*/
    wire    [31:0]  EX_PCBranchTgt;/*S*/
    wire    [31:0]  EX_PCJumpTgt;/*S*/
    wire            EX_DoBranch;/*S*/
    wire    [31:0]  EX_PCNext;/*S*/

    // AluInRaw: When forwarding is not considered.
    reg     [31:0]  EX_AluIn0Raw;/*S*/
    reg     [31:0]  EX_AluIn1Raw;/*S*/
    wire    [31:0]  EX_AluIn0;/*S*/
    wire    [31:0]  EX_AluIn1;/*S*/
    wire    [31:0]  EX_AluOut;/*S*/
    wire            EX_AluZero;/*S*/
    wire            EX_ALUOverflow;/*S*/
    wire            EX_ALUNegative;/*S*/

    wire            EX_CtrlRegDst;/*S*/
    wire            EX_CtrlRegWrite;/*S*/
    wire            EX_CtrlALUSrc;/*S*/
    wire    [1:0]   EX_CtrlALUOp;/*S*/
    wire            EX_CtrlMemtoReg;/*S*/
    wire            EX_CtrlBranch;/*S*/
    wire            EX_CtrlBranchEq;/*S*/
    wire            EX_CtrlJump;/*S*/
    wire            EX_CtrlJLink;/*S*/

    wire    [1:0]   EX_AluOp;/*S*/
    wire    [5:0]   EX_InstOp;/*S*/
    wire    [5:0]   EX_AluFunct;/*S*/
    wire    [5:0]   EX_AluCtrl;/*S*/
    wire            EX_AluSign;/*S*/
    wire            EX_CtrlJR;/*S*/
    wire            EX_CtrlJRLink;/*S*/
    wire            EX_CtrlALUShamt;/*S*/

    wire    [4:0]   EX_InstRs;/*S*/
    wire    [4:0]   EX_InstRt;/*S*/
    wire    [4:0]   EX_InstRd;/*S*/
    wire    [15:0]  EX_InstImmediate;/*S*/
    wire    [4:0]   EX_InstShamt;/*S*/
    wire    [26:0]  EX_InstJumpAddr;/*S*/

    // AluSrc: 00 as non-forward, 10 from EXMEM, 01 from MEMWB
    wire    [1:0]   EX_FWD_AluSrc0;/*S*/
    wire    [1:0]   EX_FWD_AluSrc1;/*S*/
    // RegSrcFlag: 0 if not from reg; 1 elsewise
    reg             EX_FWD_AluRegSrcFlag0;/*S*/
    reg             EX_FWD_AluRegSrcFlag1;/*S*/

    reg     [31:0]  EXMEM_Inst;/*S*/
    reg             EXMEM_CtrlWb;/*S*/
    reg     [1:0]   EXMEM_CtrlMem;/*S*/
    reg     [31:0]  EXMEM_AluOut;/*S*/
    reg     [31:0]  EXMEM_RdRegData1;/*S*/
    reg     [4:0]   EXMEM_WrRegId;/*S*/
    reg             EXMEM_RegWrite;/*S*/
    reg             EXMEM_Link;/*S*/
    reg     [31:0]  EXMEM_PCAddFour;/*S*/

    reg     [31:0]  EXMEM_PCNext;/*S*/

    wire    [31:0]  MEM_RdWrMemAddr;/*S*/
    wire    [31:0]  MEM_MemWrData;/*S*/
    wire            MEM_CtrlMemWrite;/*S*/
    wire            MEM_CtrlMemRead;/*S*/

    reg     [31:0]  MEMWB_Inst;/*S*/
    reg             MEMWB_CtrlWb;/*S*/
    reg     [31:0]  MEMWB_MemReadData;/*S*/
    reg     [4:0]   MEMWB_WrRegId;/*S*/
    reg             MEMWB_RegWrite;/*S*/
    reg             MEMWB_Link;/*S*/
    reg     [31:0]  MEMWB_PCAddFour;/*S*/
    reg     [31:0]  MEMWB_AluOut;/*S*/

    reg     [31:0]  MEMWB_PCNext;/*S*/

    wire    [4:0]   WB_WrRegId;/*S*/
    wire            WB_RegWrite;/*S*/
    wire    [31:0]  WB_WrRegData;/*S*/
    wire            WB_Link;/*S*/
    wire    [31:0]  WB_PCAddFour;/*S*/
    wire            WB_CtrlMemtoReg;/*S*/
    wire    [31:0]  WB_RdData;/*S*/
    wire    [31:0]  WB_AluOut;/*S*/

    RegFile reg_inst(
        .clk    (iClk),
        .reset  (iRst_n),
        .addr1  (ID_RdRegId0),
        .data1  (ID_RdRegData0),
        .addr2  (ID_RdRegId1),
        .data2  (ID_RdRegData1),
        .addr3  (WB_WrRegId),
        .data3  (WB_WrRegData),
        .wr     (WB_RegWrite));

    multicyc_ctrl_unit ctrl_unit_inst(   
        .iOpCode    (IFID_Inst[31:26]),
        .oRegDst    (ID_CtrlRegDst),     
        .oJump      (ID_CtrlJump),       
        .oJLink     (ID_CtrlJLink),       
        .oBranch    (ID_CtrlBranch),
        .oBranchEq  (ID_CtrlBranchEq),
        .oMemRead   (ID_CtrlMemRead),
        .oMemWrite  (ID_CtrlMemWrite),
        .oMemtoReg  (ID_CtrlMemtoReg),
        .oRegWrite  (ID_CtrlRegWrite),
        .oALUSrc    (ID_CtrlALUSrc),
        .oALUOp     (ID_CtrlALUOp));

    multicyc_alu_ctrl alu_ctrl_inst(
        .iAluOp     (EX_AluOp),
        .iInstOp    (EX_InstOp),
        .iFunct     (EX_AluFunct),
        .oAluCtrl   (EX_AluCtrl),
        .oSign      (EX_AluSign),
        .oJR        (EX_CtrlJR),
        .oJRLink    (EX_CtrlJRLink),
        .oShamt     (EX_CtrlALUShamt));

    ADD add32b_inst_PC_add_four(
        .A(PC),
        .B(32'd4),
        .S(IF_PCAddFour));

    ADD add32b_inst_jump_tgt(
        .A(IDEX_PCAddFour),
        .B(EX_PCBranchOffset),
        .S(EX_PCBranchTgt));

    ALU alu_inst(
        .iA     (EX_AluIn0),
        .iB     (EX_AluIn1),
        .iALUFun(EX_AluCtrl),
        .iSign  (EX_AluSign),
        .oS     (EX_AluOut),
        .oZ     (EX_AluZero),
        .oV     (EX_ALUOverflow),
        .oN     (EX_ALUNegative));

    assign oRdInstAddr = PC;

    assign ID_RdRegId0 = ID_InstRs;
    assign ID_RdRegId1 = ID_InstRt;
    assign ID_InstRs = IFID_Inst[25:21];
    assign ID_InstRs = IFID_Inst[20:16];

    assign EX_CtrlRegDst    = IDEX_CtrlEx[9];
    assign EX_CtrlRegWrite  = IDEX_CtrlEx[8];
    assign EX_CtrlALUSrc    = IDEX_CtrlEx[7];
    assign EX_CtrlALUOp     = IDEX_CtrlEx[6:5];
    assign EX_CtrlMemtoReg  = IDEX_CtrlEx[4];
    assign EX_CtrlBranch    = IDEX_CtrlEx[3];
    assign EX_CtrlBranchEq  = IDEX_CtrlEx[2];
    assign EX_CtrlJump      = IDEX_CtrlEx[1];
    assign EX_CtrlJLink     = IDEX_CtrlEx[0];

    assign EX_InstOp = IDEX_Inst[31:26];
    assign EX_InstRs = IDEX_Inst[25:21];
    assign EX_InstRt = IDEX_Inst[20:16];
    assign EX_InstRd = IDEX_Inst[15:11];
    assign EX_InstShamt = IDEX_Inst[10:6];
    assign EX_AluFunct = IDEX_Inst[5:0];
    assign EX_InstImmediate = IDEX_Inst[15:0];
    assign EX_InstJumpAddr = IDEX_Inst[25:0];

    assign EX_AluOp = EX_CtrlALUOp;

    always @(EX_CtrlALUShamt, EX_InstShamt, IDEX_RdRegData0, IDEX_RdRegData1,
                EX_CtrlALUSrc, EX_IStyleAluSrc1)
    begin
        EX_FWD_AluRegSrcFlag0 = 1'b0;
        EX_FWD_AluRegSrcFlag1 = 1'b0;
        if(EX_CtrlALUShamt)
            EX_AluIn0Raw = {{27{1'b0}}, EX_InstShamt};
        else
        begin
            EX_AluIn0Raw = IDEX_RdRegData0;
            EX_FWD_AluRegSrcFlag0 = 1'b1;
        end
        if(EX_CtrlALUSrc)
            EX_AluIn1Raw = EX_IStyleAluSrc1;
        else
        begin
            EX_AluIn1Raw = IDEX_RdRegData1;
            EX_FWD_AluRegSrcFlag1 = 1'b1;
        end
    end

    assign EX_IStyleAluSrc1 = {{16{EX_InstImmediate[15]}}, EX_InstImmediate};
    assign EX_WrRegId = EX_Link ? 5'd31 :
                     EX_CtrlRegDst ? EX_InstRd : 
                     EX_InstRt;
    assign EX_RegWrite = EX_CtrlRegWrite | EX_Link;
    assign EX_Link = EX_CtrlJLink | EX_CtrlJRLink;
    assign EX_PCBranchOffset = {{14{EX_InstImmediate[15]}}, 
                                EX_InstImmediate, 2'b00};
    assign EX_PCJumpTgt = {IDEX_PCAddFour[31:28], EX_InstJumpAddr, 2'b00};
    assign EX_DoBranch = EX_CtrlBranch & ~(EX_CtrlBranchEq ^ EX_AluZero);
    assign EX_PCNext = EX_DoBranch ? EX_PCBranchTgt :
                       EX_CtrlJump ? EX_PCJumpTgt :
                       EX_CtrlJR ? IDEX_RdRegData0 : 
                                   IDEX_PCAddFour;

    assign EX_FWD_AluSrc0 = (EXMEM_RegWrite 
                             & EX_FWD_AluRegSrcFlag0
                             & (EXMEM_WrRegId != 5'b0)
                             & (EXMEM_WrRegId == EX_InstRs)) 
                                                                ? 2'b10 :
                            (MEMWB_RegWrite 
                             & EX_FWD_AluRegSrcFlag0
                             & (MEMWB_WrRegId != 5'b0)
                             & (MEMWB_WrRegId != EXMEM_WrRegId)
                             & (MEMWB_WrRegId == EX_InstRs)) 
                                                                ? 2'b01 :
                            2'b00;
    assign EX_AluIn0 = (EX_FWD_AluSrc0 == 2'b00) ? EX_AluIn0Raw :
                       (EX_FWD_AluSrc0 == 2'b10) ? EXMEM :
    assign EX_FWD_AluSrc1 = (EXMEM_RegWrite 
                             & EX_FWD_AluRegSrcFlag1
                             & (EXMEM_WrRegId != 5'b0)
                             & (EXMEM_WrRegId == EX_InstRt)) 
                                                                ? 2'b10 :
                            (MEMWB_RegWrite 
                             & EX_FWD_AluRegSrcFlag1
                             & (MEMWB_WrRegId != 5'b0)
                             & (MEMWB_WrRegId != EXMEM_WrRegId)
                             & (MEMWB_WrRegId == EX_InstRt)) 
                                                                ? 2'b01 :
                            2'b00;

    assign MEM_CtrlMemWrite = EXMEM_CtrlMem[1];
    assign MEM_CtrlMemRead = EXMEM_CtrlMem[0];
    assign MEM_RdWrMemAddr = EXMEM_AluOut;
    assign MEM_MemWrData = EXMEM_RdRegData1;
    assign oRdWrMemAddr = MEM_RdWrMemAddr;
    assign oWrData = MEM_MemWrData;
    assign oMemWrite = MEM_CtrlMemWrite;
    assign oMemRead = MEM_CtrlMemRead;

    assign WB_WrRegId = MEMWB_WrRegId;
    assign WB_RegWrite = MEMWB_RegWrite;
    assign WB_Link = MEMWB_Link;
    assign WB_PCAddFour = MEMWB_PCAddFour;
    assign WB_CtrlMemtoReg = MEMWB_CtrlWb;
    assign WB_WrRegData = WB_CtrlMemtoReg ? MEMWB_MemReadData : 
                          WB_Link ? WB_PCAddFour :
                          WB_AluOut;
    assign WB_RdData = MEMWB_MemReadData;
    assign WB_AluOut = MEMWB_AluOut;

    always @(posedge iClk or negedge iRst_n)
    begin
        if(~iRst_n)
        begin
            PC <= 32'h004000a8;
        end
        else
        begin
            IFID_PCAddFour <= IF_PCAddFour;
            IFID_Inst <= iRdInst;

            IDEX_Inst <= IFID_Inst;
            IDEX_RdRegData0 <= ID_RdRegData0;
            IDEX_RdRegData1 <= ID_RdRegData1;
            IDEX_PCAddFour <= IFID_PCAddFour;
            IDEX_CtrlEx <= {
                            EX_CtrlRegDst,
                            EX_CtrlRegWrite,
                            EX_CtrlALUSrc,
                            EX_CtrlALUOp,
                            EX_CtrlMemtoReg,
                            EX_CtrlBranch,
                            EX_CtrlBranchEq,
                            EX_CtrlJump,
                            EX_CtrlJLink
                            };
            IDEX_CtrlMem <= {
                            MEM_CtrlMemWrite,
                            MEM_CtrlMemRead
                            };
            IDEX_CtrlWb <= WB_CtrlMemtoReg;

            //EXMEM_Inst <= IDEX_Inst;
            EXMEM_AluOut <= EX_AluOut;
            EXMEM_RdRegData1 <= IDEX_RdRegData1;
            EXMEM_CtrlWb <= IDEX_CtrlWb;
            EXMEM_CtrlMem <= IDEX_CtrlMem;
            EXMEM_WrRegId <= EX_WrRegId;
            EXMEM_RegWrite <= EX_RegWrite;
            EXMEM_Link <= EX_Link;
            EXMEM_PCAddFour <= IDEX_PCAddFour;
            EXMEM_PCNext <= EX_PCNext;

            //MEMWB_Inst <= EXMEM_Inst;
            MEMWB_MemReadData <= iRdData;
            MEMWB_CtrlWb <= EXMEM_CtrlWb;
            MEMWB_WrRegId <= EXMEM_WrRegId;
            MEMWB_RegWrite <= EXMEM_RegWrite;
            MEMWB_Link <= EXMEM_Link;
            MEMWB_PCAddFour <= EXMEM_PCAddFour;
            MEMWB_AluOut <= EXMEM_AluOut;
            MEMWB_PCNext <= EXMEM_PCNext;

            if(_iPCLoad)
                PC <= _iPCLoadData;
            else
                PC <= MEMWB_PCNext;

        end
    end
    assign _oPC = PC;
    assign _oPCNext = MEMWB_PCNext;

endmodule
