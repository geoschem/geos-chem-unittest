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
#  31 Oct 2014 - R. Yantosca - Initial version
#  14 Jul 2015 - M. Sulprizio- Updated for GEOS-Chem v11-01. Makefile structure
#                              is now more consistent with Makefile in UT.
#   2 Sep 2015 - R. Yantosca - Now get root data directory with getRunInfo
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
endif

ifndef TRACEBACK 
 TRACEBACK   :=n
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

# Turn off ISORROPIA for all diff testing
ifndef NO_ISO
 NO_ISO      :=y
endif

ifndef COMPILER
 COMPILER    :=ifort
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
 CHEM        :=benchmark
endif

ifndef MASSCONS 
 MASSCONS    :=n
endif

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
HMCO_END     :=$(END)

# By default, UCX, TOMAS40 and RRTMG are all set to "n".  But if we are doing
# one of thess simulations, reset the corresponding makefile variable to "y".
# Also define the proper setting for CHEM, which picks the correct KPP files.
ifeq ($(SIM),TOMAS12)
 TOMAS12     :=y
endif

ifeq ($(SIM),TOMAS15)
 TOMAS15     :=y
endif

ifeq ($(SIM),TOMAS40)
 TOMAS40     :=y
endif

ifeq ($(SIM),RRTMG)
 RRTMG       :=y
endif

ifeq ($(SIM),UCX)
 UCX         :=y
 CHEM        :=UCX
 NO_REDUCED  :=y
endif

ifeq ($(SIM),benchmark)
 UCX         :=y
 CHEM        :=benchmark
 NO_REDUCED  :=y
endif

ifeq ($(SIM),aciduptake)
 UCX         :=y
 CHEM        :=benchmark
 NO_REDUCED  :=y
endif

ifeq ($(SIM),soa)
 CHEM        :=SOA
endif

ifeq ($(SIM),soa_svpoa)
 CHEM        :=SOA_SVPOA
 NEST        :=n
endif

ifeq ($(SIM),tropchem)
 CHEM        :=NOx_Ox_HC_Aer_Br
endif

ifeq ($(SIM),fullchem)
 CHEM        :=NOx_Ox_HC_Aer_Br
endif

ifeq ($(SIM),NOx_Ox_HC_Aer_Br)
 CHEM        :=NOx_Ox_HC_Aer_Br
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
TRAC_RST     :=trac_rst.$(RUNID).$(END)
SPEC_RST     :=spec_rst.$(RUNID).$(END)
HMCO_AVG     :=HEMCO_diagnostics.$(END).nc
HMCO_RST     :=HEMCO_restart.$(HMCO_END).nc

# Diff test validation script and results file
VALIDATE     :=/usr/bin/perl $(RUN_DEV)/validate
RESULTS      :=$(LOG_DIR)/log.$(RUNID).Results

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
.PHONY: devcheck        check
.PHONY: config          refconfig       devconfig
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

refonly:
	@$(MAKE) refconfig
	@$(MAKE) -C $(RUN_REF)  ref                                         \
                                MET=$(MET)             GRID=$(GRID)         \
                                NEST=$(NEST)           UCX=$(UCX)           \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)       \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)   \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)   \
                                MASSCONS=$(MASSCONS)   OMP=yes              \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_REF)     \
                                EXEC=$(EXEC_REF)       TRAC_AVG=$(TRAC_AVG) \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG) \
                                HMCO_RST=$(HMCO_RST)   SPEC_RST=$(SPEC_RST) \
                                HMCO_LOG=$(LOG_HMCO)   LOG=$(LOG_REF)       \
                                START=$(START)         END=$(END)           \
                                TAU_OPTIONS=$(TAU_OPT)
	@$(MAKE) printbuildinfo > $(RUN_REF)/$(LOG_COMP).Ref
	@$(MAKE) printruninforef >> $(LOG_REF)
	@$(MAKE) printallinforef

