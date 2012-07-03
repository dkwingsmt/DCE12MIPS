
    IFID_Inst <= iRdInst;

    assign ID_RdRegId0 = ID_InstRs;
    assign ID_RdRegId1 = ID_InstRt;

    IDEX_RdRegData0 <= ID_RdRegData0;
    IDEX_RdRegData1 <= ID_RdRegData1;

    assign EX_AluIn0 = EX_CtrlALUShamt ? {{27{1'b0}}, EX_InstShamt} :
                    IDEX_RdRegData0;
    assign EX_AluIn1 = EX_CtrlALUSrc ? IStyleAluSrc1 : 
                    IDEX_RdRegData1;

    EXMEM_CtrlWb <= IDEX_CtrlWb;
    EXMEM_CtrlMem <= IDEX_CtrlMem;

    assign WB_WrRegId = WB_Link ? 5'd31 :
                     CtrlRegDst ? InstRd : 
                     InstRt;

    MEMWB_CtrlWb <= EXMEM_CtrlWb;
