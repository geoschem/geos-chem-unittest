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
#                                                                             .
#  (2) MET and GRID are read from input.geos using perl script
#      getRunInfo and are automatically passed to the make command. 
#      Simulation-dependent optional flags NEST, TOMAS40, and RRTMG
#      are also automatically passed. 
#                                                                             .
#  (3) There are two processing modes available: sp and mp. sp uses a single
#      processor and mp uses multiple processors. Output files 
#      have .sp or .mp suffix depending on what processing mode is used.
#                                                                             .
#  (4) All output files will be overwritten between runs unless renamed or
#      moved. Unique run log filenames can be generated between runs
#      by specifying different VERSION definitions in the make calls.
#                                                                             .
#  (4) Most recent build settings are output to a file called lastbuildinfo.
#                                                                             .
#  (5) Example make commands:	
#        make -j4 mpbuild                    # build with default settings
#        make -j4 CODE_DIR=~/mycode mpbuild  # manually specify code path
#        make -j4 TRACEBACK=y mpbuild        # build with optional settings
#        make mprun                          # run GEOS-Chem
#        make -j4 mp                         # build and run GEOS-Chem
#        make logclean                       # remove log files
#        make dataclean                      # remove output data files
#        make execlean                       # remove executables
#	 make fileclean                      # do the previous 3 commands
#        make superclean                     # Remove all output files and
#                                              make code dir realclean
# 
# !REVISION HISTORY: 
#  Navigate to your unit tester directory and type 'gitk' at the prompt
#  to browse the revision history.
#EOP
#------------------------------------------------------------------------------
#BOC

# Unix shell (we'll assume Bash, which is on every Linux system)
SHELL        :=/bin/bash

###############################################################################
#####                                                                     #####
#####   CONFIGURABLE TOKENS: You can modify these for your environment.   #####
#####                                                                     #####
###############################################################################

# GEOS-Chem run log filename prefix
ifndef VERSION
 VERSION     :=v11-02
endif

# Source code location
ifndef CODE_DIR
 CODE_DIR    :=$(HOME)/GC/Code.$(VERSION)
endif

# Output log file destination (default is run directory) 
ifndef LOG_DIR 
 LOG_DIR     :=.
endif

###############################################################################
#####                                                                     #####
#####  DEFAULT COMPILATION OPTIONS: Set various switches if not defined   #####
#####                                                                     #####
###############################################################################

ifndef NEST
 NEST        :=n
endif

ifndef TRACEBACK 
 TRACEBACK   :=y
endif

ifndef BOUNDS
 BOUNDS      :=n
endif

ifndef DEBUG
 DEBUG       :=n
endif

ifndef FPE
 FPE         :=n
endif

ifndef NO_ISO
 NO_ISO      :=n
endif

ifndef NO_REDUCED
 NO_REDUCED  :=n
endif

ifndef TOMAS12
 TOMAS12     :=n
endif

ifndef TOMAS15
 TOMAS15     :=n
endif

ifndef TOMAS30
 TOMAS30     :=n
endif

ifndef TOMAS40
 TOMAS40     :=n
endif

ifndef RRTMG
 RRTMG       :=n
endif

ifndef MASSCONS 
 MASSCONS    :=n
endif

ifndef TIMERS
 TIMERS      :=0
endif

ifndef TAU_PROF
 TAU_PROF    :=n
endif

ifndef BPCH_DIAG
 BPCH_DIAG   :=y
endif

ifndef NC_DIAG
 NC_DIAG     :=n
endif

# Add a robust check whether or not we are using netCDF diagnostics so that
# we can also binary-check the History file.  We can remove this when the
# netCDF diagnostic option is standard in GEOS-Chem. (bmy, 9/20/17)
REGEXP       :=(^[Yy]|^[Yy][Ee][Ss])
ifeq ($(shell [[ "$(NC_DIAG)" =~ $(REGEXP) ]] && echo true),true)
  IS_NC_DIAG := 1
else
  IS_NC_DIAG := 0
endif

###############################################################################
#####                                                                     #####
#####  RUN OPTIONS: Get various settings from the run directory name,     #####
#####               or from the type of simulation that is being used.    #####
#####                                                                     #####
###############################################################################

