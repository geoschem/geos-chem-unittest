#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: Makefile for use with UnitTest and GEOS-Chem run directories 
#  copied from UnitTest.
#\\
#\\
# !REMARKS:
#  (1) Users may configure CODE_DIR, VERSION, and LOG_DIR to automatically
#      the pass the source code location, output file prefix, and 
#      log directory path to the make command. Default values are
#      defined in this Makefile.
#
#  (2) There are two processing modes available: sp and mp. sp uses a single
#      processor while mp uses multiple processors. All output files
#      have a .sp or .mp suffix depending on what processing mode was run.
#
#  (3) MET, GRID, and NEST are automatically read from input.geos and passed 
#      to the make command. There is only one possible combination of MET, 
#      GRID, and NEST per run directory. Simulation information is in 
#      the input.geos configuration file.
#
#  (3) Users may configure tokens CODE_DIR, VERSION, and LOG_DIR to 
#      automatically pass the source code location, output file prefix, and 
#      log directory path to the make command. Default values are
#      defined in this Makefile.
#
#  (4) All output files generated using the same processing mode will be 
#      overwritten between runs unless renamed or moved.
#
#  (5) Most recent build settings, including compile date, are output to a 
#      file called LastBuildInfo. Compile settings useful for debugging
#      include: BOUNDS=y, TRACEBACK=y, FPE=y, DEBUG=y.
#
#  (6) Example make commands:
#        make -j4 mpbuild                    # build with default settings
#        make -j4 CODE_DIR=~/mycode mpbuild  # manually specify code to build
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

# Run directory ID
RUNID    :=$(notdir $(shell pwd))

# Executables
EXE_SP   :=geos.sp
EXE_MP   :=geos.mp

###############################################################################

#   %%%%%%%%%%%%%%%%%%%%%%%%%
#   %  CONFIGURABLE TOKENS  %	
#   %%%%%%%%%%%%%%%%%%%%%%%%%

# Define source code location
ifndef CODE_DIR
 CODE_DIR :=/home/user/GC/Code.Dev
endif

# Define output log file destination (default is run directory) 
ifndef LOG_DIR 
 LOG_DIR :=.
endif

# Define filename prefix for GEOS-Chem run log
ifndef VERSION
 VERSION :=v10-01i
endif

###############################################################################

# Get the start & end dates, met source, grid resolution, and nested grid
# information for the run by parsing the input.geos configuration file
MET      :=$(shell ./getRunInfo 0 )
GRID     :=$(shell ./getRunInfo 1 )
SIM      :=$(shell ./getRunInfo 2 )
NEST     :=$(shell ./getRunInfo 3 )
START    :=$(shell ./getRunInfo 4 )
END      :=$(shell ./getRunInfo 5 )
HMCO_END :=$(END)

# Define log file names and information
TIMESTAMP    := $(shell date +"%Y/%m/%d %H:%M")	
LOG_COMP     :="$(LOG_DIR)/lastbuild"
LOG_SP       :="$(LOG_DIR)/$(VERSION).$(RUNID).Run.sp"
LOG_MP       :="$(LOG_DIR)/$(VERSION).$(RUNID).Run.mp"
LOG_HMCO     :="$(LOG_DIR)/HEMCO.log"

# Define output data file names
TRAC_AVG :=trac_avg.$(RUNID).$(START)
TRAC_RST :=trac_rst.$(RUNID).$(END)
HMCO_RST :=HEMCO_restart.$(HMCO_END).nc

# Unit test validation script and output file
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
	cp -f $(CODE_DIR)/bin/geos geos.sp
	$(EXE_SP) > $(LOG_SP)
	@$(MAKE) addsuffixsp
	@$(MAKE) printruninfosp >> $(LOG_SP)
	@$(MAKE) printallinfosp

mp:
	@$(MAKE) mpclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET) GRID=$(GRID) NEST=$(NEST) OMP=yes > $(LOG_MP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).mp
	cp -f $(CODE_DIR)/bin/geos geos.mp
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
	cp -f $(CODE_DIR)/bin/geos geos.sp
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	@$(MAKE) printbuildinfo

mpbuild:
	@$(MAKE) mpexeclean
	@$(MAKE) mplogclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET) GRID=$(GRID) NEST=$(NEST) OMP=yes
	cp -f $(CODE_DIR)/bin/geos geos.mp
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

dataclean: spdataclean mpdataclean

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

logclean: splogclean mplogclean

splogclean:
	rm -f $(LOG_SP)
	rm -f $(LOG_HMCO).sp

mplogclean:
	rm -f $(LOG_MP)
	rm -f $(LOG_HMCO).mp

#%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Executables  %
#%%%%%%%%%%%%%%%%%%%%%%%

execlean: spexeclean mpexeclean

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
	@$(MAKE) printruninfosp
	@$(MAKE) printbuildinfo

printallinfomp: 
	@$(MAKE) printruninfomp
	@$(MAKE) printbuildinfo

#%%%%%%%%%%%%%%
#  Utilities  %
#%%%%%%%%%%%%%%

addsuffixsp:
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).sp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).sp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).sp; fi;
	if [ -f $(HMCO_LOG) ]; then mv -f $(HMCO_LOG) $(HMCO_LOG).sp; fi;

addsuffixmp:
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).mp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).mp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).mp; fi;
	if [ -f $(HMCO_LOG) ]; then mv -f $(HMCO_LOG) $(HMCO_LOG).mp; fi;

check:
	@$(VALIDATE) $(TRAC_AVG).sp $(TRAC_AVG).mp 1 0 >> $(RESULTS)
	@$(VALIDATE) $(TRAC_RST).sp $(TRAC_RST).mp 0 0 >> $(RESULTS)
	@$(VALIDATE) $(HMCO_RST).sp $(HMCO_RST).mp 0 1 >> $(RESULTS)

#EOC
