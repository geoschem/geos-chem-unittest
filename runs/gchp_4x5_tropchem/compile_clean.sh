#!/bin/bash
currDir=$PWD
if [[ ! -e CodeDir ]]; then
  echo "First set up a softlink to your code directory named CodeDir, e.g."
  echo " ln -s path/to/code CodeDir"
  exit 1
fi

# Go to the script directory
cd Scripts

# Generate and run a temporary compilation script
./compile_int.sh clean $( readlink -f $currDir/CodeDir ) yes no no

# Check output
if [[ $? -ne 0 ]]; then
  echo "Error in compile script!"
  exit 1
fi

# Return to current directory (no effect)
cd $currDir

exit 0