# Run directory path
RUN_DIR      :=$(shell pwd)

# getRunInfo perl script location (default is run directory) 
ifndef PERL_DIR
 PERL_DIR    :=$(RUN_DIR)
endif

# Get start & end dates, met source, grid resolution, and nested grid region
# These are obtained by running the "getRunInfo" perl script
MET          :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 0)
GRID         :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 1)
SIM          :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 2)
NEST         :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 3)
START        :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 4)
END          :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 5)
STARTDATE    :=$(shell $(PERL_DIR)/getRunInfo $(RUN_DIR) 7)
HMCO_END     :=$(END)

# By default, TOMAS40 and RRTMG are set to "n".  But if we are doing
# one of thess simulations, reset the corresponding makefile variable to "y".
# Also define the proper setting for CHEM, which picks the correct KPP files.
ifeq ($(SIM),TOMAS12)
 TOMAS12     :=y
 CHEM        :=Tropchem
endif

ifeq ($(SIM),TOMAS15)
 TOMAS15     :=y
 CHEM        :=Tropchem
endif

ifeq ($(SIM),TOMAS30)
 TOMAS30     :=y
 CHEM        :=Tropchem
endif

ifeq ($(SIM),TOMAS40)
 TOMAS40     :=y
 CHEM        :=Tropchem
endif

ifeq ($(SIM),RRTMG)
 RRTMG       :=y
 CHEM        :=Tropchem
endif

ifeq ($(SIM),standard)
 CHEM        :=Standard
 NO_REDUCED  :=y
endif

ifeq ($(SIM),benchmark)
 CHEM        :=Standard
 NO_REDUCED  :=y
 TIMERS      :=1
endif

ifeq ($(SIM),aciduptake)
 CHEM        :=Standard
 NO_REDUCED  :=y
endif

ifeq ($(SIM),marinePOA)
 CHEM        :=Standard
 NO_REDUCED  :=y
endif

ifeq ($(SIM),complexSOA)
 CHEM        :=Tropchem
endif

ifeq ($(SIM),complexSOA_SVPOA)
 CHEM        :=SOA_SVPOA
 NEST        :=n
endif

ifeq ($(SIM),tropchem)
 CHEM        :=Tropchem
endif

ifeq ($(SIM),custom)
 CHEM        :=Custom
 NO_REDUCED  :=y
endif

ifeq ($(SIM),masscons)
 MASSCONS    :=y
endif

ifeq ($(SIM),RnPbBe)
 NO_REDUCED  :=y
endif

# General run information
TIMESTAMP    :=$(shell date +"%Y/%m/%d %H:%M")	
RUNID        :=$(MET)_$(GRID)_$(SIM)
ifneq ($(NEST),n) 
 RUNID       :=$(RUNID)_$(NEST)
endif

# Log files that will be written to the log directory
LOG_COMP     :="$(RUN_DIR)/lastbuild"
LOG_SP       :="$(LOG_DIR)/$(VERSION).$(RUNID).log.sp"
LOG_MP       :="$(LOG_DIR)/$(VERSION).$(RUNID).log.mp"
LOG_HMCO_SA  :="$(LOG_DIR)/$(VERSION).$(RUNID).log"

# Log files that will be written to the run directory
# (For copied run directories, the log & run directories are the same)
LOG_HMCO     :="HEMCO.log"

# Executables
EXE_SP       :=geos.sp
EXE_MP       :=geos.mp
EXE_HMCO_SA  :=hemco_standalone.x

# Output data files
GC_DIAG      :=trac_avg.$(RUNID).$(START)
HMCO_RST     :=HEMCO_restart.$(HMCO_END).nc
GC_RST       :=GEOSChem_restart.$(END).nc
HIST_INS     :=GEOSChem.inst.$(STARTDATE).nc4

# Unit test validation script and results file
VALIDATE     :=/usr/bin/perl $(PERL_DIR)/validate
RESULTS      :=$(LOG_DIR)/$(VERSION).results.log

