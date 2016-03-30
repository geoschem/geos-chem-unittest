#!/bin/bash
# First time setup script - run only once!

if [[ -L CodeDir || -L geos || -L MainDataDir || -L MetDir || -L ExtraDataDir ]] ; then
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
  ExtraDataDir="/n/home03/cakelle2/data"
elif [[ $onOdyssey  == "n" ]]; then
  read -p "Enter path containing met data: " MetDir
  read -p "Enter path to HEMCO data directory: " MainDataDir
  read -p "Enter path to extra data: " ExtraDataDir
else
  echo "Invalid response given"
  unlink CodeDir
  unlink geos
  exit 1
fi

if [[ -d $MetDir && -d $MainDataDir && -d $ExtraDataDir ]]; then
  ln -s $MetDir MetDir
  ln -s $MainDataDir MainDataDir
  ln -s $ExtraDataDir ExtraDataDir
else
  echo "Could not find target directories"
  unlink CodeDir
  unlink geos
  exit 1
fi

exit 0
