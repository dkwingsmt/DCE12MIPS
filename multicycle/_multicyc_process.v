
    assign oRdInstAddr = PC;
    IFID_Inst <= iRdInst;

    assign ID_RdRegId0 = ID_InstRs;
    assign ID_RdRegId1 = ID_InstRt;

    IDEX_RdRegData0 <= ID_RdRegData0;
    IDEX_RdRegData1 <= ID_RdRegData1;

    assign EX_AluOp = IDEX_CtrlALUOp;
    assign EX_InstOp = IDEX_InstOpCode;
    assign EX_AluFunct = IDEX_InstFunct;

    assign EX_AluIn0 = EX_CtrlALUShamt ? {{27{1'b0}}, EX_InstShamt} :
                    IDEX_RdRegData0;
    assign EX_AluIn1 = EX_CtrlALUSrc ? IStyleAluSrc1 : 
                    IDEX_RdRegData1;

    assign EX_IStyleAluSrc1 = {{16{EX_InstImmediate[15]}}, EX_InstImmediate};
    assign EX_WrRegId = EX_Link ? 5'd31 :
                     EX_CtrlRegDst ? EX_InstRd : 
                     EX_InstRt;
    assign EX_RegWrite = EX_CtrlRegWrite | EX_Link;
    assign EX_Link = EX_CtrlJLink | EX_CtrlJRLink;
    assign EX_PCBranchOffset = {{14{EX_InstImmediate[15]}}, 
                                EX_InstImmediate, 2'b00};
    assign EX_PCJumpTgt = {EX_PCAddFour[31:28], EX_InstJumpAddr, 2'b00};
    assign EX_DoBranch = EX_CtrlBranch & ~(EX_CtrlBranchEq ^ EX_AluZero);
    assign EX_PCNext = EX_DoBranch ? EX_PCBranchTgt :
                    EX_CtrlJump ? EX_PCJumpTgt :
                    EX_CtrlJR ? IDEX_RdRegData0 : 
                               EX_PCAddFour;

    EXMEM_CtrlWb <= IDEX_CtrlWb;
    EXMEM_CtrlMem <= IDEX_CtrlMem;

    assign oRdWrMemAddr = MEM_RdWrMemAddr;
    assign oWrData = MEM_RdRegData1;
    assign oMemWrite = MEM_CtrlMemWrite;
    assign oMemRead = MEM_CtrlMemRead;

    MEMWB_MemReadData <= iRdData;
    MEMWB_CtrlWb <= EXMEM_CtrlWb;

    assign WB_WrRegData = WB_Link ? WB_PCAddFour :
                       WB_CtrlMemtoReg ? WB_RdData : 
                       WB_AluOut;
