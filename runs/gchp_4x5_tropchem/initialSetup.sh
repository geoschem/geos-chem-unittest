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
tileFile=DE1440xPE0720_CF0024x6C.bin
if [[ -L CodeDir && -L MainDataDir && -L MetDir && -L RestartsDir && -L ChemDataDir && -L ${tileFile}]] ; then
  echo "All necessary symbolic links already exist"
  exit 1
fi

# Prompt the user for source code directory and set symlink
read -p "Enter path to code directory:" codePath
if [[ ! -d $codePath ]]; then
  echo "Directory $codePath does not exist"
  exit 1
fi
ln -s $codePath CodeDir

# Prompt the user for directory containing tile files and set symlink
# to tile file needed to regrid Olson landmap and MODIS LAI to c24 (~4x5)
read -p "Enter path to DE1440xPE0720_CF0024x6C.bin tile file:" tilePath
if [[ ! -d $tilePath ]]; then
  echo "Directory $tilePath does not exist"
  exit 1
fi
ln -s ${tilePath}/${tileFile} ${tileFile} 

# Prompt the user on whether using Odyssey (Harvard)
read -p "Are you on Odyssey [y/n]? " onOdyssey

# Automatically set met, hemco, chem, and restart paths if on Odyssey,
# and ask the user what input met resolution to use.
onOdyssey=$( echo "$onOdyssey" | tr '[:upper:]' '[:lower:]' )
if [[ $onOdyssey == "y" ]]; then
  baseDir='/n/holylfs/EXTERNAL_REPOS/GEOS-CHEM/gcgrid'
  MetDir=$baseDir
  MainDataDir="$baseDir/data/ExtData/HEMCO"
  RestartsDir="$baseDir/data/ExtData/NC_RESTARTS"
  ChemDataDir="$baseDir/gcdata/ExtData/CHEM_INPUTS"
  echo "Valid INPUT resolution choices:"
  echo "[N] Native (0.25x0.3125) (2015-07-01 to 2015-07-10)"
  echo "[2] 2x2.5                (2012-05-01 to 2014-12-31)"
  echo "[4] 4x5                  (2012-05-01 to 2015-07-31)"
  read -p "Select an INPUT resolution for met data: " resChoice
  if [[ $resChoice == "N" || $resChoice == "n" ]]; then
    MetDir=$MetDir/GEOS_0.25x0.3125/GEOS_0.25x0.3125.d/GEOS_FP
    cp ExtData_Native.rc ExtData.rc
  elif [[ $resChoice == 4 ]]; then
    MetDir=$MetDir/GEOS_4x5/GEOS_FP
    cp ExtData_4x5.rc ExtData.rc
  elif [[ $resChoice == 2 ]]; then
    MetDir=$MetDir/GEOS_2x2.5_GEOS_5/GEOS_FP
    cp ExtData_2x25.rc ExtData.rc
  else
    echo "Invalid resolution selected"
    unlink CodeDir
    exit 1
  fi

# If not on Odyssey, ask the user for the paths
elif [[ $onOdyssey  == "n" ]]; then
  read -p "Enter path containing met data: " MetDir
  read -p "Enter path to HEMCO data directory: " MainDataDir
  read -p "Enter path to GEOS-Chem restart files: " RestartsDir
  read -p "Enter path to CHEM_INPUTS directory for Olson maps: " ChemDataDir
  echo "WARNING: You must replace ExtData.rc with the appropriate template"
  echo "         file (e.g. ExtData_4x5.rc if using 4x5 met input resolution!"
else
  echo "Invalid response given"
  unlink CodeDir
  exit 1
fi

# Set symlinks based on the paths set above
if [[ -d $MetDir && -d $MainDataDir && -d $RestartsDir && -d $ChemDataDir ]]; then
  ln -s $MetDir MetDir
  ln -s $MainDataDir MainDataDir
  ln -s $RestartsDir RestartsDir
  ln -s $ChemDataDir ChemDataDir
else
  echo "Could not find target directories"
  unlink CodeDir
  unlink geos
  exit 1
fi
echo " "
echo "IMPORTANT NOTE: You must now set up your environment!" 
echo " "
echo "  (1) Sample bashrc files that are compatible with the Harvard Odyssey"
echo "      Compute Cluster are included in this run directory. If you are on a"
echo "      different system, you may use them as a guide to customize a bashrc"
echo "      compatible with your local system. By default, the Makefile and"
echo "      GCHP.run are set to use GCHP.ifort15_openmpi_odyssey.bashrc."
echo " "
echo "  (2) Compile using build.sh, either directly or using the Makefile."
echo "      Type './build.sh help' for options."
echo " "
echo "  (3) Sample run script GCHP.run is included in this directory."
echo "      It is compatible with SLURM on the Harvard Odyssey Cluster"
echo "      and may be adapted to other systems. Prior to use, open the file,"
echo "      enter your email address for SLURM notifications, and update the"
echo "      bashrc to match your environment. The bashrc specific in the"
echo "      the Makefile is only invoked if you choose to run GCHP "
echo "      interactively using make."
echo " "
echo "Thank you for using the GCHP Dev Kit! Please send any comments, issues, "
echo "or questions to Lizzie Lundgren at elundgren@seas.harvard.edu"
exit 0