# Get information about the Git version, because some features
# (like -C) are not available in older Git versions.  The git 
# version command returns "git version X.Y.Z", so we will just take
# the 3rd word and strip all the dots. (bmy, 12/21/16)
GIT_VERSION    :=$(subst .,,$(word 3, $(shell git --version)))
NEWER_THAN_185 :=$(shell perl -e "print ($(GIT_VERSION) gt 185)")

ifeq ($(NEWER_THAN_185),1)

 # Git version 1.8.5 and higher uses the -C option to look in
 # directories other than the current directory.  Use this to
 # get info about the last committed state of the code.
 CODE_BRANCH  :=$(shell git -C $(CODE_DIR) rev-parse --abbrev-ref HEAD)
 LAST_COMMIT  :=$(shell git -C $(CODE_DIR) log -n 1 --pretty=format:"%s") 
 COMMIT_DATE  :=$(shell git -C $(CODE_DIR) log -n 1 --pretty=format:"%cd") 
 COMMIT_USER  :=$(shell git -C $(CODE_DIR) log -n 1 --pretty=format:"%cn") 
 COMMIT_HASH  :=$(shell git -C $(CODE_DIR) log -n 1 --pretty=format:"%h") 
 CODE_STATUS  :=$(shell git -C $(CODE_DIR) status -s) 

else

 # Git versions older than 1.8.5 don't have the -C option,
 # so we have to manually change to the code dir to get information
 # about the last committed state of the code. (bmy, 12/21/16)
 CODE_BRANCH  :=$(shell cd $(CODE_DIR); git rev-parse --abbrev-ref HEAD; cd $(PWD))
 LAST_COMMIT  :=$(shell cd $(CODE_DIR); git log -n 1 --pretty=format:"%s"; cd $(PWD)) 
 COMMIT_DATE  :=$(shell cd $(CODE_DIR); git log -n 1 --pretty=format:"%cd"; cd $(PWD)) 
 COMMIT_USER  :=$(shell cd $(CODE_DIR); git log -n 1 --pretty=format:"%cn"; cd $(PWD)) 
 COMMIT_HASH  :=$(shell cd $(CODE_DIR); git log -n 1 --pretty=format:"%h"; cd $(PWD)) 
 CODE_STATUS  :=$(shell cd $(CODE_DIR); git status -s; cd $(PWD)) 

endif

