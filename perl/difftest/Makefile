#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile (in the top-level directory).
#
# !DESCRIPTION: This makefile drives the entire difference test process.
#\\
#\\
# !REMARKS:
#  (1) CODE_REF (reference source code location), CODE_DEV (development source
#      code location), and LOG_DIR (output log path) are automatically passed
#      to the make command using the default values defined in this file.
#      Alternatively, they can be defined for single use at the terminal 
#      within the make call.
#                                                                             .
#  (2) MET and GRID are read from input.geos using perl script
#      getRunInfo and are automatically passed to the make command. 
#      Simulation-dependent optional flags NEST, TOMAS40, UCX, and RRTMG
#      are also automatically passed. 
#                                                                             .
#  (3) There are two processing modes available: REF and DEV. REF uses CODE_REF
#      and DEV uses CODE_DEV. Output files have .Ref or .Dev suffix depending
#      on what processing mode is used.
#                                                                             .
#  (4) All output files will be overwritten between runs unless renamed or
#      moved.
#                                                                             .
#  (4) Most recent build settings are output to a file called lastbuildinfo.
#                                                                             .
#  (5) Example make commands:	
#        make -j4 difftest                   # Runs a complete REF vs DEV test
#        make -j4 devonly                    # Compiles and runs DEV
#        make -j4 TRACEBACK=y devonly        # build with optional settings
#	 make fileclean                      # remove REF and DEV output files
#        make logclean                       # remove log files
#        make superclean                     # Remove all output files and
#                                              make code dirs realclean
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

# Reference code directory
ifndef CODE_REF
 CODE_REF    :=CODE_REF_PATH
endif

# Development code directory
ifndef CODE_DEV
 CODE_DEV    :=CODE_DEV_PATH
endif

# Output log file destination
ifndef LOG_DIR 
 LOG_DIR     :=$(CURDIR)/logs
endif

###############################################################################
#####                                                                     #####
#####  DEFAULT COMPILATION OPTIONS: Set various switches if not defined   #####
#####                                                                     #####
###############################################################################

ifndef NEST
 NEST        :=n
else
 # NOTE: If Nest is passed, then also set BPCH_DIAG=y.  We have to activate
 # the bpch I/O code to read the nested boundary conditions.  We can remove
 # this ELSE block once the bpch diagnostics have been from GC. (bmy, 1/22/18)
 BPCH_DIAG   :=y
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

ifndef OMP
 OMP         :=y
endif

# Turn off ISORROPIA for all diff testing
ifndef NO_ISO
 NO_ISO      :=y
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

ifndef UCX
 UCX         :=n
endif

ifndef RRTMG
 RRTMG       :=n
endif

ifndef CHEM
 CHEM        :=Standard
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

# Default: BPCH_DIAG is always turned ON (unless user says otherwise)
ifndef BPCH_DIAG
 BPCH_DIAG   :=y
endif

# Default: NC_DIAG is always turned OFF (unless user says otherwise)
ifndef NC_DIAG
 NC_DIAG     :=n
endif

# Add a robust check whether or not we are using netCDF diagnostics so that
# we can also binary-check the History file.  We can remove this when the
# netCDF diagnostic option is standard in GEOS-Chem. (bmy, 9/20/17)
REGEXP       :=(^[Yy]|^[Yy][Ee][Ss])
ifeq ($(shell [[ "$(NC_DIAG)" =~ $(REGEXP) ]] && echo true),true)
  IS_NC_DIAG := 2
else
  IS_NC_DIAG := 0
endif

# Add a robust check whether or not we are using bpch diagnostics so that
# we can also binary-check the History file.  We can remove this when the
# netCDF diagnostic option is standard in GEOS-Chem. (bmy, 1/16/18)
REGEXP       :=(^[Yy]|^[Yy][Ee][Ss])
ifeq ($(shell [[ "$(BPCH_DIAG)" =~ $(REGEXP) ]] && echo true),true)
  IS_BPCH_DIAG := 4
