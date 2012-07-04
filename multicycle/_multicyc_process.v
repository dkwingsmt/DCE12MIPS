
    assign oRdInstAddr = PC;
    IFID_PCAddFour <= IF_PCAddFour;
    IFID_Inst <= iRdInst;

    assign ID_RdRegId0 = ID_InstRs;
    assign ID_RdRegId1 = ID_InstRt;
    assign ID_InstRs = IFID_Inst[25:21];
    assign ID_InstRs = IFID_Inst[20:16];

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
    assign EX_InstRt = IDEX_Inst[20:16];
    assign EX_InstRd = IDEX_Inst[15:11];
    assign EX_InstShamt = IDEX_Inst[10:6];
    assign EX_AluFunct = IDEX_Inst[5:0];
    assign EX_InstImmediate = IDEX_Inst[15:0];
    assign EX_InstJumpAddr = IDEX_Inst[25:0];

    assign EX_AluOp = EX_CtrlALUOp;

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
    assign EX_PCJumpTgt = {IDEX_PCAddFour[31:28], EX_InstJumpAddr, 2'b00};
    assign EX_DoBranch = EX_CtrlBranch & ~(EX_CtrlBranchEq ^ EX_AluZero);
    assign EX_PCNext = EX_DoBranch ? EX_PCBranchTgt :
                    EX_CtrlJump ? EX_PCJumpTgt :
                    EX_CtrlJR ? IDEX_RdRegData0 : 
                               EX_PCAddFour;

    EXMEM_AluOut <= EX_AluOut;
    EXMEM_RdRegData1 <= IDEX_RdRegData1;
    EXMEM_CtrlWb <= IDEX_CtrlWb;
    EXMEM_CtrlMem <= IDEX_CtrlMem;
    EXMEM_WrRegId <= EX_WrRegId;
    EXMEM_RegWrite <= EX_RegWrite;
    EXMEM_Link <= EX_Link;
    EXMEM_PCAddFour <= PCAddFour;

    assign MEM_CtrlMemWrite = MEM_CtrlMem[1];
    assign MEM_CtrlMemRead = MEM_CtrlMem[0];
    assign MEM_RdWrMemAddr = EXMEM_AluOut;
    assign MEM_MemWrData = EXMEM_RdRegData1;
    assign oRdWrMemAddr = MEM_RdWrMemAddr;
    assign oWrData = MEM_MemWrData;
    assign oMemWrite = MEM_CtrlMemWrite;
    assign oMemRead = MEM_CtrlMemRead;

    MEMWB_MemReadData <= iRdData;
    MEMWB_CtrlWb <= EXMEM_CtrlWb;
    MEMWB_WrRegId <= EXMEM_WrRegId;
    MEMWB_RegWrite <= EXMEM_RegWrite;
    MEMWB_Link <= EXMEM_Link;
    MEMWB_PCAddFour <= EXMEM_PCAddFour;
    MEMWB_AluOut <= EXMEM_AluOut;

    assign WB_WrRegId = MEMWB_WrRegId;
    assign WB_RegWrite = MEMWB_RegWrite;
    assign WB_Link = MEMWB_Link;
    assign WB_PCAddFour = MEMWB_PCAddFour;
    assign WB_CtrlMemtoReg = MEMWB_CtrlWb;
    assign WB_WrRegData = WB_Link ? WB_PCAddFour :
                       WB_CtrlMemtoReg ? WB_MemRdData : 
                       WB_AluOut;
    assign WB_RdData = MEMWB_MemRdData;
    assign WB_AluOut = MEMWB_AluOut;
