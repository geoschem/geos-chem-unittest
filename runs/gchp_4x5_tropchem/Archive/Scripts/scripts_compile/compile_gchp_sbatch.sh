#NETCDF=yes NC_DIAG=yes !/bin/bash

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
#SBATCH -n 4                                # Number of CPUs you are requesting
#SBATCH -N 1                                # Ask for all CPUs on the same node
#SBATCH -t 180                              # Runtime in minutes (minimum: 10)
#SBATCH -p jacob                            # Partition to submit to (see above)
#SBATCH --mem-per-cpu=4000                  # Memory per cpu in MB. 
#SBATCH -o compile.out                      # File where stdout will be written
#SBATCH -e compile.err                      # File where stderr will be written
#SBATCH --mail-type=END                     # Type of email notification
#SBATCH --mail-user=seastham@fas.harvard.edu # Your email address
#SBATCH -J GCHPCleanCompile                 # Job name

# Now using the customized .bashrc
source ~/GCHP.bashrc

# Show the module list
module list
which nc-config
which nf-config

# Actually compile in /scratch
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

# Ensure that optimization is enabled (g->debug)
export ESMF_BOPT=O

## Clean the directory (esp. necessary with possibility of requeue)
#make HPC=yes realclean

# Check CPATH
echo "CPATH is: $CPATH"

if [ -e bin/geos ]
then
   rm bin/geos
fi

# Make WITHOUT RRTMG
make -j${SLURM_NTASKS} NC_DIAG=yes CHEM=XXCHEMXX EXTERNAL_GRID=yes DEBUG=yes DEVEL=yes TRACEBACK=yes MET=geos-fp GRID=4x5 NO_REDUCED=yes UCX=no hpc 2>&1 | tee ~/GCHP/outErr.log

# Exit normally if bin/geos has been created
if [ -e bin/geos ]
then
   exit 0
else
   exit 1
fi

#EOC
