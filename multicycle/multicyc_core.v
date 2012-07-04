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

    //====== Input/Output ======
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

    reg             PC;

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

    wire            EX_AluIn0;/*S*/
    wire            EX_AluIn1;/*S*/
    wire            EX_AluOut;/*S*/
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

    wire            EX_AluOp;/*S*/
    wire            EX_InstOp;/*S*/
    wire            EX_AluFunct;/*S*/
    wire            EX_AluCtrl;/*S*/
    wire            EX_AluSign;/*S*/
    wire            EX_CtrlJR;/*S*/
    wire            EX_CtrlJRLink;/*S*/
    wire            EX_CtrlALUShamt;/*S*/

    wire            EX_InstRd;/*S*/
    wire            EX_InstRt;/*S*/
    wire            EX_InstImmediate;/*S*/
    wire            EX_InstShamt;/*S*/
    wire            EX_InstJumpAddr;/*S*/

    reg             EXMEM_CtrlWb;/*S*/
    reg             EXMEM_CtrlMem;/*S*/
    reg     [31:0]  EXMEM_AluOut;/*S*/
    reg     [31:0]  EXMEM_RdRegData1;/*S*/
    reg     [4:0]   EXMEM_WrRegId;/*S*/
    reg             EXMEM_RegWrite;/*S*/
    reg             EXMEM_Link;/*S*/
    reg             EXMEM_PCAddFour;/*S*/

    wire    [31:0]  MEM_RdWrMemAddr;/*S*/
    wire    [31:0]  MEM_MemWrData;/*S*/
    wire            MEM_CtrlMemWrite;/*S*/
    wire            MEM_CtrlMemRead;/*S*/

    reg     [31:0]  MEMWB_MemReadData;/*S*/
    reg             MEMWB_CtrlWb;/*S*/
    reg     [4:0]   MEMWB_WrRegId;/*S*/
    reg             MEMWB_RegWrite;/*S*/
    reg             MEMWB_Link;/*S*/
    reg             MEMWB_PCAddFour;/*S*/
    reg     [31:0]  MEMWB_AluOut;/*S*/

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


    always @(posedge iClk or negedge iRst_n)
    begin
        if(~iRst_n)
        begin
            PC <= 32'h004000a8;
        end
        else
            if(_iPCLoad)
                PC <= _iPCLoadData;
            else
                PC <= PCNext;
        begin
        end
    end
    assign _oPC = PC;
    assign _oPCNext = PCNext;

endmodule
