#!/bin/bash
# Compiles interactively

if [[ -z $SLURM_NTASKS ]]; then
  echo "Must be run on a SLURM compute node. Exiting."
  exit 1
fi

compileType=$1
compileFolder=$2
sendEmail="no"
debugCompile=$4
useTau="no"

if [ "$compileType" = "help" ]
then
    echo "Typical compile commands:"
    echo "  Clean compile, no debug: ./compile_int.sh clean path/to/code yes no"
    exit 100
elif [ "$compileType" = "clean" ]
then
    targFile="compile_gchp_clean_sbatch.sh"
elif [ "$compileType" = "mapl" ]
then
    targFile="compile_gchp_mapl_sbatch.sh"
elif [ "$compileType" = "standard" ]
then
    targFile="compile_gchp_sbatch.sh"
elif [ "$compileType" = "purge" ]
then
    targFile="purge_gchp_sbatch.sh"
elif [ "$compileType" = "fast" ]
then
    targFile="compile_gchp_fast_sbatch.sh"
elif [ "$compileType" = "debug" ]
then
    targFile="compile_gchp_debug_sbatch.sh"
else
    echo "Bad compile type (argument 1) - must be 'clean', 'fast', 'mapl', 'debug', 'purge' or 'standard'. Aborting"
    exit 1;
fi

if [ "$sendEmail" = "yes" ]
then
    mailArg="END"
else
    mailArg=""
fi

targFull="scripts_compile/$targFile"

# Does the compile script exist?
if [ ! -f "$targFull" ]
then
    echo "Could not find compile script $targFile. Aborting"
    exit 2;
fi

# Does the compile directory exist?
if [ ! -d "$compileFolder" ]
then
    echo "Could not find code directory $compileFolder. Aborting"
    exit 3;
fi

# Follow the link..
compileFolder=$( readlink -f $compileFolder )

# Remove old compiler scripts, if any exist
if ls tempCompile* 1> /dev/null 2>&1; then
    rm tempCompile*
fi

# Generate temporary compiler script
tName=$( mktemp --tmpdir=$PWD tempCompile.XXXXXX.sh )
cp $targFull $tName

sed -i -e "s!XXGCHP_SRCXX!$compileFolder!g" $tName

if [ "$useTau" = "yes" ]; then
    echo "Compiling with Tau profiler enabled"
    sed -i -e "s!XXTAU_1XX!export ESMF_SITE=tau!g" $tName
    sed -i -e "s!XXTAU_2XX!export TAU_OPTIONS='-optPreProcess -optCPP=gcc -optCPPReset=-E -optRevert -optKeepFiles'!g" $tName
else
    echo "Compiling without Tau profiler"
    sed -i -e "s!XXTAU_1XX!!g" $tName
    sed -i -e "s!XXTAU_2XX!!g" $tName
fi

# Assume tropchem for now
sed -i -e "s!XXCHEMXX!tropchem!g" $tName

# Pass the number of CPUs
sed -i -e "s!XXNCPUSXX!${SLURM_NTASKS}!g" $tName

if [[ $debugCompile != "debug" ]]; then
    sed -i -e "s!DEBUG=yes !!g" $tName
fi

# Don't bother sourcing the environment if not necessary
nc-config --version 1> /dev/null 2> /dev/null
if [[ $? -eq 0 ]]; then
    sed -i -e "s!source ~/GCHP.bashrc!!g" $tName
fi
#sbatch --mail-type=$mailArg $tName
chmod +x $tName

$tName
exitStatus=$?
rm $tName

exit $exitStatus;