else
  IS_BPCH_DIAG := 0
endif

# Sum of IS_BPCH_DIAG and IS_NC_DIAG
# NOTE: GNU Make does not allow for numeric equality test so we have
# to do this kind of ugly kludge.  See this poste on Stack Overflow:
#stackoverflow.com/questions/3728372/version-number-comparison-inside-makefile
DIAGSUM := $$((1 + $(IS_BPCH_DIAG) + $(IS_NC_DIAG) ))
DIAGSUM_IS_7 := $(shell echo $(DIAGSUM)\==7 | bc)
DIAGSUM_IS_5 := $(shell echo $(DIAGSUM)\==5 | bc)
DIAGSUM_IS_3 := $(shell echo $(DIAGSUM)\==3 | bc)

###############################################################################
#####                                                                     #####
#####  RUN OPTIONS: Get various settings from the run directory name,     #####
#####               or from the type of simulation that is being used.    #####
#####                                                                     #####
###############################################################################

# Run directories
RUN_REF      :=$(CURDIR)/Ref
RUN_DEV      :=$(CURDIR)/Dev

# Get start & end dates, met source, grid resolution, and nested grid region
# These are obtained by running the "getRunInfo" perl script
MET          :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 0)
GRID         :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 1)
SIM          :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 2)
NEST         :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 3)
START        :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 4)
END          :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 5)
ROOT_DIR     :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 6)
STARTDATE    :=$(shell $(RUN_DEV)/getRunInfo $(RUN_DEV) 7)
HMCO_END     :=$(END)

# By default, UCX, TOMAS40 and RRTMG are all set to "n".  But if we are doing
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

ifeq ($(SIM),UCX)
 UCX         :=y
 CHEM        :=UCX
 NO_REDUCED  :=y
endif

ifeq ($(SIM),standard)
 UCX         :=y
 CHEM        :=Standard
 NO_REDUCED  :=y
endif

ifeq ($(SIM),benchmark)
 UCX         :=y
 CHEM        :=Standard
 NO_REDUCED  :=y
 TIMERS      :=1
endif

ifeq ($(SIM),aciduptake)
 UCX         :=y
 CHEM        :=Standard
 NO_REDUCED  :=y
endif

ifeq ($(SIM),marinePOA)
 UCX         :=y
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
endif

ifeq ($(SIM),masscons)
 MASSCONS    :=y
endif

# General run information
TIMESTAMP    :=$(shell date +"%Y/%m/%d %H:%M")	
RUNID        :=$(MET)_$(GRID)_$(SIM)
ifneq ($(NEST),n) 
 RUNID       :=$(RUNID)_$(NEST)
endif

# Log files that will be written to the log directory
LOG_COMP     :="lastbuild"
LOG_REF      :="$(LOG_DIR)/log.$(RUNID).Ref"
LOG_DEV      :="$(LOG_DIR)/log.$(RUNID).Dev"

# Log files that will be written to the run directory
# (For copied run directories, the log & run directories are the same)
LOG_HMCO     :="HEMCO.log"

# Executables
EXEC_REF     :=geos.Ref
EXEC_DEV     :=geos.Dev

# Output data files
TRAC_AVG     :=trac_avg.$(RUNID).$(START)
HMCO_AVG     :=HEMCO_diagnostics.$(END).nc
HMCO_RST     :=HEMCO_restart.$(HMCO_END).nc
TRAC_RST     :=GEOSChem_restart.$(END).nc
HIST_INS     :=GEOSChem.inst.$(STARTDATE).nc4

# Diff test validation script and results file
VALIDATE     :=/usr/bin/perl $(RUN_DEV)/validate
RESULTS      :=$(LOG_DIR)/log.$(RUNID).Results

