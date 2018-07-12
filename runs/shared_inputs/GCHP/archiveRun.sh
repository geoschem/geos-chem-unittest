#!/bin/bash

# Script to archive files after a run. The output data (OutputDir/*.nc4) is moved 
# but everything else is copied, including log files (*.log, slurm-*), config files
# (*.rc, input.geos), run files (*.run, *.bashrc, runConfig.sh), and restarts 
# (only gcchem*). Files are stored in subdirectories.
#
# Clean the run directory after archiving with 'make cleanup_output' prior to
# rerunning and archiving a new set of run outputs. Otherwise previous run files
# will be copied to new run archives.

# Initial version: Lizzie Lundgren - 7/12/2018

printf "Enter archive directory name (ok if non-existent):\n"
read dirname
archivedir=${dirname}
if [ -d "${archivedir}" ]; then
   printf "Warning: Directory ${archivedir} already exists.\nRemove or rename that directory, or choose a different name.\n"
   exit 1
else
   mkdir -p ${archivedir}
   mkdir -p ${archivedir}/data
   mkdir -p ${archivedir}/build
   mkdir -p ${archivedir}/logs
   mkdir -p ${archivedir}/run
   mkdir -p ${archivedir}/config
   mkdir -p ${archivedir}/restarts
fi

numfiles=$(ls -l OutputDir/*.nc4 | wc -l)
if [ "$numfiles" -eq "0" ]; then
   printf "Warning: No netcdf files in OutputDir to move. Exiting.\n"
   exit 1
else
   mv OutputDir/*.nc4 ${archivedir}/data
fi
cp -t ${archivedir}/run *.run *.bashrc runConfig.sh *multirun.sh
cp -t ${archivedir}/logs *.log slurm-*
cp -t ${archivedir}/build lastbuild compile.log
cp -t ${archivedir}/config *.rc input.geos
cp -t ${archivedir}/restarts gcchem_* *restart*
printf "Archiving in ${archivedir} complete.\n"

exit 0
