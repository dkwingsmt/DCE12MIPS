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
VERILOG_SRCFILE = testbench.v singcyc.v \
				  $(PERIDIR)rom.v \
				  $(PERIDIR)DataMem.v \
				  $(ALUDIR)*.v
VERILOG_DEPEND = tb1.v
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
