`timescale 1ns/1ps
`include "../alu/isa_define.v"

`define INTERRUPT_PC 32'h80000004
`define INTERRUPT_REG 5'd26

module singcyc_alu_ctrl(iAluOp,
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

module singcyc_ctrl_unit(   iOpCode,
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
            oBranch = 1'b1;    oBranchOpt = 2'b00; oJump = 1'b0;
            oALUSrc = 1'b0;    oALUOp = 2'b01;
        end
        `OPCODE_BNE: begin
            oBranch = 1'b1;    oBranchOpt = 2'b01; oJump = 1'b0;
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
            oJump = 1'b1;      oJLink = 1'b1;
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
                    iInterrupt,
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
    input               iInterrupt;

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
    wire            CtrlJR;       
    wire            CtrlJLink;       
    wire            CtrlJRLink;       
    wire            CtrlBranch;
    wire    [1:0]   CtrlBranchOpt;
    wire            CtrlMemRead;
    wire            CtrlMemWrite;
    wire            CtrlMemtoReg;
    wire            CtrlRegWrite;
    wire            CtrlALUSrc;
    wire    [1:0]   CtrlALUOp;
    wire            CtrlALUShamt;
    
    //====== Other ======
    wire    [31:0]  PCAddFour;
    wire    [31:0]  IStyleAluSrc1;
    wire    [31:0]  PCBranchOffset;
    wire    [31:0]  PCBranchTgt;
    wire    [31:0]  PCJumpTgt;
    wire    [31:0]  PCNextRaw;
    wire    [31:0]  PCNext;
    wire            TakeBranch;
    wire            Link;
    wire            BeginInterrupt;

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

    assign BeginInterrupt = (~PC[31])&iInterrupt;

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
        .oJLink     (CtrlJLink),       
        .oBranch    (CtrlBranch),
        .oBranchOpt (CtrlBranchOpt),
        .oMemRead   (CtrlMemRead),
        .oMemWrite  (CtrlMemWrite),
        .oMemtoReg  (CtrlMemtoReg),
        .oRegWrite  (CtrlRegWrite),
        .oALUSrc    (CtrlALUSrc),
        .oALUOp     (CtrlALUOp));

    singcyc_alu_ctrl alu_ctrl_inst(
        .iAluOp(CtrlALUOp),
        .iInstOp(InstOpCode),
        .iFunct(InstFunct),
        .oAluCtrl(AluCtrl),
        .oSign(AluSign),
        .oJR(CtrlJR),
        .oJRLink(CtrlJRLink),
        .oShamt(CtrlALUShamt));

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

    assign Link = CtrlJLink | CtrlJRLink;
    assign RdRegId0 = InstRs;
    assign RdRegId1 = InstRt;
    assign WrRegId = BeginInterrupt ? `INTERRUPT_REG :
                     Link ? 5'd31 :
                     CtrlRegDst ? InstRd : 
                     InstRt;
    assign WrRegData = BeginInterrupt ? PC :
                       Link ? PCAddFour :
                       CtrlMemtoReg ? iRdData : 
                       AluOut;
    assign RegWrite = BeginInterrupt | CtrlRegWrite | Link;

    assign AluIn0 = CtrlALUShamt ? {{27{1'b0}}, InstShamt} :
                    RdRegData0;
    assign AluIn1 = CtrlALUSrc ? IStyleAluSrc1 : 
                    RdRegData1;
    assign TakeBranch = CtrlBranch & ((^CtrlBranchOpt) ^ AluZero);

    assign oRdWrMemAddr = AluOut;
    assign oWrData = RdRegData1;
    assign oMemWrite = (~BeginInterrupt) & CtrlMemWrite;
    assign oMemRead = CtrlMemRead;
    assign oRdInstAddr = PC;

    assign PCNextRaw  = BeginInterrupt ? `INTERRUPT_PC :
                        TakeBranch ? PCBranchTgt :
                        CtrlJump ? PCJumpTgt :
                        CtrlJR ? RdRegData0 : 
                               PCAddFour;
    assign PCNext = (BeginInterrupt|CtrlJR) ? PCNextRaw :
                    {PC[31],PCNextRaw[30:0]};

    always @(posedge iClk or negedge iRst_n)
    begin
        if(~iRst_n)
        begin
            PC <= 32'h00400000;
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
