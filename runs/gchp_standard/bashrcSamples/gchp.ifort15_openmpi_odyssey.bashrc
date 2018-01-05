#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: gchp.ifort15_openmpi_odyssey.bashrc
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the Intel 
#  Fortran Compiler v15 on the Odyssey.rc.fas.harvard.edu cluster using
#  the MPI implementation OpenMPI. You may adapt it for use on your own
#  compute cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source gchp.ifort15_openmpi_odyssey.bashrc  or
#  . gchp.ifort15_openmpi_odyssey.bashrc
#
# !REMARKS
#
# !REVISION HISTORY:
#  26 Oct 2016 - S. Eastham  - Initial version
#  03 Feb 2017 - S. Eastham  - Updated for GCHP v1
#  05 Jan 2018 - E. Lundgren - Initial commit
#  See git commit history for subsequent revisions
#EOP
#------------------------------------------------------------------------------
#BOC

if [[ $- = *i* ]] ; then
  echo "Loading modules for GCHP on Odyssey, please wait ..."
fi

#==============================================================================
# Modules and paths
#==============================================================================

# These modules were defined with the older "module" command but are in the
# process of being renamed during the transition to "lmod".  We still need
# these for the GIGC/ESMF/MPI environment, so load them by their old names.
source new-modules.sh

module purge
module load git

# These are for Intel 15 with OpenMPI
module load intel/15.0.0-fasrc01
module load openmpi/1.10.3-fasrc01
module load zlib/1.2.8-fasrc03
module load hdf5/1.8.12-fasrc12
module load netcdf/4.1.3-fasrc09

# Display loaded modules
module list

#==============================================================================
# Environment variables
#==============================================================================

# MPI environment variables
export ESMF_COMM=openmpi
export MPI_ROOT=$( dirname $( dirname $( which mpirun ) ) )

# Make links to all the relevant files somewhere accessible
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

# NetCDF library paths for GEOS-Chem
export GC_BIN="$NETCDF_HOME/bin"
export GC_INCLUDE="$NETCDF_HOME/include"
export GC_LIB="$NETCDF_HOME/lib"

# Settings for compilers
export FC=ifort                                # Fortran compiler
export COMPILER=$FC                            # Tell GC which compiler to use
export F90=$FC                                 # F90 compiler
export F77=$FC                                 # F77 compiler
export CC=gcc
export CXX=g++
export OMPI_FC=$FC                             # Fortran compiler for MPI
export OMPI_CC=$CC                             # C compiler for MPI
export OMPI_CXX=$CXX                           # C++ compiler for MPI
export OMP_NUM_THREADS=$SLURM_NTASKS           # Default # of threads

# Memory settings
export KMP_STACKSIZE=30g
ulimit -v unlimited              # vmemoryuse
ulimit -l unlimited              # memorylocked
ulimit -u unlimited              # maxproc

# Name of this bashrc file
export BASHRC=gchp.ifort15_openmpi_odyssey.bashrc

# Echo info if it's an interactive session
if [[ $- = *i* ]] ; then
  echo "Done sourcing $BASHRC"
fi

#==============================================================================
# Aliases
#==============================================================================
alias mcs="make compile_standard"    # Recompile GC but not MAPL, ESMF, dycore
alias mco="make cleanup_output"      # Clean run directory before a new run
alias gchprun="sbatch gchp.run"      # Run GCHP (SLURM-specific, edit as needed)
alias tfl="tail --follow gchp.log -n 100"  # Follow log output on screen
