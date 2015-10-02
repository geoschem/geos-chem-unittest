#!/bin/bash
# This script compares binary output files by using IDL script
# ctm_locatediff, storing results in log files, and showing on screen
# (off by default). It is best to use summarizeDiff.sh before recording all
# differences to ensure the full differences file will not be too large.
#
# E. Lundgren, August 2015

# restart files
RSTFILE1="./Dev/trac_rst.geosfp_4x5_Hg.201301010100.Dev"
RSTFILE2="./Ref/trac_rst.geosfp_4x5_Hg.201301010100.Ref"

# diagnostic files
DIAGFILE1="./Dev/trac_avg.geosfp_4x5_Hg.201301010000.Dev"
DIAGFILE2="./Ref/trac_avg.geosfp_4x5_Hg.201301010000.Ref"

# destination files for differences
RSTDIFF="logs/rst_diffs_all.log"
DIAGDIFF="logs/diag_diffs_all.log"

# Get rst file diffs 
# warning: may produce a large file!
idl << idlenv
ctm_locatediff, '$RSTFILE1', '$RSTFILE2', OutFileName='$RSTDIFF'
idlenv

# View rst diffs
#cat $RSTDIFF

# Get diagnostic file diffs 
# warning: may produce a large file!
#idl << idlend
#ctm_locatediff, '$DIAGFILE1', '$DIAGFILE2', OutFileName='$DIAGDIFF'
#idlenv

# View diag diffs
#cat $DIAGDIFF
