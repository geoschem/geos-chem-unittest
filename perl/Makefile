#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: Makefile for unit testing and GEOS-Chem run directories 
#  copied from UnitTest.
#\\
#\\
# !REMARKS:
#  (1) CODE_DIR (source code location), VERSION (output log prefix), and 
#      LOG_DIR (output log path) are automatically passed to the make 
#      command using the default values defined in this file.
#      Alternatively, they can be defined for single use at the terminal 
#      within the make call (e.g. make -4 VERSION=v10-01i mp).
#
#  (2) MET, GRID, and NEST are read from input.geos using perl script
#      getRunInfo and are automatically passed to the make command.
#
#  (3) There are two processing modes available: sp and mp. sp uses a single
#      processor and mp uses multiple processors. Output files 
#      have .sp or .mp suffix depending on what processing mode is used.
#
#  (4) All output files will be overwritten between runs unless renamed or
#      moved. Unique run log filenames can be generated between runs
#      by specifying different VERSION definitions in the make calls.
#
#  (4) Most recent build settings are output to a file called lastbuildinfo.
#
#  (5) Example make commands:	
#        make -j4 mpbuild                    # build with default settings
#        make -j4 CODE_DIR=~/mycode mpbuild  # manually specify code path
#        make -j4 TRACEBACK=y mpbuild        # build with optional settings
#        make mprun                          # run GEOS-Chem
#        make -j4 mp                         # build and run GEOS-Chem
#        make mplogclean                     # remove .mp log files
#        make mpdataclean                    # remove .mp output data files
#        make mpexeclean                     # remove geos.mp executable
#	 make mpclean                        # do the previous 3 commands
#        make superclean                     # Remove all output files
#                                              make code dir realclean
# 
# !REVISION HISTORY: 
#  02 Apr 2015 - E. Lundgren - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# Unix shell
SHELL    :=/bin/bash

###############################################################################

#   %%%%%%%%%%%%%%%%%%%%%%%%%
#   %  CONFIGURABLE TOKENS  %	
#   %%%%%%%%%%%%%%%%%%%%%%%%%

# Source code location
ifndef CODE_DIR
 CODE_DIR :=/home/elundgren/GC/Code.Dev
endif

# Output log file destination (default is run directory) 
ifndef LOG_DIR 
 LOG_DIR :=.
endif

# GEOS-Chem run log filename prefix
ifndef VERSION
 VERSION :=v10-01i
endif

###############################################################################

# Run directory ID
RUNID    :=$(notdir $(shell pwd))

# Run directory path
RUN_DIR :=$(shell pwd)

# getRunInfo perl script location (default is run directory) 
ifndef PERL_DIR
 PERL_DIR :=$(RUN_DIR)
endif

# Get start & end dates, met source, grid resolution, and nested grid region
MET      :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 0 )
GRID     :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 1 )
SIM      :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 2 )
NEST     :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 3 )
START    :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 4 )
END      :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 5 )
HMCO_END :=$(END)

# Log files and information
TIMESTAMP    := $(shell date +"%Y/%m/%d %H:%M")	
LOG_COMP     :="$(RUN_DIR)/lastbuild"
LOG_SP       :="$(LOG_DIR)/$(VERSION).$(RUNID).Run.sp"
LOG_MP       :="$(LOG_DIR)/$(VERSION).$(RUNID).Run.mp"
LOG_HMCO     :="$(LOG_DIR)/HEMCO.log"

# Executables
EXE_SP   :=geos.sp
EXE_MP   :=geos.mp

# Output data files
TRAC_AVG :=trac_avg.$(RUNID).$(START)
TRAC_RST :=trac_rst.$(RUNID).$(END)
HMCO_RST :=HEMCO_restart.$(HMCO_END).nc

# Unit test validation script and results file
VALIDATE :=/usr/bin/perl ./validate
RESULTS  :=$(LOG_DIR)/$(VERSION).results.log

#=============================================================================
# Makefile targets: type "make help" for a complete list!
#=============================================================================

.PHONY: all dataclean logclean fileclean spclean mpclean
.PHONY: spexeclean mpexeclean superclean printallinfo

