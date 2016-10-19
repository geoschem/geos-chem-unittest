#!/bin/bash
# Determine which version of MPI is being used
iMPI=$( which mpirun )
if [[ $iMPI == *"mvapich2"* ]]; then
  echo "mvapich2"
elif [[ $iMPI == *"openmpi"* ]]; then
  echo "openmpi"
else
  echo ""
fi
