#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: initialSetup.sh
# 
# !DESCRIPTION: Sets up symbolic links to data required by GCHP.
#\\
#\\
# !REMARKS:
#  (1) Use upon first time setup of the run directory.  
#  (2) Subsequent usage requires deletion of the following symbolic links
#         CodeDir
#         MainDataDir
#         MetDir
#         RestartsDir
#         ChemDataDir
#         TileFiles
#
# !REVISION HISTORY: 
#  Navigate to your unit tester directory and type 'gitk' at the prompt
#  to browse the revision history.
#EOP
#------------------------------------------------------------------------------
#BOC
# First time setup script - run only once!

# Check whether symlinks for source code, met, hemco, chem, and restarts 
# already are set. If yes then exist since setup is not necessary. 
if [[ -L CodeDir && -L MainDataDir && -L MetDir && -L RestartsDir && -L ChemDataDir && -L TileFiles ]] ; then
  echo "Symbolic links already set up"
  exit 1
fi

# Prompt the user for source code directory and set symlink
read -p "Enter path to code directory:" codePath
if [[ ! -d ${codePath} ]]; then
  echo "Directory ${codePath} does not exist"
  exit 1
fi
ln -s ${codePath} CodeDir

# Define tile file needed to regrid Olson landmap and MODIS LAI to c24 (~4x5)
tileFile=DE1440xPE0720_CF0024x6C.bin

# Prompt the user on whether using Odyssey (Harvard)
read -p "Are you on Odyssey [y/n]? " onOdyssey

# Automatically set met, hemco, chem, and restart paths if on Odyssey,
# and ask the user what input met resolution to use.
onOdyssey=$( echo "${onOdyssey}" | tr '[:upper:]' '[:lower:]' )
if [[ ${onOdyssey} == "y" ]]; then
  baseDir='/n/holylfs/EXTERNAL_REPOS/GEOS-CHEM/gcgrid'
  MetDir=$baseDir
  MainDataDir="$baseDir/data/ExtData/HEMCO"
  RestartsDir="$baseDir/data/ExtData/NC_RESTARTS"
  ChemDataDir="$baseDir/gcdata/ExtData/CHEM_INPUTS"
  TileFileDir="$baseDir/gcdata/ExtData/GCHP/TileFiles"
  echo "Valid INPUT resolution choices:"
  echo "[N] Native (0.25x0.3125) (2015-07-01 to 2015-07-10)"
  echo "[2] 2x2.5                (2012-05-01 to 2014-12-31)"
  echo "[4] 4x5                  (2012-05-01 to 2015-07-31)"
  read -p "Select an INPUT resolution for met data: " resChoice

  if [[ ${resChoice} == "N" || ${resChoice} == "n" ]]; then
    MetDir=${MetDir}/GEOS_0.25x0.3125/GEOS_0.25x0.3125.d/GEOS_FP
    cp ExtData_Native.rc ExtData.rc
  elif [[ ${resChoice} == 4 ]]; then
    MetDir=${MetDir}/GEOS_4x5/GEOS_FP
    cp ExtData_4x5.rc ExtData.rc
  elif [[ ${resChoice} == 2 ]]; then
    MetDir=${MetDir}/GEOS_2x2.5_GEOS_5/GEOS_FP
    cp ExtData_2x25.rc ExtData.rc
  else
    echo "Invalid resolution selected"
    unlink CodeDir
    exit 1
  fi

# If not on Odyssey, ask the user for the paths
elif [[ ${onOdyssey} == "n" ]]; then
  read -p "Enter path containing met data: " MetDir
  read -p "Enter path to HEMCO data directory: " MainDataDir
  read -p "Enter path to GEOS-Chem restart files: " RestartsDir
  read -p "Enter path to CHEM_INPUTS directory: " ChemDataDir
  read -p "Enter path to tile files: " TileFileDir
  echo "WARNING: You must replace ExtData.rc with the appropriate template"
  echo "         file (e.g. ExtData_4x5.rc if using 4x5 met input resolution!"
else
  echo "Invalid response given"
  unlink CodeDir
  exit 1
fi

# Set symlinks based on the paths set above
if [[ -d ${MetDir} && -d ${MainDataDir} && -d ${RestartsDir} && -d ${ChemDataDir} && -d ${TileFileDir} ]]; then
  ln -s ${MetDir} MetDir
  ln -s ${MainDataDir} MainDataDir
  ln -s ${RestartsDir} RestartsDir
  ln -s ${ChemDataDir} ChemDataDir
  ln -s ${TileFileDir} TileFiles
else
  echo "Could not find target directories"
  unlink CodeDir
  exit 1
fi
echo " "
echo "IMPORTANT NOTES: You must now set up your environment, compile, and run" 
echo " "
echo "  (1) ENVIRONMENT: You must set up your environment by sourcing a "
echo "bashrc file. Sample bashrc files compatible with Harvard's Odyssey "
echo "Compute Cluster and Dalhousie's ACENET Glooscap cluster are included"
echo "in this run directory. If you are on a different system, you may use"
echo "them as a guide to customize a bashrc compatible with your local "
echo "system. If you clean and compile with build.sh, or with any make"
echo "commands that call build.sh, then you will be guided through the"
echo "process of setting up your environment."
echo " "
echo "  (2) COMPILE: Compile using one of the make commands defined in the"
echo "Makefile which calls build.sh, or use build.sh directly. Enter"
echo "'make help' or './build.sh help' for options."
echo " "
echo "  (3) RUN: Sample run scripts for SLURM and Grid Engine schedulers"
echo "are included in this directory. The scripts are GCHP_slurm.run and"
echo "and GCHP_gridengine.run. GCHP_slurm.run is configured for use"
echo "on Harvard's Odyssey cluster and GCHP_gridengine.run for use on"
echo "Dalhousie's Glooscap cluster. These may be helpful in creating"
echo "a run script for your own system. Beware that the bashrc is"
echo "hard-coded in the run scripts and you should check and edit as"
echo "needed prior to submitting."
echo " "
echo "Thank you for using the GCHP Dev Kit! Please send any comments, issues,"
echo "or questions to Lizzie Lundgren at elundgren@seas.harvard.edu"

exit 0