# Get information about the Git version, because some features
# (like -C) are not available in older Git versions.  The git 
# version command returns "git version X.Y.Z", so we will just take
# the 3rd word and strip all the dots. (bmy, 12/21/16)
GIT_VERSION    :=$(subst .,,$(word 3, $(shell git --version)))
NEWER_THAN_185 :=$(shell perl -e "print ($(GIT_VERSION) gt 185)")

ifeq ($(NEWER_THAN_185),1)

 # Git version 1.8.5 and higher uses the -C option to look in directories 
 # other than the current directory.  Use this to get info about the last 
 # committed states of the Dev and Ref codes. (bmy, 12/22/16)
 CODE_BRANCH_REF :=$(shell git -C $(CODE_REF) rev-parse --abbrev-ref HEAD)
 LAST_COMMIT_REF :=$(shell git -C $(CODE_REF) log -n 1 --pretty=format:"%s")
 COMMIT_DATE_REF :=$(shell git -C $(CODE_REF) log -n 1 --pretty=format:"%cd")
 CODE_BRANCH_DEV :=$(shell git -C $(CODE_DEV) rev-parse --abbrev-ref HEAD)
 LAST_COMMIT_DEV :=$(shell git -C $(CODE_DEV) log -n 1 --pretty=format:"%s")
 COMMIT_DATE_DEV :=$(shell git -C $(CODE_DEV) log -n 1 --pretty=format:"%cd")

else

 # Git versions older than 1.8.5 don't have the -C option, so we have to 
 # manually change to the Dev or Ref code dir to get information 
 # about the last committed state of the Dev and Ref codes. (bmy, 12/22/16)
 CODE_BRANCH_REF :=$(shell cd $(CODE_REF); git rev-parse --abbrev-ref HEAD; cd $(PWD))
 LAST_COMMIT_REF :=$(shell cd $(CODE_REF); git log -n 1 --pretty=format:"%s"; cd $(PWD))
 COMMIT_DATE_REF :=$(shell cd $(CODE_REF); git log -n 1 --pretty=format:"%cd"; cd $(PWD))
 CODE_BRANCH_DEV :=$(shell cd $(CODE_DEV); git rev-parse --abbrev-ref HEAD; cd $(PWD))
 LAST_COMMIT_DEV :=$(shell cd $(CODE_DEV); git log -n 1 --pretty=format:"%s"; cd $(PWD))
 COMMIT_DATE_DEV :=$(shell cd $(CODE_DEV); git log -n 1 --pretty=format:"%cd"; cd $(PWD))

endif

# Error check, make sure to strip out quote characters from each commit string
# or else GNU Make will think that the string is ending prematurely.
# See: https://stackoverflow.com/questions/10424645/how-to-convert-a-quoted-string-to-a-normal-one-in-makefile
LAST_COMMIT_REF := $(subst $\",,$(LAST_COMMIT_REF))
LAST_COMMIT_REF := $(subst $\',,$(LAST_COMMIT_REF))
LAST_COMMIT_DEV := $(subst $\",,$(LAST_COMMIT_DEV))
LAST_COMMIT_DEV := $(subst $\',,$(LAST_COMMIT_DEV))

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
.PHONY: all             dt              difftest
.PHONY: devcheck        check           quickdt
.PHONY: realclean       refclean        devclean  
.PHONY: tauclean        reftauclean     devtauclean
.PHONY: fileclean       superclean      logclean
.PHONY: tvsp_ref        tvmp_ref
.PHONY: tvsp_dev        tvmp_dev
.PHONY: printbuildinfo
.PHONY: printruninforef printruninfodev
.PHONY: printallinforef printallinfodev

all: difftest

dt: difftest

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Build and Run          %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

difftest:
	@$(MAKE) superclean
	@$(MAKE) logclean
	@$(MAKE) refonly
	@$(MAKE) devonly
	@$(MAKE) check

quickdt:
	@$(MAKE) refonly
	@$(MAKE) devonly
	@$(MAKE) check

refonly:
	@$(MAKE) -C $(RUN_REF)  ref                                          \
                                MET=$(MET)             GRID=$(GRID)          \
                                NEST=$(NEST)           UCX=$(UCX)            \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)        \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)    \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)    \
                                MASSCONS=$(MASSCONS)   OMP=$(OMP)            \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_REF)      \
                                EXEC=$(EXEC_REF)       TRAC_AVG=$(TRAC_AVG)  \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG)  \
                                HMCO_RST=$(HMCO_RST)   HIST_INS=$(HIST_INS)  \
                                HMCO_LOG=$(LOG_HMCO)   LOG=$(LOG_REF)        \
                                START=$(START)         END=$(END)            \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)  \
                                TAU_OPTIONS=$(TAU_OPT) NC_DIAG=$(NC_DIAG)    \
                                BPCH_DIAG=$(BPCH_DIAG)
	@$(MAKE) printbuildinfo > $(RUN_REF)/$(LOG_COMP).Ref
	@$(MAKE) printruninforef >> $(LOG_REF)
	@$(MAKE) printallinforef

