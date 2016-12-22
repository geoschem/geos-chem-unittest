#!/bin/bash

#SBATCH -c 8
#SBATCH -N 1
#SBATCH -t 04:00:00
#SBATCH -p QUEUE_NAME
#SBATCH -w NODE_NAME
#SBATCH --mem=8000
#SBATCH --mail-type=ALL
#SBATCH --mail-user=YOUR_EMAIL_ADDRESS
#SBATCH -o ./doTimeTest.log.%j
#SBATCH -e ./doTimeTest.log.%j

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: doTimeTest.slurm
#
# !DESCRIPTION: This bash script submits the GEOS-Chem timing test
#  to a computational queue using the SLURM scheduler.
#\\
#\\
# !REMARKS:
#  The SBATCH tags at the top of the file request computational resources
#  for this job via the SLURM scheduler:
#
#    -c 8             : Use 8 CPUs
#    -N 1             : Use a single node
#    -p QUEUE_NAME    : Specify the run queue in which you want to run the test
#    -w NODE_NAME     : (Optional) Use a specific node of the cluster
#    --mem=8000       : Use 8 GB total memory for the test
#    --mail-type=ALL  : Get an email when the test starts, stops, or fails
#    --mail-user=___  : Send email notifications to this address
#    -o FILENAME      : Send stdout output to this log
#    -e FILENAME      : Send stderr output to this log
#
#  You will have to specify the queue & node names for your system, as well
#  as your email address.  Everything else may be left "as-is".
#
# !REVISION HISTORY:
#  23 Nov 2015 - R. Yantosca - Initial version
#  16 Dec 2016 - R. Yantosca - Now use SLURM tag -c instead of -n
#EOP
#------------------------------------------------------------------------------
#BOC

# Set OMP num threads properly
if [[ "x$SLURM_CPUS_PER_TASK" != x ]]; then
  export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
fi

# Run GEOS-Chem (timing output goes to stderr)
# NOTE: Using srun will tell SLURM that only this part 
# of the script should use multiple CPUs (bmy, 12/22/16)
srun -c $OMP_NUM_THREADS time -p ./geos.mp

# Echo info from computational cores to log file for displaying results
nodeName=`uname -n`
echo "# of CPUs : $OMP_NUM_THREADS"
echo "NodeName : $nodeName"
grep "vendor_id"  /proc/cpuinfo
grep "model name" /proc/cpuinfo
grep "cpu MHz"    /proc/cpuinfo

# Undefine variables
unset nodeName

# Exit normally
exit 0
#EOC
