#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: Makefile for G-C Unit Test rundir: merra_4x5_tagCO
#\\
#\\
# !REMARKS:
#  This will be called by the gcUnitTest script.
#
# !REVISION HISTORY: 
#  10 Apr 2014 - R. Yantosca - Initial version
#  30 Jun 2014 - R. Yantosca - Add extrafileclean target
#  04 Sep 2014 - R. Yantosca - Updated for HEMCO
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
LOG_HMCO :=HEMCO.log

# Output file names
TRAC_AVG :=trac_avg.$(RUNID).$(START)
TRAC_RST :=trac_rst.$(RUNID).$(END)
HMCO_RST :=HEMCO_restart.$(HMCO_END).nc

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
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).sp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).sp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).sp; fi;
	if [ -f $(LOG_HMCO) ]; then mv -f $(LOG_HMCO) $(LOG_HMCO).sp; fi;

mp:
	rm -f $(LOG_MP)
	@$(MAKE) -C $(CODE_DIR) OMP=yes >> $(LOG_MP)
	cp -f $(CODE_DIR)/bin/geos geos.mp
	$(EXE_MP) >> $(LOG_MP)
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).mp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).mp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).mp; fi;
	if [ -f $(LOG_HMCO) ]; then mv -f $(LOG_HMCO) $(LOG_HMCO).mp; fi;

check:
	@$(VALIDATE) $(TRAC_AVG).sp $(TRAC_AVG).mp 1 0 >> $(RESULTS)
	@$(VALIDATE) $(TRAC_RST).sp $(TRAC_RST).mp 0 0 >> $(RESULTS)
	@$(VALIDATE) $(HMCO_RST).sp $(HMCO_RST).mp 0 1 >> $(RESULTS)

clean:
	@$(MAKE) -C $(CODE_DIR) clean

fileclean:
	@$(MAKE) logclean
	rm -f diaginfo.dat tracerinfo.dat smv2.log
	rm -f *.sp
	rm -f *.mp
	rm -f HEMCO.log*
	rm -f HEMCO*restart*

extrafileclean:
	rm -f input.geos
	rm -f HEMCO_Config.rc

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
	@echo "LOG_HMCO : $(LOG_HMCO)"
	@echo "START    : $(START)"
	@echo "END      : $(END)"
	@echo "RUNID    : $(RUNID)"
	@echo "TRAC_AVG : $(TRAC_AVG)"
	@echo "TRAC_RST : $(TRAC_RST)"
	@echo "HMCO_RST : $(HMCO_RST)"
	@echo "HMCO_END : $(HMCO_END)"
#EOC