devonly:
	@$(MAKE) -C $(RUN_DEV)  dev                                          \
                                MET=$(MET)             GRID=$(GRID)          \
                                NEST=$(NEST)           UCX=$(UCX)            \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)        \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)    \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)    \
                                MASSCONS=$(MASSCONS)   OMP=$(OMP)            \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_DEV)      \
                                EXEC=$(EXEC_DEV)       TRAC_AVG=$(TRAC_AVG)  \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG)  \
                                HMCO_RST=$(HMCO_RST)   HIST_INS=$(HIST_INS)  \
                                HMCO_LOG=$(LOG_HMCO)   LOG=$(LOG_DEV)        \
                                START=$(START)         END=$(END)            \
                                TIMERS=$(TIMERS)       TAU_PROF=$(TAU_PROF)  \
                                TAU_OPTIONS=$(TAU_OPT) NC_DIAG=$(NC_DIAG)    \
                                BPCH_DIAG=$(BPCH_DIAG)
	@$(MAKE) printbuildinfo > $(RUN_DEV)/$(LOG_COMP).Dev
	@$(MAKE) printruninfodev >> $(LOG_DEV)
	@$(MAKE) printallinfodev

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Build Only             %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

devlib:
	@$(MAKE) -C $(RUN_DEV)  lib                                          \
                                MET=$(MET)             GRID=$(GRID)          \
                                NEST=$(NEST)           UCX=$(UCX)            \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)        \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)    \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)    \
                                MASSCONS=$(MASSCONS)   OMP=yes               \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_DEV)      \
                                EXEC=$(EXEC_DEV)       TRAC_AVG=$(TRAC_AVG)  \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG)  \
                                HMCO_RST=$(HMCO_RST)   SPEC_RST=$(SPEC_RST)  \
                                HIST_INS=$(HIST_INS)   HMCO_LOG=$(LOG_HMCO)  \
                                LOG=$(LOG_DEV)         START=$(START)        \
                                END=$(END)             TIMERS=$(TIMERS)      \
                                TAU_OPTIONS=$(TAU_OPT) NC_DIAG=$(NC_DIAG)    \
                                BPCH_DIAG=$(BPCH_DIAG)
	@$(MAKE) printbuildinfo > $(RUN_DEV)/$(LOG_COMP).Dev
	@$(MAKE) printruninfodev >> $(LOG_DEV)
	@$(MAKE) printallinfodev

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Run Only               %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

