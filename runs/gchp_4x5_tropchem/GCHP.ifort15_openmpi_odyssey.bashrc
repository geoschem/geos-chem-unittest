#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: GCHP.ifort15_openmpi_odyssey.bashrc
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the Intel 
#  Fortran Compiler v15 on the odyssey.rc.fas.harvard.edu cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source GCHP.ifort15_openmpi_odyssey.bashrc  or
#  . GCHP.ifort15_openmpi_odyssey.bashrc
#
# !REMARKS
#  To run GCHP with OpenMPI, you must have the following updates:
#    (1) In GCHP/GIGC.mk, the OpenMPI lines for setting MPI_LIB are
#        uncommented and the MVAPICH line are commented out
#    (2) In GCHP/Makefile, "export ESMF_COMM=openmpi" is uncommented
#        and "export ESMF_COMM=mvapich2" is commented out
#    (3) In build.sh within the run directory, BASHRC is set to a
#        bashrc that includes "openmpi" in the filename (such as this)
#        and the ESMF_COMM export is set to openmpi
#
# !REVISION HISTORY:
#  06 Jan 2015 - R. Yantosca - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# Source systemwide global definitions from /etc/bashrc
if [[ -f /etc/bashrc ]]; then
 . /etc/bashrc
fi

#==============================================================================
# Modules and paths
#==============================================================================

# Load modules
export LMOD_COLORIZE=yes
source new-modules.sh 
module purge
module load git
module load intel
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

# NetCDF paths for GEOS-Chem
export GC_BIN="$NETCDF_HOME/bin"
export GC_INCLUDE="$NETCDF_INCLUDE"
export GC_LIB="$NETCDF_LIB"

# NetCDF Fortran paths for GEOS-Chem 
# (These are in a separate path from the netCDF-C libraries)
export GC_F_BIN="$NETCDF_FORTRAN_HOME/bin"
export GC_F_INCLUDE="$NETCDF_FORTRAN_INCLUDE"
export GC_F_LIB="$NETCDF_FORTRAN_LIB"

# Add NetCDF to path
export PATH=$PATH:${NETCDF_HOME}/bin

# Compiler environnment settings
export FC=ifort                            # Fortran compiler
export F90=$FC                             # F90 compiler
export F77=$FC                             # F77 compiler
export CC=icc                              # C compiler
export CXX=icpc                            # C++ compiler
export OMPI_FC=$FC                         # Fortran compiler for MPI
export OMPI_CC=$CC                         # C compiler for MPI
export OMPI_CXX=$CXX                       # C++ compiler for MPI
export OMP_NUM_THREADS=$SLURM_NTASKS       # Default # of threads
export OMP_STACKSIZE=500m                  # Stacksize mem for OpenMP

# Max out certain memory limits
ulimit -v unlimited                        # vmemoryuse
ulimit -l unlimited                        # memorylocked
ulimit -u unlimited                        # maxproc

#EOC