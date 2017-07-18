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
if [[ -L CodeDir && -L MainDataDir && -L MetDir && -L ChemDataDir && -L TileFiles ]] ; then
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

# Define the restart filename stored on gcgrid
RestartsFile="initial_GEOSChem_rst.c24_standard.nc"

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
  RestartsDir="$baseDir/data/ExtData/SPC_RESTARTS"
  ChemDataDir="$baseDir/gcdata/ExtData/CHEM_INPUTS"
  TileFileDir="$baseDir/gcdata/ExtData/GCHP/TileFiles"
  MetDir=${baseDir}/GEOS_2x2.5_GEOS_5/GEOS_FP
  # On Odyssey, remove the safety check - holylfs is only visible off the login nodes
  checkPath=0

# If not on Odyssey, ask the user for the paths
elif [[ ${onOdyssey} == "n" ]]; then
  read -p "Enter path containing met data: " MetDir
  read -p "Enter path to HEMCO data directory: " MainDataDir
  read -p "Enter path to GEOS-Chem restart files: " RestartsDir
  read -p "Enter path to CHEM_INPUTS directory: " ChemDataDir
  read -p "Enter path to tile files: " TileFileDir
  checkPath=1
else
  echo "Invalid response given"
  unlink CodeDir
  exit 1
fi

# Check if the target paths exist (if not on Odyssey)
if [[ $checkPath -eq 1 ]]; then
  pathOK=0
  if [[ -d ${MetDir} && -d ${MainDataDir} && -d ${RestartsDir} && -d ${ChemDataDir} && -d ${TileFileDir} ]]; then
    pathOK=1
  fi
else
  # On Odyssey, assume the paths are OK
  pathOK=1
fi

# Set symlinks based on the paths set above
if [[ $pathOK -eq 1 ]]; then
  ln -s ${MetDir} MetDir
  ln -s ${MainDataDir} MainDataDir
  ln -s ${RestartsDir}/${RestartsFile} ${RestartsFile}
  ln -s ${ChemDataDir} ChemDataDir
  ln -s ${TileFileDir} TileFiles
else
  echo "Could not find target directories"
  unlink CodeDir
  exit 1
fi

exit 0
