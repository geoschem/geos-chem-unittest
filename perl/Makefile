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
#  (2) MET and GRID are read from input.geos using perl script
#      getRunInfo and are automatically passed to the make command. 
#      Simulation-dependent optional flags NEST, TOMAS40, UCX, and RRTMG
#      are also automatically passed. 
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
#        make logclean                       # remove log files
#        make dataclean                      # remove output data files
#        make execlean                       # remove executables
#	 make fileclean                      # do the previous 3 commands
#        make superclean                     # Remove all output files
#                                              make code dir realclean
# 
# !REVISION HISTORY: 
#  02 Apr 2015 - E. Lundgren - Initial version
#  14 Apr 2015 - R. Yantosca - Now user $(USER) in default CODE_DIR
#  14 Apr 2015 - R. Yantosca - Now look for ocean_rst file for Hg simulatons
#  14 Apr 2015 - R. Yantosca - Also now use $(PERL_DIR)/validate directly
#  14 Apr 2015 - R. Yantosca - Also rename the ocean restart files to .sp, .mp
#  22 Apr 2015 - E. Lundgren - Now define defaults for Makefile variables
#  22 Apr 2015 - R. Yantosca - Bug fix: write LOG_HMCO to the run directory
#  22 Apr 2015 - R. Yantosca - Cosmetic changes, updated comments
#  26 May 2015 - R. Yantosca - Now define the default setting for CHEM
#  26 May 2015 - R. Yantosca - Add ./ to executable to avoid bash errors
#  26 May 2015 - R. Yantosca - Now define CHEM based on the simulation type
#                              and pass it explicitly in build sequence
#  28 May 2015 - R. Yantosca - Fixed bug in RUNID for nested grid simulations
#  05 Jun 2015 - R. Yantosca - Quick fix; set NEST=n if SIM=soa_svpoa.
#  09 Jun 2015 - E. Lundgren - Include HEMCO_restart* and geos.mp.* in cleans
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

# Source code location
ifndef CODE_DIR
 CODE_DIR    :=/home/$(USER)/GC/Code.v10-01
endif

# Output log file destination (default is run directory) 
ifndef LOG_DIR 
 LOG_DIR     :=.
endif

# GEOS-Chem run log filename prefix
ifndef VERSION
 VERSION     :=v10-01
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

ifndef NO_ISO
 NO_ISO      :=n
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
endif

ifeq ($(SIM),benchmark)
 UCX         :=y
 CHEM        :=benchmark
endif

ifeq ($(SIM),soa)
 CHEM        :=SOA
endif

ifeq ($(SIM),soa_svpoa)
 CHEM        :=SOA
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

# General run information
TIMESTAMP    := $(shell date +"%Y/%m/%d %H:%M")	
RUNID        :=$(MET)_$(GRID)_$(SIM)
ifneq ($(NEST),n) 
 RUNID       :=$(RUNID)_$(NEST)
endif

# Log files that will be written to the log directory
LOG_COMP     :="$(RUN_DIR)/lastbuild"
LOG_SP       :="$(LOG_DIR)/$(VERSION).$(RUNID).log.sp"
LOG_MP       :="$(LOG_DIR)/$(VERSION).$(RUNID).log.mp"

# Log files that will be written to the run directory
# (For copied run directories, the log & run directories are the same)
LOG_HMCO     :="HEMCO.log"

# Executables
EXE_SP       :=geos.sp
EXE_MP       :=geos.mp

# Output data files
TRAC_AVG     :=trac_avg.$(RUNID).$(START)
TRAC_RST     :=trac_rst.$(RUNID).$(END)
HMCO_RST     :=HEMCO_restart.$(HMCO_END).nc
ifeq ($(SIM),Hg)
 OCN_RST     :=ocean_rst.$(RUNID).$(END)
endif

# Unit test validation script and results file
VALIDATE     :=/usr/bin/perl $(PERL_DIR)/validate
RESULTS      :=$(LOG_DIR)/$(VERSION).results.log

###############################################################################
#####                                                                     #####
#####                          MAKEFILE TARGETS                           #####
#####                                                                     #####
###############################################################################

# PHONY targets don't actually compile anything. They either are
# synonyms for other targets, they remove files, or they print output.
.PHONY: all     dataclean  logclean   fileclean  spclean
.PHONY: mpclean spexeclean mpexeclean superclean printallinfo

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Build and Run          %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

