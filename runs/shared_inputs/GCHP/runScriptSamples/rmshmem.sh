#!/bin/bash
# Script to remove shared memory segments. This should be used before and
# after running GCHP if the shared memory option is turned on (USE_SHMEM: 1 in
# CAP.rc). This is done automatically in the example slurm run script.

segments=$( ipcs -m | grep '^0x' | awk '{print $1}' )
owners=$( ipcs -m | grep '^0x' | awk '{print $3}' | uniq )
echo $owners

if [[ -z $segments ]]
then
    echo "No shared memory segments to remove."
else
    echo "Removing segments..."
    for seg in $segments
    do
       echo "Removing segment $seg"
       ipcrm -M $seg
       if [[ ! $? ]]
       then
          echo "Unable to remove segments owned by $owners"
       fi
    done
fi