# Error check, make sure to strip out quote characters from commit string
# or else GNU Make will think that the string is ending prematurely.
# See: https://stackoverflow.com/questions/10424645/how-to-convert-a-quoted-string-to-a-normal-one-in-makefile
LAST_COMMIT := $(subst $\",,$(LAST_COMMIT))
LAST_COMMIT := $(subst $\',,$(LAST_COMMIT))

# Get compiler version
COMPILER_VERSION_LONG :=$(shell $(FC) --version))
COMPILER_VERSION_LONG :=$(sort $(COMPILER_VERSION_LONG))

# For ifort, the 3rd substring of the sorted text is the version number.
# For pgfortran and gfortran, it's the 4th substring.
# NOTE: Future compiler updates may break this algorithm.
REGEXP      :=(^[Ii][Ff][Oo][Rr][Tt])
ifeq ($(shell [[ "$(FC)" =~ $(REGEXP) ]] && echo true),true)
 COMPILER_VERSION :=$(word 3, $(COMPILER_VERSION_LONG))
else
 COMPILER_VERSION :=$(word 4, $(COMPILER_VERSION_LONG))
endif

# Variable to hold the TAU_OPTIONS environment setting
TAU_OPT     :=""

# If we are compiling for use w/ TAU, then also set TAU_OPTIONS accordingly
# TAU_SF sets the -optTauSelectFile option for removing throttled files
REGEXP      :=(^[Yy]|^[Yy][Ee][Ss])
ifeq ($(shell [[ "$(TAU_PROF)" =~ $(REGEXP) ]] && echo true),true)
  ifdef TAU_SF 
    TAU_OPT :="$(TAU_OPTIONS) -optTauSelectFile=$(TAU_SF)"
  else
    TAU_OPT :="$(TAU_OPTIONS)"
  endif
endif

###############################################################################
#####                                                                     #####
#####                          MAKEFILE TARGETS                           #####
#####                                                                     #####
###############################################################################

# PHONY targets don't actually compile anything. They either are
# synonyms for other targets, they remove files, or they print output.
.PHONY: all     dataclean  logclean   fileclean  spclean      tauclean
.PHONY: mpclean spexeclean mpexeclean superclean printallinfo

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Build and Run          %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

all: unittest

ut: unittest

unittest:
	@$(MAKE) realclean
	@$(MAKE) sp
	@$(MAKE) realclean
	@$(MAKE) mp
	@$(MAKE) check

sp:
	@$(MAKE) spclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)             GRID=$(GRID)           \
                                NEST=$(NEST)                                  \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)         \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)     \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)     \
                                MASSCONS=$(MASSCONS)   OMP=no                 \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)   \
                                TAU_OPTIONS=$(TAU_OPT) BPCH_DIAG=$(BPCH_DIAG) \
                                NO_REDUCED=$(NO_REDUCED) NC_DIAG=$(NC_DIAG)   \
                                > $(LOG_SP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	cp -f $(CODE_DIR)/bin/geos $(EXE_SP)
	./$(EXE_SP) >> $(LOG_SP)
	@$(MAKE) addsuffixsp
	@$(MAKE) printruninfosp >> $(LOG_SP)
	@$(MAKE) printallinfosp

mp:
	@$(MAKE) mpclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)             GRID=$(GRID)           \
                                NEST=$(NEST)                                  \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)         \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)     \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)     \
                                MASSCONS=$(MASSCONS)   OMP=yes                \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)   \
                                TAU_OPTIONS=$(TAU_OPT) BPCH_DIAG=$(BPCH_DIAG) \
                                NO_REDUCED=$(NO_REDUCED) NC_DIAG=$(NC_DIAG)   \
                                > $(LOG_MP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).mp
	cp -f $(CODE_DIR)/bin/geos $(EXE_MP)
	./$(EXE_MP) >> $(LOG_MP)
	@$(MAKE) addsuffixmp
	@$(MAKE) printruninfomp >> $(LOG_MP)
	@$(MAKE) printallinfomp

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Build Only             %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

spbuild:
	@$(MAKE) spexeclean
	@$(MAKE) splogclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)             GRID=$(GRID)           \
                                NEST=$(NEST)                                  \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)         \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)     \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)     \
                                MASSCONS=$(MASSCONS)   OMP=no                 \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)   \
                                TAU_OPTIONS=$(TAU_OPT) BPCH_DIAG=$(BPCH_DIAG) \
                                NO_REDUCED=$(NO_REDUCED) NC_DIAG=$(NC_DIAG)
	cp -f $(CODE_DIR)/bin/geos $(EXE_SP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	@$(MAKE) printbuildinfo

mpbuild:
	@$(MAKE) mpexeclean
	@$(MAKE) mplogclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)             GRID=$(GRID)           \
                                NEST=$(NEST)                                  \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)         \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)     \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)     \
                                MASSCONS=$(MASSCONS)   OMP=yes                \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)   \
                                TAU_OPTIONS=$(TAU_OPT) BPCH_DIAG=$(BPCH_DIAG) \
                                NO_REDUCED=$(NO_REDUCED) NC_DIAG=$(NC_DIAG)
	cp -f $(CODE_DIR)/bin/geos $(EXE_MP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).mp
	@$(MAKE) printbuildinfo

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Run Only               %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

sprun:
	@$(MAKE) spdataclean
	./$(EXE_SP) > $(LOG_SP)
	@$(MAKE) addsuffixsp
	@$(MAKE) printruninfosp >> $(LOG_SP)
	@$(MAKE) printruninfosp

mprun:
	@$(MAKE) mpdataclean
	./$(EXE_MP) > $(LOG_MP)
	@$(MAKE) addsuffixmp
	@$(MAKE) printruninfomp >> $(LOG_MP)
	@$(MAKE) printruninfomp

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  HEMCO Standalone       %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

# Synonyms
hemco:      hco
hemcobuild: hcobuild
hemcorun:   hcorun