all: unittest

unittest:
	@$(MAKE) superclean
	@$(MAKE) sp
	@$(MAKE) realclean
	@$(MAKE) mp
	@$(MAKE) check

sp:
	@$(MAKE) spclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)         GRID=$(GRID)       \
                                NEST=$(NEST)       UCX=$(UCX)         \
                                CHEM=$(CHEM)       RRTMG=$(RRTMG)     \
                                TOMAS12=$(TOMAS12) TOMAS15=$(TOMAS15) \
                                TOMAS30=$(TOMAS30) TOMAS40=$(TOMAS40) \
                                OMP=no > $(LOG_SP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	cp -f $(CODE_DIR)/bin/geos $(EXE_SP)
	./$(EXE_SP) >> $(LOG_SP)
	@$(MAKE) addsuffixsp
	@$(MAKE) printruninfosp >> $(LOG_SP)
	@$(MAKE) printallinfosp

mp:
	@$(MAKE) mpclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)         GRID=$(GRID)       \
                                NEST=$(NEST)       UCX=$(UCX)         \
                                CHEM=$(CHEM)       RRTMG=$(RRTMG)     \
                                TOMAS12=$(TOMAS12) TOMAS15=$(TOMAS15) \
                                TOMAS30=$(TOMAS30) TOMAS40=$(TOMAS40) \
                                OMP=yes > $(LOG_MP)
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
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)         GRID=$(GRID)       \
                                NEST=$(NEST)       UCX=$(UCX)         \
                                CHEM=$(CHEM)       RRTMG=$(RRTMG)     \
                                TOMAS12=$(TOMAS12) TOMAS15=$(TOMAS15) \
                                TOMAS30=$(TOMAS30) TOMAS40=$(TOMAS40) \
                                OMP=no
	cp -f $(CODE_DIR)/bin/geos $(EXE_SP)
	@$(MAKE) printbuildinfo > $(LOG_COMP).sp
	@$(MAKE) printbuildinfo

mpbuild:
	@$(MAKE) mpexeclean
	@$(MAKE) mplogclean
	@$(MAKE) -C $(CODE_DIR) MET=$(MET)         GRID=$(GRID)       \
                                NEST=$(NEST)       UCX=$(UCX)         \
                                CHEM=$(CHEM)       RRTMG=$(RRTMG)     \
                                TOMAS12=$(TOMAS12) TOMAS15=$(TOMAS15) \
                                TOMAS30=$(TOMAS30) TOMAS40=$(TOMAS40) \
                                OMP=yes
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
#  Remove Output Data     %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

dataclean: 
	rm -f HEMCO_diagnostics*
	if [ -f HEMCO_restart.$(START).nc ]; then mv -f HEMCO_restart.$(START).nc HC.nc; fi;
	rm -f HEMCO_restart.*;
	if [ -f HC.nc ]; then mv -f HC.nc HEMCO_restart.$(START).nc; fi;
	rm -f trac_rst*
	rm -f trac_avg*
	rm -f os.mass.*
	rm -f diaginfo.dat tracerinfo.dat

spdataclean:
	rm -f $(TRAC_AVG)*.sp
	rm -f $(TRAC_RST)*.sp
	rm -f HEMCO_restart*.sp
	rm -f diaginfo.dat tracerinfo.dat

mpdataclean:
	rm -f $(TRAC_AVG)*.mp
	rm -f $(TRAC_RST)*.mp
	rm -f HEMCO_restart*.mp
	rm -f diaginfo.dat tracerinfo.dat

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Remove Logs            %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

logclean: 
	@$(MAKE) splogclean 
	@$(MAKE) mplogclean
	rm -f $(LOG_HMCO)
	rm -f *.log

splogclean:
	rm -f $(LOG_SP)
	rm -f $(LOG_HMCO).sp
	rm -f smv2.log
	rm -f geos.sp.*

mplogclean:
	rm -f $(LOG_MP)
	rm -f $(LOG_HMCO).mp
	rm -f smv2.log
	rm -f geos.mp.*

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

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Clean and Remove All   %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

superclean: fileclean realclean

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
	@echo "  Tracer Data File    : $(TRAC_AVG).sp"
	@echo "  Tracer Restart File : $(TRAC_RST).sp"
	@echo "  HEMCO Restart File  : $(HMCO_RST).sp"
	@echo "  GC Run Log File     : $(LOG_SP)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).sp"

