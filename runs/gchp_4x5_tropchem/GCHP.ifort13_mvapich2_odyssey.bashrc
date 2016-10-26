#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: GCHP.ifort13_mvapich2_odyssey.bashrc
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the Intel 
#  Fortran Compiler v13 on the Odyssey.rc.fas.harvard.edu cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source GCHP.ifort13_mvapich2_odyssey.bashrc  or
#  . GCHP.ifort13_mvapich2_odyssey.bashrc
#
# !REMARKS
#  To run GCHP with MVAPICH2, you must have the following updates:
#    (1) In GCHP/GIGC.mk, the OpenMPI lines for setting MPI_LIB are
#        commented out and the MVAPICH line is uncommented
#    (2) In GCHP/Makefile, "export ESMF_COMM=openmpi" is commented out
#        and "export ESMF_COMM=mvapich2" is uncommented
#    (3) In build.sh within the run directory, BASHRC is set to a
#        bashrc that includes "mvapich2" in the filename (such as this)
#        and the ESMF_COMM export is set to mvapich2
#
# !REVISION HISTORY:
#  26 Oct 2016 - S. Eastham - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# These modules were defined with the older "module" command but are in the
# process of being renamed during the transition to "lmod".  We still need
# these for the GIGC/ESMF/MPI environment, so load them by their old names.
module purge

# These are for Intel 13 on Odyssey with MVAPICH2 (10/18/2016)
module load intel/13.0.079-fasrc01
module load mvapich2/2.2-fasrc01
module load zlib/1.2.8-fasrc07
module load szip/2.1-fasrc02
module load hdf5/1.8.17-fasrc01
module load netcdf/4.4.0-fasrc02
module load netcdf-fortran/4.4.4-fasrc02
module load git/2.1.0-fasrc01
#module load totalview

export MVAPICH2=$( dirname $( dirname $( which mpirun ) ) )

# Made links to all the relevant files somewhere accessible
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

#export CPATH=/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/netcdf/4.1.3-fasrc01/include:/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/hdf5/1.8.12-fasrc03/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/zlib/1.2.8-fasrc02/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/gsl/1.16-fasrc02/include:/n/sw/intel_cluster_studio-2013/composerxe/include/intel64:/n/sw/fasrcsw/apps/Core/nco/4.5.3-fasrc01/include:/n/sw/fasrcsw/apps/Core/antlr/2.7.7-fasrc01/include:/n/sw/fasrcsw/apps/Core/udunits/2.2.18-fasrc01/include


#==============================================================================
# Environment variables
#==============================================================================

# Directory paths
export GC_BIN="$NETCDF_HOME/bin"
export GC_INCLUDE="$NETCDF_HOME/include"
export GC_LIB="$NETCDF_HOME/lib"
export GC_F_BIN="$NETCDF_FORTRAN_HOME/bin"
export GC_F_INCLUDE="$NETCDF_FORTRAN_HOME/include"
export GC_F_LIB="$NETCDF_FORTRAN_HOME/lib"

# Add NetCDF to path
export PATH=$PATH:${NETCDF_HOME}/bin
export PATH=$PATH:${NETCDF_HOME}/bin:${NETCDF_FORTRAN_HOME}/bin

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
#export KMP_STACKSIZE=5000000000000000000                 # Kludge for OpenMP
# Actual maximum
#export KMP_STACKSIZE=9223372036854775807
#export KMP_STACKSIZE=9000000000000000000
# WARNING: Setting it too large can ALSO cause problems!
export KMP_STACKSIZE=30g

# NEW
ulimit -v unlimited              # vmemoryuse
ulimit -l unlimited              # memorylocked
ulimit -u unlimited              # maxproc