hco:
	@$(MAKE) hcobuild
	@$(MAKE) hcorun

hcobuild:
	@$(MAKE) hcoexeclean
	@$(MAKE) hcologclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)             GRID=$(GRID)           \
                                NEST=$(NEST)                                  \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)         \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)     \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)     \
                                MASSCONS=$(MASSCONS)   OMP=yes                \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)   \
                                TAU_OPTIONS=$(TAU_OPT) BPCH_DIAG=$(BPCH_DIAG) \
                                NC_DIAG=$(NC_DIAG)     libhemcosa
	cp -f $(CODE_DIR)/bin/hemco_standalone.x $(EXE_HMCO_SA)
	@$(MAKE) printbuildinfo > $(LOG_COMP).hemco
	@$(MAKE) printbuildinfo

hcorun:
	@$(MAKE) hcodataclean
	./$(EXE_HMCO_SA) HEMCO_sa_Config.rc  > $(LOG_HMCO_SA)
	@$(MAKE) printruninfohco >> $(LOG_HMCO_SA)
	@$(MAKE) printruninfohco


#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Output Data     %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

dataclean: 
	rm -f HEMCO_diagnostics*
	if [ -f HEMCO_restart.$(START).nc ]; then mv -f HEMCO_restart.$(START).nc HC.nc; fi;
	rm -f HEMCO_restart.*;
	if [ -f HC.nc ]; then mv -f HC.nc HEMCO_restart.$(START).nc; fi;
	rm -f GEOSChem_restart.*.sp*
	rm -f GEOSChem_restart.*.mp*
	rm -f GEOSCHEM_diagnostics.*
	rm -f trac_avg*
	rm -f Ox.mass.*
	rm -f diaginfo.dat tracerinfo.dat
	rm -f tracer_mass*.dat
	rm -f core.*
	rm -f *.nc4

spdataclean:
	rm -f $(GC_DIAG)*.sp
	rm -f $(GC_RST)*.sp
	rm -f *.nc4.sp
	rm -f HEMCO_restart*.sp
	rm -f diaginfo.dat tracerinfo.dat

mpdataclean:
	rm -f $(GC_DIAG)*.mp
	rm -f $(GC_RST)*.mp
	rm -f *.nc4.mp
	rm -f HEMCO_restart*.mp
	rm -f diaginfo.dat tracerinfo.dat