devonly:
	@$(MAKE) devconfig
	@$(MAKE) -C $(RUN_DEV)  dev                                         \
                                MET=$(MET)             GRID=$(GRID)         \
                                NEST=$(NEST)           UCX=$(UCX)           \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)       \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)   \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)   \
                                MASSCONS=$(MASSCONS)   OMP=yes              \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_DEV)     \
                                EXEC=$(EXEC_DEV)       TRAC_AVG=$(TRAC_AVG) \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG) \
                                HMCO_RST=$(HMCO_RST)   SPEC_RST=$(SPEC_RST) \
                                HMCO_LOG=$(LOG_HMCO)   LOG=$(LOG_DEV)       \
                                START=$(START)         END=$(END)           \
                                TAU_OPTIONS=$(TAU_OPT)
	@$(MAKE) printbuildinfo > $(RUN_DEV)/$(LOG_COMP).Dev
	@$(MAKE) printruninfodev >> $(LOG_DEV)
	@$(MAKE) printallinfodev

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Build Only             %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

devlib:
	@$(MAKE) devconfig
	@$(MAKE) -C $(RUN_DEV)  lib                                          \
                                MET=$(MET)             GRID=$(GRID)         \
                                NEST=$(NEST)           UCX=$(UCX)           \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)       \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)   \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)   \
                                MASSCONS=$(MASSCONS)   OMP=yes              \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_DEV)     \
                                EXEC=$(EXEC_DEV)       TRAC_AVG=$(TRAC_AVG) \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG) \
                                HMCO_RST=$(HMCO_RST)   SPEC_RST=$(SPEC_RST) \
                                HMCO_LOG=$(LOG_HMCO)   LOG=$(LOG_DEV)       \
                                START=$(START)         END=$(END)           \
                                TAU_OPTIONS=$(TAU_OPT)
	@$(MAKE) printbuildinfo > $(RUN_DEV)/$(LOG_COMP).Dev
	@$(MAKE) printruninfodev >> $(LOG_DEV)
	@$(MAKE) printallinfodev

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Run Only               %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

