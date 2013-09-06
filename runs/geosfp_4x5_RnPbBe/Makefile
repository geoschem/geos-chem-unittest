#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: Makefile for G-C Unit Test rundir: geosfp_4x5_RnPbBe
#\\
#\\
# !REMARKS:
#  This will be called by the gcUnitTest script.
#
# !REVISION HISTORY: 
#  06 Sep 2013 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# Unix shell
SHELL    :=/bin/bash

# Run directory ID
RUNID    :=$(notdir $(shell pwd))

# Executables
EXE_SP   :=geos.sp
EXE_MP   :=geos.mp

# Log file names
RESULTS  :=$(LOG_DIR)/$(VERSION).results.log
LOG_SP   :=$(LOG_DIR)/$(VERSION).$(RUNID).sp
LOG_MP   :=$(LOG_DIR)/$(VERSION).$(RUNID).mp

# Output file names
TRAC_AVG :=trac_avg.$(RUNID).$(START)
TRAC_RST :=trac_rst.$(RUNID).$(END)

# Validation script
VALIDATE :=/usr/bin/perl $(PERL_DIR)/validate

#=============================================================================
# Makefile targets: type "make help" for a complete list!
#=============================================================================

.PHONY: all geos clean realclean fileclean logclean superclean

all: unittest

unittest:
	@$(MAKE) superclean
	@$(MAKE) sp
	@$(MAKE) realclean
	@$(MAKE) mp
	@$(MAKE) check

sp:
	rm -f $(LOG_SP)
	@$(MAKE) -C $(CODE_DIR) OMP=no > $(LOG_SP)
	cp -f $(CODE_DIR)/bin/geos geos.sp
	$(EXE_SP) >> $(LOG_SP)
	mv $(TRAC_AVG) $(TRAC_AVG).sp
	mv $(TRAC_RST) $(TRAC_RST).sp

mp:
	rm -f $(LOG_MP)
	@$(MAKE) -C $(CODE_DIR) OMP=yes > $(LOG_MP)
	cp -f $(CODE_DIR)/bin/geos geos.mp
	$(EXE_MP) >> $(LOG_MP)
	mv $(TRAC_AVG) $(TRAC_AVG).mp
	mv $(TRAC_RST) $(TRAC_RST).mp

check:
	@$(VALIDATE) $(TRAC_AVG).sp $(TRAC_AVG).mp 1 0 >> $(RESULTS)
	@$(VALIDATE) $(TRAC_RST).sp $(TRAC_RST).mp 0 1 >> $(RESULTS)

clean:
	@$(MAKE) -C $(CODE_DIR) clean

fileclean:
	@$(MAKE) logclean
	rm -f input.geos diaginfo.dat tracerinfo.dat
	rm -f *.sp
	rm -f *.mp

logclean:
	rm -f $(LOG_SP) 
	rm -f $(LOG_MP)

realclean:
	@$(MAKE) -C $(CODE_DIR) realclean

distclean: realclean

superclean: fileclean realclean

print:
	@echo "BOUNDS   : $(BOUNDS)"
	@echo "DEBUG    : $(DEBUG)"
	@echo "FPE      : $(FPE)"
	@echo "COMPILER : $(COMPILER)"
	@echo "MET      : $(MET)"
	@echo "GRID     : $(GRID)"
	@echo "SIM      : $(SIM)"
	@echo "NEST     : $(NEST)"
	@echo "VERSION  : $(VERSION)"
	@echo "LOG_DIR  : $(LOG_DIR)"
	@echo "CODE_DIR : $(CODE_DIR)"
	@echo "LOG_SP   : $(LOG_SP)"
	@echo "LOG_SP   : $(LOG_MP)"
	@echo "START    : $(START)"
	@echo "END      : $(END)"
	@echo "RUNID    : $(RUNID)"
	@echo "BPCH     : $(BPCH)"
	@echo "RST      : $(RST)"
#EOC
