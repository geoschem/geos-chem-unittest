#!/bin/bash

# runSettings.sh: Update select settings in GCHP *.rc files
#
# Usage: ./runSettings.sh
#
# NOTE: This script is under development. Add functionality as needed
# and see ideas for the future at the bottom of the script (ewl, 1/19/16)

###################################################################
####   User-specified run settings (all you need to change)    ####
###################################################################

CUBE_SPHERE_RES=180    # 24~4x5, 48~2x2.5, etc.
NUM_NODES=6           
NUM_CORES_PER_NODE=12  # must be multiple of 6
DEBUG_LEVEL=1         # 0 is none, output increases with higher values (to 20)
INPUT_MET_RES=2x25    # 4x5, 2x25, etc (warning: not yet implemented)

# NOTE: set start time, end time, and timesteps in input.geos

########################################
###   Extract Info from input.geos   ###
########################################
filename=input.geos
while read -r line
do
    if [[ $line == 'Start YYYYMMDD, hhmmss'* ]]; then
	IFS=' '; arrline=($line); unset IFS
        START_DATE=${arrline[4]}; START_TIME=${arrline[5]}
    elif [[ $line == 'End   YYYYMMDD, hhmmss'* ]]; then
	IFS=' '; arrline=($line); unset IFS
        END_DATE=${arrline[4]}; END_TIME=${arrline[5]}
    elif [[ $line == 'Emiss Timestep [min]'* ]]; then
	IFS=' '; arrline=($line); unset IFS; EMISS_DT=$((10#${arrline[4]})); 
    elif [[ $line == 'Transport Timestep [min]'* ]]; then
	IFS=' '; arrline=($line); unset IFS; TRANSPORT_DT=$((10#${arrline[3]}))
    elif [[ $line == 'Convect Timestep [min]'* ]]; then
	IFS=' '; arrline=($line); unset IFS; CONVECT_DT=$((10#${arrline[4]}))
    elif [[ $line == 'Chemistry Timestep [min]'* ]]; then
	IFS=' '; arrline=($line); unset IFS; CHEM_DT=$((10#${arrline[3]}))
    elif [[ $line == 'Turn on Transport'* ]]; then
	IFS=' '; arrline=($line); unset IFS; TRANSPORT_ON=${arrline[4]}
    elif [[ $line == 'Turn on Cloud Conv'* ]]; then
	IFS=' '; arrline=($line); unset IFS; CONVECTION_ON=${arrline[5]}
    elif [[ $line == 'Turn on PBL Mixing'* ]]; then
	IFS=' '; arrline=($line); unset IFS; MIXING_ON=${arrline[5]}
    elif [[ $line == 'Turn on emissions'* ]]; then
	IFS=' '; arrline=($line); unset IFS; EMISSIONS_ON=${arrline[4]}
    elif [[ $line == 'Turn on Dry Deposition'* ]]; then
	IFS=' '; arrline=($line); unset IFS; DRYDEP_ON=${arrline[5]}
    elif [[ $line == 'Turn on Wet Deposition'* ]]; then
	IFS=' '; arrline=($line); unset IFS; WETDEP_ON=${arrline[5]}
    elif [[ $line == 'Turn on Chemistry'* ]]; then
	IFS=' '; arrline=($line); unset IFS; CHEMISTRY_ON=${arrline[4]}
    else
	continue
    fi
done < "$filename"

#### Summarize input.geos settings
	echo "Input.geos settings: "
	echo "   Simulation start/end:"
	echo "      Start: $START_DATE $START_TIME"
	echo "      End: $END_DATE $END_TIME"
	echo "   Timesteps (min):"
	echo "      Advection : $TRANSPORT_DT"
	echo "      Convection : $CONVECT_DT"
	echo "      Emissions : $EMISS_DT"
	echo "      Chemistry : $CHEM_DT"
	echo "   Components:"
	echo "      Advection: ${TRANSPORT_ON}"
	echo "      Convection: ${CONVECTION_ON}"
	echo "      Mixing: ${MIXING_ON}"
	echo "      Emissions: ${EMISSIONS_ON}"
	echo "      Dry Deposition: ${DRYDEP_ON}"
	echo "      Wet Deposition: ${WETDEP_ON}"
	echo "      Chemistry: ${CHEMISTRY_ON}"

#### Convert to seconds
DYN_DT_S=$(($TRANSPORT_DT*60))
CHEM_DT_S=$(($CHEM_DT*60))

#### Define strings for CAP.rc 
DURATION_DATE=$(printf %08d $(($((10#$END_DATE))-$((10#$START_DATE)))))
DURATION_TIME=$(printf %06d $(($((10#$END_TIME))-$((10#$START_TIME)))))
GC_DURATION="$DURATION_DATE $DURATION_TIME"
GC_START="$START_DATE $START_TIME"
GC_END="$END_DATE $END_TIME"

#### Define transport string for GCHP.rc
if [[ ${TRANSPORT_ON} == "T" ]]; then
    ADVCORE_ADVECTION=1
elif [[ ${TRANSPORT_ON} == "F" ]]; then
    ADVCORE_ADVECTION=0
else
    echo "Incorrect transport setting in input.geos"
    exit 1
fi

#############################################
###   Extract Info from HEMCO_Config.rc   ###
#############################################

# placeholder. This will be used to ensure consistency.

################################################################
###   Give Warnings and/or Stop if Settings Not Compatible   ###
################################################################
# Check that timesteps make sense (emiss=chem, conv=transport)
# Give relevant warnings about timesteps in input.geos vs. GCHP (temporary)
# Give warnings about CS resolution and timestep compatibility
# Issue any other warnings/errors regarding input.geos and/or run settings
# check that the transport settins are consistent


###############################
###   Update .rc Files   ###
###############################

#### Save backups
cp GCHP.rc GCHP.rc.bak
cp CAP.rc CAP.rc.bak
cp fvcore_layout.rc fvcore_layout.rc.bak
cp HISTORY.rc HISTORY.rc.bak

#### Define function to replace values in .rc files
replace_val() {
    KEY=$1
    VALUE=$2
    FILE=$3
    echo "      ${KEY} = ${VALUE} in ${FILE}"

    # replace value in line starting with 'whitespace + key + whitespace + : +
    # whitespace + value' where whitespace is variable length including none
    sed "s|^\([\t ]*${KEY}[\t ]*:[\t ]*\).*|\1${VALUE}|" ${FILE} > tmp
    mv tmp ${FILE}
}

echo "Updating .rc files"

#### Set # nodes and # cores
echo "   Compute Resources:"
replace_val NX            "${NUM_NODES}"          GCHP.rc
replace_val NY            "${NUM_CORES_PER_NODE}" GCHP.rc
replace_val CoresPerNode  "${NUM_CORES_PER_NODE}" HISTORY.rc

####  set cubed-sphere resolution
echo "   Cubed-sphere Resolution:"
CS_RES_TIMES_SIX=$((CUBE_SPHERE_RES*6)) # Is there a better term for this?
replace_val IM            "${CUBE_SPHERE_RES}"  GCHP.rc
replace_val JM            "${CS_RES_TIMES_SIX}" GCHP.rc
replace_val npx           "${CUBE_SPHERE_RES}"  fvcore_layout.rc
replace_val npy           "${CUBE_SPHERE_RES}"  fvcore_layout.rc
replace_val GRIDNAME "PE${CUBE_SPHERE_RES}x${CS_RES_TIMES_SIX}-CF" GCHP.rc

#### Set simulation start and end datetimes based on input.geos
echo "   Simulation start/end (from input.geos):"
replace_val BEG_DATE      "${GC_START}"    CAP.rc
replace_val END_DATE      "${GC_END}"      CAP.rc
replace_val JOB_SGMT      "${GC_DURATION}" CAP.rc
echo "      *** Check that JOB_SGMT (duration) makes sense and update as needed in CAP.rc ***"

#### Set timesteps based on input.geos
echo "   Timesteps (from input.geos):"
replace_val HEARTBEAT_DT  "${DYN_DT_S}"  GCHP.rc
replace_val SOLAR_DT      "${DYN_DT_S}"  GCHP.rc
replace_val IRRAD_DT      "${DYN_DT_S}"  GCHP.rc
replace_val RUN_DT        "${DYN_DT_S}"  GCHP.rc
replace_val GIGCchem_DT   "${CHEM_DT_S}" GCHP.rc
replace_val DYNAMICS_DT   "${DYN_DT_S}"  GCHP.rc
replace_val HEARTBEAT_DT  "${DYN_DT_S}"  CAP.rc
replace_val dt            "${DYN_DT_S}"  fvcore_layout.rc

#### Set debug level
echo "   MAPL Debug Level:"
replace_val DEBUG_LEVEL "${DEBUG_LEVEL}" CAP.rc

#### Set advection on/off based on input.geos
echo "   Advection on/off (from input.geos):"
replace_val AdvCore_Advection "${ADVCORE_ADVECTION}" GCHP.rc

################################################
###   Print Run Settings to runSettings.log  ###
################################################

# placeholder