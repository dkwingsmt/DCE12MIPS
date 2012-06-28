.PHONY : all clean

######################################################################
# Tool settings
IVERILOG_EXE = iverilog
VVP_EXE = vvp
GTKWAVE_EXE = gtkwave
VVP_PREFLAGS = -n
VVP_POSTFLAGS = -lxt2
WAVEFILE_POSTFIX = .lxt

######################################################################
# Project settings
PERIDIR = ../peripheral/
ALUDIR = ../alu/
VERILOG_SRCFILE = testbench.v singcyc.v singcyc_core.v \
				  $(PERIDIR)rom.v \
				  $(PERIDIR)regfile.v \
				  $(PERIDIR)DataMem.v \
				  $(ALUDIR)ALU.v \
				  $(ALUDIR)ADD.v \
				  $(ALUDIR)AND.v \
				  $(ALUDIR)GEZ.v \
				  $(ALUDIR)LEZ.v \
				  $(ALUDIR)NOR.v \
				  $(ALUDIR)SRA.v \
				  $(ALUDIR)STA.v \
				  $(ALUDIR)XOR.v \
				  $(ALUDIR)EQ.v \
				  $(ALUDIR)GTZ.v \
				  $(ALUDIR)LT.v \
				  $(ALUDIR)LUI.v \
				  $(ALUDIR)NEQ.v \
				  $(ALUDIR)OR.v \
				  $(ALUDIR)SLL.v \
				  $(ALUDIR)SRL.v \
				  $(ALUDIR)SUB.v
VERILOG_DEPEND = tb1.v \
				 $(PERIDIR)DataMemInit.v \
				 $(PERIDIR)InstRom.v
COMPILE_DST = v.out
SIMULATE_OUTPUT = v.lxt
SIMULATE_POSTFIX = .lxt
MV_CMD = cp

######################################################################
# Temp vars

WAVE_DST = $(SIMULATE_OUTPUT:%$(SIMULATE_POSTFIX)=%$(WAVEFILE_POSTFIX))

######################################################################
# Tasks

all : compile simulate view_wave

.PHONY : compile simulate view_wave 

compile : $(COMPILE_DST) 
	
simulate : $(SIMULATE_OUTPUT)

view_wave : $(SIMULATE_OUTPUT) 
ifeq ($(SIMULATE_POSTFIX), $(WAVEFILE_POSTFIX))
else
	$(MV_CMD) $< $@ 
endif
	$(GTKWAVE_EXE) $(WAVE_DST)

$(COMPILE_DST) : $(VERILOG_SRCFILE) $(VERILOG_DEPEND)
	$(IVERILOG_EXE) -o $(COMPILE_DST) $(VERILOG_SRCFILE)

$(SIMULATE_OUTPUT) : $(COMPILE_DST)
	$(VVP_EXE) $(VVP_PREFLAGS) $(COMPILE_DST) $(VVP_POSTFLAGS)


clean : 
	-rm $(COMPILE_DST) 
	-rm $(SIMULATE_OUTPUT)
	-rm $(WAVE_DST)