devrun:
	@$(MAKE) devconfig
	@$(MAKE) -C $(RUN_DEV)  run                                         \
                                MET=$(MET)             GRID=$(GRID)         \
                                NEST=$(NEST)           UCX=$(UCX)           \
                                CHEM=$(CHEM)           RRTMG=$(RRTMG)       \
                                TOMAS12=$(TOMAS12)     TOMAS15=$(TOMAS15)   \
                                TOMAS30=$(TOMAS30)     TOMAS40=$(TOMAS40)   \
                                MASSCONS=$(MASSCONS)   OMP=yes              \
                                NO_ISO=$(NO_ISO)       CODE=$(CODE_DEV)     \
                                EXEC=$(EXEC_DEV)       TRAC_AVG=$(TRAC_AVG) \
                                TRAC_RST=$(TRAC_RST)   HMCO_AVG=$(HMCO_AVG) \
                                HMCO_RST=$(HMCO_RST)   SPEC_RST=$(SPEC_RST) \
                                HMCO_LOG=$(LOG_HMCO)   LOG=$(LOG_DEV)       \
                                START=$(START)         END=$(END)           \
                                TAU_OPTIONS=$(TAU_OPT)
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
	@$(VALIDATE) $(RUN_REF)/$(TRAC_AVG).Ref \
                     $(RUN_DEV)/$(TRAC_AVG).Dev 1 0 >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref \
                     $(RUN_DEV)/$(TRAC_RST).Dev 0 0 >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1 >> $(RESULTS)
	@$(VALIDATE) $(RUN_REF)/$(TRAC_AVG).Ref \
                     $(RUN_DEV)/$(TRAC_AVG).Dev 1 0
	@$(VALIDATE) $(RUN_REF)/$(TRAC_RST).Ref \
                     $(RUN_DEV)/$(TRAC_RST).Dev 0 0
	@$(VALIDATE) $(RUN_REF)/$(HMCO_RST).Ref \
                     $(RUN_DEV)/$(HMCO_RST).Dev 0 1

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
	rm -f $(RUN_DEV)/*.Dev
	rm -f $(RUN_DEV)/core.*
	rm -f $(RUN_DEV)/GEOSCHEM*.nc*
	rm -f $(RUN_DEV)/HEMCO.log*
	rm -f $(RUN_DEV)/*info.dat
	rm -f $(RUN_DEV)/*.log
	rm -f $(RUN_DEV)/Ox.mass.*

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
	@$(MAKE) refconfig
	@$(MAKE) -C $(RUN_REF) CODE=$(CODE_REF) EXEC=$(EXEC_REF) \
                    DEBUG=y    OMP=n            tvsp

tvmp_ref:
	@$(MAKE) refconfig
	@$(MAKE) -C $(RUN_REF) CODE=$(CODE_REF) EXEC=$(EXEC_REF) \
                    DEBUG=y    OMP=y            tvmp

tvsp_dev:
	@$(MAKE) devconfig
	@$(MAKE) -C $(RUN_DEV) CODE=$(CODE_DEV) EXEC=$(EXEC_DEV) \
                    DEBUG=y    OMP=n            tvsp

tvmp_dev:
	@$(MAKE) devconfig
	@$(MAKE) -C $(RUN_DEV) CODE=$(CODE_DEV) EXEC=$(EXEC_DEV) \
                    DEBUG=y    OMP=y            tvmp

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Print information      %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

printruninforef:
	@echo "RUN SETTINGS:"
	@echo "  Code directory      : $(CODE_REF)"
	@echo "  Run directory       : $(RUN_REF)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Tracer Data File    : $(TRAC_AVG).Ref"
	@echo "  Tracer Restart File : $(TRAC_RST).Ref"
	@echo "  HEMCO Restart File  : $(HMCO_RST).Ref"
	@echo "  GC Run Log File     : $(LOG_REF)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).Ref"

printruninfodev:
	@echo "RUN SETTINGS:"
	@echo "  Code directory      : $(CODE_DEV)"
	@echo "  Run directory       : $(RUN_DEV)"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Tracer Data File    : $(TRAC_AVG).Dev"
	@echo "  Tracer Restart File : $(TRAC_RST).Dev"
	@echo "  HEMCO Restart File  : $(HMCO_RST).Dev"
	@echo "  GC Run Log File     : $(LOG_DEV)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).Dev"

printbuildinfo:
	@echo "LAST BUILD INFORMATION:"
	@echo "  MET       : $(MET)"
	@echo "  GRID      : $(GRID)"
	@echo "  SIM       : $(SIM)"
	@echo "  NEST      : $(NEST)"
	@echo "  TRACEBACK : $(TRACEBACK)"
	@echo "  BOUNDS    : $(BOUNDS)"
	@echo "  DEBUG     : $(DEBUG)"
	@echo "  FPE       : $(FPE)"
	@echo "  NO_ISO    : $(NO_ISO)"	
	@echo "  NO_REDUCED: $(NO_REDUCED)"
	@echo "  CHEM      : $(CHEM)"
	@echo "  UCX       : $(UCX)"
	@echo "  TOMAS12   : $(TOMAS12)"	
	@echo "  TOMAS15   : $(TOMAS15)"
	@echo "  TOMAS40   : $(TOMAS40)"
	@echo "  RRTMG     : $(RRTMG)"
	@echo "  MASSCONS  : $(MASSCONS)"
	@echo "  COMPILER  : $(COMPILER)"
	@echo "  Datetime  : $(TIMESTAMP)"

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
	@echo 'DEBUG=y           Compiles GEOS-Chem with various debugging options'
	@echo 'BOUNDS=y          Compiles GEOS-Chem with out-of-bounds error checks'
	@echo 'FPE=y             Compiles GEOS-Chem with floating-point math error checks'
	@echo 'TRACEBACK=y       Compiles GEOS-Chem with traceback error printout'
	@echo 'NO_ISO=y          Compiles GEOS-Chem and turns off ISORROPIA'
#EOC