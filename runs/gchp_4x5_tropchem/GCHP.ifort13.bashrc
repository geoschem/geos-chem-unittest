# These modules were defined with the older "module" command but are in the
# process of being renamed during the transition to "lmod".  We still need
# these for the GIGC/ESMF/MPI environment, so load them by their old names.
module purge
module load git ncview nco

# These are for Intel 13 on Odyssey (03/30/2016)
module load intel/13.0.079-fasrc01
module load openmpi/1.8.1-fasrc01
module load zlib/1.2.8-fasrc02
module load hdf5/1.8.12-fasrc03
module load netcdf/4.1.3-fasrc01
module load totalview

# Made links to all the relevant files somewhere accessible
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

export CPATH=/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/netcdf/4.1.3-fasrc01/include:/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/hdf5/1.8.12-fasrc03/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/zlib/1.2.8-fasrc02/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/gsl/1.16-fasrc02/include:/n/sw/intel_cluster_studio-2013/composerxe/include/intel64:/n/sw/fasrcsw/apps/Core/nco/4.5.3-fasrc01/include:/n/sw/fasrcsw/apps/Core/antlr/2.7.7-fasrc01/include:/n/sw/fasrcsw/apps/Core/udunits/2.2.18-fasrc01/include


#==============================================================================
# Environment variables
#==============================================================================

# Directory paths
export GC_BIN="$NETCDF_HOME/bin"
export GC_INCLUDE="$NETCDF_HOME/include"
export GC_LIB="$NETCDF_HOME/lib"

# Add NetCDF to path
export PATH=$PATH:${NETCDF_HOME}/bin

# Compiler environnment settings
export FC=ifort                                # Fortran compiler
export F90=$FC                                 # F90 compiler
export F77=$FC                                 # F77 compiler
export CC=gcc
export CXX=g++
export OMPI_FC=$FC                             # Fortran compiler for MPI
export OMPI_CC=$CC                             # C compiler for MPI
export OMPI_CXX=$CXX                           # C++ compiler for MPI
export OMP_NUM_THREADS=$SLURM_NTASKS           # Default # of threads
# Had to increase this - global 0.25x0.3125 is quite demanding
export KMP_STACKSIZE=50000000000                 # Kludge for OpenMP

# NEW
ulimit -v unlimited              # vmemoryuse
ulimit -l unlimited              # memorylocked
ulimit -u unlimited              # maxproc
