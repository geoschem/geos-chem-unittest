#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: Makefile for G-C Unit Test rundir: geos5_4x5_CH4
#\\
#\\
# !REMARKS:
#  This will be called by the gcUnitTest script.
#
# !REVISION HISTORY: 
#  23 Aug 2013 - R. Yantosca - Initial version
#  27 Aug 2013 - R. Yantosca - Now use a perl script to validate output files
#  06 Sep 2013 - R. Yantosca - "fileclean" now removes *.sp and *.mp files
#  30 Jan 2014 - R. Yantosca - Test if output files are present before renaming
#  30 Jun 2014 - R. Yantosca - Add extrafileclean target
#  23 Sep 2014 - R. Yantosca - Updated for HEMCO
#  11 Mar 2015 - R. Yantosca - Add defaults for LOG_DIR and VERSION
#  11 Mar 2015 - R. Yantosca - Now get start and end dates via scripts
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

###############################################################################
# When running in the unit tester, values for these Makefile variables will
# passed to the make command in the unit test job script.  But now that the 
# GEOS-Chem run directories can be generated from unit test run directories,
# we need to add default values for these Makefile variables here.  This will
# allow GEOS-Chem users to set up simulations independently of the unit test
# structure. (bmy, 3/11/15)

# Add default for LOG_DIR
ifndef LOG_DIR 
 LOG_DIR :=.
endif

# Add default for VERSION
ifndef VERSION
 VERSION :=GC
endif
###############################################################################

# Get the start & end dates of the run by parsing the input.geos file
START    :=$(shell ./getStart.pl)
END      :=$(shell ./getEnd.pl  )
HMCO_END :=$(END)

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
VALIDATE :=/usr/bin/perl ./validate

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
	@$(MAKE) -C $(CODE_DIR) OMP=yes > $(LOG_MP)
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
	rm -f diaginfo.dat tracerinfo.dat
	rm -f *.sp
	rm -f *.mp
	rm -f HEMCO.log*
	rm -f HEMCO.restart*

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