devrun:
	@$(MAKE) -C $(RUN_DEV)  run                                          \
                                MET=$(MET)             GRID=$(GRID)          \
                                NEST=$(NEST)           UCX=$(UCX)            \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)        \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)    \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)    \
                                MASSCONS=$(MASSCONS)   OMP=yes               \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_DEV)      \
                                EXEC=$(EXEC_DEV)       TRAC_AVG=$(TRAC_AVG)  \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG)  \
                                HMCO_RST=$(HMCO_RST)   SPEC_RST=$(SPEC_RST)  \
                                HIST_INS=$(HIST_INS)   HMCO_LOG=$(LOG_HMCO)  \
                                LOG_DEV=$(LOG_DEV)     START=$(START)        \
                                END=$(END)             TIMERS=$(TIMERS)      \
                                TAU_OPTIONS=$(TAU_OPT) NC_DIAG=$(NC_DIAG)    \
                                BPCH_DIAG=$(BPCH_DIAG)                       \
	@$(MAKE) printbuildinfo > $(RUN_DEV)/$(LOG_COMP).Dev
	@$(MAKE) printruninfodev >> $(LOG_DEV)
	@$(MAKE) printallinfodev

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Check Output           %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

devcheck:
	@$(MAKE) devonly
	@$(MAKE) check

check:
ifeq ($(DIAGSUM_IS_7),1)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_AVG).Ref                             \
                     $(RUN_DEV)/$(TRAC_AVG).Dev 7 0 $(RUNID) >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref                             \
                     $(RUN_DEV)/$(TRAC_RST).Dev 0 0          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(HIST_INS).Ref                             \
                     $(RUN_DEV)/$(HIST_INS).Dev 0 0          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref                             \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_AVG).Ref                             \
                     $(RUN_DEV)/$(TRAC_AVG).Dev 7 0 $(RUNID)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref                             \
                     $(RUN_DEV)/$(TRAC_RST).Dev 0 0
	@$(VALIDATE) $(RUN_REF)/$(HIST_INS).Ref                             \
                     $(RUN_DEV)/$(HIST_INS).Dev 0 0
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref                             \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1
else
ifeq ($(DIAGSUM_IS_5),1)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_AVG).Ref                             \
                     $(RUN_DEV)/$(TRAC_AVG).Dev 5 0 $(RUNID) >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref                             \
                     $(RUN_DEV)/$(TRAC_RST).Dev 0 0          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref                             \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_AVG).Ref                             \
                     $(RUN_DEV)/$(TRAC_AVG).Dev 5 0 $(RUNID)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref                             \
                     $(RUN_DEV)/$(TRAC_RST).Dev 0 0
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref                             \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1
else
ifeq ($(DIAGSUM_IS_3),1)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref                             \
                     $(RUN_DEV)/$(TRAC_RST).Dev 3 0 $(RUNID) >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(HIST_INS).Ref                             \
                     $(RUN_DEV)/$(HIST_INS).Dev 0 0          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref                             \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1          >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref                             \
                     $(RUN_DEV)/$(TRAC_RST).Dev 3 0 $(RUNID)
	@$(VALIDATE) $(RUN_REF)/$(HIST_INS).Ref                             \
                     $(RUN_DEV)/$(HIST_INS).Dev 0 0
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref                             \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1
endif
endif
endif

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Output Data     %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

refclean:
	@$(MAKE) -C $(CODE_REF) realclean

devclean:
	@$(MAKE) -C $(CODE_DEV) realclean

realclean:
	@$(MAKE) refclean
	@$(MAKE) devclean

