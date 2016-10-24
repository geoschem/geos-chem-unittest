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

BASHRC=GCHP.ifort13.bashrc.odyssey
export ESMF_COMPILER=intel
export ESMF_COMM=openmpi

# WARNING: Code changes are necessary if switching from openmp to mvapich:
#   (1) In CodeDir/GCHP/GIGC.mk, comment out the OpenMPI line (L53) and 
#       uncomment the MVAPICH line (55)
#   (2) In CodeDir/GCHP/Makefile, change “export ESMF_COMM=openmpi” to 
#       “export ESMF_COMM=mvapich2”
# NOTE: eventually these changes will be automatic

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

# Error check
if [[ ! -e CodeDir ]]; then
  echo "First set up a softlink to your code directory named CodeDir, e.g."
  echo " ln -s path/to/code CodeDir"
  exit 1
elif [[ $# == 0 ]]; then
  echo "Must pass argument to compile.sh"
  exit 1
elif [[ ! -f ${BASHRC} ]]; then
  echo "Bashrc file in build.sh does not exist"
  exit 1
fi

# Source the bashrc
source ${runDir}/${BASHRC}

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
    make EXTERNAL_GRID=y DEVEL=y the_nuclear_option
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
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_fvdycore
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_mapl
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
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_fvdycore
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_mapl
    cd ..

# compile_clean
elif [[ $1 == "compile_clean" ]]; then
    make HPC=yes realclean
    cd GCHP
    make EXTERNAL_GRID=y  DEVEL=y  the_nuclear_option
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
    make -j${SLURM_NTASKS} NC_DIAG=y   CHEM=tropchem  EXTERNAL_GRID=y  \
                           DEBUG=y     DEVEL=y        TRACEBACK=y      \
                           MET=geosfp  GRID=4x5       NO_REDUCED=y     \
                           UCX=n       BOUNDS=y       FPEX=y           \
                           EXTERNAL_FORCING=y         hpc
elif [[ $1 == "compile_standard" ]] || \
     [[ $1 == "compile_mapl"     ]] || \
     [[ $1 == "compile_clean"    ]]; then
    make -j${SLURM_NTASKS} NC_DIAG=y   CHEM=tropchem EXTERNAL_GRID=y   \
                           DEBUG=y     DEVEL=y       TRACEBACK=y       \
                           MET=geos-fp GRID=4x5      NO_REDUCED=y      \
                           UCX=n       hpc
fi

###############################
###       Cleanup           ###
###############################
# Change back to the run directory
cd ${runDir}

# Cleanup and quit
if [[ -e ${runDir}/CodeDir/bin/geos ]]; then
   echo '#############################################'
   echo '### GCHP executable compiled succesfully! ###'
   echo '#############################################'
   cp CodeDir/bin/geos .
else
   echo '###################################################'
   echo '### WARNING: GCHP executable does not yet exist ###'
   echo '###################################################'
   unset runDir
fi

unset runDir

exit 0
