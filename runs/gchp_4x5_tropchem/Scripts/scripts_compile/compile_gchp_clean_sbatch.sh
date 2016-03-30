#!/bin/bash
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
#which nf-config

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

# Try this out..
#export ESMF_CPP=icc

# Additional Tau directives
XXTAU_1XX
XXTAU_2XX

# Ensure that optimization is enabled (g->debug)
export ESMF_BOPT=O

# Clean the directory (esp. necessary with possibility of requeue)
make HPC=yes realclean

# Burn it all.
cd GCHP
make EXTERNAL_GRID=yes DEVEL=yes the_nuclear_option
cd ..

# Check CPATH
echo "CPATH is: $CPATH"

# Remove bin/geos, if it exists
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
