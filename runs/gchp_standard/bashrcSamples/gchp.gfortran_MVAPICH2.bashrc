#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: gchp.gfortran_mvapich2_odyssey.bashrc
#
# !DESCRIPTION: Use this .bashrc to compile and run GCHP with the GNU 
#  Fortran Compiler v5.2.0 on the Odyssey.rc.fas.harvard.edu cluster.
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
#  31 May 2017 - S. Eastham - Converted for gfortran
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

module load gcc/5.2.0-fasrc01
module load mvapich2/2.2a-fasrc01
module load netcdf/4.3.3.1-fasrc02
module load netcdf-fortran/4.4.2-fasrc01

export ESMF_COMM=mvapich2
export MPI_ROOT=$( dirname $( dirname $( which mpirun ) ) )

# Display loaded modules if it's an interactive session
if [[ $- = *i* ]] ; then
  module list
fi

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

# Made links to all the relevant files somewhere accessible
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib
export PATH=${NETCDF_FORTRAN_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_FORTRAN_HOME}/lib

# Compiler environnment settings
export FC=gfortran                             # Fortran compiler
export F90=$FC                                 # F90 compiler
export F77=$FC                                 # F77 compiler
export CC=gcc
export CXX=g++
#export OMPI_FC=$FC                             # Fortran compiler for MPI
#export OMPI_CC=$CC                             # C compiler for MPI
#export OMPI_CXX=$CXX                           # C++ compiler for MPI
MAX_CPUS=$SLURM_NTASKS
if [[ $MAX_CPUS == 1 ]]; then
   ALT_CPUS=$SLURM_CPUS_PER_TASK
   if [[ $ALT_CPUS -gt $MAX_CPUS ]]; then
      MAX_CPUS=$ALT_CPUS
   fi
fi
export OMP_NUM_THREADS=$MAX_CPUS               # Default # of threads
# 60g worked for a while but the key is to prevent it from being too small or too big
# Just set to 5g for now. Should probably be equal to (total mem / # threads)
export OMP_STACKSIZE=5g
export KMP_STACKSIZE=$OMP_STACKSIZE

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
