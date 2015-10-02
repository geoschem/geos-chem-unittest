#!/bin/bash
# This script compares binary output files by using IDL script
# ctm_locatediff, storing a summary of the results in log files
# and showing them on screen.
#
# E. Lundgren, August 2015

# restart files
RSTFILE1="./Dev/trac_rst.geosfp_4x5_Hg.201301010100.Dev"
RSTFILE2="./Ref/trac_rst.geosfp_4x5_Hg.201301010100.Ref"

# diagnostic files
DIAGFILE1="./Dev/trac_avg.geosfp_4x5_Hg.201301010000.Dev"
DIAGFILE2="./Ref/trac_avg.geosfp_4x5_Hg.201301010000.Ref"

# destination files for differences
RSTDIFF="logs/rst_diffs_summary.log"
DIAGDIFF="logs/diag_diffs_summary.log"

# Get rst and diag file diffs
idl << idlenv
ctm_summarizediff, '$RSTFILE1', '$RSTFILE2', OutFileName='$RSTDIFF'
ctm_summarizediff, '$DIAGFILE1', '$DIAGFILE2', OutFileName='$DIAGDIFF'
idlenv

# View results (rst only)
cat $RSTDIFF

