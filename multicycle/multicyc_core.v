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
            `OPCODE_BLEZ:   begin oAluCtrl = `ALUCTRL_LEZ;  oSign = 1'b1; end
            `OPCODE_BGTZ:   begin oAluCtrl = `ALUCTRL_LEZ;  oSign = 1'b1; end
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
                            oBranchOpt,
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
    output  reg [1:0]   oBranchOpt; // 0*: Do branch if (A != B : A == B) if branch
                                    // 1*: Do branch if (A > 0 : A <= 0) if branch 
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
            oBranch = 1'b0;    oBranchOpt = 1'bx;  
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
            oBranch = 1'b1;    oBranchOpt = 2'b00;  oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b01;
        end
        `OPCODE_BNE: begin
            oBranch = 1'b1;    oBranchOpt = 2'b01;  oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b01;
        end
        `OPCODE_BLEZ: begin
            oBranch = 1'b1;    oBranchOpt = 2'b10; oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b11;
        end
        `OPCODE_BGTZ: begin
            oBranch = 1'b1;    oBranchOpt = 2'b11; oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b11;
        end
        `OPCODE_J: begin
            oJump = 1'b1;      oJLink = 1'b0;
        end
        `OPCODE_JAL: begin
            oJump = 1'b1;      oJLink = 1'b1;       oMemtoReg = 1'b0;
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
                     iInterrupt,
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
    input               iInterrupt;
    input               _iPCLoad;
    input       [31:0]  _iPCLoadData;
    output      [31:0]  _oPC;
    output      [31:0]  _oPCNext;

    reg     [31:0]  PC;
    wire    [31:0]  PC_Raw;
    wire            BeginInterrupt;
    reg             InstFromInterrupt;
    wire    [31:0]  NextInstAddr;

    wire    [31:0]  IF_PCAddFour;/*S*/
    
    reg     [31:0]  IFID_PC;
    reg     [31:0]  IFID_PCAddFour;/*S*/
    reg     [31:0]  IFID_Inst;/*S*/

    wire    [5:0]   ID_InstOp;/*S*/
    wire    [4:0]   ID_InstRs;/*S*/
    wire    [4:0]   ID_InstRt;/*S*/
    wire    [5:0]   ID_InstFunct;/*S*/
    wire    [26:0]  ID_InstJumpAddr;/*S*/
    wire    [4:0]   ID_RdRegId0;/*S*/
    wire    [31:0]  ID_RdRegData0Origin;/*S*/
    wire    [31:0]  ID_RdRegData0;/*S*/
    wire    [4:0]   ID_RdRegId1;/*S*/
    wire    [31:0]  ID_RdRegData1Origin;/*S*/
    wire    [31:0]  ID_RdRegData1;/*S*/
    wire    [31:0]  ID_PCJumpTgt;/*S*/

    wire            ID_CtrlRegDst;/*S*/
    wire            ID_CtrlJump;/*S*/
    wire            ID_CtrlJLink;/*S*/
    wire            ID_CtrlBranch;/*S*/
    wire    [1:0]   ID_CtrlBranchOpt;/*S*/
    wire            ID_CtrlMemRead;/*S*/
    wire            ID_CtrlMemWrite;/*S*/
    wire            ID_CtrlMemtoReg;/*S*/
    wire            ID_CtrlRegWrite;/*S*/
    wire            ID_CtrlALUSrc;/*S*/
    wire    [1:0]   ID_CtrlALUOp;/*S*/

    wire            ID_AluSign;/*S*/
    wire    [5:0]   ID_AluCtrl;/*S*/
    wire            ID_CtrlJR;/*S*/
    wire            ID_CtrlJRLink;/*S*/
    wire            ID_CtrlALUShamt;/*S*/

    reg     [31:0]  IDEX_PC;
    reg     [31:0]  IDEX_Inst;/*S*/
    //reg     [9:0]   IDEX_CtrlWb;/*S*/
    reg     [2:0]   IDEX_CtrlMem;/*S*/
    reg     [10:0]  IDEX_CtrlEx;/*S*/
    reg     [31:0]  IDEX_RdRegData0;/*S*/
    reg     [31:0]  IDEX_RdRegData1;/*S*/
    reg     [31:0]  IDEX_PCJumpTgt;/*S*/
    reg             IDEX_AluSign;/*S*/
    reg     [5:0]   IDEX_AluCtrl;/*S*/
    reg             IDEX_CtrlJump;/*S*/
    reg             IDEX_CtrlJR;/*S*/
    reg             IDEX_CtrlJRLink;/*S*/
    reg             IDEX_CtrlALUShamt;/*S*/

    reg     [31:0]  IDEX_PCAddFour;/*S*/

    wire    [31:0]  EX_WrRegDataProposalEx;
    wire    [31:0]  EX_IStyleAluSrc1;/*S*/
    wire    [4:0]   EX_WrRegId;/*S*/
    wire            EX_RegWrite;/*S*/
    wire            EX_Link;/*S*/
    wire    [31:0]  EX_PCBranchOffset;/*S*/
    wire    [31:0]  EX_PCBranchTgt;/*S*/
    wire            EX_TakeBranch;/*S*/
    wire    [31:0]  EX_PCNext;/*S*/
    wire            EX_FalseBranch;
    wire    [31:0]  EX_AlterBranchAddr;

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
    wire    [1:0]   EX_CtrlBranchOpt;/*S*/
    wire            EX_CtrlJump;/*S*/
    wire            EX_CtrlJLink;/*S*/

    wire            EX_CtrlMemRead;/*S*/ // From MEM

    wire    [1:0]   EX_AluOp;/*S*/
    wire    [5:0]   EX_AluFunct;/*S*/

    wire    [5:0]   EX_InstOp;/*S*/
    wire    [4:0]   EX_InstRs;/*S*/
    wire    [4:0]   EX_InstRt;/*S*/
    wire    [4:0]   EX_InstRd;/*S*/
    wire    [15:0]  EX_InstImmediate;/*S*/
    wire    [4:0]   EX_InstShamt;/*S*/

    // AluSrc: 00 as non-forward, 10 from EXMEM, 01 from MEMWB
    wire    [1:0]   EX_FWD_AluSrc0;/*S*/
    wire    [1:0]   EX_FWD_AluSrc1;/*S*/
    // RealRdRegData: RdRegData with forwarding counted in
    wire    [31:0]  EX_RealRdRegData0;/*S*/
    wire    [31:0]  EX_RealRdRegData1;/*S*/

    reg     [31:0]  EXMEM_PC;
    reg             EXMEM_Interrupt;
    reg     [31:0]  EXMEM_WrRegDataProposalEx;
    reg     [31:0]  EXMEM_Inst;/*S*/
    //reg             EXMEM_CtrlWb;/*S*/
    reg     [2:0]   EXMEM_CtrlMem;/*S*/
    reg     [31:0]  EXMEM_AluOut;/*S*/
    reg     [31:0]  EXMEM_RealRdRegData1;/*S*/
    reg     [4:0]   EXMEM_WrRegId;/*S*/
    reg             EXMEM_RegWrite;/*S*/
    reg             EXMEM_Link;/*S*/
    reg             EXMEM_FalseBranch;
    reg     [31:0]  EXMEM_AlterBranchAddr;
    reg     [31:0]  EXMEM_PCAddFour;/*S*/

    reg     [31:0]  EXMEM_PCNext;/*S*/

    wire    [31:0]  MEM_WrRegDataProposalMem;
    wire    [31:0]  MEM_RdWrMemAddr;/*S*/
    wire    [31:0]  MEM_MemWrData;/*S*/
    wire            MEM_CtrlMemWrite;/*S*/
    wire            MEM_CtrlMemRead;/*S*/
    wire            MEM_CtrlMemtoReg;/*S*/

    reg     [31:0]  MEMWB_PC;
    reg             MEMWB_Interrupt;
    reg     [31:0]  MEMWB_WrRegDataProposalMem;
    reg     [31:0]  MEMWB_Inst;/*S*/
    //reg             MEMWB_CtrlWb;/*S*/
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
    //wire            WB_CtrlMemtoReg;/*S*/
    wire    [31:0]  WB_RdData;/*S*/
    wire    [31:0]  WB_AluOut;/*S*/

    reg             IFIDReg_Stall;
    reg             IFIDReg_Flush;
    reg             IDEXReg_Stall;
    reg             IDEXReg_Flush;
    reg             EXMEMReg_Stall;
    reg             EXMEMReg_Flush;
    reg             MEMWBReg_Stall;
    reg             MEMWBReg_Flush;
    wire            Flush_All;

    RegFile reg_inst(
        .clk    (iClk),
        .reset  (iRst_n),
        .addr1  (ID_RdRegId0),
        .data1  (ID_RdRegData0Origin),
        .addr2  (ID_RdRegId1),
        .data2  (ID_RdRegData1Origin),
        .addr3  (WB_WrRegId),
        .data3  (WB_WrRegData),
        .wr     (WB_RegWrite));

    multicyc_ctrl_unit ctrl_unit_inst(   
        .iOpCode    (IFID_Inst[31:26]),
        .oRegDst    (ID_CtrlRegDst),     
        .oJump      (ID_CtrlJump),       
        .oJLink     (ID_CtrlJLink),       
        .oBranch    (ID_CtrlBranch),
        .oBranchOpt (ID_CtrlBranchOpt),
        .oMemRead   (ID_CtrlMemRead),
        .oMemWrite  (ID_CtrlMemWrite),
        .oMemtoReg  (ID_CtrlMemtoReg),
        .oRegWrite  (ID_CtrlRegWrite),
        .oALUSrc    (ID_CtrlALUSrc),
        .oALUOp     (ID_CtrlALUOp));

    multicyc_alu_ctrl alu_ctrl_inst(
        .iAluOp     (ID_CtrlALUOp),
        .iInstOp    (ID_InstOp),
        .iFunct     (ID_InstFunct),
        .oAluCtrl   (ID_AluCtrl),
        .oSign      (ID_AluSign),
        .oJR        (ID_CtrlJR),
        .oJRLink    (ID_CtrlJRLink),
        .oShamt     (ID_CtrlALUShamt));

    ADD add32b_inst_PC_add_four(
        .A(NextInstAddr),
        .B(32'd4),
        .S(IF_PCAddFour));

    ADD add32b_inst_jump_tgt(
        .A(IDEX_PCAddFour),
        .B(EX_PCBranchOffset),
        .S(EX_PCBranchTgt));

    ALU alu_inst(
        .iA     (EX_AluIn0),
        .iB     (EX_AluIn1),
        .iALUFun(IDEX_AluCtrl),
        .iSign  (IDEX_AluSign),
        .oS     (EX_AluOut),
        .oZ     (EX_AluZero),
        .oV     (EX_ALUOverflow),
        .oN     (EX_ALUNegative));

    assign NextInstAddr = InstFromInterrupt ? 32'h80000004 :
                          EXMEM_FalseBranch ? EXMEM_AlterBranchAddr :
                          IDEX_CtrlJump ? IDEX_PCJumpTgt :
                          IDEX_CtrlJR ? EX_RealRdRegData0 :     // Stalled 1 cyc
                          PC;
    assign oRdInstAddr = NextInstAddr;
    assign PC_Raw = {(BeginInterrupt ? 1'b1 :
                    IDEX_CtrlJR ? EX_RealRdRegData0[31] :
                    PC[31]),IF_PCAddFour[30:0]};

    assign BeginInterrupt = (~NextInstAddr[31])&(~IFID_PC[31])&(~IDEX_PC[31])&iInterrupt;
    assign Flush_All = BeginInterrupt;

    assign ID_RdRegId0 = ID_InstRs;
    assign ID_RdRegData0 = (WB_RegWrite & (ID_RdRegId0 == WB_WrRegId)) ? 
                            WB_WrRegData : ID_RdRegData0Origin;
    assign ID_RdRegId1 = ID_InstRt;
    assign ID_RdRegData1 = (WB_RegWrite & (ID_RdRegId1 == WB_WrRegId)) ? 
                            WB_WrRegData : ID_RdRegData1Origin;
    assign ID_InstOp = IFID_Inst[31:26];
    assign ID_InstRs = IFID_Inst[25:21];
    assign ID_InstRt = IFID_Inst[20:16];
    assign ID_InstFunct = IFID_Inst[5:0];
    assign ID_InstJumpAddr = IFID_Inst[25:0];
    assign ID_PCJumpTgt = {IFID_PCAddFour[31:28], ID_InstJumpAddr, 2'b00};

    assign EX_CtrlRegDst    = IDEX_CtrlEx[10];
    assign EX_CtrlRegWrite  = IDEX_CtrlEx[9];
    assign EX_CtrlALUSrc    = IDEX_CtrlEx[8];
    assign EX_CtrlALUOp     = IDEX_CtrlEx[7:6];
    assign EX_CtrlMemtoReg  = IDEX_CtrlEx[5];
    assign EX_CtrlBranch    = IDEX_CtrlEx[4];
    assign EX_CtrlBranchOpt = IDEX_CtrlEx[3:2];
    assign EX_CtrlJump      = IDEX_CtrlEx[1];
    assign EX_CtrlJLink     = IDEX_CtrlEx[0];

    assign EX_InstOp = IDEX_Inst[31:26];
    assign EX_InstRs = IDEX_Inst[25:21];
    assign EX_InstRt = IDEX_Inst[20:16];
    assign EX_InstRd = IDEX_Inst[15:11];
    assign EX_InstShamt = IDEX_Inst[10:6];
    assign EX_AluFunct = IDEX_Inst[5:0];
    assign EX_InstImmediate = IDEX_Inst[15:0];

    assign EX_AluOp = EX_CtrlALUOp;
    assign EX_AluIn0 = IDEX_CtrlALUShamt ? {{27{1'b0}}, EX_InstShamt}
                                         : EX_RealRdRegData0;
    assign EX_AluIn1 = EX_CtrlALUSrc ? EX_IStyleAluSrc1
                                     : EX_RealRdRegData1;

    assign EX_WrRegDataProposalEx = EX_Link ? IDEX_PCAddFour :
                                    EX_AluOut;
    assign EX_IStyleAluSrc1 = {{16{EX_InstImmediate[15]}}, EX_InstImmediate};
    assign EX_WrRegId = EX_Link ? 5'd31 :
                     EX_CtrlRegDst ? EX_InstRd : 
                     EX_InstRt;
    assign EX_RegWrite = EX_CtrlRegWrite | EX_Link;
    assign EX_Link = EX_CtrlJLink | IDEX_CtrlJRLink;
    assign EX_PCBranchOffset = {{14{EX_InstImmediate[15]}}, 
                                EX_InstImmediate, 2'b00};
    assign EX_TakeBranch = EX_CtrlBranch & (^EX_CtrlBranchOpt ^ EX_AluZero);
    //assign EX_PCNext = EX_TakeBranch ? EX_PCBranchTgt :
                                   //IDEX_PCAddFour;
    assign EX_FalseBranch = EX_TakeBranch;      // Plz always make sure & CtrlBranch
    assign EX_AlterBranchAddr = EX_PCBranchTgt;

    assign EX_FWD_AluSrc0 = (EXMEM_RegWrite 
                             & (EXMEM_WrRegId != 5'b0)
                             & (EXMEM_WrRegId == EX_InstRs)) 
                                                                ? 2'b10 :
                            (MEMWB_RegWrite 
                             & (MEMWB_WrRegId != 5'b0)
                             & (MEMWB_WrRegId != EXMEM_WrRegId)
                             & (MEMWB_WrRegId == EX_InstRs)) 
                                                                ? 2'b01 :
                            2'b00;
    assign EX_FWD_AluSrc1 = (EXMEM_RegWrite 
                             & (EXMEM_WrRegId != 5'b0)
                             & (EXMEM_WrRegId == EX_InstRt)) 
                                                                ? 2'b10 :
                            (MEMWB_RegWrite 
                             & (MEMWB_WrRegId != 5'b0)
                             & (MEMWB_WrRegId != EXMEM_WrRegId)
                             & (MEMWB_WrRegId == EX_InstRt)) 
                                                                ? 2'b01 :
                            2'b00;

    assign EX_RealRdRegData0 = (EX_FWD_AluSrc0 == 2'b10) ? EXMEM_WrRegDataProposalEx :
                               (EX_FWD_AluSrc0 == 2'b01) ? MEMWB_WrRegDataProposalMem :
                               IDEX_RdRegData0;
    assign EX_RealRdRegData1 = (EX_FWD_AluSrc1 == 2'b10) ? EXMEM_WrRegDataProposalEx :
                               (EX_FWD_AluSrc1 == 2'b01) ? MEMWB_WrRegDataProposalMem :
                               IDEX_RdRegData1;

    assign MEM_WrRegDataProposalMem = MEM_CtrlMemtoReg ? iRdData : 
                                      EXMEM_WrRegDataProposalEx;
    assign MEM_CtrlMemtoReg = EXMEM_CtrlMem[2];
    assign MEM_CtrlMemWrite = EXMEM_CtrlMem[1];
    assign MEM_CtrlMemRead = EXMEM_CtrlMem[0];
    assign EX_CtrlMemRead   = IDEX_CtrlMem[0];

    assign MEM_RdWrMemAddr = EXMEM_AluOut;
    assign MEM_MemWrData = EXMEM_RealRdRegData1;
    assign oRdWrMemAddr = MEM_RdWrMemAddr;
    assign oWrData = MEM_MemWrData;
    assign oMemWrite = MEM_CtrlMemWrite;
    assign oMemRead = MEM_CtrlMemRead;

    assign WB_WrRegId = MEMWB_Interrupt ? `INTERRUPT_REG : MEMWB_WrRegId;
    assign WB_RegWrite = MEMWB_RegWrite | MEMWB_Interrupt;
    assign WB_WrRegData = MEMWB_Interrupt ? MEMWB_PC : MEMWB_WrRegDataProposalMem;
    //assign WB_CtrlMemtoReg = MEMWB_CtrlWb;
    //assign WB_RdData = MEMWB_MemReadData;
    
    always @(*)
    begin
        IFIDReg_Stall = 0;
        IFIDReg_Flush = 0;
        IDEXReg_Stall = 0;
        IDEXReg_Flush = 0;
        EXMEMReg_Stall = 0;
        EXMEMReg_Flush = 0;
        MEMWBReg_Stall = 0;
        MEMWBReg_Flush = 0;
        // Branch took false branch
        if(EX_FalseBranch)
        begin
            IFIDReg_Flush = 1;
            IDEXReg_Flush = 1;
        end
        // J or JR, stall 1 cyc
        else if(ID_CtrlJR | ID_CtrlJump)
        begin
            IFIDReg_Flush = 1;
        end
        // Load-Use, stall 1 cyc
        else if(EX_CtrlMemRead
            & (EX_InstRt != 5'b0)
            & ((EX_InstRt == ID_InstRs) 
               | (EX_InstRt == ID_InstRt)))
        begin
            IFIDReg_Stall = 1;
            IDEXReg_Flush = 1;
        end

    end

    always @(posedge iClk or negedge iRst_n)
    begin
        if(~iRst_n)
        begin
            InstFromInterrupt <= 0;
            PC <= 32'h00400000;
            IFID_PC <= 0;
            IDEX_PC <= 0;
            EXMEM_PC <=0;
            MEMWB_PC <=0;
            IFID_PCAddFour <= 0;
            IFID_Inst <= 0;
            
            IDEX_Inst <= 0;
            IDEX_RdRegData0 <= 0;
            IDEX_RdRegData1 <= 0;
            IDEX_PCAddFour <= 0;
            IDEX_PCJumpTgt <= 0;
            IDEX_CtrlEx <= 0;
            IDEX_CtrlMem <= 0;
            //IDEX_CtrlWb <= 0;
            IDEX_AluSign <= 0;
            IDEX_AluCtrl <= 0;
            IDEX_CtrlJump <= 0;
            IDEX_CtrlJR <= 0;
            IDEX_CtrlJRLink <= 0;
            IDEX_CtrlALUShamt <= 0;

            //EXMEM_Inst <= 0;
            EXMEM_RealRdRegData1 <= 0;
            EXMEM_WrRegDataProposalEx <= 0;
            EXMEM_AluOut <= 0;
            EXMEM_RealRdRegData1 <= 0;
            //EXMEM_CtrlWb <= 0;
            EXMEM_CtrlMem <= 0;
            EXMEM_WrRegId <= 0;
            EXMEM_RegWrite <= 0;
            EXMEM_Link <= 0;
            EXMEM_FalseBranch <= 0;
            EXMEM_AlterBranchAddr <= 0;
            EXMEM_PCAddFour <= 0;
            EXMEM_PCNext <= 0;

            //MEMWB_Inst <= 0;
            MEMWB_WrRegDataProposalMem <= 0;
            MEMWB_MemReadData <= 0;
            //MEMWB_CtrlWb <= 0;
            MEMWB_WrRegId <= 0;
            MEMWB_RegWrite <= 0;
            MEMWB_Link <= 0;
            MEMWB_PCAddFour <= 0;
            MEMWB_AluOut <= 0;
            MEMWB_PCNext <= 0;
        end
        else
        begin
            InstFromInterrupt <= BeginInterrupt;
            if(IFIDReg_Flush | Flush_All)
            begin
                if(Flush_All)
                    PC <= PC_Raw;
                IFID_PC <= 0;
                IFID_PCAddFour <= 0;
                IFID_Inst <= 0;
            end
            else if(~IFIDReg_Stall)
            begin
                PC <= PC_Raw;
                IFID_PC <= NextInstAddr;
                IFID_PCAddFour <= IF_PCAddFour;
                IFID_Inst <= iRdInst;
            end

            if(IDEXReg_Flush | Flush_All)
            begin
                IDEX_PC <= 0;
                IDEX_Inst <= 0;
                IDEX_RdRegData0 <= 0;
                IDEX_RdRegData1 <= 0;
                IDEX_PCAddFour <= 0;
                IDEX_PCJumpTgt <= 0;
                IDEX_CtrlEx <= 0;
                IDEX_CtrlMem <= 0;
                //IDEX_CtrlWb <= 0;
                IDEX_AluSign <= 0;
                IDEX_AluCtrl <= 0;
                IDEX_CtrlJump <= 0;
                IDEX_CtrlJR <= 0;
                IDEX_CtrlJRLink <= 0;
                IDEX_CtrlALUShamt <= 0;
            end
            else if(~IDEXReg_Stall) 
            begin
                IDEX_PC <= IFID_PC;
                IDEX_Inst <= IFID_Inst;
                IDEX_RdRegData0 <= ID_RdRegData0;
                IDEX_RdRegData1 <= ID_RdRegData1;
                IDEX_PCAddFour <= IFID_PCAddFour;
                IDEX_PCJumpTgt <= ID_PCJumpTgt;
                IDEX_CtrlEx <= {
                                ID_CtrlRegDst,
                                ID_CtrlRegWrite,
                                ID_CtrlALUSrc,
                                ID_CtrlALUOp,
                                ID_CtrlMemtoReg,
                                ID_CtrlBranch,
                                ID_CtrlBranchOpt,
                                ID_CtrlJump,
                                ID_CtrlJLink
                                };
                IDEX_CtrlMem <= {
                                ID_CtrlMemtoReg,
                                ID_CtrlMemWrite,
                                ID_CtrlMemRead
                                };
                //IDEX_CtrlWb <= WB_CtrlMemtoReg;
                IDEX_AluSign <= ID_AluSign;
                IDEX_AluCtrl <= ID_AluCtrl;
                IDEX_CtrlJump <= ID_CtrlJump;
                IDEX_CtrlJR <= ID_CtrlJR;
                IDEX_CtrlJRLink <= ID_CtrlJRLink;
                IDEX_CtrlALUShamt <= ID_CtrlALUShamt;
            end

            if(EXMEMReg_Flush | Flush_All)
            begin
//                EXMEM_PC <= (~IDEXReg_Flush) ? IDEX_PC :
//                            (IFIDReg_Flush) ? NextInstAddr :
//                                            IFID_PC;
                if (Flush_All)
                    EXMEM_PC <= (IDEX_PC) ? IDEX_PC :
                                (IFID_PC) ? IFID_PC :
                                NextInstAddr;
                else
                    EXMEM_PC <= IDEX_PC;
                EXMEM_Interrupt <= Flush_All;
                EXMEM_RealRdRegData1 <= 0;
                EXMEM_WrRegDataProposalEx <= 0;
                EXMEM_AluOut <= 0;
                EXMEM_RealRdRegData1 <= 0;
                //EXMEM_CtrlWb <= 0;
                EXMEM_CtrlMem <= 0;
                EXMEM_WrRegId <= 0;
                EXMEM_RegWrite <= 0;
                EXMEM_Link <= 0;
                EXMEM_FalseBranch <= 0;
                EXMEM_AlterBranchAddr <= 0;
                EXMEM_PCAddFour <= 0;
                EXMEM_PCNext <= 0;
            end
            else if(~EXMEMReg_Stall)
            begin
                EXMEM_Interrupt <= 1'b0;
                EXMEM_PC <= IDEX_PC;
                //EXMEM_Inst <= IDEX_Inst;
                EXMEM_WrRegDataProposalEx <= EX_WrRegDataProposalEx;
                EXMEM_AluOut <= EX_AluOut;
                EXMEM_RealRdRegData1 <= EX_RealRdRegData1;
                //EXMEM_CtrlWb <= IDEX_CtrlWb;
                EXMEM_CtrlMem <= IDEX_CtrlMem;
                EXMEM_WrRegId <= EX_WrRegId;
                EXMEM_RegWrite <= EX_RegWrite;
                EXMEM_Link <= EX_Link;
                EXMEM_FalseBranch <= EX_FalseBranch;
                EXMEM_AlterBranchAddr <= EX_AlterBranchAddr;
                EXMEM_PCAddFour <= IDEX_PCAddFour;
                EXMEM_PCNext <= EX_PCNext;
            end

            if(MEMWBReg_Flush)
            begin
                MEMWB_Interrupt <= 0;
                //MEMWB_Inst <= 0;
                MEMWB_WrRegDataProposalMem <= 0;
                MEMWB_MemReadData <= 0;
                //MEMWB_CtrlWb <= 0;
                MEMWB_WrRegId <= 0;
                MEMWB_RegWrite <= 0;
                MEMWB_Link <= 0;
                MEMWB_PCAddFour <= 0;
                MEMWB_AluOut <= 0;
                MEMWB_PCNext <= 0;
            end
            else if(~MEMWBReg_Stall)
            begin
                MEMWB_Interrupt <= EXMEM_Interrupt;
                MEMWB_PC <= EXMEM_PC;
                //MEMWB_Inst <= EXMEM_Inst;
                MEMWB_WrRegDataProposalMem <= MEM_WrRegDataProposalMem;
                MEMWB_MemReadData <= iRdData;
                //MEMWB_CtrlWb <= EXMEM_CtrlWb;
                MEMWB_WrRegId <= EXMEM_WrRegId;
                MEMWB_RegWrite <= EXMEM_RegWrite;
                MEMWB_Link <= EXMEM_Link;
                MEMWB_PCAddFour <= EXMEM_PCAddFour;
                MEMWB_AluOut <= EXMEM_AluOut;
                MEMWB_PCNext <= EXMEM_PCNext;
            end


        end
    end
    assign _oPC = PC;
    assign _oPCNext = IF_PCAddFour;

endmodule