#%%%%%%%%%%%%%%%%%%
#  Build and Run  %
#%%%%%%%%%%%%%%%%%%

all: unittest

unittest:
	@$(MAKE) superclean
	@$(MAKE) sp
	@$(MAKE) realclean
	@$(MAKE) mp
	@$(MAKE) check

sp:
	@$(MAKE) spclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET) GRID=$(GRID) NEST=$(NEST) OMP=no > $(LOG_SP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	cp -f $(CODE_DIR)/bin/geos $(EXE_SP)
	$(EXE_SP) > $(LOG_SP)
	@$(MAKE) addsuffixsp
	@$(MAKE) printruninfosp >> $(LOG_SP)
	@$(MAKE) printallinfosp

mp:
	@$(MAKE) mpclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET) GRID=$(GRID) NEST=$(NEST) OMP=yes > $(LOG_MP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).mp
	cp -f $(CODE_DIR)/bin/geos $(EXE_MP)
	$(EXE_MP) > $(LOG_MP)
	@$(MAKE) addsuffixmp
	@$(MAKE) printruninfomp >> $(LOG_MP)
	@$(MAKE) printallinfomp

#%%%%%%%%%%%%%%%
#  Build Only  %
#%%%%%%%%%%%%%%%

spbuild:
	@$(MAKE) spexeclean
	@$(MAKE) splogclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET) GRID=$(GRID) NEST=$(NEST) OMP=no
	cp -f $(CODE_DIR)/bin/geos $(EXE_SP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	@$(MAKE) printbuildinfo

mpbuild:
	@$(MAKE) mpexeclean
	@$(MAKE) mplogclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET) GRID=$(GRID) NEST=$(NEST) OMP=yes
	cp -f $(CODE_DIR)/bin/geos $(EXE_MP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).mp
	@$(MAKE) printbuildinfo

#%%%%%%%%%%%%%
#  Run Only  %
#%%%%%%%%%%%%%

sprun:
	@$(MAKE) spdataclean
	$(EXE_SP) > $(LOG_SP)
	@$(MAKE) addsuffixsp
	@$(MAKE) printruninfosp >> $(LOG_SP)
	@$(MAKE) printruninfosp

mprun:
	@$(MAKE) mpdataclean
	$(EXE_MP) > $(LOG_MP)
	@$(MAKE) addsuffixmp
	@$(MAKE) printruninfomp >> $(LOG_MP)
	@$(MAKE) printruninfomp

#%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Output Data  %
#%%%%%%%%%%%%%%%%%%%%%%%

dataclean: 
	@$(MAKE) spdataclean 
	@$(MAKE) mpdataclean
	rm -f $(TRAC_AVG)
	rm -f $(TRAC_RST)
	rm -f $(HMCO_RST)

spdataclean:
	rm -f $(TRAC_AVG)*.sp
	rm -f $(TRAC_RST)*.sp
	rm -f $(HMCO_RST)*.sp
	rm -f diaginfo.dat tracerinfo.dat

mpdataclean:
	rm -f $(TRAC_AVG)*.mp
	rm -f $(TRAC_RST)*.mp
	rm -f $(HMCO_RST)*.mp
	rm -f diaginfo.dat tracerinfo.dat

#%%%%%%%%%%%%%%%%
#  Remove Logs  %
#%%%%%%%%%%%%%%%%

logclean: 
	@$(MAKE) splogclean 
	@$(MAKE) mplogclean
	rm -f $(LOG_HMCO)

splogclean:
	rm -f $(LOG_SP)
	rm -f $(LOG_HMCO).sp

mplogclean:
	rm -f $(LOG_MP)
	rm -f $(LOG_HMCO).mp

#%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Executables  %
#%%%%%%%%%%%%%%%%%%%%%%%

execlean: 
	@$(MAKE) spexeclean 
	@$(MAKE) mpexeclean
	rm -f geos

spexeclean:
	rm -f $(EXE_SP)
	rm -f $(LOG_COMP).sp

mpexeclean:
	rm -f $(EXE_MP)
	rm -f $(LOG_COMP).mp

