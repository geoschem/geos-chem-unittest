# These modules were defined with the older "module" command but are in the
# process of being renamed during the transition to "lmod".  We still need
# these for the GIGC/ESMF/MPI environment, so load them by their old names.
module purge
module load git

# Now try "generic" installs
module load intel

# New installations from Paul Eadmon (2015-12-18)
module load openmpi/1.10.1-fasrc01
module load hdf5/1.8.16-fasrc01
module load netcdf/4.3.3.1-fasrc02
module load netcdf-fortran/4.4.2-fasrc01

module load totalview

# Made links to all the relevant files somewhere accessible
export NETCDF_HOME=/n/regal/jacob_lab/seastham/NCLinks
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

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
export CC=icc
export CXX=icpc
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
