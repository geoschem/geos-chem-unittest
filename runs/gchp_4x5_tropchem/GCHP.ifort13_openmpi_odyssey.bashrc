#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: GCHP.ifort13_openmpi_odyssey.bashrc
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the Intel 
#  Fortran Compiler v13 on the Odyssey.rc.fas.harvard.edu cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source GCHP.ifort13_openmpi_odyssey.bashrc or
#  . GCHP.ifort13_openmpi_odyssey.bashrc
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
module load intel/13.0.079-fasrc01 openmpi/1.8.1-fasrc01 netcdf/4.1.3-fasrc01
module load totalview
module list

# Made links to all the relevant files somewhere accessible
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

export CPATH=/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/netcdf/4.1.3-fasrc01/include:/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/hdf5/1.8.12-fasrc03/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/zlib/1.2.8-fasrc02/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/gsl/1.16-fasrc02/include:/n/sw/intel_cluster_studio-2013/composerxe/include/intel64:/n/sw/fasrcsw/apps/Core/nco/4.5.3-fasrc01/include:/n/sw/fasrcsw/apps/Core/antlr/2.7.7-fasrc01/include:/n/sw/fasrcsw/apps/Core/udunits/2.2.18-fasrc01/include

#==============================================================================
# Environment variables
#==============================================================================

# NetCDF paths for GEOS-Chem 
export GC_BIN="$NETCDF_HOME/bin"
export GC_INCLUDE="$NETCDF_INCLUDE"
export GC_LIB="$NETCDF_LIB"

# Add NetCDF to path
export PATH=$PATH:${NETCDF_HOME}/bin

# Compiler environnment settings
export FC=ifort                            # Fortran compiler
export F90=$FC                             # F90 compiler
export F77=$FC                             # F77 compiler
export CC=gcc                              # C compiler
export CXX=g++                             # C++ compiler
export OMPI_FC=$FC                         # Fortran compiler for MPI
export OMPI_CC=$CC                         # C compiler for MPI
export OMPI_CXX=$CXX                       # C++ compiler for MPI
export OMP_NUM_THREADS=$SLURM_NTASKS       # Default # of threads
export OMP_STACKSIZE=500m                  # Stacksize memory for OpenMP
					   
# Max out certain memory limits 	   
ulimit -v unlimited                        # vmemoryuse
ulimit -l unlimited                        # memorylocked
ulimit -u unlimited                        # maxproc

#EOC