printruninfomp:
	@echo "RUN SETTINGS:"
	@echo "  Run ID              : $(RUNID)"
	@echo "  Run directory       : $(RUN_DIR)"
	@echo "  Simulation Start    : $(START)"
	@echo "  Simulation End      : $(END)"
	@echo "  HEMCO End           : $(HMCO_END)"
	@echo "  Version             : $(VERSION)"
	@echo "  Tracer Data File    : $(TRAC_AVG).mp"
	@echo "  Tracer Restart File : $(TRAC_RST).mp"
	@echo "  HEMCO Restart File  : $(HMCO_RST).mp"
	@echo "  GC Run Log File     : $(LOG_MP)"
	@echo "  HEMCO Log File      : $(LOG_HMCO).mp"

printbuildinfo:
	@echo "LAST BUILD INFORMATION:"
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
	@echo "  NO_REDUCED: $(NO_ISO)"
	@echo "  CHEM      : $(CHEM)"
	@echo "  UCX       : $(UCX)"
	@echo "  TOMAS12   : $(TOMAS12)"	
	@echo "  TOMAS15   : $(TOMAS15)"
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

#%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Utilities              %
#%%%%%%%%%%%%%%%%%%%%%%%%%%

addsuffixsp:
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).sp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).sp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).sp; fi;
	if [ -f $(LOG_HMCO) ]; then mv -f $(LOG_HMCO) $(LOG_HMCO).sp; fi;
ifeq ($(SIM),Hg)
	if [ -f $(OCN_RST)  ]; then mv -f $(OCN_RST)  $(OCN_RST).sp;  fi;
endif

addsuffixmp:
	if [ -f $(TRAC_AVG) ]; then mv -f $(TRAC_AVG) $(TRAC_AVG).mp; fi;
	if [ -f $(TRAC_RST) ]; then mv -f $(TRAC_RST) $(TRAC_RST).mp; fi;
	if [ -f $(HMCO_RST) ]; then mv -f $(HMCO_RST) $(HMCO_RST).mp; fi;
	if [ -f $(LOG_HMCO) ]; then mv -f $(LOG_HMCO) $(LOG_HMCO).mp; fi;
ifeq ($(SIM),Hg)
	if [ -f $(OCN_RST)  ]; then mv -f $(OCN_RST)  $(OCN_RST).mp;  fi;
endif

check:
ifeq ($(SIM),Hg)
	@$(VALIDATE) $(TRAC_AVG).sp $(TRAC_AVG).mp 1 0 >> $(RESULTS)
	@$(VALIDATE) $(TRAC_RST).sp $(TRAC_RST).mp 0 0 >> $(RESULTS)
	@$(VALIDATE) $(HMCO_RST).sp $(HMCO_RST).mp 0 0 >> $(RESULTS)
	@$(VALIDATE) $(OCN_RST).sp  $(OCN_RST).mp  0 1 >> $(RESULTS)
else
	@$(VALIDATE) $(TRAC_AVG).sp $(TRAC_AVG).mp 1 0 >> $(RESULTS)
	@$(VALIDATE) $(TRAC_RST).sp $(TRAC_RST).mp 0 0 >> $(RESULTS)
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
	@echo ''
	@echo '%%% CLEAN AND REMOVE ALL %%%'
	@echo 'superclean        Synonym for: fileclean realclean"'
	@echo ''
	@echo '%%% PRINT INFORMATION %%%'
	@echo 'printruninfosp    Prints the run settings for GEOS-Chem simulations'
	@echo '                    for which the parallelization is turned OFF.'
	@echo 'printruninfomp    Prints the run settings for GEOS-Chem simulations'
	@echo '                    for which the parallelization is turned ON'
	@echo 'printbuildinfo    Prints the build settings for GEOS-Chem simulations'
	@echo 'prinallinfosp     Synonym for: printbuildinfosp printruninfosp'
	@echo 'prinallinfomp     Synonym for: printbuildinfomp printruninfomp;'
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
	@echo 'TRACEBACK=y       Compiles GEOS-Chem with traceback error printout'
	@echo 'NO_ISO=y          Compiles GEOS-Chem and turns off ISORROPIA'
#EOC
