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

    reg             IFID_Inst;/*S*/

    wire            ID_InstRs;
    wire            ID_InstRt;
    wire            ID_RdRegId0;/*S*/
    wire            ID_RdRegData0;/*S*/
    wire            ID_RdRegId1;/*S*/
    wire            ID_RdRegData1;/*S*/

    reg     [31:0]  IDEX_CtrlWb;
    reg     [31:0]  IDEX_CtrlMem;
    reg     [31:0]  IDEX_CtrlEx;
    wire            IDEX_RdRegData0;
    reg             IDEX_RdRegData1;
    /*
    reg             IDEX_CtrlALUOp;
    reg             IDEX_InstOpCode;
    reg             IDEX_InstFunct;
    reg             IDEX_PCAddFour;*/

    wire            EX_IStyleAluSrc1;/*S*/
    wire            EX_AluIn0;/*S*/
    wire            EX_AluIn1;/*S*/
    wire            EX_WrRegId;/*S*/
    wire            EX_RegWrite;/*S*/
    wire            EX_Link;/*S*/
    wire            EX_PCBranchOffset;/*S*/
    wire            EX_PCJumpTgt;/*S*/
    wire            EX_PCAddFour;
    wire            EX_CtrlALUShamt;
    wire            EX_CtrlRegDst;
    wire            EX_CtrlMemtoReg;
    wire            EX_CtrlJLink;
    wire            EX_CtrlJRLink;
    wire            EX_CtrlRegWrite;
    wire            EX_InstRd;
    wire            EX_InstRt;
    wire            EX_InstImmediate;
    wire            EX_InstShamt;
    wire            EX_InstJumpAddr;

    reg             EXMEM_CtrlWb;/*S*/
    reg             EXMEM_CtrlMem;/*S*/

    wire            MEM_WrRegId;/*S*/
    wire            MEM_WrRegData;
    wire            MEM_RegWrite;

    reg             MEMWB_CtrlWb;/*S*/

    wire            WB_WrRegData;/*S*/
    wire            WB_Link;
    wire            WB_PCAddFour;
    wire            WB_CtrlMemtoReg;
    wire            WB_RdData;
    wire            WB_AluOut;

    assign w_RdRegId0 = w_Inst;
    assign w_RdRegId1 = IFID_RdRegId1;
    assign w_WrRegId = MEMWB_WrRegId;
    assign w_WrRegData = MEMWB_WrRegData;
    assign w_RegWrite = MEMWB_RegWrite;

    RegFile reg_inst(
        .clk    (iClk),
        .reset  (iRst_n),
        .addr1  (ID_RdRegId0),
        .data1  (ID_RdRegData0),
        .addr2  (ID_RdRegId1),
        .data2  (ID_RdRegData1),
        .addr3  (MEM_WrRegId),
        .data3  (MEM_WrRegData),
        .wr     (MEM_RegWrite));

    multicyc_ctrl_unit ctrl_unit_inst(   
        .iOpCode    (IFID_iRdIns[31:26]),
        .oRegDst    (w_CtrlRegDst),     
        .oJump      (w_CtrlJump),       
        .oJLink     (w_CtrlJLink),       
        .oBranch    (w_CtrlBranch),
        .oBranchEq  (w_CtrlBranchEq),
        .oMemRead   (w_CtrlMemRead),
        .oMemWrite  (w_CtrlMemWrite),
        .oMemtoReg  (w_CtrlMemtoReg),
        .oRegWrite  (w_CtrlRegWrite),
        .oALUSrc    (w_CtrlALUSrc),
        .oALUOp     (w_CtrlALUOp));

    wire            w_AluOP;
    wire            w_InstOp;
    wire            w_AluFunct;
    assign w_AluOp = IDEX_CtrlALUOp;
    assign w_InstOp = IDEX_InstOpCode;
    assign w_AluFunct = IDEX_InstFunct;

    multicyc_alu_ctrl alu_ctrl_inst(
        .iAluOp     (w_AluOp),
        .iInstOp    (w_InstOp),
        .iFunct     (w_AluFunct),
        .oAluCtrl   (w_AluCtrl),
        .oSign      (w_AluSign),
        .oJR        (w_CtrlJR),
        .oJRLink    (w_CtrlJRLink),
        .oShamt     (w_CtrlALUShamt));

    ADD add32b_inst_PC_add_four(
        .A(PC),
        .B(32'd4),
        .S(w_PCAddFour));

    ADD add32b_inst_jump_tgt(
        .A(IDEX_PCAddFour),
        .B(w_PCBranchOffset),
        .S(w_PCBranchTgt));

    ALU alu_inst(
        .iA     (w_AluIn0),
        .iB     (w_AluIn1),
        .iALUFun(w_AluCtrl),
        .iSign  (w_AluSign),
        .oS     (w_AluOut),
        .oZ     (w_AluZero),
        .oV     (w_ALUOverflow),
        .oN     (w_ALUNegative));


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
