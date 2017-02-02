#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: compile_gchp
# 
# !DESCRIPTION: Compiles a GEOS-Chem High Performance (GCHP) directory on Odyssey.
#\\
#\\
# !REMARKS:
#
#  The available partitions (i.e. run queues) are:
#  (1) jacob
#  (2) general 
#  (3) unrestricted 
#  (4) interactive 
#  (5) serial_requeue 
#  (6) bigmem
# 
#  The available options for email notification are:
#  (1) BEGIN : When the job starts
#  (2) END   : When the job finishes
#  (3) FAIL  : If the job dies with an error
#  (4) ALL   : (1), (2), and (3) combined
#
#  Alternative SLURM option keywords:
#  (1) Instead of -n 8    you can also use --ntasks=8
#  (2) Instead of -N 1    you can also use --nodes=1
#  (3) Instead of -t 2880 you can also use --time=2880
#
# !REVISION HISTORY: 
#  05 Dec 2014 - R. Yantosca - Initial version, based on Lu Hu's script
#  16 Jul 2015 - M. Sulprizio- Now use jacob partition by default 
#  12 Aug 2015 - M. Sulprizio- Now set OMP_NUM_THREADS to $SLURM_NTASKS
#EOP
#------------------------------------------------------------------------------
#BOC

# Settings for the SLURM scheduler
#SBATCH -n 1                                # Number of CPUs you are requesting
#SBATCH -N 1                                # Ask for all CPUs on the same node
#SBATCH -t 180                              # Runtime in minutes (minimum: 10)
#SBATCH -p jacob                            # Partition to submit to (see above)
#SBATCH --mem-per-cpu=4000                  # Memory per cpu in MB. 
#SBATCH -o compile.out                      # File where stdout will be written
#SBATCH -e compile.err                      # File where stderr will be written
#SBATCH --mail-type=END                     # Type of email notification
#SBATCH --mail-user=seastham@fas.harvard.edu # Your email address
#SBATCH -J GCHPMAPLCompile                  # Job name

# Now using the customized .bashrc
source ~/GCHP.bashrc

# Show the module list
module list > cmpMods.log 2>&1
which nc-config

compileSource=XXGCHP_SRCXX
compileFolder=$compileSource

# Set the proper # of threads for OpenMP
# SLURM_NTASKS ensures this matches the number you set with -n above
export OMP_NUM_THREADS=$SLURM_NTASKS

# Set the necessary environment variables
export ESMF_COMPILER=intel
#export ESMF_COMM=mvapich2
export ESMF_COMM=$( scripts_compile/whichMPI.sh )

# Move to code directory
cd $compileFolder

# Additional Tau directives
XXTAU_1XX
XXTAU_2XX

# Compiler log
log=compile_gchp_mapl.log

# Remove any prior log files w/ the same name
rm -f $log

# Clean the directory (esp. necessary with possibility of requeue)
make realclean

# Clean MAPL and FV3 only
cd GCHP
make EXTERNAL_GRID=yes DEVEL=yes DEBUG=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no wipeout_fvdycore
make EXTERNAL_GRID=yes DEVEL=yes DEBUG=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no wipeout_mapl
cd ..

# Check CPATH
echo "CPATH is: $CPATH"

if [ -e bin/geos ]
then
   rm bin/geos
fi

# Make WITHOUT RRTMG
make -j${SLURM_NTASKS} NC_DIAG=yes CHEM=XXCHEMXX EXTERNAL_GRID=yes DEVEL=yes DEBUG=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no hpc 2>&1 | tee $log

# Exit normally if bin/geos has been created
if [ -e bin/geos ]
then
   exit 0
else
   exit 1
fi
#EOC
## Actually compile in /scratch
#compileSource=XXGCHP_SRCXX
#mkdir -p /scratch/seastham/temp_compile
#compileFolder=$( mktemp -d --tmpdir='/scratch/seastham/temp_compile' )
#
## Store current location
#baseLoc=$PWD
#
## Copy over the code directory
#rsync -aqh $baseLoc/XXGCHP_SRCXX/ $compileFolder --exclude=compile_script.sh
#
## Move to code directory
#cd $compileFolder
#
## Set the proper # of threads for OpenMP
## SLURM_NTASKS ensures this matches the number you set with -n above
#export OMP_NUM_THREADS=$SLURM_NTASKS
#
## Set the necessary environment variables
#export ESMF_COMPILER=intel
#export ESMF_COMM=mvapich2
#
## Compiler log
#log=compile_gchp_clean.log
#
## Remove any prior log files w/ the same name
#rm -f $log
#
## Clean the directory (esp. necessary with possibility of requeue)
#make realclean
#
## Burn it all.
#cd GCHP
#make EXTERNAL_GRID=yes DEVEL=yes DEBUG=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no wipeout_fvdycore
#make EXTERNAL_GRID=yes DEVEL=yes DEBUG=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no wipeout_mapl
#cd ..
#
## Check CPATH
#echo "CPATH is: $CPATH"
#
## Make WITHOUT RRTMG
#make EXTERNAL_GRID=yes DEVEL=yes DEBUG=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no hpc 2>&1 | tee $log
#
## Copy back into source directory
#rsync -aqh $compileFolder/ $baseLoc/XXGCHP_SRCXX --exclude=compile_script.sh
#
## Exit normally
#exit 0
##EOC
