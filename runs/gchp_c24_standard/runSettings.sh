#!/bin/bash

# runSettings.sh: Update select settings in GCHP *.rc files
#
# Usage: ./runSettings.sh
#
# NOTE: This script is under development. Add functionality as needed
# and see ideas for the future at the bottom of the script (ewl, 1/19/16)

#### User-specified run settings
CUBE_SPHERE_RES=24    # 24~4x5, 48~2x2.5, etc.
NUM_NODES=1           
NUM_CORES_PER_NODE=6  # must be multiple of 6
DEBUG_LEVEL=0         # 0 is none, output increases with higher values (to 20)
CHEM_TIMESTEP_S=1200  # seconds, currently all components forced to chem dt

#### Save backups of files
cp GCHP.rc GCHP.rc.bak
cp CAP.rc CAP.rc.bak
cp fvcore_layout.rc fvcore_layout.rc.bak
cp HISTORY.rc HISTORY.rc.bak

#### Define replace function. Accepts 3 args: key, value, file
replace_line() {
    KEY=$1
    VALUE=$2
    FILE=$3
    echo "   ${FILE}: ${KEY} = ${VALUE}"

    # replace value in line starting with 'whitespace + key + whitespace + : +
    # whitespace + value' where whitespace is variable length including none
    sed "s|^\([\t ]*${KEY}[\t ]*:[\t ]*\).*|\1${VALUE}|" ${FILE} > tmp
    mv tmp ${FILE}
}

#### Print settings
echo "New settings in *.rc files:"
echo "   Cubed sphere side length: ${CUBE_SPHERE_RES}"
echo "   Number of nodes: ${NUM_NODES}"
echo "   Number of cores per node: ${NUM_CORES_PER_NODE}"
echo "   Debug level: ${DEBUG_LEVEL}"

####  set compute resources
echo "Updating compute resources"
replace_line NX "${NUM_NODES}" GCHP.rc
replace_line NY "${NUM_CORES_PER_NODE}" GCHP.rc
replace_line CoresPerNode "${NUM_CORES_PER_NODE}" HISTORY.rc

####  set debug level
echo "Updating debug level"
replace_line DEBUG_LEVEL "${DEBUG_LEVEL}" CAP.rc

####  set cube sphere resolution
echo "Updating cube sphere resolution"
CS_RES_TIMES_SIX=$((CUBE_SPHERE_RES*6)) # Is there a better term for this?
replace_line IM "${CUBE_SPHERE_RES}" GCHP.rc
replace_line JM "${CS_RES_TIMES_SIX}" GCHP.rc
replace_line GRIDNAME "PE${CUBE_SPHERE_RES}x${CS_RES_TIMES_SIX}-CF" GCHP.rc
replace_line npx "${CUBE_SPHERE_RES}" fvcore_layout.rc
replace_line npy "${CUBE_SPHERE_RES}" fvcore_layout.rc

####  set timestep (to be edited to get from input.geos, see below)
echo "Updating model timestep"
replace_line HEARTBEAT_DT "${CHEM_TIMESTEP_S}" GCHP.rc
replace_line SOLAR_DT "${CHEM_TIMESTEP_S}" GCHP.rc
replace_line IRRAD_DT "${CHEM_TIMESTEP_S}" GCHP.rc
replace_line RUN_DT "${CHEM_TIMESTEP_S}" GCHP.rc
replace_line GIGCchem_DT "${CHEM_TIMESTEP_S}" GCHP.rc
replace_line DYNAMICS_DT "${CHEM_TIMESTEP_S}" GCHP.rc
replace_line HEARTBEAT_DT "${CHEM_TIMESTEP_S}" CAP.rc
replace_line dt "${CHEM_TIMESTEP_S}" fvcore_layout.rc

####  set start/end/duration (to be added, see below)

# To be added:

# 1. read time info from input.geos
# 2. calculate duration from time info
# 3. insert start time, end time, and duration into CAP.rc
# 4. read timestep info from input.geos
# 5. calculate GCHP timestep from input.geos chem timestep info
# 6. set GCHP timestep in all relevant *.rc files
# 7. Give warning about current timestep handling in GCHP (temporary)
# 8. Give relevant warnings about timesteps in input.geos vs. GCHP (temporary)
# 9. Give warnings about CS resolution and timestep compatibility
# 10. Issue any other warnings/errors regarding input.geos and/or run settings
# 11. Add additional settings to this file as deemed useful


