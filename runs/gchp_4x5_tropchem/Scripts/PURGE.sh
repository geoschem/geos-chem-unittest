#!/bin/bash
currDir=$PWD

cd ..
if [[ ! -e CodeDir ]]; then
  echo "First set up a softlink to your code directory named CodeDir, e.g."
  echo " ln -s path/to/code CodeDir"
  exit 1
fi
cd $currDir

# Generate and run a temporary compilation script
./compile_int.sh purge $( readlink -f $currDir/CodeDir ) yes no no

# Check output
if [[ $? -ne 0 ]]; then
  echo "Error in compile script!"
  exit 1
fi

exit 0
