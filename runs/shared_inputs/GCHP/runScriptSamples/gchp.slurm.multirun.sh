#!/bin/bash

# Initial version: Lizzie Lundgren, 7/12/2018

# Use this bash script to submit multiple consecutive GCHP jobs to SLURM. 
# This allows breaking up long duration simulations into jobs of shorter 
# duration. 
#
# Each job runs gchp.multirun.run only once. with duration configured in 
# runConfig.sh. The first job submitted starts at the start date configured 
# in runConfig.sh. Subsequent jobs start where the last job left off, and 
# the date-time string is stored in cap_restart. Since cap_restart is 
# over-written with every job, the start dates are sent to log file 
# cap_restart.log for later inspection. 
#
# Special Notes:
#  1. Configure the total number of runs within runConfig.sh. This is 
#     equivalent to how many jobs will be submitted to SLURM. Make sure that 
#     the end date in runConfig.sh is sufficiently past the start date to 
#     accomodate all configured runs.
#
#  2. runConfig.sh need only be sourced once, at the very start of this script,
#     and cap_restart should never be deleted. This is why there is a special
#     run script for the multi-run segments (gchp_slurm.multirun.run). Using 
#     the default run script instead (gchp_slurm.run) will not work for 
#     multi-segmented run without manual updates. 
#
#  3. The run script submitted on loop in this shell script will send stdout to
#     to gchp.log. Log output is not over-written by subsequent runs. 
#
#  4. Because GCHP output diagnostics files contain the date, those output
#     files will also not be over-written by subsequent runs. 
#
#  5. Restart files will always be produced at the end of a run for use in 
#     the next run, but will not include the date in the filename. They will 
#     therefore be over-written. However, you can configure the 
#     RECORD_FREQUENCY in GCHP.rc to archive restart files at a fixed period 
#     with date timestamp. This feature is on by default and set to 30 days.
# 
#  6. gchp.log and cap_restart.log are both deleted at the top of this script.
#     If you want to keep logs from a prior run you must archive elsewhere.
#
# ~ GEOS-Chem Support Team, 7/9/2018

# Source runConfig.sh to update rc files and get variables used below.
source runConfig.sh > runConfig.log
rm -f gchp.log
rm -f cap_restart.log

printf "Submitting ${Num_Runs} jobs with duration '${Duration}'\n"
printf "Start date: ${Start_Time}\n"
printf "End date:   ${End_Time}\n"
printf "*** Check that end date is sufficiently past start date to accomodate all runs ***\n"

msg=$(sbatch gchp_slurm.multirun.run)
echo $msg
IFS=', ' IFS=', ' read -r -a msgarray <<< "$msg"
jobid=${msgarray[3]}

for i in $(seq 1 $((Num_Runs-1))); 
do
  msg=$(sbatch --dependency=afterok:$jobid gchp_slurm.multirun.run)
  echo $msg
  IFS=', ' IFS=', ' read -r -a msgarray <<< "$msg"
  jobid=${msgarray[3]}
done

exit 0

