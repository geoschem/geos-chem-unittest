#!/bin/bash
# First time setup script - run only once!

if [[ -L CodeDir || -L geos || -L MainDataDir || -L MetDir ]] ; then
  echo "Soft links already set up"
  exit 1
fi
read -p "Enter path to code directory:" codePath
if [[ ! -d $codePath ]]; then
  echo "Directory $codePath does not exist"
  exit 1
fi
ln -s $codePath CodeDir
ln -s CodeDir/bin/geos geos

# Now set up paths to the meteorological data
read -p "Are you on Odyssey [y/n]? " onOdyssey
# Make lower-case
onOdyssey=$( echo "$onOdyssey" | tr '[:upper:]' '[:lower:]' )
if [[ $onOdyssey == "y" ]]; then
  baseDir='/n/seasasfs01/gcgrid'
  MetDir=$baseDir
  MainDataDir="$baseDir/data/ExtData/HEMCO"
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
    unlink geos
    exit 1
  fi
elif [[ $onOdyssey  == "n" ]]; then
  read -p "Enter path containing met data: " MetDir
  read -p "Enter path to HEMCO data directory: " MainDataDir
else
  echo "Invalid response given"
  unlink CodeDir
  unlink geos
  exit 1
fi

if [[ -d $MetDir && -d $MainDataDir ]]; then
  ln -s $MetDir MetDir
  ln -s $MainDataDir MainDataDir
else
  echo "Could not find target directories"
  unlink CodeDir
  unlink geos
  exit 1
fi

exit 0