hcodataclean:
	rm -f HEMCO_restart*
	rm -f diaginfo.dat tracerinfo.dat
	rm -f output/*.nc

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Logs            %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

logclean: 
	@$(MAKE) splogclean 
	@$(MAKE) mplogclean
	@$(MAKE) hcologclean
	rm -f $(LOG_HMCO)
	rm -f *.log

splogclean:
	rm -f $(LOG_SP)
	rm -f $(LOG_HMCO).sp

mplogclean:
	rm -f $(LOG_MP)
	rm -f $(LOG_HMCO).mp

hcologclean:
	rm -f $(LOG_HMCO)
	rm -f $(LOG_HMCO_SA)

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Executables     %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

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

hcoexeclean:
	rm -f $(EXE_HMCO_SA)
	rm -f $(LOG_COMP).hemco_sa

tauclean:
	@$(MAKE) -C $(CODE_DIR) tauclean

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove All             %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

fileclean: dataclean logclean execlean

spclean: spdataclean splogclean spexeclean

mpclean: mpdataclean mplogclean mpexeclean

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Config Files    %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

extrafileclean:
	rm -f input.geos
	rm -f HEMCO_Config.rc

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Clean Source           % 
#%%%%%%%%%%%%%%%%%%%%%%%%%%

clean:
	@$(MAKE) -C $(CODE_DIR) clean

realclean:
	@$(MAKE) -C $(CODE_DIR) realclean
	@$(MAKE) execlean
	rm -f lastbuild.*

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Clean and Remove All   %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

superclean: fileclean realclean tauclean

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Print information      %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

printruninfosp:
	@echo "RUN SETTINGS:"
	@echo "  Run directory       : $(RUN_DIR)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Version             : $(VERSION)"
	@echo "  GC Diagnostic File  : $(GC_DIAG).sp"
	@echo "  GC Restart File     : $(GC_RST).sp"
	@echo "  History file (inst) ; $(HIST_INS).sp"
	@echo "  HEMCO Restart File  : $(HMCO_RST).sp"
	@echo "  GC Run Log File     : $(LOG_SP)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).sp"

printruninfomp:
	@echo "RUN SETTINGS:"
	@echo "  Run directory       : $(RUN_DIR)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Version             : $(VERSION)"
	@echo "  GC Diagnostic File  : $(GC_DIAG).mp"
	@echo "  GC Restart File     : $(GC_RST).mp"
	@echo "  History file (inst) ; $(HIST_INS).mp"
	@echo "  HEMCO Restart File  : $(HMCO_RST).mp"
	@echo "  GC Run Log File     : $(LOG_MP)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).mp"

printruninfohco:
	@echo "RUN SETTINGS:"
	@echo "  Run directory       : $(RUN_DIR)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Version             : $(VERSION)"
	@echo "  HEMCO Restart File  : $(HMCO_RST)"
	@echo "  HEMCO Run Log File  : $(LOG_HMCO_SA)"
	@echo "  HEMCO Log File      : $(LOG_HMCO)"

printbuildinfo:
	@echo "LAST BUILD INFORMATION:"
	@echo "  CODE_DIR     : $(CODE_DIR)"
	@echo "  CODE_BRANCH  : $(CODE_BRANCH)"
	@echo "  LAST_COMMIT  : $(LAST_COMMIT)"
	@echo "  COMMIT_DATE  : $(COMMIT_DATE)"
	@echo "  VERSION      : $(VERSION)"
	@echo "  MET          : $(MET)"
	@echo "  GRID         : $(GRID)"
	@echo "  SIM          : $(SIM)"
	@echo "  NEST         : $(NEST)"
	@echo "  TRACEBACK    : $(TRACEBACK)"
	@echo "  BOUNDS       : $(BOUNDS)"
	@echo "  DEBUG        : $(DEBUG)"
	@echo "  FPE          : $(FPE)"
	@echo "  NO_ISO       : $(NO_ISO)"	
	@echo "  NO_REDUCED   : $(NO_REDUCED)"
	@echo "  CHEM         : $(CHEM)"
	@echo "  TOMAS12      : $(TOMAS12)"	
	@echo "  TOMAS15      : $(TOMAS15)"
	@echo "  TOMAS30      : $(TOMAS30)"
	@echo "  TOMAS40      : $(TOMAS40)"
	@echo "  RRTMG        : $(RRTMG)"
	@echo "  MASSCONS     : $(MASSCONS)"
	@echo "  TIMERS       : $(TIMERS)"
	@echo "  TAU_PROF     : $(TAU_PROF)"
	@echo "  BPCH_DIAG    : $(BPCH_DIAG)"
	@echo "  NC_DIAG      : $(NC_DIAG)"
	@echo "  COMPILER     : $(FC) $(COMPILER_VERSION)"
	@echo "  Datetime     : $(TIMESTAMP)"

printallinfosp: 
	@$(MAKE) printbuildinfo
	@$(MAKE) printruninfosp

printallinfomp: 
	@$(MAKE) printbuildinfo
	@$(MAKE) printruninfomp

printcodeinfo:
	@echo -e "Code directory:  $(CODE_DIR)"
	@echo -e "Git branch:      $(CODE_BRANCH)"
	@echo -e "Last commit:"
	@echo -e "   Message:      $(LAST_COMMIT)"
	@echo -e "   Date:         $(COMMIT_DATE)"
	@echo -e "   Committer:    $(COMMIT_USER)"
	@echo -e "   Hash abbrev:  $(COMMIT_HASH)"
	@echo -e "Uncommitted files (if any):\n$(CODE_STATUS)"

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Utilities              %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

addsuffixsp:
	if [[ -f $(GC_DIAG)  ]]; then mv -f $(GC_DIAG)  $(GC_DIAG).sp;  fi;
	if [[ -f $(GC_RST)   ]]; then mv -f $(GC_RST)   $(GC_RST).sp;   fi;
	if [[ -f $(HIST_INS) ]]; then mv -f $(HIST_INS) $(HIST_INS).sp; fi;
	if [[ -f $(HMCO_RST) ]]; then mv -f $(HMCO_RST) $(HMCO_RST).sp; fi;
	if [[ -f $(LOG_HMCO) ]]; then mv -f $(LOG_HMCO) $(LOG_HMCO).sp; fi;

addsuffixmp:
	if [[ -f $(GC_DIAG)  ]]; then mv -f $(GC_DIAG)  $(GC_DIAG).mp; fi;
	if [[ -f $(GC_RST)   ]]; then mv -f $(GC_RST)   $(GC_RST).mp;   fi;
	if [[ -f $(HIST_INS) ]]; then mv -f $(HIST_INS) $(HIST_INS).mp; fi;
	if [[ -f $(HMCO_RST) ]]; then mv -f $(HMCO_RST) $(HMCO_RST).mp; fi;
	if [[ -f $(LOG_HMCO) ]]; then mv -f $(LOG_HMCO) $(LOG_HMCO).mp; fi;

check:
ifeq ($(IS_NC_DIAG),1)
	@$(VALIDATE) $(GC_DIAG).sp  $(GC_DIAG).mp  2 0 >> $(RESULTS)
	@$(VALIDATE) $(GC_RST).sp   $(GC_RST).mp   0 0 >> $(RESULTS)
	@$(VALIDATE) $(HIST_INS).sp $(HIST_INS).mp 0 0 >> $(RESULTS)
	@$(VALIDATE) $(HMCO_RST).sp $(HMCO_RST).mp 0 1 >> $(RESULTS)
else
	@$(VALIDATE) $(GC_DIAG).sp  $(GC_DIAG).mp  1 0 >> $(RESULTS)
	@$(VALIDATE) $(GC_RST).sp   $(GC_RST).mp   0 0 >> $(RESULTS)
	@$(VALIDATE) $(HMCO_RST).sp $(HMCO_RST).mp 0 1 >> $(RESULTS)
endif

###############################################################################
#####                                                                     #####
#####                             HELP SCREEN                             #####
#####                                                                     #####
################################################################################

help:
	@echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
	@echo '%%%    GEOS-Chem Run Directory Makefile Help Screen    %%%'
	@echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
	@echo
	@echo 'Usage: make -jN TARGET [OPTIONAL-FLAGS]'
	@echo ''
	@echo '-jN               Compiles N files at a time (reduces compile time)'
	@echo ''
	@echo '----------------------------------------------------------'
	@echo 'TARGET may be one of the following:'
	@echo '----------------------------------------------------------'
	@echo 'all               Default target (synonym for "unittest")'
	@echo ''
	@echo '%%% COMPILE AND RUN %%%'
	@echo 'unittest          Runs a GEOS-Chem unit test:'
	@echo '                  (1) Builds & runs GEOS-Chem with parallelization OFF;'
	@echo '                  (2) Builds & runs GEOS-Chem with parallelzation ON;'
	@echo '                  (3) Checks to see if the output is identical.'
	@echo 'sp                Builds and runs GEOS-Chem with parallelization OFF.'
	@echo 'mp                Builds and runs GEOS-Chem with parallelization ON.'
	@echo ''
	@echo '%%% BUILD ONLY %%%'
	@echo 'spbuild           Just builds GEOS-Chem with parallelization OFF.'
	@echo 'mpbuild           Just builds GEOS-Chem with parallelization ON.'
	@echo ''
	@echo '%%% RUN ONLY %%%'
	@echo 'sprun             Just runs GEOS-Chem with parallelization OFF.'
	@echo 'mprun             Just runs GEOS_Chem with parallelization ON.'  
	@echo ''
	@echo '%%% REMOVE DATA FILES %%%'
	@echo 'dataclean         Removes ALL GEOS-Chem diagnostic and restart files'
	@echo 'spdataclean       Removes diagnostic and restart files from GEOS-Chem'
	@echo '                    simulations with parallelization turned OFF.'
	@echo 'mpdataclean       Removes diagnostic and restart files from GEOS-Chem'
	@echo '                    simulations with parallelization turned ON.'
	@echo ''
	@echo '%%% REMOVE LOG FILES %%%'
	@echo 'logclean          Removes all GEOS-Chem and HEMCO output log files.'
	@echo 'splogclean        Removes GEOS-Chem and HEMCO log files from GEOS-Chem'
	@echo '                    simulations with parallelization turned OFF.'
	@echo 'mplogclean        Removes GEOS-Chem and HEMCO log files from GEOS-Chems'
	@echo '                    simulations with parallelization turned ON.'
	@echo ''
	@echo '%%% REMOVE EXECUTABLE FILES %%%'
	@echo 'execlean          Removes all GEOS-Chem executable files'
	@echo 'spexeclean        Removes GEOS-Chem executable files for which the'
	@echo '                    parallelization has been turned OFF.'
	@echo 'mpexeclean        Removes GEOS-Chem executable files for which the'
	@echo '                    parallelization has been turned ON.'
	@echo ''
	@echo '%%% REMOVE ALL FILES %%%'
	@echo 'fileclean         Synonym for: dataclean   logclean   execlean'
	@echo 'spclean           Synonym for: spdataclean splogclean spexeclean'
	@echo 'mpclean           Synonym for: mpdataclean mplogclean mpexeclean'
	@echo ''
	@echo '%%% REMOVE CONFIG FILES %%%'
	@echo 'extrafileclean  Removes input.geos and HEMCO_Config.rc files'
	@echo ''
	@echo '%%% CLEAN SOURCE CODE %%%'
	@echo 'clean             Makes "clean" in source code directory $CODE_DIR'
	@echo 'realclean         Makes "realclean" in the source code directory $CODE_DIR'
	@echo 'tauclean          Removes all TAU files in the source code directory $CODE_DIR'
	@echo ''
	@echo '%%% CLEAN AND REMOVE ALL %%%'
	@echo 'superclean        Synonym for: fileclean realclean'
	@echo ''
	@echo '%%% PRINT INFORMATION %%%'
	@echo 'printruninfosp    Prints the run settings for GEOS-Chem simulations'
	@echo '                    for which the parallelization is turned OFF.'
	@echo 'printruninfomp    Prints the run settings for GEOS-Chem simulations'
	@echo '                    for which the parallelization is turned ON'
	@echo 'printbuildinfo    Prints the build settings for GEOS-Chem simulations'
	@echo 'printallinfosp    Synonym for: printbuildinfosp printruninfosp'
	@echo 'printallinfomp    Synonym for: printbuildinfomp printruninfomp'
	@echo 'printcodeinfo     Print code directory git information'
	@echo ''
	@echo '%%% UTILITIES %%%'
	@echo 'addsuffixsp       Adds ".sp" to files generated by GEOS-Chem simulations'
	@echo '                    for which the parallelization is turned OFF.'
	@echo 'addsuffixmp       Adds ".mp" to files generated by GEOS-Chem simulations'
	@echo '                    for which the parallelization is turned ON.'
	@echo 'check             Executes the "validate" script to test if the files'
	@echo '                    ending in ".sp" contain identical results to the'
	@echo '                    files ending in ".mp".'
	@echo 'help              Prints this help screen'
	@echo ''
	@echo '----------------------------------------------------------'
	@echo 'OPTIONAL-FLAGS may be one of the following:'
	@echo '----------------------------------------------------------'
	@echo 'DEBUG=y           Compiles GEOS-Chem with various debugging options'
	@echo 'BOUNDS=y          Compiles GEOS-Chem with out-of-bounds error checks'
	@echo 'FPE=y             Compiles GEOS-Chem with floating-point math error checks'
	@echo 'TRACEBACK=y       Compiles GEOS-Chem with traceback error printout (this is the default)'
	@echo 'NO_ISO=y          Compiles GEOS-Chem and turns off ISORROPIA'
	@echo 'TIMERS=1          Compiles GEOS-Chem with timers turned on'
	@echo 'NC_DIAG=y       Compiles GEOS-Chem such that diagnostics are output in NetCDF format (default is binary-punch)'
#EOC