fileclean:
	rm -f $(RUN_REF)/*.Ref
	rm -f $(RUN_REF)/core.*
	rm -f $(RUN_REF)/GEOSCHEM*.nc*
	rm -f $(RUN_REF)/HEMCO.log*
	rm -f $(RUN_REF)/*info.dat
	rm -f $(RUN_REF)/*.log
	rm -f $(RUN_REF)/Ox.mass.*
	rm -f $(RUN_REF)/*.nc4
	rm -f $(RUN_DEV)/*.Dev
	rm -f $(RUN_DEV)/core.*
	rm -f $(RUN_DEV)/GEOSCHEM*.nc*
	rm -f $(RUN_DEV)/HEMCO.log*
	rm -f $(RUN_DEV)/*info.dat
	rm -f $(RUN_DEV)/*.log
	rm -f $(RUN_DEV)/Ox.mass.*
	rm -f $(RUN_DEV)/*.nc4

reftauclean:
	@$(MAKE) -C $(CODE_REF) tauclean

devtauclean:
	@$(MAKE) -C $(CODE_DEV) tauclean


tauclean:
	@$(MAKE) reftauclean
	@$(MAKE) devtauclean

superclean:
	@$(MAKE) realclean
	@$(MAKE) fileclean

logclean:
	rm -f $(LOG_DIR)/log.*

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Debugging              %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

tvsp_ref:
	@$(MAKE) -C $(RUN_REF) CODE=$(CODE_REF) EXEC=$(EXEC_REF) \
                    DEBUG=y    OMP=n            tvsp

tvmp_ref:
	@$(MAKE) -C $(RUN_REF) CODE=$(CODE_REF) EXEC=$(EXEC_REF) \
                    DEBUG=y    OMP=y            tvmp

tvsp_dev:
	@$(MAKE) -C $(RUN_DEV) CODE=$(CODE_DEV) EXEC=$(EXEC_DEV) \
                    DEBUG=y    OMP=n            tvsp

tvmp_dev:
	@$(MAKE) -C $(RUN_DEV) CODE=$(CODE_DEV) EXEC=$(EXEC_DEV) \
                    DEBUG=y    OMP=y            tvmp

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Print information      %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

printruninforef:
	@echo "RUN SETTINGS:"
	@echo "  Code directory      : $(CODE_REF)"
	@echo "  Code branch         : $(CODE_BRANCH_REF)"
	@echo "  Last commit         : $(LAST_COMMIT_REF)"
	@echo "  Commit date         : $(COMMIT_DATE_REF)"
	@echo "  Run directory       : $(RUN_REF)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Tracer Data File    : $(TRAC_AVG).Ref"
	@echo "  Tracer Restart File : $(TRAC_RST).Ref"
	@echo "  History File (inst) : $(HIST_INS).Ref"
	@echo "  HEMCO Restart File  : $(HMCO_RST).Ref"
	@echo "  GC Run Log File     : $(LOG_REF)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).Ref"

printruninfodev:
	@echo "RUN SETTINGS:"
	@echo "  Code directory      : $(CODE_DEV)"
	@echo "  Code branch         : $(CODE_BRANCH_DEV)"
	@echo "  Last commit         : $(LAST_COMMIT_DEV)"
	@echo "  Commit date         : $(COMMIT_DATE_DEV)"
	@echo "  Run directory       : $(RUN_DEV)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Tracer Data File    : $(TRAC_AVG).Dev"
	@echo "  Tracer Restart File : $(TRAC_RST).Dev"
	@echo "  HEMCO Restart File  : $(HMCO_RST).Dev"
	@echo "  History File (inst) : $(HIST_INS).Dev"
	@echo "  GC Run Log File     : $(LOG_DEV)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).Dev"

printbuildinfo:
	@echo "LAST BUILD INFORMATION:"
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
	@echo "  UCX          : $(UCX)"
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

printallinforef: 
	@$(MAKE) printbuildinfo
	@$(MAKE) printruninforef

printallinfodev: 
	@$(MAKE) printbuildinfo
	@$(MAKE) printruninfodev

###############################################################################
#####                                                                     #####
#####                             HELP SCREEN                             #####
#####                                                                     #####
################################################################################

help:
	@echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
	@echo '%%%    GEOS-Chem Diff Test Makefile Help Screen        %%%'
	@echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
	@echo
	@echo 'Usage: make -jN TARGET [OPTIONAL-FLAGS]'
	@echo ''
	@echo '-jN               Compiles N files at a time (reduces compile time)'
	@echo ''
	@echo '----------------------------------------------------------'
	@echo 'TARGET may be one of the following:'
	@echo '----------------------------------------------------------'
	@echo 'all               Default target (synonym for "difftest")'
	@echo 'dt                Synonym for "difftest"'
	@echo ''
	@echo '%%% COMPILE AND RUN %%%'
	@echo 'difftest          Runs a GEOS-Chem difference test:'
	@echo '                  (1) Builds & runs GEOS-Chem with CODE_REF'
	@echo '                  (2) Builds & runs GEOS-Chem with CODE_DEV'
	@echo '                  (3) Checks to see if the output is identical'
	@echo 'refonly           Builds and runs GEOS-Chem with CODE_REF'
	@echo 'devonly           Builds and runs GEOS-Chem with CODE_DEV'
	@echo ''
	@echo '%%% BUILD ONLY %%%'
	@echo 'devlib            Just builds GEOS-Chem with CODE_DEV'
	@echo ''
	@echo '%%% RUN ONLY %%%'
	@echo 'devrun            Just runs GEOS_Chem with CODE_DEV'  
	@echo ''
	@echo '%%% VALIDATE OUTPUT %%%'
	@echo 'devcheck          Synonym for: devonly check'
	@echo 'check             Executes the "validate" script to test if the files'
	@echo '                    ending in ".Ref" contain identical results to the'
	@echo '                    files ending in ".Dev".'
	@echo ''
	@echo '%%% CLEAN SOURCE CODE %%%'
	@echo 'refclean          Removes compiled files in the REF code directory'
	@echo 'devclean          Removes compiled files in the DEV code directory'
	@echo 'realclean         Synonym for: refclean devclean'
	@echo ''
	@echo '%%% REMOVE OUTPUT FILES %%%'
	@echo 'fileclean         Removes all GEOS-Chem REF & DEV output files + logs'
	@echo ''
	@echo '%%% REMOVE TAU FILES %%%'
	@echo 'reftauclean       Removes all TAU files in the REF code'
	@echo 'devtauclean       Removes all TAU files in the DEV code'
	@echo 'tauclean          Synonym for: reftauclean devtauclean'
	@echo ''
	@echo '%%% CLEAN AND REMOVE ALL %%%'
	@echo 'superclean        Synonym for: fileclean realclean'
	@echo ''
	@echo '%%% REMOVE LOG FILES %%%'
	@echo 'logclean          Removes all log files in LOG_DIR'
	@echo ''
	@echo '%%% DEBUGGING %%%'
	@echo 'tvsp_ref          Runs totalview for REF (single processor)'
	@echo 'tvmp_ref          Runs totalview for REF (multi  processor)'
	@echo 'tvsp_dev          Runs totalview for DEV (single processor)'
	@echo 'tvmp_dev          Runs totalview for DEV (multi  processor)'
	@echo ''
	@echo '%%% PRINT INFORMATION %%%'
	@echo 'printruninforef   Prints the run settings for REF simulations'
	@echo 'printruninfodev   Prints the run settings for DEV simulations'
	@echo 'printbuildinfo    Prints the build settings for GEOS-Chem simulations'
	@echo 'prinallinforef    Synonym for: printbuildinfo printruninforef'
	@echo 'prinallinfodev    Synonym for: printbuildinfo printruninfodev'
	@echo ''
	@echo '%%% UTILITIES %%%'
	@echo 'help              Prints this help screen'
	@echo ''
	@echo '----------------------------------------------------------'
	@echo 'OPTIONAL-FLAGS may be one of the following:'
	@echo '----------------------------------------------------------'
	@echo 'DEBUG=y           Compiles with various debugging options'
	@echo 'BOUNDS=y          Compiles with out-of-bounds error checks'
	@echo 'FPE=y             Compiles with floating-point math error checks'
	@echo 'TRACEBACK=y       Compiles with traceback error printout'
	@echo 'NO_ISO=n          Compiles with ISORROPIA on (default is off for diff testing)'
	@echo 'TIMERS=1          Compiles GEOS-Chem with timers turned on'
	@echo 'NC_DIAG=y         Compiles GEOS-Chem such that diagnostics are output in NetCDF format (default is binary-punch)'
#EOC
