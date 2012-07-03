    //====== Essential ======

    //====== Registers ======
    wire    [4:0]   RdRegId0;
    wire    [4:0]   RdRegId1;
    wire    [4:0]   WrRegId;
    wire    [31:0]  RdRegData0;
    wire    [31:0]  RdRegData1;
    wire    [31:0]  WrRegData;
    wire            RegWrite;
    
    //====== Other ======
    wire    [31:0]  IStyleAluSrc1;
    wire    [31:0]  PCJumpTgt;
    wire    [31:0]  PCNext;
    wire            DoBranch;
    wire            Link;

    // ====== Instantialization ======
    // EX
    assign PCBranchOffset = {{14{InstImmediate[15]}}, InstImmediate, 2'b00};
    assign IStyleAluSrc1 = {{16{InstImmediate[15]}}, InstImmediate};
    assign PCJumpTgt = {PCAddFour[31:28], InstJumpAddr, 2'b00};

    //MEM
    assign oRdWrMemAddr = AluOut;
    assign oWrData = RdRegData1;
    assign oMemWrite = CtrlMemWrite;
    assign oMemRead = CtrlMemRead;
    assign oRdInstAddr = PC;

    //WB
    assign WrRegData = Link ? PCAddFour :
                       CtrlMemtoReg ? iRdData : 
                       AluOut;
    assign RegWrite = CtrlRegWrite | Link;
    assign Link = CtrlJLink | CtrlJRLink;
    assign DoBranch = CtrlBranch & ~(CtrlBranchEq ^ AluZero);
    assign PCNext = DoBranch ? PCBranchTgt :
                    CtrlJump ? PCJumpTgt :
                    CtrlJR ? RdRegData0 : 
                               PCAddFour;

    assign InstOpCode    = iRdInst[31:26];
    assign InstRs        = iRdInst[25:21];
    assign InstRt        = iRdInst[20:16];
    assign InstRd        = iRdInst[15:11];
    assign InstShamt     = iRdInst[10:6];
    assign InstFunct     = iRdInst[5:0];
    assign InstImmediate = iRdInst[15:0];
    assign InstJumpAddr  = iRdInst[25:0];

