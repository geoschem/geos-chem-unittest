#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: GCHP.ifort13.bashrc.glooscap
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the Intel 
#  Fortran Compiler v13 on the glooscap.ace-net.ca cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source GCHP.ifort13.bashrc.glooscap  or
#  . GCHP.ifort13.bashrc.glooscap
#
# !REMARKS
#  To run GCHP with MVAPICH2, you must have the following updates:
#    (1) In GCHP/GIGC.mk, the OpenMPI lines for setting MPI_LIB are
#        uncommented out and the MVAPICH line are commented out
#    (2) In GCHP/Makefile, "export ESMF_COMM=openmpi" is uncommented
#        and "export ESMF_COMM=mvapich2" are commented out
#    (3) In build.sh within the run directory, BASHRC is set to a
#        bashrc that includes "openmpi" in the filename (such as this)
#        and the ESMF_COMM export is set to openmpi
#
# !REVISION HISTORY:
#  Use the "gitk" browser to view the version history!
#EOP
#------------------------------------------------------------------------------
#BOC

# Load default ACEnet cluster profile
if [ -f /usr/local/lib/bashrc ]; then
  source /usr/local/lib/bashrc
fi

#==============================================================================
# Modules and paths
#==============================================================================
module purge
module load intel/13.0.0.079 openmpi/intel/1.8.1 netcdf/intel/4.1.3  
module load git
module load totalview
module list

# MPI settings
export ESMF_COMM=openmpi
export MPI_ROOT=$( dirname $( dirname $( which mpirun ) ) )

# NetCDF library paths for GEOS-Chem
export GC_BIN="$NETCDF/bin"
export GC_LIB="$NETCDF/lib"
export GC_INCLUDE="$NETCDF/include"

#==============================================================================
# %%%%% Settings for programming languages and applications %%%%%
#==============================================================================

# Settings for compilers
export FC=ifort              # Fortran compiler
export CC=icc                # C compiler
export CXX=icpc              # C++ compiler
export COMPILER=$FC          # Tells GEOS-Chem which compiler to use
export OMPI_FC=$FC           # Tells OpenMPI which Fortran compiler to use
export OMPI_CC=$CC           # Tells OpenMPI which C compiler to use
export OMPI_CXX=$CXX         # Tells OpenMPI which C++ compiler to use

# Max out the stack memory for OpenMP
# OMP_STACKSIZE works with all compilers; KMP_STACKSIZE works only w/ Intel
export OMP_STACKSIZE=500m
 
