#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: build.sh
# 
# !DESCRIPTION: Cleans and/or compiles a GEOS-Chem High Performance (GCHP) 
#  source code. Accepts one keyword argument indicating combination of clean 
#  and compile settings. 
#\\
#\\
# !REMARKS:
#  (1) Implemented arguments options include:
#         help (lists options)
#         clean_gc
#         clean_nuclear
#         clean_all
#         clean_mapl
#         compile_debug
#         compile_standard
#         compile_mapl
#         compile_clean
#  (2) To add a new one simply add an 'elif' block in the clean section
#      and/or the compile section.
#
# !REVISION HISTORY: 
#  19 Oct 2016 - E. Lundgren - Initial version
#  Navigate to your unit tester directory and type 'gitk' at the prompt
#  to browse the revision history.
#EOP
#------------------------------------------------------------------------------
#BOC

###############################
###  Configurable Settings  ###
###############################
# Ask user to source and export a bashrc, if not already done
if [[ "x${MPI_ROOT}" == x ]]; then
   echo "Source your environment settings before continuing. See the bashrcSamples subdirectory for examples."
else 
   echo "MPI_ROOT is set to ${MPI_ROOT}"
fi

# Check MPI implementation
if [[ "x${ESMF_COMM}" == x ]]; then
   echo "ESMF_COMM and MPI_ROOT must both be set!"
   exit 2
fi

# Set compilers. ESMF_COMPILER controls GCHP, and COMPILER controls the GC module.
if [[ "$FC" == "ifort" ]]; then
   export ESMF_COMPILER=intel
   export COMPILER=ifort
elif [[ "$FC" == "gfortran" ]]; then
   export ESMF_COMPILER=gfortran
   export COMPILER=gfortran
else
   echo "Command FC=$FC did not give a compiler recognized by/compatible with GCHP"
   exit 3
fi

# Set ESMF optimization (g=debugging, O=optimized)
export ESMF_BOPT=O

###############################
###       Help              ###
###############################
if [[ $1 == "help" ]]; then
  echo "Script name:"
  echo "   build.sh"
  echo "Arguments:"
  echo "   Accepts single argument indicating clean and/or compile settings."
  echo "   Currently implemented arguments include:"
  echo "      clean_gc         - classic only"
  echo "      clean_nuclear    - GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "      clean_all        - classic, GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "      clean_mapl       - mapl and fvdycore only"
  echo "      compile_debug    - turns on debug flags, no cleaning"
  echo "      compile_standard - no cleaning"
  echo "      compile_mapl     - includes fvdycore"
  echo "      compile_clean    - cleans and compiles everything (be careful!)"
  echo "Example usage:"
  echo "   ./build.sh compile_standard"
  exit 0
fi

###############################
###     General Setup       ###
###############################

# Set run directory
runDir=$PWD

# Designed for full chemistry
UCX=yes
CHEM=Standard

# Error check
if [[ ! -e CodeDir ]]; then
  echo "First set up a softlink to your source code directory named CodeDir."
  echo "You may use the setCodeDir function for this, e.g."
  echo "   ./setCodeDir /path/to/your/code"
  exit 1
elif [[ $# == 0 ]]; then
  echo "Must pass argument to compile.sh"
  exit 1
fi

# Go to the source code directory
cd ${runDir}/CodeDir

###############################
###       Clean             ###
###############################

# clean_gc
if [[ $1 == "clean_gc" ]]; then
    make HPC=yes realclean

# clean_nuclear
elif [[ $1 == "clean_nuclear" ]]; then
    cd GCHP
    make EXTERNAL_GRID=y the_nuclear_option
    cd ..

# clean_all
elif [[ $1 == "clean_all" ]]; then
    make HPC=yes realclean
    cd GCHP
    make the_nuclear_option
    cd ..

# clean_mapl
elif [[ $1 == "clean_mapl" ]]; then
    make realclean
    cd GCHP
    make EXTERNAL_GRID=y  DEBUG=y   GRID=4x5      MET=geos-fp      \
         NO_REDUCED=y     UCX=$UCX  wipeout_fvdycore
    make EXTERNAL_GRID=y  DEBUG=y   GRID=4x5      MET=geos-fp      \
         NO_REDUCED=y     UCX=$UCX  wipeout_mapl
    cd ..

# compile_debug
elif [[ $1 == "compile_debug" ]]; then
    cd GCHP
    make clean
    cd ..

# compile_standard
elif [[ $1 == "compile_standard" ]]; then
    cd GCHP
    make clean
    cd ..

# compile_mapl
elif [[ $1 == "compile_mapl" ]]; then
    make realclean
    cd GCHP
    make EXTERNAL_GRID=y  DEBUG=y   GRID=4x5  MET=geos-fp      \
         NO_REDUCED=y  UCX=$UCX     wipeout_fvdycore
    make EXTERNAL_GRID=y  DEBUG=y   GRID=4x5  MET=geos-fp      \
         NO_REDUCED=y  UCX=$UCX     wipeout_mapl
    cd ..

# compile_clean
elif [[ $1 == "compile_clean" ]]; then
    make HPC=yes realclean
    cd GCHP
    make EXTERNAL_GRID=y  the_nuclear_option
    cd ..

else
  echo "Argument passed to util.sh is not defined"
  echo "Defined options include:"
  echo "   clean_gc         - classic only"
  echo "   clean_nuclear    - GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "   clean_all        - classic, GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "   clean_mapl       - mapl and fvdycore only"
  echo "   compile_debug    - turns on debug flags, no cleaning"
  echo "   compile_standard - no cleaning"
  echo "   compile_mapl     - includes fvdycore"
  echo "   compile_clean    - cleans and compiles everything (be careful!)"
  exit 1
fi
 # Remove executable, if it exists
rm -f ${runDir}/CodeDir/bin/geos

# Check CPATH
echo "CPATH is: $CPATH"

###############################
###       Compile           ###
###############################
if [[ $1 == "compile_debug" ]]; then
    make -j${SLURM_NTASKS} NC_DIAG=y   CHEM=$CHEM     EXTERNAL_GRID=y  \
                           DEBUG=y     TRACEBACK=y    MET=geosfp       \
                           GRID=4x5    NO_REDUCED=y   UCX=$UCX         \
                           BOUNDS=y    FPEX=y         EXTERNAL_FORCING=y  hpc
elif [[ $1 == "compile_standard" ]] || \
     [[ $1 == "compile_mapl"     ]] || \
     [[ $1 == "compile_clean"    ]]; then
    make -j${SLURM_NTASKS} NC_DIAG=y   CHEM=$CHEM    EXTERNAL_GRID=y   \
                           DEBUG=n     TRACEBACK=y   MET=geos-fp       \
                           GRID=4x5    NO_REDUCED=y  UCX=$UCX    hpc
fi

###############################
###       Cleanup           ###
###############################
# Change back to the run directory
cd ${runDir}

# Cleanup and quit
if [[ -e ${runDir}/CodeDir/bin/geos ]]; then
   echo '###################################'
   echo '### GCHP compiled successfully! ###'
   echo '###################################'
   cp CodeDir/bin/geos .
else
   echo '###################################################'
   echo '### WARNING: GCHP executable does not yet exist ###'
   echo '###################################################'
   unset runDir
fi

unset runDir

exit 0
