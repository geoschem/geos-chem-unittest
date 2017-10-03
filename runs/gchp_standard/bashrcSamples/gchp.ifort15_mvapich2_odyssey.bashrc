#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: gchp.ifort15_mvapich2_odyssey.bashrc
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the Intel 
#  Fortran Compiler v15 on the Odyssey.rc.fas.harvard.edu cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source gchp.ifort15_mvapich2_odyssey.bashrc  or
#  . gchp.ifort15_mvapich2_odyssey.bashrc
#
# !REMARKS
#
# !REVISION HISTORY:
#  26 Oct 2016 - S. Eastham - Initial version
#  03 Feb 2017 - S. Eastham - Updated for GCHP v1
#  See git commit history for subsequent revisions
#EOP
#------------------------------------------------------------------------------
#BOC

#==============================================================================
# Aliases (edit as needed for your system and preferences)
#==============================================================================

alias mcs="make compile_standard"    # Recompile GC but not MAPL, ESMF, dycore
alias mco="make cleanup_output"      # Clean run directory before a new run
alias gchprun="sbatch gchp.run"      # Run GCHP (SLURM-specific, edit as needed)
alias tfl="tail --follow gchp.log -n 100"  # Follow log output on screen
alias checkgit="make printbuildinfo" # Show current code git info
alias checkbuild="cat lastbuild"     # Show build code git info

#==============================================================================
# Modules and paths
#==============================================================================

# Echo info if it's an interactive session
if [[ $- = *i* ]] ; then
  echo "Loading modules for GCHP on Odyssey, please wait ..."
fi

# These modules were defined with the older "module" command but are in the
# process of being renamed during the transition to "lmod".  We still need
# these for the GIGC/ESMF/MPI environment, so load them by their old names.
module purge
module load git

# These are for Intel 15 on Odyssey with MVAPICH2 (10/18/2016)
module load intel/15.0.0-fasrc01
module load mvapich2/2.3b-fasrc01
module load netcdf/4.1.3-fasrc09
# NOTE: this automatically loads the following
# zlib/1.2.8-fasrc07
# hdf5/1.8.12-fasrc12

# Display loaded modules if it's an interactive session
if [[ $- = *i* ]] ; then
  module list
fi

export ESMF_COMM=mvapich2
export MPI_ROOT=$( dirname $( dirname $( which mpirun ) ) )

# Made links to all the relevant files somewhere accessible
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

#export CPATH=/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/netcdf/4.1.3-fasrc01/include:/n/sw/fasrcsw/apps/MPI/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/hdf5/1.8.12-fasrc03/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/zlib/1.2.8-fasrc02/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/openmpi/1.8.1-fasrc01/include:/n/sw/fasrcsw/apps/Comp/intel/13.0.079-fasrc01/gsl/1.16-fasrc02/include:/n/sw/intel_cluster_studio-2013/composerxe/include/intel64:/n/sw/fasrcsw/apps/Core/nco/4.5.3-fasrc01/include:/n/sw/fasrcsw/apps/Core/antlr/2.7.7-fasrc01/include:/n/sw/fasrcsw/apps/Core/udunits/2.2.18-fasrc01/include

#==============================================================================
# Environment variables
#==============================================================================

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

# Max out the stack memory
# OMP_STACKSIZE works with all compilers; KMP_STACKSIZE works only w/ Intel
#export KMP_STACKSIZE=5000000000000000000                 # Kludge for OpenMP
# Had to increase this - global 0.25x0.3125 is quite demanding
# Actual maximum
#export KMP_STACKSIZE=9223372036854775807
#export KMP_STACKSIZE=9000000000000000000
# WARNING: Setting it too large can ALSO cause problems!
export KMP_STACKSIZE=30g

# NEW
ulimit -v unlimited              # vmemoryuse
ulimit -l unlimited              # memorylocked
ulimit -u unlimited              # maxproc

# Name of this bashrc file
export BASHRC=gchp.ifort15_mvapich2_odyssey.bashrc

# Echo info if it's an interactive session
if [[ $- = *i* ]] ; then
  echo "Done sourcing $BASHRC"
fi