#%%%%%%%%%%%%%%%
#  Remove All  %
#%%%%%%%%%%%%%%%

fileclean: dataclean logclean execlean

spclean: spdataclean splogclean spexeclean

mpclean: mpdataclean mplogclean mpexeclean

#%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Config Files  %
#%%%%%%%%%%%%%%%%%%%%%%%%

extrafileclean:
	rm -f input.geos
	rm -f HEMCO_Config.rc

#%%%%%%%%%%%%%%%%%
#  Clean Source  % 
#%%%%%%%%%%%%%%%%%

clean:
	@$(MAKE) -C $(CODE_DIR) clean

realclean:
	@$(MAKE) -C $(CODE_DIR) realclean

#%%%%%%%%%%%%%%%%%%%%%%%%%
#  Clean and Remove All  %
#%%%%%%%%%%%%%%%%%%%%%%%%%

superclean: fileclean realclean

#%%%%%%%%%%
#  Print  %
#%%%%%%%%%%

printruninfosp:
	@echo "RUN SETTINGS:"
	@echo "  Run directory       : $(RUN_DIR)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  MET/GRID/SIM        : $(RUNID)"
	@echo "  Version             : $(VERSION)"
	@echo "  Tracer Output File  : $(TRAC_AVG).sp"
	@echo "  Tracer Restart File : $(TRAC_RST).sp"
	@echo "  HEMCO Restart File  : $(HMCO_RST).sp"
	@echo "  GC Run Log File     : $(LOG_SP)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).sp"

printruninfomp:
	@echo "RUN SETTINGS:"
	@echo "  Run directory       : $(RUN_DIR)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  MET/GRID/SIM        : $(RUNID)"
	@echo "  Version             : $(VERSION)"
	@echo "  Tracer Output File  : $(TRAC_AVG).mp"
	@echo "  Tracer Restart File : $(TRAC_RST).mp"
	@echo "  HEMCO Restart File  : $(HMCO_RST).mp"
	@echo "  GC Run Log File     : $(LOG_SP)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).mp"

printbuildinfo:
	@echo "BUILD INFORMATION:"
	@echo "  CODE_DIR  : $(CODE_DIR)"
	@echo "  VERSION   : $(VERSION)"
	@echo "  MET       : $(MET)"
	@echo "  GRID      : $(GRID)"
	@echo "  SIM       : $(SIM)"
	@echo "  NEST      : $(NEST)"
	@echo "  TRACEBACK : $(TRACEBACK)"
	@echo "  BOUNDS    : $(BOUNDS)"
	@echo "  DEBUG     : $(DEBUG)"
	@echo "  FPE       : $(FPE)"
	@echo "  NO_ISO    : $(NO_ISO)"
	@echo "  UCX       : $(UCX)"
	@echo "  TOMAS40   : $(TOMAS40)"
	@echo "  RRTMG     : $(RRTMG)"
	@echo "  COMPILER  : $(COMPILER)"
	@echo "  Datetime  : $(TIMESTAMP)"

printallinfosp: 
	@$(MAKE) printbuildinfo
	@$(MAKE) printruninfosp

printallinfomp: 
	@$(MAKE) printbuildinfo
	@$(MAKE) printruninfomp

#%%%%%%%%%%%%%%
#  Utilities  %
#%%%%%%%%%%%%%%

addsuffixsp:
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).sp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).sp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).sp; fi;
	if [ -f $(LOG_HMCO) ]; then mv -f $(LOG_HMCO) $(LOG_HMCO).sp; fi;

addsuffixmp:
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).mp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).mp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).mp; fi;
	if [ -f $(LOG_HMCO) ]; then mv -f $(LOG_HMCO) $(LOG_HMCO).mp; fi;

check:
	@$(VALIDATE) $(TRAC_AVG).sp $(TRAC_AVG).mp 1 0 >> $(RESULTS)
	@$(VALIDATE) $(TRAC_RST).sp $(TRAC_RST).mp 0 0 >> $(RESULTS)
	@$(VALIDATE) $(HMCO_RST).sp $(HMCO_RST).mp 0 1 >> $(RESULTS)

#EOC
